-- Check if profiles table exists, if not create it
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE,
    full_name TEXT,
    avatar_url TEXT,
    bio TEXT,
    school TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Add indexes to improve performance
CREATE INDEX IF NOT EXISTS profiles_username_idx ON public.profiles(username);
CREATE INDEX IF NOT EXISTS profiles_id_idx ON public.profiles(id);

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policies for profiles
-- Allow users to view any profile
DROP POLICY IF EXISTS "Anyone can view profiles" ON public.profiles;
CREATE POLICY "Anyone can view profiles" 
ON public.profiles 
FOR SELECT USING (true);

-- Allow users to update only their own profile
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile" 
ON public.profiles 
FOR UPDATE USING (auth.uid() = id);

-- Allow users to insert their own profile
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
CREATE POLICY "Users can insert their own profile" 
ON public.profiles 
FOR INSERT WITH CHECK (auth.uid() = id);

-- Grant permissions to authenticated users
GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;

-- Create function to automatically create a profile when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
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
  END;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log error but continue - don't prevent user creation
    RAISE WARNING 'Error creating profile for user %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile after sign up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to manually create profiles for existing users who don't have one
CREATE OR REPLACE FUNCTION public.create_missing_profiles()
RETURNS void AS $$
DECLARE
  missing_user RECORD;
  username_base TEXT;
  username_final TEXT;
  random_suffix TEXT;
BEGIN
  FOR missing_user IN
    SELECT au.id, au.email
    FROM auth.users au
    LEFT JOIN public.profiles p ON p.id = au.id
    WHERE p.id IS NULL
  LOOP
    -- Extract base username from email
    username_base := split_part(missing_user.email, '@', 1);
    
    -- Add a random suffix to make it unique
    random_suffix := substr(md5(random()::text), 1, 6);
    username_final := username_base || '_' || random_suffix;
    
    BEGIN
      INSERT INTO public.profiles (id, username, full_name)
      VALUES (
        missing_user.id, 
        username_final,
        username_base
      );
    EXCEPTION 
      WHEN unique_violation THEN
        -- If there's a username conflict, try again with a different random suffix
        random_suffix := substr(md5(random()::text || now()::text), 1, 8);
        
        INSERT INTO public.profiles (id, username, full_name)
        VALUES (
          missing_user.id, 
          'user_' || random_suffix,
          username_base
        );
      WHEN OTHERS THEN
        RAISE WARNING 'Could not create profile for user %: %', missing_user.id, SQLERRM;
    END;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 