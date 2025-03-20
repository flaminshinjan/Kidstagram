-- Fix storage policies
-- First, drop existing policies that might be restricting access
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Post images are viewable by everyone' AND tablename = 'objects') THEN
    DROP POLICY "Post images are viewable by everyone" ON storage.objects;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can upload their own post images' AND tablename = 'objects') THEN
    DROP POLICY "Users can upload their own post images" ON storage.objects;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can upload post images' AND tablename = 'objects') THEN
    DROP POLICY "Users can upload post images" ON storage.objects;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can update their own post images' AND tablename = 'objects') THEN
    DROP POLICY "Users can update their own post images" ON storage.objects;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can update post images' AND tablename = 'objects') THEN
    DROP POLICY "Users can update post images" ON storage.objects;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can delete their own post images' AND tablename = 'objects') THEN
    DROP POLICY "Users can delete their own post images" ON storage.objects;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can delete post images' AND tablename = 'objects') THEN
    DROP POLICY "Users can delete post images" ON storage.objects;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Profile images are viewable by everyone' AND tablename = 'objects') THEN
    DROP POLICY "Profile images are viewable by everyone" ON storage.objects;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can upload their own profile images' AND tablename = 'objects') THEN
    DROP POLICY "Users can upload their own profile images" ON storage.objects;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can upload profile images' AND tablename = 'objects') THEN
    DROP POLICY "Users can upload profile images" ON storage.objects;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can update their own profile images' AND tablename = 'objects') THEN
    DROP POLICY "Users can update their own profile images" ON storage.objects;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can update profile images' AND tablename = 'objects') THEN
    DROP POLICY "Users can update profile images" ON storage.objects;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can delete their own profile images' AND tablename = 'objects') THEN
    DROP POLICY "Users can delete their own profile images" ON storage.objects;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can delete profile images' AND tablename = 'objects') THEN
    DROP POLICY "Users can delete profile images" ON storage.objects;
  END IF;
END
$$;

-- Create storage policies only if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Post images are viewable by everyone' AND tablename = 'objects') THEN
    CREATE POLICY "Post images are viewable by everyone"
      ON storage.objects FOR SELECT
      USING (bucket_id = 'post_images');
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can upload post images' AND tablename = 'objects') THEN
    CREATE POLICY "Users can upload post images"
      ON storage.objects FOR INSERT
      WITH CHECK (bucket_id = 'post_images');
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can update post images' AND tablename = 'objects') THEN
    CREATE POLICY "Users can update post images"
      ON storage.objects FOR UPDATE
      USING (bucket_id = 'post_images');
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can delete post images' AND tablename = 'objects') THEN
    CREATE POLICY "Users can delete post images"
      ON storage.objects FOR DELETE
      USING (bucket_id = 'post_images');
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Profile images are viewable by everyone' AND tablename = 'objects') THEN
    CREATE POLICY "Profile images are viewable by everyone"
      ON storage.objects FOR SELECT
      USING (bucket_id = 'profile_images');
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can upload profile images' AND tablename = 'objects') THEN
    CREATE POLICY "Users can upload profile images"
      ON storage.objects FOR INSERT
      WITH CHECK (bucket_id = 'profile_images');
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can update profile images' AND tablename = 'objects') THEN
    CREATE POLICY "Users can update profile images"
      ON storage.objects FOR UPDATE
      USING (bucket_id = 'profile_images');
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can delete profile images' AND tablename = 'objects') THEN
    CREATE POLICY "Users can delete profile images"
      ON storage.objects FOR DELETE
      USING (bucket_id = 'profile_images');
  END IF;
END
$$;

-- Fix likes table policies
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Likes are viewable by everyone' AND tablename = 'likes') THEN
    DROP POLICY "Likes are viewable by everyone" ON likes;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can create their own likes' AND tablename = 'likes') THEN
    DROP POLICY "Users can create their own likes" ON likes;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Authenticated users can create likes' AND tablename = 'likes') THEN
    DROP POLICY "Authenticated users can create likes" ON likes;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can delete their own likes' AND tablename = 'likes') THEN
    DROP POLICY "Users can delete their own likes" ON likes;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Anyone can view likes' AND tablename = 'likes') THEN
    CREATE POLICY "Anyone can view likes"
      ON likes FOR SELECT
      USING (true);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Authenticated users can create likes' AND tablename = 'likes') THEN
    CREATE POLICY "Authenticated users can create likes"
      ON likes FOR INSERT
      WITH CHECK (auth.role() = 'authenticated');
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can delete their own likes' AND tablename = 'likes') THEN
    CREATE POLICY "Users can delete their own likes"
      ON likes FOR DELETE
      USING (auth.uid() = user_id);
  END IF;
END
$$;

-- Add school column to profiles table if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'school'
  ) THEN
    ALTER TABLE profiles ADD COLUMN school TEXT;
  END IF;
END
$$;

-- Ensure trigger for profile creation exists
CREATE OR REPLACE FUNCTION create_profile_for_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, username, full_name, bio, school)
  VALUES (NEW.id, NEW.email, SPLIT_PART(NEW.email, '@', 1), 'Hello, I am new here!', NULL)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Check if trigger exists and create if it doesn't
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'create_profile_trigger'
  ) THEN
    CREATE TRIGGER create_profile_trigger
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION create_profile_for_user();
  END IF;
END
$$; 