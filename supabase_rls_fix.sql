-- SUPABASE RLS POLICY FIX
-- Run these commands in your Supabase SQL Editor to fix the update issue

-- 1. First, check current RLS policies
SELECT * FROM pg_policies WHERE tablename = 'service_requests';

-- 2. Drop existing restrictive policies (if any)
DROP POLICY IF EXISTS "Users can update their own requests" ON service_requests;
DROP POLICY IF EXISTS "Mechanics can update assigned requests" ON service_requests;
DROP POLICY IF EXISTS "Only users can update requests" ON service_requests;

-- 3. Create permissive policies for updates
CREATE POLICY "Allow authenticated users to update service_requests" 
ON service_requests FOR UPDATE 
TO authenticated 
USING (true) 
WITH CHECK (true);

-- 4. Alternative: Create specific policies for mechanics
CREATE POLICY "Mechanics can update assigned requests" 
ON service_requests FOR UPDATE 
TO authenticated 
USING (
  auth.uid()::text = ANY(mechanic_ids) OR 
  auth.uid()::text = accepted_mechanic_id OR
  auth.uid()::text = user_id
) 
WITH CHECK (true);

-- 5. Ensure RLS is enabled but with permissive policies
ALTER TABLE service_requests ENABLE ROW LEVEL SECURITY;

-- 6. Test the update (run this to verify it works)
-- UPDATE service_requests 
-- SET status = 'in_progress', accepted_mechanic_id = 'test-mechanic-id'
-- WHERE id = 'your-request-id-here';

-- 7. If you want to temporarily disable RLS for testing:
-- ALTER TABLE service_requests DISABLE ROW LEVEL SECURITY;
