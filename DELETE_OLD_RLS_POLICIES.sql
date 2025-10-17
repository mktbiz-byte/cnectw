-- =====================================================
-- DELETE OLD RLS POLICIES (causing infinite recursion)
-- =====================================================

-- These old policies reference user_profiles table,
-- causing infinite recursion errors.
-- We need to delete them and keep only the new ones.

-- Delete old user_profiles policy
DROP POLICY IF EXISTS "Admins can manage all profiles" ON user_profiles;

-- Delete old campaign_applications policies
DROP POLICY IF EXISTS "Admins can manage all applications" ON campaign_applications;
DROP POLICY IF EXISTS "Users can create own applications" ON campaign_applications;

-- Delete old point_transactions policies
DROP POLICY IF EXISTS "Admins can manage all point transactions" ON point_transactions;
DROP POLICY IF EXISTS "Users can view own point transactions" ON point_transactions;

-- Delete old withdrawal_requests policies
DROP POLICY IF EXISTS "Admins can manage all withdrawal requests" ON withdrawal_requests;
DROP POLICY IF EXISTS "Users can create own withdrawal requests" ON withdrawal_requests;
DROP POLICY IF EXISTS "Users can view own withdrawal requests" ON withdrawal_requests;

-- =====================================================
-- Verify: Only new policies should remain
-- =====================================================

SELECT 
  tablename,
  policyname,
  cmd,
  CASE 
    WHEN qual LIKE '%user_profiles%' THEN '⚠️ STILL HAS RECURSION!'
    ELSE '✅ OK'
  END as status
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('user_profiles', 'campaign_applications', 'point_transactions', 'withdrawal_requests')
ORDER BY tablename, policyname;

-- Expected result: No policies should have "user_profiles" in USING clause
-- All admin checks should use: auth.jwt() -> 'user_metadata' ->> 'role'

