-- =====================================================
-- ADD MISSING COLUMNS TO CAMPAIGNS TABLE
-- =====================================================

-- Add application_deadline column
ALTER TABLE campaigns 
ADD COLUMN IF NOT EXISTS application_deadline DATE;

-- Add age_requirement column
ALTER TABLE campaigns 
ADD COLUMN IF NOT EXISTS age_requirement TEXT;

-- Add skin_type_requirement column
ALTER TABLE campaigns 
ADD COLUMN IF NOT EXISTS skin_type_requirement TEXT;

-- Add gender_requirement column
ALTER TABLE campaigns 
ADD COLUMN IF NOT EXISTS gender_requirement TEXT;

-- Add follower_requirement column
ALTER TABLE campaigns 
ADD COLUMN IF NOT EXISTS follower_requirement INTEGER;

-- Add questions column (for custom application questions)
ALTER TABLE campaigns 
ADD COLUMN IF NOT EXISTS questions JSONB DEFAULT '[]'::jsonb;

-- Add product_info column
ALTER TABLE campaigns 
ADD COLUMN IF NOT EXISTS product_info TEXT;

-- Add delivery_info column
ALTER TABLE campaigns 
ADD COLUMN IF NOT EXISTS delivery_info TEXT;

-- Add additional_requirements column
ALTER TABLE campaigns 
ADD COLUMN IF NOT EXISTS additional_requirements TEXT;

-- Add offline_visit_requirement column
ALTER TABLE campaigns 
ADD COLUMN IF NOT EXISTS offline_visit_requirement TEXT;

-- Add target_platforms column (JSONB)
ALTER TABLE campaigns 
ADD COLUMN IF NOT EXISTS target_platforms JSONB DEFAULT '{"instagram": false, "youtube": false, "tiktok": false}'::jsonb;

-- Add custom questions columns
ALTER TABLE campaigns ADD COLUMN IF NOT EXISTS question1 TEXT;
ALTER TABLE campaigns ADD COLUMN IF NOT EXISTS question1_type TEXT DEFAULT 'short';
ALTER TABLE campaigns ADD COLUMN IF NOT EXISTS question1_options TEXT;
ALTER TABLE campaigns ADD COLUMN IF NOT EXISTS question2 TEXT;
ALTER TABLE campaigns ADD COLUMN IF NOT EXISTS question2_type TEXT DEFAULT 'short';
ALTER TABLE campaigns ADD COLUMN IF NOT EXISTS question2_options TEXT;
ALTER TABLE campaigns ADD COLUMN IF NOT EXISTS question3 TEXT;
ALTER TABLE campaigns ADD COLUMN IF NOT EXISTS question3_type TEXT DEFAULT 'short';
ALTER TABLE campaigns ADD COLUMN IF NOT EXISTS question3_options TEXT;
ALTER TABLE campaigns ADD COLUMN IF NOT EXISTS question4 TEXT;
ALTER TABLE campaigns ADD COLUMN IF NOT EXISTS question4_type TEXT DEFAULT 'short';
ALTER TABLE campaigns ADD COLUMN IF NOT EXISTS question4_options TEXT;

-- Add tags column
ALTER TABLE campaigns 
ADD COLUMN IF NOT EXISTS tags TEXT[];

-- Add priority column (for sorting)
ALTER TABLE campaigns 
ADD COLUMN IF NOT EXISTS priority INTEGER DEFAULT 0;

-- Add is_featured column
ALTER TABLE campaigns 
ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT FALSE;

-- =====================================================
-- VERIFY COLUMNS
-- =====================================================

SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'campaigns'
  AND column_name IN (
    'application_deadline',
    'age_requirement',
    'skin_type_requirement',
    'gender_requirement',
    'follower_requirement',
    'questions',
    'product_info',
    'delivery_info',
    'additional_requirements',
    'tags',
    'priority',
    'is_featured',
    'offline_visit_requirement',
    'target_platforms',
    'question1',
    'question1_type',
    'question1_options',
    'question2',
    'question2_type',
    'question2_options',
    'question3',
    'question3_type',
    'question3_options',
    'question4',
    'question4_type',
    'question4_options'
  )
ORDER BY column_name;

-- =====================================================
-- DONE! All missing columns added
-- =====================================================

