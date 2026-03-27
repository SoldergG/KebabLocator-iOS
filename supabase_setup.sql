-- =====================================================
-- KEBAB LOCATOR - SUPABASE SETUP SQL
-- =====================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABLES
-- =====================================================

-- Main kebab shops table
CREATE TABLE IF NOT EXISTS kebab_shops (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    rating DECIMAL(2,1) DEFAULT 0,
    reviews INTEGER DEFAULT 0,
    address TEXT NOT NULL,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    tags TEXT[] DEFAULT '{}',
    price TEXT DEFAULT '€',
    hours TEXT DEFAULT '11:00 - 23:00',
    open_hour INTEGER DEFAULT 11,
    close_hour INTEGER DEFAULT 23,
    description TEXT,
    category TEXT DEFAULT 'doner',
    phone TEXT,
    website TEXT,
    popular_dishes TEXT[] DEFAULT '{}',
    has_delivery BOOLEAN DEFAULT false,
    has_dine_in BOOLEAN DEFAULT true,
    has_takeaway BOOLEAN DEFAULT true,
    image_url TEXT,
    is_sponsored BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    contributor_id UUID REFERENCES auth.users(id),
    status TEXT DEFAULT 'pending', -- pending, approved, rejected
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Favorites table (user favorites)
CREATE TABLE IF NOT EXISTS user_favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    shop_id UUID NOT NULL REFERENCES kebab_shops(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, shop_id)
);

-- Reviews/Ratings table
CREATE TABLE IF NOT EXISTS shop_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id UUID NOT NULL REFERENCES kebab_shops(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, shop_id)
);

-- User profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE,
    display_name TEXT,
    avatar_url TEXT,
    bio TEXT,
    is_contributor BOOLEAN DEFAULT false,
    is_admin BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_kebab_shops_location 
    ON kebab_shops USING GIST (ll_to_earth(latitude, longitude));

CREATE INDEX IF NOT EXISTS idx_kebab_shops_status 
    ON kebab_shops(status);

CREATE INDEX IF NOT EXISTS idx_kebab_shops_sponsored 
    ON kebab_shops(is_sponsored) WHERE is_sponsored = true;

CREATE INDEX IF NOT EXISTS idx_user_favorites_user_id 
    ON user_favorites(user_id);

CREATE INDEX IF NOT EXISTS idx_user_favorites_shop_id 
    ON user_favorites(shop_id);

CREATE INDEX IF NOT EXISTS idx_shop_reviews_shop_id 
    ON shop_reviews(shop_id);

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
CREATE TRIGGER update_kebab_shops_updated_at 
    BEFORE UPDATE ON kebab_shops 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at 
    BEFORE UPDATE ON user_profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_shop_reviews_updated_at 
    BEFORE UPDATE ON shop_reviews 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to calculate distance between two points
CREATE OR REPLACE FUNCTION calculate_distance(
    lat1 DECIMAL, lon1 DECIMAL,
    lat2 DECIMAL, lon2 DECIMAL
) RETURNS DECIMAL AS $$
DECLARE
    R DECIMAL := 6371000; -- Earth radius in meters
    dLat DECIMAL;
    dLon DECIMAL;
    a DECIMAL;
    c DECIMAL;
BEGIN
    dLat := RADIANS(lat2 - lat1);
    dLon := RADIANS(lon2 - lon1);
    a := SIN(dLat/2) * SIN(dLat/2) +
         COS(RADIANS(lat1)) * COS(RADIANS(lat2)) *
         SIN(dLon/2) * SIN(dLon/2);
    c := 2 * ATAN2(SQRT(a), SQRT(1-a));
    RETURN R * c;
END;
$$ LANGUAGE plpgsql;

-- Function to get nearby shops
CREATE OR REPLACE FUNCTION get_nearby_shops(
    user_lat DECIMAL,
    user_lon DECIMAL,
    radius_meters INTEGER DEFAULT 5000
) RETURNS TABLE (
    id UUID,
    name TEXT,
    rating DECIMAL,
    reviews INTEGER,
    address TEXT,
    latitude DECIMAL,
    longitude DECIMAL,
    distance DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ks.id,
        ks.name,
        ks.rating,
        ks.reviews,
        ks.address,
        ks.latitude,
        ks.longitude,
        calculate_distance(user_lat, user_lon, ks.latitude, ks.longitude) as distance
    FROM kebab_shops ks
    WHERE ks.status = 'approved'
        AND calculate_distance(user_lat, user_lon, ks.latitude, ks.longitude) <= radius_meters
    ORDER BY distance;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE kebab_shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE shop_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Kebab shops policies
CREATE POLICY "Anyone can view approved shops" 
    ON kebab_shops FOR SELECT 
    USING (status = 'approved' OR auth.uid() = contributor_id);

CREATE POLICY "Authenticated users can add shops" 
    ON kebab_shops FOR INSERT 
    TO authenticated 
    WITH CHECK (auth.uid() = contributor_id);

CREATE POLICY "Users can update their own shops" 
    ON kebab_shops FOR UPDATE 
    TO authenticated 
    USING (auth.uid() = contributor_id);

-- User favorites policies
CREATE POLICY "Users can view their own favorites" 
    ON user_favorites FOR SELECT 
    TO authenticated 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can add their own favorites" 
    ON user_favorites FOR INSERT 
    TO authenticated 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own favorites" 
    ON user_favorites FOR DELETE 
    TO authenticated 
    USING (auth.uid() = user_id);

-- Shop reviews policies
CREATE POLICY "Anyone can view reviews" 
    ON shop_reviews FOR SELECT 
    TO anon, authenticated 
    USING (true);

CREATE POLICY "Authenticated users can add reviews" 
    ON shop_reviews FOR INSERT 
    TO authenticated 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own reviews" 
    ON shop_reviews FOR UPDATE 
    TO authenticated 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own reviews" 
    ON shop_reviews FOR DELETE 
    TO authenticated 
    USING (auth.uid() = user_id);

-- User profiles policies
CREATE POLICY "Anyone can view profiles" 
    ON user_profiles FOR SELECT 
    TO anon, authenticated 
    USING (true);

CREATE POLICY "Users can update their own profile" 
    ON user_profiles FOR UPDATE 
    TO authenticated 
    USING (auth.uid() = id);

-- =====================================================
-- STORAGE BUCKET SETUP
-- =====================================================

-- Create storage bucket for shop photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('shop-photos', 'shop-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies
CREATE POLICY "Anyone can view shop photos" 
    ON storage.objects FOR SELECT 
    TO anon, authenticated 
    USING (bucket_id = 'shop-photos');

CREATE POLICY "Authenticated users can upload photos" 
    ON storage.objects FOR INSERT 
    TO authenticated 
    WITH CHECK (bucket_id = 'shop-photos');

-- =====================================================
-- SAMPLE DATA (Optional)
-- =====================================================

-- Insert some sample kebab shops (Lisbon area)
INSERT INTO kebab_shops (name, rating, reviews, address, latitude, longitude, tags, price, hours, open_hour, close_hour, description, category, popular_dishes, has_delivery, has_dine_in, has_takeaway, is_verified, status)
VALUES 
    ('Kebab do Bruno', 4.5, 128, 'Rua Augusta 45, Lisboa', 38.7139, -9.1395, ARRAY['Halal', 'Late Night', 'Family'], '€', '11:00 - 02:00', 11, 2, 'Traditional kebab shop with authentic recipes from Istanbul. Known for their generous portions and fresh ingredients.', 'doner', ARRAY['Doner Kebab', 'Falafel', 'Baklava'], true, true, true, true, 'approved'),
    
    ('Sultão Kebab House', 4.2, 89, 'Avenida da Liberdade 120, Lisboa', 38.7205, -9.1462, ARRAY['Premium', 'Outdoor Seating', 'Vegetarian'], '€€', '12:00 - 23:00', 12, 23, 'Premium kebab experience with outdoor seating. Great for groups and families.', 'shawarma', ARRAY['Shawarma Plate', 'Mixed Grill', 'Turkish Coffee'], true, true, true, true, 'approved'),
    
    ('Istanbul Street Food', 4.7, 203, 'Rua de São Paulo 78, Lisboa', 38.7087, -9.1438, ARRAY['Authentic', 'Quick Bite', 'Budget'], '€', '10:00 - 00:00', 10, 0, 'Street food style kebabs just like in Istanbul. Fast, delicious and affordable.', 'durum', ARRAY['Durum Wrap', 'Lahmacun', 'Ayran'], false, false, true, true, 'approved'),
    
    ('Anatolian Grill', 4.3, 156, 'Rua dos Douradores 22, Lisboa', 38.7121, -9.1367, ARRAY['Grill', 'Traditional', 'Cozy'], '€€', '11:30 - 22:30', 11, 22, 'Family-run restaurant specializing in grilled meats and traditional Turkish kebabs.', 'shish', ARRAY['Shish Kebab', 'Adana Kebab', 'Pide'], false, true, true, true, 'approved'),
    
    ('Midnight Kebab', 4.0, 67, 'Rua Nova do Carvalho 15, Lisboa', 38.7065, -9.1442, ARRAY['Late Night', 'Quick', 'Cheap'], '€', '18:00 - 04:00', 18, 4, 'Perfect for late night cravings. Open until 4am on weekends.', 'doner', ARRAY['Kebab Box', 'Fries', 'Soft Drinks'], false, false, true, true, 'approved')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- REALTIME SETUP
-- =====================================================

-- Enable realtime for kebab_shops table
ALTER PUBLICATION supabase_realtime ADD TABLE kebab_shops;
