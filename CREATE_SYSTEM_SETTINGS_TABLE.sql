-- system_settings 테이블 생성
CREATE TABLE IF NOT EXISTS system_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  setting_key TEXT UNIQUE NOT NULL,
  setting_value JSONB NOT NULL,
  updated_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS 정책 설정
ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;

-- Admin만 조회 가능
CREATE POLICY "system_settings_select_admin"
ON system_settings FOR SELECT TO authenticated
USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');

-- Admin만 삽입 가능
CREATE POLICY "system_settings_insert_admin"
ON system_settings FOR INSERT TO authenticated
WITH CHECK ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');

-- Admin만 수정 가능
CREATE POLICY "system_settings_update_admin"
ON system_settings FOR UPDATE TO authenticated
USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin')
WITH CHECK ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');

-- Admin만 삭제 가능
CREATE POLICY "system_settings_delete_admin"
ON system_settings FOR DELETE TO authenticated
USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_system_settings_key ON system_settings(setting_key);

-- updated_at 자동 업데이트 트리거
CREATE OR REPLACE FUNCTION update_system_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_system_settings_updated_at
BEFORE UPDATE ON system_settings
FOR EACH ROW
EXECUTE FUNCTION update_system_settings_updated_at();

-- 초기 데이터 삽입 (Taiwan 버전)
INSERT INTO system_settings (setting_key, setting_value) VALUES
('seo', '{
  "siteName": "CNEC tw - K-Beauty",
  "siteDescription": "K-Beauty × 創作者配信平台",
  "siteKeywords": "K-Beauty, 創作者, 配信, 平台, 韓國化妝品",
  "ogTitle": "CNEC tw - K-Beauty × 創作者配信平台",
  "ogDescription": "參加韓國化妝品品牌的最新活動，將您的影響力變現",
  "ogImage": "",
  "twitterCard": "summary_large_image",
  "twitterSite": "@cnectw",
  "canonicalUrl": "https://cnec-tw.com",
  "robotsTxt": "User-agent: *\\nAllow: /",
  "sitemapUrl": "https://cnec-tw.com/sitemap.xml",
  "googleAnalyticsId": "",
  "googleTagManagerId": "",
  "facebookPixelId": "",
  "metaAuthor": "CNEC Taiwan",
  "metaViewport": "width=device-width, initial-scale=1.0",
  "metaCharset": "UTF-8",
  "favicon": "/favicon.ico",
  "appleTouchIcon": "/apple-touch-icon.png"
}'::jsonb),
('email', '{
  "smtpHost": "",
  "smtpPort": "587",
  "smtpSecure": false,
  "smtpUser": "",
  "smtpPass": "",
  "fromEmail": "noreply@cnec-tw.com",
  "fromName": "CNEC Taiwan",
  "replyToEmail": "support@cnec-tw.com"
}'::jsonb)
ON CONFLICT (setting_key) DO NOTHING;

