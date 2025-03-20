-- Direct profile insertion script
-- This script allows you to create profiles directly, bypassing any auth issues
-- Use this for development only, not for production!

-- 1. Create a UUID extension if it doesn't exist
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Function to create profiles directly
CREATE OR REPLACE FUNCTION public.direct_create_profile(
    p_email TEXT,
    p_username TEXT DEFAULT NULL,
    p_full_name TEXT DEFAULT NULL,
    p_bio TEXT DEFAULT NULL,
    p_school TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    new_id UUID;
    actual_username TEXT;
BEGIN
    -- Generate a UUID for the user
    new_id := uuid_generate_v4();
    
    -- Create a username if not provided
    actual_username := COALESCE(p_username, 
                           LOWER(REGEXP_REPLACE(p_email, '@.*$', '')) || '_' || 
                           SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 6));
    
    -- Insert the profile directly
    INSERT INTO public.profiles (
        id,
        username,
        full_name,
        bio,
        school,
        created_at
    ) VALUES (
        new_id,
        actual_username,
        COALESCE(p_full_name, SPLIT_PART(p_email, '@', 1)),
        COALESCE(p_bio, 'Hello, I am new here!'),
        p_school,
        NOW()
    );
    
    RETURN new_id;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error creating profile: %', SQLERRM;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Example usage:
-- Create some test profiles
SELECT 'Creating test profile 1' as operation, public.direct_create_profile('user1@example.com', 'user1', 'User One', 'Test bio 1', 'School A') as profile_id;
SELECT 'Creating test profile 2' as operation, public.direct_create_profile('user2@example.com', 'user2', 'User Two', 'Test bio 2', 'School B') as profile_id;
SELECT 'Creating test profile 3' as operation, public.direct_create_profile('user3@example.com') as profile_id;

-- 4. List all profiles
SELECT * FROM public.profiles ORDER BY created_at DESC LIMIT 10;

-- 5. Function to get profile by username
CREATE OR REPLACE FUNCTION public.get_profile_by_username(p_username TEXT)
RETURNS TABLE (
    id UUID,
    username TEXT,
    full_name TEXT,
    avatar_url TEXT,
    bio TEXT,
    school TEXT,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id, p.username, p.full_name, p.avatar_url, p.bio, p.school, p.created_at
    FROM public.profiles p
    WHERE p.username = p_username;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Example usage:
-- SELECT * FROM public.get_profile_by_username('user1'); 