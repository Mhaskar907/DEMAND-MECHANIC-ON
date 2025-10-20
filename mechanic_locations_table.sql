-- MECHANIC LOCATION TRACKING TABLE
-- Run this in your Supabase SQL Editor

-- 1. Create the mechanic_locations table
CREATE TABLE IF NOT EXISTS public.mechanic_locations (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  mechanic_id UUID NOT NULL,
  mechanic_name TEXT NOT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  address TEXT,
  is_online BOOLEAN DEFAULT true,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  CONSTRAINT mechanic_locations_pkey PRIMARY KEY (id),
  CONSTRAINT mechanic_locations_mechanic_id_fkey FOREIGN KEY (mechanic_id) REFERENCES auth.users (id) ON DELETE CASCADE
) TABLESPACE pg_default;

-- 2. Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_mechanic_locations_mechanic_id ON public.mechanic_locations(mechanic_id);
CREATE INDEX IF NOT EXISTS idx_mechanic_locations_last_updated ON public.mechanic_locations(last_updated);
CREATE INDEX IF NOT EXISTS idx_mechanic_locations_is_online ON public.mechanic_locations(is_online);

-- 3. Enable RLS
ALTER TABLE public.mechanic_locations ENABLE ROW LEVEL SECURITY;

-- 4. Create RLS Policies
-- Policy 1: Mechanics can insert/update their own location
CREATE POLICY "Mechanics can manage their own location" 
ON public.mechanic_locations 
FOR ALL 
TO authenticated 
USING (auth.uid() = mechanic_id) 
WITH CHECK (auth.uid() = mechanic_id);

-- Policy 2: Users can view mechanic locations (for map display)
CREATE POLICY "Users can view mechanic locations" 
ON public.mechanic_locations 
FOR SELECT 
TO authenticated 
USING (is_online = true);

-- Policy 3: Allow service to update locations (for background updates)
CREATE POLICY "Service can update locations" 
ON public.mechanic_locations 
FOR UPDATE 
TO authenticated 
USING (true) 
WITH CHECK (true);

-- 5. Create a function to clean up old location data (optional)
CREATE OR REPLACE FUNCTION cleanup_old_locations()
RETURNS void AS $$
BEGIN
  -- Delete locations older than 24 hours
  DELETE FROM public.mechanic_locations 
  WHERE last_updated < NOW() - INTERVAL '24 hours';
END;
$$ LANGUAGE plpgsql;

-- 6. Create a trigger to automatically update last_updated timestamp
CREATE OR REPLACE FUNCTION update_last_updated_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_updated = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_mechanic_locations_last_updated
  BEFORE UPDATE ON public.mechanic_locations
  FOR EACH ROW
  EXECUTE FUNCTION update_last_updated_column();

-- 7. Test the setup
-- Insert a test location (replace with actual mechanic ID)
-- INSERT INTO public.mechanic_locations (mechanic_id, mechanic_name, latitude, longitude, address)
-- VALUES ('your-mechanic-id', 'Test Mechanic', 19.0760, 72.8777, 'Mumbai, India');

-- 8. Verify policies
SELECT * FROM pg_policies WHERE tablename = 'mechanic_locations';
