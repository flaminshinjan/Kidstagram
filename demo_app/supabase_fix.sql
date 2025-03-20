-- Drop all constraints and recreate tables if needed
-- IMPORTANT: This will reset your database. Only run if you're sure!

-- Add debug output
DO $$
BEGIN
  RAISE NOTICE 'Starting database fix script...';
END $$;

-- Check if auth schema is accessible
DO $$
BEGIN
  RAISE NOTICE 'Checking auth schema access...';
  PERFORM schema_name FROM information_schema.schemata WHERE schema_name = 'auth';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Auth schema does not exist or is not accessible!';
  END IF;
END $$;

-- Check if users table exists in auth schema
DO $$
BEGIN
  RAISE NOTICE 'Checking auth.users table access...';
  PERFORM table_name FROM information_schema.tables WHERE table_schema = 'auth' AND table_name = 'users';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'auth.users table does not exist or is not accessible!';
  END IF;
END $$;

-- 1. Drop existing tables in proper order
DROP TABLE IF EXISTS likes CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- 2. Now recreate tables with proper references
DO $$
BEGIN
  RAISE NOTICE 'Creating profiles table...';
END $$;

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

DO $$
BEGIN
  RAISE NOTICE 'Creating posts table...';
END $$;

CREATE TABLE IF NOT EXISTS posts (
  id UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  caption TEXT NOT NULL,
  image_url TEXT,
  user_name TEXT,
  user_avatar TEXT,
  like_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

DO $$
BEGIN
  RAISE NOTICE 'Creating likes table...';
END $$;

CREATE TABLE IF NOT EXISTS likes (
  id UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  UNIQUE(user_id, post_id)
);

DO $$
BEGIN
  RAISE NOTICE 'Creating comments table...';
END $$;

CREATE TABLE IF NOT EXISTS comments (
  id UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 3. Create the necessary functions
CREATE OR REPLACE FUNCTION increment_likes(post_id_param UUID)
RETURNS void AS $$
BEGIN
  UPDATE posts
  SET like_count = like_count + 1
  WHERE id = post_id_param;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION decrement_likes(post_id_param UUID)
RETURNS void AS $$
BEGIN
  UPDATE posts
  SET like_count = GREATEST(0, like_count - 1)
  WHERE id = post_id_param;
END;
$$ LANGUAGE plpgsql;

-- 4. Create profile for existing users
DO $$
BEGIN
  RAISE NOTICE 'Creating profiles for existing users...';
END $$;

INSERT INTO profiles (id, username, full_name)
SELECT 
  id, 
  email, 
  SPLIT_PART(email, '@', 1)
FROM 
  auth.users
ON CONFLICT (id) DO NOTHING;

-- 5. Set up row level security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- Create policies for profiles
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON profiles;
CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Users can update their own profiles" ON profiles;
CREATE POLICY "Users can update their own profiles"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert their own profiles" ON profiles;
CREATE POLICY "Users can insert their own profiles"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Create policies for posts
DROP POLICY IF EXISTS "Posts are viewable by everyone" ON posts;
CREATE POLICY "Posts are viewable by everyone"
  ON posts FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Users can create their own posts" ON posts;
CREATE POLICY "Users can create their own posts"
  ON posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own posts" ON posts;
CREATE POLICY "Users can update their own posts"
  ON posts FOR UPDATE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own posts" ON posts;
CREATE POLICY "Users can delete their own posts"
  ON posts FOR DELETE
  USING (auth.uid() = user_id);

-- 6. Check and create buckets
INSERT INTO storage.buckets (id, name, public) VALUES ('post_images', 'post_images', true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('profile_images', 'profile_images', true)
ON CONFLICT (id) DO NOTHING;

-- Create a trigger to handle new user creation
DO $$
BEGIN
  RAISE NOTICE 'Creating user creation trigger...';
END $$;

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  username_base TEXT;
  username_final TEXT;
  random_suffix TEXT;
BEGIN
  -- Extract base username from email
  username_base := split_part(NEW.email, '@', 1);
  
  -- Add a random suffix to make it unique
  random_suffix := substr(md5(random()::text), 1, 6);
  username_final := username_base || '_' || random_suffix;
  
  BEGIN
    INSERT INTO public.profiles (id, username, full_name)
    VALUES (
      NEW.id, 
      username_final,
      COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
    );
    RAISE NOTICE 'Created profile for user %', NEW.id;
  EXCEPTION 
    WHEN unique_violation THEN
      -- If there's a username conflict, try again with a different random suffix
      random_suffix := substr(md5(random()::text || clock_timestamp()::text), 1, 8);
      
      INSERT INTO public.profiles (id, username, full_name)
      VALUES (
        NEW.id, 
        'user_' || random_suffix,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
      );
      RAISE NOTICE 'Created profile with fallback username for user %', NEW.id;
    WHEN OTHERS THEN
      -- Log error but continue - don't prevent user creation
      RAISE WARNING 'Error creating profile for user %: %', NEW.id, SQLERRM;
  END;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log error but continue - don't prevent user creation
    RAISE WARNING 'Error in handle_new_user trigger: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop the trigger if it already exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create the trigger to run after a user is created
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Verify the tables were created properly
DO $$
BEGIN
  RAISE NOTICE 'Verifying table creation...';
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'profiles') THEN
    RAISE NOTICE 'profiles table exists';
  ELSE
    RAISE WARNING 'profiles table does NOT exist!';
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'posts') THEN
    RAISE NOTICE 'posts table exists';
  ELSE
    RAISE WARNING 'posts table does NOT exist!';
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'likes') THEN
    RAISE NOTICE 'likes table exists';
  ELSE
    RAISE WARNING 'likes table does NOT exist!';
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'comments') THEN
    RAISE NOTICE 'comments table exists';
  ELSE
    RAISE WARNING 'comments table does NOT exist!';
  END IF;
  
  RAISE NOTICE 'Database fix script completed successfully.';
END $$; 