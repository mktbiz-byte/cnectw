-- =====================================================
-- CREATE STORAGE POLICIES ONLY
-- (Buckets already created manually)
-- =====================================================

-- Drop existing policies if any
DROP POLICY IF EXISTS "campaign_images_public_read" ON storage.objects;
DROP POLICY IF EXISTS "campaign_images_authenticated_upload" ON storage.objects;
DROP POLICY IF EXISTS "campaign_images_admin_upload" ON storage.objects;
DROP POLICY IF EXISTS "campaign_images_owner_delete" ON storage.objects;
DROP POLICY IF EXISTS "campaign_images_admin_delete" ON storage.objects;
DROP POLICY IF EXISTS "creator_materials_owner_read" ON storage.objects;
DROP POLICY IF EXISTS "creator_materials_owner_upload" ON storage.objects;
DROP POLICY IF EXISTS "creator_materials_owner_delete" ON storage.objects;
DROP POLICY IF EXISTS "creator_materials_admin_read" ON storage.objects;

-- =====================================================
-- CAMPAIGN-IMAGES POLICIES
-- =====================================================

-- Anyone can read campaign images (public bucket)
CREATE POLICY "campaign_images_public_read"
ON storage.objects FOR SELECT
USING (bucket_id = 'campaign-images');

-- Authenticated users (admins) can upload
CREATE POLICY "campaign_images_admin_upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'campaign-images'
);

-- Authenticated users (admins) can update
CREATE POLICY "campaign_images_admin_update"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'campaign-images')
WITH CHECK (bucket_id = 'campaign-images');

-- Authenticated users (admins) can delete
CREATE POLICY "campaign_images_admin_delete"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'campaign-images');

-- =====================================================
-- CREATOR-MATERIALS POLICIES
-- =====================================================

-- Users can read their own materials
CREATE POLICY "creator_materials_owner_read"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'creator-materials'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Users can upload their own materials
CREATE POLICY "creator_materials_owner_upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'creator-materials'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Users can update their own materials
CREATE POLICY "creator_materials_owner_update"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'creator-materials'
  AND (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
  bucket_id = 'creator-materials'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Users can delete their own materials
CREATE POLICY "creator_materials_owner_delete"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'creator-materials'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Admins can read all creator materials
CREATE POLICY "creator_materials_admin_read"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'creator-materials'
  AND (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- =====================================================
-- VERIFY POLICIES
-- =====================================================

SELECT 
  policyname,
  cmd,
  CASE 
    WHEN qual IS NOT NULL THEN substring(qual::text, 1, 100)
    ELSE ''
  END as using_clause
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND (policyname LIKE '%campaign%' OR policyname LIKE '%creator%')
ORDER BY policyname;

-- =====================================================
-- DONE! Now you can upload images
-- =====================================================

