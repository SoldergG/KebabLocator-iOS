-- SQL para adicionar suporte a convenience stores na tabela kebab_shops

-- Atualizar a tabela existente para incluir tipo de lugar
ALTER TABLE kebab_shops 
ADD COLUMN place_type VARCHAR(20) DEFAULT 'kebab' CHECK (place_type IN ('kebab', 'convenience'));

-- Criar tabela de reports para lugares
CREATE TABLE IF NOT EXISTS place_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    place_id UUID NOT NULL REFERENCES kebab_shops(id) ON DELETE CASCADE,
    reporter_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    reason VARCHAR(50) NOT NULL CHECK (reason IN ('closed', 'wrong_location', 'duplicate', 'inappropriate', 'other')),
    description TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(place_id, reporter_id, reason) -- Um user não pode reportar o mesmo lugar pelo mesmo motivo
);

-- Criar tabela de verificação de lugares (para sistema de 3 adições)
CREATE TABLE IF NOT EXISTS place_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    place_id UUID NOT NULL REFERENCES kebab_shops(id) ON DELETE CASCADE,
    submitter_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(place_id, submitter_id) -- Um user só pode submeter o mesmo lugar uma vez
);

-- Adicionar colunas de contagem na tabela principal
ALTER TABLE kebab_shops 
ADD COLUMN IF NOT EXISTS report_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS submission_count INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- Trigger para remover lugar após 3 reports
CREATE OR REPLACE FUNCTION check_and_disable_place()
RETURNS TRIGGER AS $$
BEGIN
    -- Se tiver 3 ou mais reports, desativar o lugar
    IF NEW.report_count >= 3 THEN
        NEW.is_active = false;
    END IF;
    
    -- Se tiver 3 ou mais submissões diferentes, aprovar o lugar
    IF NEW.submission_count >= 3 THEN
        NEW.is_verified = true;
        NEW.is_active = true;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER place_report_check_trigger
    BEFORE UPDATE ON kebab_shops
    FOR EACH ROW
    EXECUTE FUNCTION check_and_disable_place();

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_place_reports_place_id ON place_reports(place_id);
CREATE INDEX IF NOT EXISTS idx_place_reports_status ON place_reports(status);
CREATE INDEX IF NOT EXISTS idx_place_submissions_place_id ON place_submissions(place_id);
CREATE INDEX IF NOT EXISTS idx_place_submissions_status ON place_submissions(status);
CREATE INDEX IF NOT EXISTS idx_kebab_shops_active ON kebab_shops(is_active);

-- Inserir dados de exemplo para convenience stores
INSERT INTO kebab_shops (
    id, name, rating, reviews, address, latitude, longitude, 
    tags, price, hours, open_hour, close_hour, description, 
    image_name, category, phone, website, popular_dishes, 
    has_delivery, has_dine_in, has_takeaway, is_sponsored, 
    is_verified, place_type, created_at, updated_at
) VALUES 
(
    gen_random_uuid(), 
    '24h Mini Market', 
    4.2, 
    128, 
    'Rua Augusta 125, Lisboa', 
    38.7169, 
    -9.1395, 
    ARRAY['24h', 'Snacks', 'Drinks'], 
    '€', 
    '24 Hours', 
    0, 
    24, 
    'Convenience store open 24/7. Sells snacks, drinks, and essentials.', 
    'kebab1', 
    'Mixed Plate', 
    '+351 912 345 678', 
    '', 
    ARRAY['Snacks', 'Drinks', 'Essentials'], 
    false, 
    false, 
    true, 
    false, 
    true, 
    'convenience', 
    NOW(), 
    NOW()
),
(
    gen_random_uuid(), 
    'Quick Stop Market', 
    3.8, 
    85, 
    'Avenida da Liberdade 200, Lisboa', 
    38.7147, 
    -9.1406, 
    ARRAY['Late Night', 'Food', 'Drinks'], 
    '€', 
    '22:00 - 06:00', 
    22, 
    6, 
    'Late night convenience store for all your needs.', 
    'kebab2', 
    'Döner', 
    '+351 923 456 789', 
    '', 
    ARRAY['Hot Dogs', 'Sodas', 'Chips'], 
    false, 
    false, 
    true, 
    false, 
    true, 
    'convenience', 
    NOW(), 
    NOW()
),
(
    gen_random_uuid(), 
    'Corner Shop Express', 
    4.0, 
    156, 
    'Rua do Ouro 45, Lisboa', 
    38.7132, 
    -9.1388, 
    ARRAY['24h', 'ATM', 'Lottery'], 
    '€', 
    '24 Hours', 
    0, 
    24, 
    'Your neighborhood 24h shop with ATM and lottery.', 
    'kebab3', 
    'Dürüm', 
    '+351 934 567 890', 
    '', 
    ARRAY['Coffee', 'Newspapers', 'Bread'], 
    false, 
    false, 
    true, 
    false, 
    true, 
    'convenience', 
    NOW(), 
    NOW()
);

-- Criar índice para melhor performance de queries por tipo
CREATE INDEX idx_kebab_shops_place_type ON kebab_shops(place_type);

-- Criar função para buscar convenience stores
CREATE OR REPLACE FUNCTION get_convenience_stores(
    lat_range FLOAT DEFAULT 0.01,
    lon_range FLOAT DEFAULT 0.01,
    center_lat FLOAT DEFAULT 38.7169,
    center_lon FLOAT DEFAULT -9.1395
)
RETURNS TABLE (
    id UUID,
    name VARCHAR,
    rating FLOAT,
    reviews INTEGER,
    address VARCHAR,
    latitude FLOAT,
    longitude FLOAT,
    tags TEXT[],
    price VARCHAR,
    hours VARCHAR,
    open_hour INTEGER,
    close_hour INTEGER,
    description TEXT,
    image_name VARCHAR,
    category VARCHAR,
    phone VARCHAR,
    website VARCHAR,
    popular_dishes TEXT[],
    has_delivery BOOLEAN,
    has_dine_in BOOLEAN,
    has_takeaway BOOLEAN,
    is_sponsored BOOLEAN,
    is_verified BOOLEAN,
    place_type VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ks.*,
        ST_Distance(
            ST_MakePoint(ks.longitude, ks.latitude)::geography,
            ST_MakePoint(center_lon, center_lat)::geography
        ) as distance_meters
    FROM kebab_shops ks
    WHERE ks.place_type = 'convenience'
    AND ks.latitude BETWEEN (center_lat - lat_range) AND (center_lat + lat_range)
    AND ks.longitude BETWEEN (center_lon - lon_range) AND (center_lon + lon_range)
    AND ks.is_verified = true
    AND ks.is_active = true
    ORDER BY distance_meters;
END;
$$ LANGUAGE plpgsql;

-- Função para reportar um lugar
CREATE OR REPLACE FUNCTION report_place(
    p_place_id UUID,
    p_reporter_id UUID,
    p_reason VARCHAR,
    p_description TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    report_count INTEGER;
BEGIN
    -- Inserir o report
    INSERT INTO place_reports (place_id, reporter_id, reason, description)
    VALUES (p_place_id, p_reporter_id, p_reason, p_description)
    ON CONFLICT (place_id, reporter_id, reason) DO NOTHING;
    
    -- Contar reports para este lugar
    SELECT COUNT(*) INTO report_count
    FROM place_reports
    WHERE place_id = p_place_id;
    
    -- Atualizar contagem na tabela principal
    UPDATE kebab_shops 
    SET report_count = report_count
    WHERE id = p_place_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Função para submeter um lugar (sistema de 3 confirmações)
CREATE OR REPLACE FUNCTION submit_place_verification(
    p_place_id UUID,
    p_submitter_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    submission_count INTEGER;
BEGIN
    -- Inserir submissão
    INSERT INTO place_submissions (place_id, submitter_id)
    VALUES (p_place_id, p_submitter_id)
    ON CONFLICT (place_id, submitter_id) DO NOTHING;
    
    -- Contar submissões diferentes para este lugar
    SELECT COUNT(DISTINCT submitter_id) INTO submission_count
    FROM place_submissions
    WHERE place_id = p_place_id;
    
    -- Atualizar contagem na tabela principal
    UPDATE kebab_shops 
    SET submission_count = submission_count
    WHERE id = p_place_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Função para obter lugares ativos (incluindo os não verificados mas com submissões)
CREATE OR REPLACE FUNCTION get_active_places(
    lat_range FLOAT DEFAULT 0.01,
    lon_range FLOAT DEFAULT 0.01,
    center_lat FLOAT DEFAULT 38.7169,
    center_lon FLOAT DEFAULT -9.1395,
    p_place_type VARCHAR DEFAULT 'kebab'
)
RETURNS TABLE (
    id UUID,
    name VARCHAR,
    rating FLOAT,
    reviews INTEGER,
    address VARCHAR,
    latitude FLOAT,
    longitude FLOAT,
    tags TEXT[],
    price VARCHAR,
    hours VARCHAR,
    open_hour INTEGER,
    close_hour INTEGER,
    description TEXT,
    image_name VARCHAR,
    category VARCHAR,
    phone VARCHAR,
    website VARCHAR,
    popular_dishes TEXT[],
    has_delivery BOOLEAN,
    has_dine_in BOOLEAN,
    has_takeaway BOOLEAN,
    is_sponsored BOOLEAN,
    is_verified BOOLEAN,
    place_type VARCHAR,
    submission_count INTEGER,
    is_active BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ks.*,
        ST_Distance(
            ST_MakePoint(ks.longitude, ks.latitude)::geography,
            ST_MakePoint(center_lon, center_lat)::geography
        ) as distance_meters
    FROM kebab_shops ks
    WHERE ks.place_type = p_place_type
    AND ks.latitude BETWEEN (center_lat - lat_range) AND (center_lat + lat_range)
    AND ks.longitude BETWEEN (center_lon - lon_range) AND (center_lon + lon_range)
    AND ks.is_active = true
    -- Mostrar se está verificado OU tem pelo menos 1 submissão
    AND (ks.is_verified = true OR ks.submission_count >= 1)
    ORDER BY 
        ks.is_verified DESC, -- Verificados primeiro
        ks.submission_count DESC, -- Depois por número de submissões
        distance_meters; -- Finalmente por distância
END;
$$ LANGUAGE plpgsql;

-- Criar trigger para atualizar timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_kebab_shops_updated_at
    BEFORE UPDATE ON kebab_shops
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Política RLS para convenience stores (se já tiver RLS ativado)
ALTER TABLE kebab_shops ENABLE ROW LEVEL SECURITY;

-- Política para permitir leitura pública de convenience stores verificadas
CREATE POLICY "Public read access to verified convenience stores"
    ON kebab_shops FOR SELECT
    USING (place_type = 'convenience' AND is_verified = true);

-- Política para permitir inserção de convenience stores (requer autenticação)
CREATE POLICY "Users can insert convenience stores"
    ON kebab_shops FOR INSERT
    WITH CHECK (place_type = 'convenience' AND auth.uid() = contributor_id);

-- Política para permitir atualização dos próprios convenience stores
CREATE POLICY "Users can update own convenience stores"
    ON kebab_shops FOR UPDATE
    USING (place_type = 'convenience' AND auth.uid() = contributor_id);
