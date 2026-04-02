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

### Palavras-chave (100 chars — separadas por vírgula, sem espaços após vírgula)
```
kebab,kebab near me,kebab restaurant,food finder,shawarma,doner,halal food,food map,restaurant finder
```

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

## Screenshots — iPhone 6.5" (1242×2688px)

Tirar no simulador **iPhone 14 Plus** ou **iPhone 11 Pro Max**:

| # | Ecrã | Descrição sugerida |
|---|------|--------------------|
| 1 | HomeView | "Kebabs perto de ti" com lista |
| 2 | MapTabView | Mapa com pins de kebabs |
| 3 | ExploreView | Pesquisa e filtros |
| 4 | ShopDetailView | Detalhe de uma loja |
| 5 | FavoritesView | Lista de favoritos |

**Como tirar:** Xcode → Simulator → File → Take Screenshot (⌘S)

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
