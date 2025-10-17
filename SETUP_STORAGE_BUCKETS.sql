-- =====================================================
-- SETUP STORAGE BUCKETS FOR TAIWAN PLATFORM
-- =====================================================

-- Create storage buckets for campaign images and materials
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  (
    'campaign-images',
    'campaign-images',
    true,
    5242880, -- 5MB
    ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
  )
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  (
    'creator-materials',
    'creator-materials',
    false,
    52428800, -- 50MB
    ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp', 'video/mp4', 'video/quicktime', 'application/pdf']
  )
ON CONFLICT (id) DO UPDATE SET
  public = false,
  file_size_limit = 52428800,
  allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp', 'video/mp4', 'video/quicktime', 'application/pdf'];

-- =====================================================
-- STORAGE POLICIES
-- =====================================================

-- Drop existing policies if any
DROP POLICY IF EXISTS "campaign_images_public_read" ON storage.objects;
DROP POLICY IF EXISTS "campaign_images_authenticated_upload" ON storage.objects;
DROP POLICY IF EXISTS "campaign_images_owner_delete" ON storage.objects;
DROP POLICY IF EXISTS "creator_materials_owner_read" ON storage.objects;
DROP POLICY IF EXISTS "creator_materials_owner_upload" ON storage.objects;
DROP POLICY IF EXISTS "creator_materials_owner_delete" ON storage.objects;
DROP POLICY IF EXISTS "creator_materials_admin_read" ON storage.objects;

-- Campaign Images: Public read, authenticated upload
CREATE POLICY "campaign_images_public_read"
ON storage.objects FOR SELECT
USING (bucket_id = 'campaign-images');

CREATE POLICY "campaign_images_authenticated_upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'campaign-images' 
  AND (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

CREATE POLICY "campaign_images_owner_delete"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'campaign-images'
  AND (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- Creator Materials: Owner access only
CREATE POLICY "creator_materials_owner_read"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'creator-materials'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "creator_materials_owner_upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'creator-materials'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "creator_materials_owner_delete"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'creator-materials'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Admin can read all creator materials
CREATE POLICY "creator_materials_admin_read"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'creator-materials'
  AND (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- =====================================================
-- VERIFY SETUP
-- =====================================================

-- Check buckets
SELECT 
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
FROM storage.buckets
WHERE id IN ('campaign-images', 'creator-materials');

-- Check policies
SELECT 
  policyname,
  cmd,
  CASE 
    WHEN qual IS NOT NULL THEN 'USING: ' || qual
    ELSE ''
  END as using_clause
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND policyname LIKE '%campaign%' OR policyname LIKE '%creator%'
ORDER BY policyname;

-- =====================================================
-- DONE! Storage is ready
-- =====================================================

