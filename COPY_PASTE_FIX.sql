-- =====================================================
-- 1단계: 모든 정책 강제 삭제
-- =====================================================

DO $$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname, tablename FROM pg_policies WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON ' || quote_ident(r.tablename);
    END LOOP;
END $$;

-- =====================================================
-- 2단계: 새 정책 생성 (JWT만 사용)
-- =====================================================

-- user_profiles
CREATE POLICY "user_profiles_select_own" ON user_profiles FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "user_profiles_insert_own" ON user_profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "user_profiles_update_own" ON user_profiles FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "user_profiles_select_admin" ON user_profiles FOR SELECT TO authenticated USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');
CREATE POLICY "user_profiles_update_admin" ON user_profiles FOR UPDATE TO authenticated USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin') WITH CHECK ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');
CREATE POLICY "user_profiles_delete_admin" ON user_profiles FOR DELETE TO authenticated USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');

-- campaigns
CREATE POLICY "campaigns_select_all" ON campaigns FOR SELECT TO authenticated USING (true);
CREATE POLICY "campaigns_insert_admin" ON campaigns FOR INSERT TO authenticated WITH CHECK ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');
CREATE POLICY "campaigns_update_admin" ON campaigns FOR UPDATE TO authenticated USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin') WITH CHECK ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');
CREATE POLICY "campaigns_delete_admin" ON campaigns FOR DELETE TO authenticated USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');

-- campaign_applications
CREATE POLICY "applications_select_own" ON campaign_applications FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "applications_insert_own" ON campaign_applications FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "applications_update_own" ON campaign_applications FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "applications_select_admin" ON campaign_applications FOR SELECT TO authenticated USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');
CREATE POLICY "applications_update_admin" ON campaign_applications FOR UPDATE TO authenticated USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin') WITH CHECK ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');
CREATE POLICY "applications_delete_admin" ON campaign_applications FOR DELETE TO authenticated USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');

-- point_transactions
CREATE POLICY "point_transactions_select_own" ON point_transactions FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "point_transactions_select_admin" ON point_transactions FOR SELECT TO authenticated USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');
CREATE POLICY "point_transactions_insert_system" ON point_transactions FOR INSERT TO authenticated WITH CHECK (true);

-- withdrawal_requests
CREATE POLICY "withdrawals_select_own" ON withdrawal_requests FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "withdrawals_insert_own" ON withdrawal_requests FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "withdrawals_select_admin" ON withdrawal_requests FOR SELECT TO authenticated USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');
CREATE POLICY "withdrawals_update_admin" ON withdrawal_requests FOR UPDATE TO authenticated USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin') WITH CHECK ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');

-- =====================================================
-- 3단계: Admin 역할 설정
-- =====================================================

UPDATE auth.users SET raw_user_meta_data = jsonb_set(COALESCE(raw_user_meta_data, '{}'::jsonb), '{role}', '"admin"') WHERE email = 'mkt_biz@cnec.co.kr';

-- =====================================================
-- 완료! 이제 로그아웃 후 시크릿 모드로 재로그인하세요
-- =====================================================

