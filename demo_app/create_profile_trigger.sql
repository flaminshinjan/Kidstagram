-- Script to create trigger for auto-creating profiles
-- Run this after the profiles table is created

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
    WHEN OTHERS THEN
      -- Log error but continue - don't prevent user creation
      RAISE WARNING 'Error creating profile for user %: %', NEW.id, SQLERRM;
  END;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log error but continue - don't prevent user creation
    RAISE WARNING 'Error creating profile for user %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop the trigger if it already exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create the trigger to run after a user is created
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Verify the trigger exists
SELECT 
  trigger_name, 
  event_manipulation, 
  action_statement
FROM information_schema.triggers
WHERE event_object_table = 'users'
AND event_object_schema = 'auth'; 