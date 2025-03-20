-- Direct fix for Supabase auth issues
-- This is meant to be run on a development database to quickly bypass auth problems
-- WARNING: This is NOT for production use, only development

-- 1. Create a test user directly in the auth schema
INSERT INTO auth.users (
  id,
  instance_id,
  email,
  email_confirmed_at,
  encrypted_password,
  aud,
  role,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token  
)
VALUES (
  gen_random_uuid(), -- id
  '00000000-0000-0000-0000-000000000000', -- instance_id
  'test@development.com', -- email
  now(), -- email_confirmed_at
  crypt('password123', gen_salt('bf')), -- encrypted_password using BCRYPT
  'authenticated', -- aud
  'authenticated', -- role
  '{"provider": "email", "providers": ["email"]}', -- raw_app_meta_data
  '{"username": "test_developer"}', -- raw_user_meta_data
  now(), -- created_at
  now(), -- updated_at
  '', -- confirmation_token
  '', -- email_change
  '', -- email_change_token_new
  '' -- recovery_token
)
ON CONFLICT (email) DO NOTHING;

-- 2. Get the user ID of the test user
DO $$
DECLARE
  test_user_id UUID;
BEGIN
  SELECT id INTO test_user_id FROM auth.users WHERE email = 'test@development.com' LIMIT 1;
  
  -- 3. Ensure the test user has a profile
  INSERT INTO public.profiles (
    id, 
    username, 
    full_name, 
    bio, 
    school,
    created_at
  )
  VALUES (
    test_user_id,
    'test_developer',
    'Test Developer',
    'This is a development account',
    'Dev School',
    now()
  )
  ON CONFLICT (id) DO NOTHING;

  -- 4. Output the credentials for development
  RAISE NOTICE 'Development account created:';
  RAISE NOTICE 'Email: test@development.com';
  RAISE NOTICE 'Password: password123';
  RAISE NOTICE 'User ID: %', test_user_id;
END $$;

-- 5. Verify profiles table exists and has entries
SELECT COUNT(*) as profile_count FROM public.profiles;

-- 6. Create any test data needed for development
-- Posts table example (uncomment if you have this table)
-- INSERT INTO public.posts (id, user_id, content, created_at)
-- SELECT 
--   gen_random_uuid(),
--   p.id, 
--   'This is a test post for development',
--   now()
-- FROM public.profiles p
-- WHERE p.username = 'test_developer'
-- LIMIT 1;

-- 7. Verify the triggers and RLS are set up correctly
SELECT 
  t.tgname AS trigger_name,
  ns.nspname AS schema_name,
  r.relname AS table_name,
  pg_get_triggerdef(t.oid) AS trigger_definition
FROM pg_trigger t
JOIN pg_class r ON t.tgrelid = r.oid
JOIN pg_namespace ns ON r.relnamespace = ns.oid
WHERE t.tgname LIKE '%auth%' OR t.tgname LIKE '%user%' OR t.tgname LIKE '%profile%'
ORDER BY r.relname, t.tgname; 