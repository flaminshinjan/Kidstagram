-- Supabase Auth Troubleshooting Script
-- Run this in your Supabase SQL Editor to fix auth system issues

-- 1. Check auth schema references and permissions
SELECT 
  prt.relname AS table_name,
  prt.relnamespace::regnamespace::text AS schema_name,
  pgi.conname AS constraint_name,  
  pch.relname AS referenced_table,
  pch.relnamespace::regnamespace::text AS referenced_schema
FROM pg_constraint pgi
JOIN pg_class prt ON pgi.conrelid = prt.oid
JOIN pg_class pch ON pgi.confrelid = pch.oid
WHERE prt.relname = 'profiles' 
  AND prt.relnamespace::regnamespace::text = 'public';

-- 2. Check if we have permission to create users
SELECT has_table_privilege('authenticated', 'auth.users', 'INSERT');
SELECT has_table_privilege('anon', 'auth.users', 'INSERT');
SELECT has_table_privilege('service_role', 'auth.users', 'INSERT');

-- 3. Check existing auth hooks that might be interfering
SELECT p.proname AS function_name,
       n.nspname AS schema_name,
       pg_get_functiondef(p.oid) AS function_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname LIKE '%auth%'
  AND n.nspname NOT IN ('pg_catalog', 'information_schema');

-- 4. Verify and fix auth table configurations 
-- This is a safe way to ensure the auth schema is not misconfigured
SELECT jsonb_pretty(current_setting('auth.config', true)::jsonb);

-- 5. Check and fix any corrupted auth settings
-- Sometimes the auth schema config can become corrupted, this tries to reset it
DO $$
BEGIN
  -- Try to restart the auth hooks
  PERFORM auth.restart();
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Could not restart auth: %', SQLERRM;
END $$;

-- 6. Fix broken foreign key relationships with auth schema if they exist
DO $$
DECLARE
  fk_exists boolean;
BEGIN
  -- Check if the profiles table exists
  PERFORM FROM information_schema.tables 
  WHERE table_schema = 'public' AND table_name = 'profiles';
  
  IF NOT FOUND THEN
    RAISE NOTICE 'Creating profiles table as it does not exist';
    
    -- Create the profiles table
    CREATE TABLE public.profiles (
      id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
      username TEXT UNIQUE,
      full_name TEXT,
      avatar_url TEXT,
      bio TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
    );
    
    -- Set up RLS
    ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
    
    -- Create policies for the profiles table
    CREATE POLICY "Public profiles are viewable by everyone"
      ON public.profiles FOR SELECT
      USING (true);
      
    CREATE POLICY "Users can update their own profiles"
      ON public.profiles FOR UPDATE
      USING (auth.uid() = id);
      
    CREATE POLICY "Users can insert their own profiles"
      ON public.profiles FOR INSERT
      WITH CHECK (auth.uid() = id);
      
    RAISE NOTICE 'Profiles table created successfully';
  ELSE
    RAISE NOTICE 'Profiles table already exists';
  END IF;
END $$;

-- 7. Create function for app to create profiles table if it's missing
CREATE OR REPLACE FUNCTION public.create_profiles_table_if_missing()
RETURNS boolean AS $$
DECLARE
  table_exists boolean;
BEGIN
  -- Check if the profiles table exists
  SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'profiles'
  ) INTO table_exists;
  
  IF table_exists THEN
    RAISE NOTICE 'Profiles table already exists';
    RETURN true;
  END IF;

  -- Create the profiles table
  CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE,
    full_name TEXT,
    avatar_url TEXT,
    bio TEXT,
    school TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
  );
  
  -- Set up RLS
  ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
  
  -- Create policies for the profiles table
  CREATE POLICY "Public profiles are viewable by everyone"
    ON public.profiles FOR SELECT
    USING (true);
    
  CREATE POLICY "Users can update their own profiles"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);
    
  CREATE POLICY "Users can insert their own profiles"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);
    
  RAISE NOTICE 'Profiles table created successfully';
  RETURN true;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Failed to create profiles table: %', SQLERRM;
    RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Create function for manually creating a profile (as a backup)
CREATE OR REPLACE FUNCTION public.manually_create_profile(
  user_id UUID,
  user_name TEXT,
  user_full_name TEXT
)
RETURNS boolean AS $$
BEGIN
  -- First make sure the table exists
  PERFORM public.create_profiles_table_if_missing();
  
  -- Insert the profile
  INSERT INTO public.profiles (id, username, full_name, bio, created_at)
  VALUES (
    user_id,
    user_name,
    user_full_name,
    'Hello, I am new here!', 
    NOW()
  )
  ON CONFLICT (id) DO UPDATE
  SET username = EXCLUDED.username,
      full_name = EXCLUDED.full_name;
  
  RETURN true;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Failed to manually create profile: %', SQLERRM;
    RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. Verify that the auth.users table is properly accessible and configured
SELECT 
  tablename, 
  schemaname,
  tableowner,
  hasindexes,
  rowsecurity
FROM pg_tables
WHERE schemaname = 'auth'
ORDER BY tablename; 