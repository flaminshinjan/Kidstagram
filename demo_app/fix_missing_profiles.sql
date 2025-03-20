-- Fix missing profiles script
-- Run this script in your Supabase SQL Editor to fix users without profiles

-- First, check for users without profiles
SELECT au.id, au.email, au.created_at 
FROM auth.users au
LEFT JOIN public.profiles p ON p.id = au.id
WHERE p.id IS NULL
ORDER BY au.created_at DESC;

-- Create the function to handle missing profiles
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

-- Now run the function to create missing profiles
SELECT public.create_missing_profiles();

-- Verify all users now have profiles
SELECT 
  COUNT(*) as total_users,
  (SELECT COUNT(*) FROM public.profiles) as total_profiles,
  COUNT(*) - (SELECT COUNT(*) FROM public.profiles) as missing_profiles
FROM auth.users;

-- Reset the sequence for any custom sequences
-- (If you have any custom sequences in your table)
-- ALTER SEQUENCE profiles_id_seq RESTART WITH 1000;

-- Add a comment to help with diagnosing other potential issues
COMMENT ON TABLE public.profiles IS 'User profiles with auto-creation via trigger'; 