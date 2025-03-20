# Signup Fix Guide - Bypass Profiles Table Requirement

This guide will help you fix the user signup issue in your application without needing to create or maintain a profiles table.

## The Problem

You're encountering this error during signup:
```
ERROR: relation "profiles" does not exist (SQLSTATE 42P01)
```

This happens because by default, Supabase's auth triggers try to create a profile for each new user, but the profiles table doesn't exist in your database.

## Solution 1: Quick Database Fix (Recommended)

1. **Log in to your Supabase dashboard** at https://app.supabase.com
2. **Navigate to the SQL Editor**
3. **Create a new query**
4. **Copy and paste the following SQL script**:

```sql
-- Script to bypass profiles table requirement during signup

-- First, check if there's an existing trigger creating profiles
DO $$
BEGIN
  -- Check if the trigger exists
  IF EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'on_auth_user_created') THEN
    -- Drop the existing trigger
    DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
    RAISE NOTICE 'Removed existing profile creation trigger';
  END IF;
END $$;

-- Check if there's a handle_new_user function and replace it
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create a new function that doesn't try to insert into profiles
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- This function does nothing but return NEW
  -- It won't try to create a profile entry
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a new trigger that uses our function
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

5. **Click "Run" to execute the script**
6. **Try signing up again** - it should work now without trying to create a profile

## Solution 2: Modify Your Code

If you prefer to modify your frontend code instead, update the `_signUp` function in your `login.dart` file with this simplified version:

```dart
Future<void> _signUp() async {
  final isValid = _formKey.currentState?.validate();
  if (isValid != true) {
    return;
  }
  
  setState(() {
    _signUpLoading = true;
  });
  
  try {
    // Simple signup without additional metadata
    final response = await supabase.auth.signUp(
      email: _emailController.text,
      password: _passwordController.text
    );
    
    if (response.user != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Account created successfully!"),
        backgroundColor: Color.fromARGB(255, 252, 116, 5),
      ));
    }
  } catch (e) {
    String errorMessage = "Sign Up Failed";
    
    if (e is AuthException) {
      if (e.message.contains('unique constraint')) {
        errorMessage = "Email already registered. Please use a different email or try logging in.";
      } else {
        errorMessage = e.message;
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(errorMessage),
      backgroundColor: Color.fromARGB(255, 255, 15, 7),
    ));
    
    print('Error during signup: $e');
  } finally {
    setState(() {
      _signUpLoading = false;
    });
  }
}
```

## How This Works

The SQL script removes the database trigger that tries to create a profile for each new user. Instead, it replaces it with a simple trigger that does nothing but allow the user to be created.

The simplified code version removes any additional data or steps that might be triggering the profiles table interaction.

## If You Need Profiles Later

If you decide you want to use profiles later, you can:

1. Create the profiles table properly using the `supabase_fix.sql` script
2. Populate it with profiles for existing users
3. Reinstate the original trigger

But for now, this approach will let you create users without dealing with the profiles table.

## Need More Help?

If you're still having issues, you can:

1. Run the full `supabase_fix.sql` script to create a proper profiles table
2. Check your Supabase logs for more specific errors 