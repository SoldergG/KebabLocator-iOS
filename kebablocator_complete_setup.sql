-- SQL COMPLETO E ATUALIZADO PARA KEBABLOCATOR COM SISTEMA DE REPORTS E VERIFICAÇÕES
-- Execute este script no seu Supabase SQL Editor

-- =====================================================
-- 0. VERIFICAR E CRIAR TABELA BASE SE NECESSÁRIO
-- =====================================================

-- Criar tabela base se não existir (compatível com supabase_setup.sql)
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
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 1. ATUALIZAR TABELA PRINCIPAL
-- =====================================================

-- Adicionar colunas para sistema de reports e verificações (só se não existirem)
DO $$
BEGIN
    -- Adicionar phone se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'kebab_shops' AND column_name = 'phone') THEN
        ALTER TABLE kebab_shops ADD COLUMN phone TEXT;
    END IF;
    
    -- Adicionar website se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'kebab_shops' AND column_name = 'website') THEN
        ALTER TABLE kebab_shops ADD COLUMN website TEXT;
    END IF;
    
    -- Adicionar popular_dishes se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'kebab_shops' AND column_name = 'popular_dishes') THEN
        ALTER TABLE kebab_shops ADD COLUMN popular_dishes TEXT[] DEFAULT '{}';
    END IF;
    
    -- Adicionar has_delivery se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'kebab_shops' AND column_name = 'has_delivery') THEN
        ALTER TABLE kebab_shops ADD COLUMN has_delivery BOOLEAN DEFAULT false;
    END IF;
    
    -- Adicionar has_dine_in se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'kebab_shops' AND column_name = 'has_dine_in') THEN
        ALTER TABLE kebab_shops ADD COLUMN has_dine_in BOOLEAN DEFAULT true;
    END IF;
    
    -- Adicionar has_takeaway se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'kebab_shops' AND column_name = 'has_takeaway') THEN
        ALTER TABLE kebab_shops ADD COLUMN has_takeaway BOOLEAN DEFAULT true;
    END IF;
    
    -- Adicionar image_url se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'kebab_shops' AND column_name = 'image_url') THEN
        ALTER TABLE kebab_shops ADD COLUMN image_url TEXT;
    END IF;
    
    -- Adicionar is_sponsored se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'kebab_shops' AND column_name = 'is_sponsored') THEN
        ALTER TABLE kebab_shops ADD COLUMN is_sponsored BOOLEAN DEFAULT false;
    END IF;
    
    -- Adicionar is_verified se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'kebab_shops' AND column_name = 'is_verified') THEN
        ALTER TABLE kebab_shops ADD COLUMN is_verified BOOLEAN DEFAULT false;
    END IF;
    
    -- Adicionar contributor_id se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'kebab_shops' AND column_name = 'contributor_id') THEN
        ALTER TABLE kebab_shops ADD COLUMN contributor_id UUID REFERENCES auth.users(id);
    END IF;
    
    -- Adicionar status se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'kebab_shops' AND column_name = 'status') THEN
        ALTER TABLE kebab_shops ADD COLUMN status TEXT DEFAULT 'pending';
    END IF;
    
    -- Adicionar place_type se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'kebab_shops' AND column_name = 'place_type') THEN
        ALTER TABLE kebab_shops ADD COLUMN place_type VARCHAR(20) DEFAULT 'kebab' CHECK (place_type IN ('kebab', 'convenience'));
    END IF;
    
    -- Adicionar report_count se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'kebab_shops' AND column_name = 'report_count') THEN
        ALTER TABLE kebab_shops ADD COLUMN report_count INTEGER DEFAULT 0;
    END IF;
    
    -- Adicionar submission_count se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'kebab_shops' AND column_name = 'submission_count') THEN
        ALTER TABLE kebab_shops ADD COLUMN submission_count INTEGER DEFAULT 1;
    END IF;
    
    -- Adicionar is_active se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'kebab_shops' AND column_name = 'is_active') THEN
        ALTER TABLE kebab_shops ADD COLUMN is_active BOOLEAN DEFAULT true;
    END IF;
    
    -- Adicionar created_at se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'kebab_shops' AND column_name = 'created_at') THEN
        ALTER TABLE kebab_shops ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
    
    -- Adicionar updated_at se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'kebab_shops' AND column_name = 'updated_at') THEN
        ALTER TABLE kebab_shops ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- =====================================================
-- 2. CRIAR TABELAS DE REPORTS E SUBMISSÕES
-- =====================================================

-- Tabela de reports para lugares
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

-- Tabela de verificação de lugares (sistema de 3 confirmações)
CREATE TABLE IF NOT EXISTS place_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    place_id UUID NOT NULL REFERENCES kebab_shops(id) ON DELETE CASCADE,
    submitter_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(place_id, submitter_id) -- Um user só pode submeter o mesmo lugar uma vez
);

-- =====================================================
-- 3. CRIAR TRIGGERS AUTOMÁTICOS
-- =====================================================

-- Trigger para remover/aprovar lugares automaticamente
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

-- Criar trigger se não existir
DROP TRIGGER IF EXISTS place_report_check_trigger ON kebab_shops;
CREATE TRIGGER place_report_check_trigger
    BEFORE UPDATE ON kebab_shops
    FOR EACH ROW
    EXECUTE FUNCTION check_and_disable_place();

-- Trigger para atualizar timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_kebab_shops_updated_at ON kebab_shops;
CREATE TRIGGER update_kebab_shops_updated_at
    BEFORE UPDATE ON kebab_shops
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 4. CRIAR ÍNDICES PARA PERFORMANCE
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_place_reports_place_id ON place_reports(place_id);
CREATE INDEX IF NOT EXISTS idx_place_reports_status ON place_reports(status);
CREATE INDEX IF NOT EXISTS idx_place_submissions_place_id ON place_submissions(place_id);
CREATE INDEX IF NOT EXISTS idx_place_submissions_status ON place_submissions(status);
CREATE INDEX IF NOT EXISTS idx_kebab_shops_active ON kebab_shops(is_active);
CREATE INDEX IF NOT EXISTS idx_kebab_shops_place_type ON kebab_shops(place_type);

-- =====================================================
-- 5. INSERIR DADOS DE EXEMPLO (CONVENIENCE STORES)
-- =====================================================

INSERT INTO kebab_shops (
    id, name, rating, reviews, address, latitude, longitude, 
    tags, price, hours, open_hour, close_hour, description, 
    category, is_verified, place_type, created_at, updated_at
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
    'Mixed Plate', 
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
    'Döner', 
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
    'Dürüm', 
    true, 
    'convenience', 
    NOW(), 
    NOW()
);

-- =====================================================
-- 6. CRIAR FUNÇÕES ÚTEIS
-- =====================================================

-- Função para buscar convenience stores ativos
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
    image_url VARCHAR,
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
    is_active BOOLEAN,
    report_count INTEGER,
    submission_count INTEGER
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
    AND ks.is_active = true
    -- Mostrar se está verificado OU tem pelo menos 1 submissão
    AND (ks.is_verified = true OR ks.submission_count >= 1)
    ORDER BY 
        ks.is_verified DESC, -- Verificados primeiro
        ks.submission_count DESC, -- Depois por número de submissões
        distance_meters; -- Finalmente por distância
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

-- Função para submeter verificação de lugar
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

-- Função principal para buscar lugares ativos (kebabs e convenience)
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
    image_url VARCHAR,
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
    is_active BOOLEAN,
    report_count INTEGER
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

-- =====================================================
-- 7. CONFIGURAR ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Ativar RLS na tabela principal se ainda não estiver ativo
ALTER TABLE kebab_shops ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes antes de criar novas
DROP POLICY IF EXISTS "Public read access to active verified places" ON kebab_shops;
DROP POLICY IF EXISTS "Users can insert places" ON kebab_shops;
DROP POLICY IF EXISTS "Users can update own places" ON kebab_shops;

-- Políticas para a tabela principal
CREATE POLICY "Public read access to active verified places"
    ON kebab_shops FOR SELECT
    USING (is_active = true AND (is_verified = true OR submission_count >= 1));

CREATE POLICY "Users can insert places"
    ON kebab_shops FOR INSERT
    WITH CHECK (auth.uid() = contributor_id);

CREATE POLICY "Users can update own places"
    ON kebab_shops FOR UPDATE
    USING (auth.uid() = contributor_id);

-- Ativar RLS nas tabelas de reports e submissões
ALTER TABLE place_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE place_submissions ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes
DROP POLICY IF EXISTS "Users can create reports" ON place_reports;
DROP POLICY IF EXISTS "Users can view own reports" ON place_reports;
DROP POLICY IF EXISTS "Users can create submissions" ON place_submissions;
DROP POLICY IF EXISTS "Users can view own submissions" ON place_submissions;

-- Políticas para reports
CREATE POLICY "Users can create reports"
    ON place_reports FOR INSERT
    WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "Users can view own reports"
    ON place_reports FOR SELECT
    USING (auth.uid() = reporter_id);

-- Políticas para submissões
CREATE POLICY "Users can create submissions"
    ON place_submissions FOR INSERT
    WITH CHECK (auth.uid() = submitter_id);

CREATE POLICY "Users can view own submissions"
    ON place_submissions FOR SELECT
    USING (auth.uid() = submitter_id);

-- =====================================================
-- 8. VIEWS ÚTEIS PARA CONSULTAS
-- =====================================================

-- View para lugares ativos (incluindo estatísticas)
CREATE OR REPLACE VIEW active_places_view AS
SELECT 
    ks.*,
    CASE 
        WHEN ks.is_verified THEN 'Verified'
        WHEN ks.submission_count >= 3 THEN 'Verified'
        WHEN ks.submission_count > 0 THEN 'Pending'
        ELSE 'New'
    END as verification_status,
    CASE 
        WHEN ks.report_count >= 3 THEN 'Removed'
        WHEN ks.report_count > 0 THEN 'Reported'
        ELSE 'Active'
    END as moderation_status
FROM kebab_shops ks
WHERE ks.is_active = true;

-- View para estatísticas de moderação
CREATE OR REPLACE VIEW moderation_stats_view AS
SELECT 
    ks.id,
    ks.name,
    ks.place_type,
    ks.is_verified,
    ks.is_active,
    ks.report_count,
    ks.submission_count,
    COUNT(pr.id) as total_reports,
    COUNT(ps.id) as total_submissions
FROM kebab_shops ks
LEFT JOIN place_reports pr ON ks.id = pr.place_id
LEFT JOIN place_submissions ps ON ks.id = ps.place_id
GROUP BY ks.id, ks.name, ks.place_type, ks.is_verified, ks.is_active, ks.report_count, ks.submission_count;

-- =====================================================
-- 9. FINALIZAÇÃO
-- =====================================================

-- Mostrar resumo do que foi criado
DO $$
DECLARE
    table_count INTEGER;
    function_count INTEGER;
    view_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO table_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name IN ('kebab_shops', 'place_reports', 'place_submissions');
    
    SELECT COUNT(*) INTO function_count
    FROM information_schema.routines
    WHERE routine_schema = 'public'
    AND routine_name IN ('get_convenience_stores', 'report_place', 'submit_place_verification', 'get_active_places', 'check_and_disable_place', 'update_updated_at_column');
    
    SELECT COUNT(*) INTO view_count
    FROM information_schema.views
    WHERE table_schema = 'public'
    AND table_name IN ('active_places_view', 'moderation_stats_view');
    
    RAISE NOTICE '✅ KebabLocator setup completed!';
    RAISE NOTICE '📊 Tables created: %', table_count;
    RAISE NOTICE '🔧 Functions created: %', function_count;
    RAISE NOTICE '👁️ Views created: %', view_count;
    RAISE NOTICE '🎯 System ready for reports and verifications!';
END $$;
