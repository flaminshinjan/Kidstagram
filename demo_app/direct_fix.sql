-- Direct fix for missing profiles
-- This script directly inserts profiles for users that don't have them
-- Without relying on functions that might not exist

-- First, identify users without profiles
SELECT au.id, au.email, au.created_at 
FROM auth.users au
LEFT JOIN public.profiles p ON p.id = au.id
WHERE p.id IS NULL
ORDER BY au.created_at DESC;

-- Directly create profiles for users without them
INSERT INTO public.profiles (id, username, full_name, bio, created_at)
SELECT 
  au.id, 
  'user_' || substr(md5(au.email || random()::text), 1, 8),
  split_part(au.email, '@', 1),
  'Hello, I am new here!',
  NOW()
FROM auth.users au
LEFT JOIN public.profiles p ON p.id = au.id
WHERE p.id IS NULL;

-- Show users that still don't have profiles (should be none)
SELECT au.id, au.email, au.created_at 
FROM auth.users au
LEFT JOIN public.profiles p ON p.id = au.id
WHERE p.id IS NULL
ORDER BY au.created_at DESC;

-- Verify counts
SELECT 
  (SELECT COUNT(*) FROM auth.users) as total_users,
  (SELECT COUNT(*) FROM public.profiles) as total_profiles,
  (SELECT COUNT(*) FROM auth.users) - (SELECT COUNT(*) FROM public.profiles) as missing_profiles;

-- Make sure the profiles table has appropriate policies
DO $$
BEGIN
  -- Enable RLS if not already enabled
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE schemaname = 'public' 
    AND tablename = 'profiles' 
    AND rowsecurity = true
  ) THEN
    ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
  END IF;
END
$$;

-- Create basic policies if they don't exist
DO $$
BEGIN
  -- Policy for select
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'profiles'
    AND policyname = 'Anyone can view profiles'
  ) THEN
    CREATE POLICY "Anyone can view profiles" 
    ON public.profiles 
    FOR SELECT USING (true);
  END IF;
  
  -- Policy for update
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'profiles'
    AND policyname = 'Users can update their own profile'
  ) THEN
    CREATE POLICY "Users can update their own profile" 
    ON public.profiles 
    FOR UPDATE USING (auth.uid() = id);
  END IF;
  
  -- Policy for insert
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'profiles'
    AND policyname = 'Users can insert their own profile'
  ) THEN
    CREATE POLICY "Users can insert their own profile" 
    ON public.profiles 
    FOR INSERT WITH CHECK (auth.uid() = id);
  END IF;
END
$$;

-- Grant permissions
GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated; 