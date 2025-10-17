-- Check campaigns table policies
SELECT 
  policyname,
  cmd,
  CASE 
    WHEN qual IS NOT NULL THEN substring(qual::text, 1, 200)
    ELSE 'N/A'
  END as using_clause,
  CASE 
    WHEN with_check IS NOT NULL THEN substring(with_check::text, 1, 200)
    ELSE 'N/A'
  END as with_check_clause
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'campaigns'
ORDER BY cmd, policyname;
