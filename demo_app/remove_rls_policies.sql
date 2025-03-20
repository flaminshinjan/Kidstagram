-- Script to remove RLS policies that might be causing auth errors
-- WARNING: This disables security features for development purposes only
-- DO NOT use this in production!

-- 1. Show existing policies before removing them
SELECT 
    schemaname, 
    tablename, 
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE schemaname = 'public';

-- 2. Disable RLS on the profiles table
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- 3. Remove all policies from the profiles table 
DROP POLICY IF EXISTS "Anyone can view profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
DROP POLICY IF EXISTS "profiles_policy" ON public.profiles;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.profiles;
DROP POLICY IF EXISTS "Enable update for users based on id" ON public.profiles;
DROP POLICY IF EXISTS "Enable delete for users based on id" ON public.profiles;

-- 4. Grant all permissions to authenticated users
GRANT ALL ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO anon;
GRANT ALL ON public.profiles TO service_role;

-- 5. Verify RLS is disabled
SELECT 
    n.nspname as schema_name,
    c.relname as table_name,
    c.relrowsecurity as rls_enabled,
    c.relforcerowsecurity as rls_forced
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public' AND c.relname = 'profiles';

-- 6. Create a view that can help bypass RLS for debugging
CREATE OR REPLACE VIEW public.all_profiles AS
SELECT * FROM public.profiles;

-- 7. Grant access to the view
GRANT ALL ON public.all_profiles TO authenticated;
GRANT ALL ON public.all_profiles TO anon;
GRANT ALL ON public.all_profiles TO service_role;

-- 8. Remove any triggers that might be causing issues
-- DO $$
-- BEGIN
--   DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
--   EXCEPTION WHEN OTHERS THEN
--     RAISE NOTICE 'Could not drop trigger: %', SQLERRM;
-- END
-- $$; 