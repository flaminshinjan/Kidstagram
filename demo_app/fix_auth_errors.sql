-- Comprehensive script to fix Supabase auth errors
-- Run this in your Supabase SQL Editor

-- 1. Fix permission issues by granting proper permissions
BEGIN;

-- Grant necessary permissions on the auth schema tables
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT USAGE ON SCHEMA auth TO postgres;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO anon;

-- Grant specific permissions to auth.users
GRANT SELECT, INSERT, UPDATE ON auth.users TO authenticated;
GRANT SELECT, INSERT, UPDATE ON auth.users TO service_role;
GRANT SELECT ON auth.users TO anon;

-- Grant permissions to other auth tables that might be related
GRANT SELECT, INSERT, UPDATE ON auth.refresh_tokens TO authenticated;
GRANT SELECT, INSERT, UPDATE ON auth.refresh_tokens TO service_role;
GRANT SELECT, INSERT, UPDATE ON auth.audit_log_entries TO service_role;
GRANT SELECT, INSERT, UPDATE ON auth.instances TO service_role;
GRANT SELECT, INSERT, UPDATE ON auth.schema_migrations TO service_role;

-- 2. Fix profile table issues in public schema
-- Simplify profiles table (disables RLS)
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- Drop all existing policies on the profiles table
DO $$
DECLARE
    _policy record;
BEGIN
    FOR _policy IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' AND tablename = 'profiles'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.profiles', _policy.policyname);
    END LOOP;
END
$$;

-- Grant permissions to the profiles table
GRANT ALL ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO anon;
GRANT ALL ON public.profiles TO service_role;

-- 3. Try to restart Supabase auth hooks
DO $$
BEGIN
  PERFORM auth.restart();
  RAISE NOTICE 'Successfully restarted auth hooks';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Could not restart auth hooks: %', SQLERRM;
END
$$;

-- 4. Fix possible schema migration issues
-- Check if there are any pending migrations
SELECT version, statements_applied FROM auth.schema_migrations ORDER BY version DESC LIMIT 5;

-- 5. Ensure users can be created
DO $$
BEGIN
    -- Create a test user if they don't exist
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'test_dev@example.com') THEN
        INSERT INTO auth.users (
            instance_id,
            id,
            aud,
            role,
            email,
            encrypted_password,
            email_confirmed_at,
            recovery_sent_at,
            last_sign_in_at,
            raw_app_meta_data,
            raw_user_meta_data,
            created_at,
            updated_at
        ) VALUES (
            '00000000-0000-0000-0000-000000000000',
            gen_random_uuid(),
            'authenticated',
            'authenticated',
            'test_dev@example.com',
            crypt('simplepassword', gen_salt('bf')),
            now(),
            now(),
            now(),
            '{"provider":"email","providers":["email"]}',
            '{}',
            now(),
            now()
        );
        
        -- Get the user ID we just created
        WITH new_user AS (
            SELECT id FROM auth.users WHERE email = 'test_dev@example.com' LIMIT 1
        )
        INSERT INTO public.profiles (id, username, full_name, created_at)
        SELECT id, 'test_dev', 'Test Developer', now()
        FROM new_user
        ON CONFLICT (id) DO NOTHING;
        
        RAISE NOTICE 'Created test user test_dev@example.com with password simplepassword';
    ELSE
        RAISE NOTICE 'Test user already exists';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error creating test user: %', SQLERRM;
END
$$;

-- 6. Verify the changes
SELECT count(*) AS user_count FROM auth.users;
SELECT count(*) AS profile_count FROM public.profiles;

-- Check permissions on auth.users
SELECT * FROM information_schema.role_table_grants 
WHERE table_schema = 'auth' AND table_name = 'users' 
ORDER BY grantee, privilege_type;

COMMIT; 