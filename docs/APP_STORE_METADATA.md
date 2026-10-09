# App Store Connect — Formulário de Submissão
## Kebab Locator | v1.0 | iOS

---

## Metadados (English — United States)

### Nome da App
```
Kebab Locator
```

### Subtítulo (30 chars max)
```
Find Kebab Shops Near You
```

### Texto Promocional (170 chars — aparece sem update da app)
```
Discover the best kebab restaurants near you. Browse, save favorites, and explore the map to find your next delicious kebab meal!
```

### Descrição (4000 chars)
```
Kebab Locator helps you find the best kebab restaurants and shops near your current location or any location you choose.

FEATURES:
• 📍 Find kebab shops near you using GPS
• 🗺️ Interactive map with all nearby locations
• 🔍 Search and filter by distance and rating
• ❤️ Save your favorite spots for quick access
• ➕ Add new kebab shops to help the community
• 📊 View ratings, hours, and contact info

HOW IT WORKS:
1. Open the app and allow location access
2. Instantly see kebab shops around you
3. Tap any shop for details, directions, and reviews
4. Save favorites to your personal list
5. Can't find a place? Add it yourself!

OWNER PORTAL:
Business owners can claim and manage their listings directly in the app.

Free to use. Supported by non-intrusive ads.
```

### Palavras-chave (100 bytes — separadas por vírgula, sem espaços após vírgula)
```
doner,shawarma,falafel,durum,gyro,halal,takeaway,turkish,restaurant,map,nearby,wrap,pita,lebanese
```
**97/100 bytes** (validado com `.claude/skills/app-store-assets/scripts/check_metadata.py`).

Porquê assim:
- Não repete palavras do nome/subtítulo (`kebab`, `locator`, `find`, `shops`, `near`, `you`) nem o nome do developer — já são pesquisáveis.
- Sem `food`: faz parte da categoria (Food & Drink), e a Apple pede para não usar nomes de categorias.
- Palavras soltas em vez de frases: combinam com o nome e o subtítulo ("kebab" + "doner" → "doner kebab", "shawarma" + "near" → "shawarma near").
- Limite em **bytes** UTF-8: evitar acentos (`döner` gasta 6 bytes, `doner` gasta 5).

### URL de Suporte
```
https://github.com/SoldergG/KebabLocator-iOS/issues
```

### URL de Privacidade
```
https://solderg.github.io/KebabLocator-iOS/privacy-policy.html
```

### URL de Marketing (opcional)
```
(deixar vazio por agora)
```

### Versão
```
1.0
```

### Copyright
```
© 2026 Lucas
```

---

## Screenshots

A app corre em iPhone **e iPad** (`TARGETED_DEVICE_FAMILY = "1,2"`), por isso são precisos 3 conjuntos, todos em **portrait**:

| Conjunto | Tamanho exato | Simulador | Obrigatório? |
|----------|---------------|-----------|--------------|
| iPhone 6.9" | **1320×2868** | iPhone 17 Pro Max | Sim (ou 6.5"); serve de base para os iPhones grandes |
| iPhone 6.1" | **1206×2622** | iPhone 17 | Sim; é o tamanho de iPhone que o App Store Connect exige |
| iPad 13" | **2064×2752** | iPad Pro 13-inch (M5) | Sim, porque a app corre em iPad |

Regras: 1–10 por tamanho, `.png`/`.jpg`, **sem transparência**, tamanho em píxeis exato (o simulador já os gera certos; não redimensionar). Os 3 primeiros aparecem nos resultados de pesquisa, por isso são os que vendem a app.

### Ordem e legendas (en-US)

| # | Ecrã | Legenda (en-US) | O que mostra |
|---|------|-----------------|--------------|
| 1 | HomeView (lista "Nearest") | Find kebabs around you | Valor principal: kebabs mais perto, com distância |
| 2 | MapTabView | Every spot on one map | Mapa com vários pins na zona |
| 3 | ShopDetailView | Hours, ratings and directions | Horário, rating, "Get Directions" e "Call" |
| 4 | ExploreView | Search and filter by distance | Pesquisa e filtro de raio (km) |
| 5 | FavoritesView (Saved) | Save the spots you love | 3–4 lojas guardadas |
| 6 | AddKebabView | Add a spot that's missing | Contribuição da comunidade |

Legendas validadas: sem preços, sem URLs, sem "best"/"#1", sem outras plataformas.

### Antes de capturar

- **Não usar o HeroView**: mostra "🥙 #1 Kebab Finder" e "Best Kebabs". São afirmações não verificáveis (Guideline 2.3.7) e é um ecrã de entrada, não a app em uso (2.3.3).
- **Esconder os banners AdMob**: anúncios reais mostram conteúdo de terceiros sobre o qual não tens direitos (2.3.9), que pode incluir logos de Google Play/Android (2.3.10).
- **Dados de lojas**: escolhe uma zona com várias lojas e nomes reais e limpos, sem fotos de terceiros que não possas usar.
- Dark mode está forçado na app, logo todos os screenshots ficam escuros e consistentes.

### Como tirar

```bash
# 1. Arrancar o simulador certo e pôr a barra de estado "limpa" (Wi-Fi e bateria cheios, 9:41)
xcrun simctl boot "iPhone 17 Pro Max"
xcrun simctl status_bar booted override --time "9:41" --dataNetwork wifi --wifiMode active --wifiBars 3 \
  --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100

# 2. Localização com várias lojas (ex.: Lisboa centro)
xcrun simctl location booted set 38.7223,-9.1393

# 3. Navegar até cada ecrã e capturar
xcrun simctl io booted screenshot --type=png "iphone69-01-home.png"

# 4. Repetir para "iPhone 17" (6.1") e "iPad Pro 13-inch (M5)"

# 5. Validar tudo antes de fazer upload
python3 .claude/skills/app-store-assets/scripts/check_assets.py AppStoreScreenshots/ --ipad
```

Se adicionares legendas num editor (Figma, Pixelmator…), cria o canvas logo no tamanho final (1320×2868, 1206×2622, 2064×2752) e exporta sem transparência.

---

## Ícone da App
- Ficheiro: `KebabLocator-iOS/KebabLocator/Assets.xcassets/AppIcon.appiconset/`
- Tamanho necessário para upload manual: **1024×1024px PNG**, sem transparência, sem cantos arredondados

---

## AdMob — IDs de Produção ⚠️
Substituir antes da submissão:

| Ficheiro | Chave | Valor atual (TEST) | Substituir por |
|----------|-------|--------------------|----------------|
| `Info.plist` | `GADApplicationIdentifier` | `ca-app-pub-3758472607555726~1637933842` | ID real da AdMob |
| `BannerAdView.swift` | Ad Unit IDs | IDs de teste | IDs reais |

---

## Informações para a Equipa de Revisão

### Necessário iniciar sessão?
- **Não** — a app não requer conta para navegar

### Informações de Contacto (preencher no formulário)
```
Nome: Lucas
Apelido: [Apelido]
Número de telefone: [Número]
E-mail: [Email]
```

### Notas para o Reviewer
```
This app uses Core Location to find kebab restaurants near the user's location.
Location permission is requested on first launch with a clear explanation.

The app uses Google AdMob for advertising, which requires the App Tracking Transparency
prompt. ATT permission description is included in Info.plist.

No login is required to use the main features. The "Add Kebab" feature allows anonymous
submissions to help grow the community database.

Test the map by allowing location access when prompted.
```

---

## Privacy Nutrition Labels (App Store Connect → Privacy)

| Categoria | Tipo de dado | Uso | Linked to user? |
|-----------|-------------|-----|-----------------|
| Location | Precise Location | App Functionality | No |
| Identifiers | Device ID | Advertising (AdMob) | Yes |
| Usage Data | Product Interaction | Analytics | No |

---

## Exportação de Criptografia
- A app usa HTTPS standard (URLSession / Supabase REST)
- Responder: **"Sim, usa algoritmos de criptografia standard"** → marca como exempta (EAR exemption 740.17(a))
- Não é necessário BIS approval

---

## Lançamento da Versão
- Recomendado: **Lançar automaticamente após aprovação**
