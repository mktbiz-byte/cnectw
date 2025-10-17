-- =====================================================
-- GRANT ADMIN ROLE TO USER
-- =====================================================

-- Step 1: Check current user info
SELECT 
  id,
  email,
  raw_user_meta_data->>'role' as current_role,
  raw_user_meta_data
FROM auth.users
WHERE email = 'mkt_biz@cnec.co.kr';

-- Step 2: Grant admin role
UPDATE auth.users
SET raw_user_meta_data = 
  jsonb_set(
    COALESCE(raw_user_meta_data, '{}'::jsonb),
    '{role}',
    '"admin"'
  )
WHERE email = 'mkt_biz@cnec.co.kr';

-- Step 3: Verify the change
SELECT 
  id,
  email,
  raw_user_meta_data->>'role' as new_role,
  raw_user_meta_data
FROM auth.users
WHERE email = 'mkt_biz@cnec.co.kr';

-- Step 4: Update user_profiles table as well (if exists)
UPDATE user_profiles
SET role = 'admin'
WHERE email = 'mkt_biz@cnec.co.kr';

-- Step 5: Verify user_profiles
SELECT 
  user_id,
  email,
  name,
  role
FROM user_profiles
WHERE email = 'mkt_biz@cnec.co.kr';

-- =====================================================
-- DONE! You are now an admin
-- =====================================================

-- IMPORTANT: After running this SQL:
-- 1. Log out from the website
-- 2. Log in again
-- 3. Now you can create campaigns!

