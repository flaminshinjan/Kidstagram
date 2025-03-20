-- Clean fix for Supabase signup issues
-- Simply removes the profile creation dependency

-- Drop the existing trigger that tries to create profiles
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Drop the existing function 
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create a minimal replacement function that doesn't interact with profiles
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a basic trigger that uses our function
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user(); 