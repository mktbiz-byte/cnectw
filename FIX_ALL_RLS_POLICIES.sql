-- =====================================================
-- FIX ALL RLS POLICIES - Remove Infinite Recursion
-- Taiwan Platform (cnec-taiwan)
-- =====================================================

-- IMPORTANT: This fixes the infinite recursion error by:
-- 1. Using auth.users table directly for admin checks (not user_profiles)
-- 2. Avoiding circular references in policies
-- 3. Simplifying policy logic

-- =====================================================
-- STEP 1: Drop ALL existing policies
-- =====================================================

-- user_profiles policies
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON user_profiles;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON user_profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON user_profiles;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON user_profiles;
DROP POLICY IF EXISTS "user_profiles_select_own" ON user_profiles;
DROP POLICY IF EXISTS "user_profiles_insert_own" ON user_profiles;
DROP POLICY IF EXISTS "user_profiles_update_own" ON user_profiles;
DROP POLICY IF EXISTS "user_profiles_select_admin" ON user_profiles;
DROP POLICY IF EXISTS "user_profiles_update_admin" ON user_profiles;

-- campaigns policies
DROP POLICY IF EXISTS "Anyone can view active campaigns" ON campaigns;
DROP POLICY IF EXISTS "Admins can manage campaigns" ON campaigns;
DROP POLICY IF EXISTS "Enable read access for all users" ON campaigns;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON campaigns;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON campaigns;
DROP POLICY IF EXISTS "Enable delete for users based on user_id" ON campaigns;

-- campaign_applications policies
DROP POLICY IF EXISTS "Users can view own applications" ON campaign_applications;
DROP POLICY IF EXISTS "Users can create applications" ON campaign_applications;
DROP POLICY IF EXISTS "Admins can view all applications" ON campaign_applications;
DROP POLICY IF EXISTS "Admins can update applications" ON campaign_applications;

-- =====================================================
-- STEP 2: Create SIMPLE, NON-RECURSIVE policies
-- =====================================================

-- -----------------------------------------------------
-- user_profiles: Simple policies without recursion
-- -----------------------------------------------------

-- Users can SELECT their own profile
CREATE POLICY "user_profiles_select_own"
ON user_profiles FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Users can INSERT their own profile
CREATE POLICY "user_profiles_insert_own"
ON user_profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Users can UPDATE their own profile
CREATE POLICY "user_profiles_update_own"
ON user_profiles FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Admins can SELECT all profiles (check role in auth.users, NOT user_profiles)
CREATE POLICY "user_profiles_select_admin"
ON user_profiles FOR SELECT
TO authenticated
USING (
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- Admins can UPDATE all profiles
CREATE POLICY "user_profiles_update_admin"
ON user_profiles FOR UPDATE
TO authenticated
USING (
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
)
WITH CHECK (
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- Admins can DELETE profiles
CREATE POLICY "user_profiles_delete_admin"
ON user_profiles FOR DELETE
TO authenticated
USING (
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- -----------------------------------------------------
-- campaigns: Public read, admin write
-- -----------------------------------------------------

-- Anyone can view active campaigns
CREATE POLICY "campaigns_select_all"
ON campaigns FOR SELECT
TO authenticated
USING (true);

-- Admins can INSERT campaigns
CREATE POLICY "campaigns_insert_admin"
ON campaigns FOR INSERT
TO authenticated
WITH CHECK (
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- Admins can UPDATE campaigns
CREATE POLICY "campaigns_update_admin"
ON campaigns FOR UPDATE
TO authenticated
USING (
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
)
WITH CHECK (
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- Admins can DELETE campaigns
CREATE POLICY "campaigns_delete_admin"
ON campaigns FOR DELETE
TO authenticated
USING (
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- -----------------------------------------------------
-- campaign_applications: Users see own, admins see all
-- -----------------------------------------------------

-- Users can SELECT their own applications
CREATE POLICY "applications_select_own"
ON campaign_applications FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Users can INSERT their own applications
CREATE POLICY "applications_insert_own"
ON campaign_applications FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Users can UPDATE their own applications
CREATE POLICY "applications_update_own"
ON campaign_applications FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Admins can SELECT all applications
CREATE POLICY "applications_select_admin"
ON campaign_applications FOR SELECT
TO authenticated
USING (
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- Admins can UPDATE all applications
CREATE POLICY "applications_update_admin"
ON campaign_applications FOR UPDATE
TO authenticated
USING (
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
)
WITH CHECK (
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- Admins can DELETE applications
CREATE POLICY "applications_delete_admin"
ON campaign_applications FOR DELETE
TO authenticated
USING (
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- -----------------------------------------------------
-- point_transactions: Users see own, admins see all
-- -----------------------------------------------------

DROP POLICY IF EXISTS "Users can view own transactions" ON point_transactions;
DROP POLICY IF EXISTS "Admins can view all transactions" ON point_transactions;
DROP POLICY IF EXISTS "System can insert transactions" ON point_transactions;

CREATE POLICY "point_transactions_select_own"
ON point_transactions FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "point_transactions_select_admin"
ON point_transactions FOR SELECT
TO authenticated
USING (
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

CREATE POLICY "point_transactions_insert_system"
ON point_transactions FOR INSERT
TO authenticated
WITH CHECK (true);

-- -----------------------------------------------------
-- withdrawal_requests: Users see own, admins see all
-- -----------------------------------------------------

DROP POLICY IF EXISTS "Users can view own withdrawals" ON withdrawal_requests;
DROP POLICY IF EXISTS "Users can create withdrawals" ON withdrawal_requests;
DROP POLICY IF EXISTS "Admins can view all withdrawals" ON withdrawal_requests;
DROP POLICY IF EXISTS "Admins can update withdrawals" ON withdrawal_requests;

CREATE POLICY "withdrawals_select_own"
ON withdrawal_requests FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "withdrawals_insert_own"
ON withdrawal_requests FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "withdrawals_select_admin"
ON withdrawal_requests FOR SELECT
TO authenticated
USING (
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

CREATE POLICY "withdrawals_update_admin"
ON withdrawal_requests FOR UPDATE
TO authenticated
USING (
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
)
WITH CHECK (
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- =====================================================
-- STEP 3: Verify all policies
-- =====================================================

SELECT 
  tablename,
  policyname,
  cmd,
  CASE 
    WHEN qual IS NOT NULL THEN 'USING: ' || qual
    ELSE ''
  END as using_clause,
  CASE 
    WHEN with_check IS NOT NULL THEN 'WITH CHECK: ' || with_check
    ELSE ''
  END as with_check_clause
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('user_profiles', 'campaigns', 'campaign_applications', 'point_transactions', 'withdrawal_requests')
ORDER BY tablename, policyname;

-- =====================================================
-- DONE! All policies fixed
-- =====================================================

