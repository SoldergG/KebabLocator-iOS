# App Store Launch Checklist — Kebab Locator

Bundle ID: `com.lucas.KebabLocator2` | Version: 1.0 | Build: 1

---

## 1. Identifiers, Certificados e Perfis

| Item | Status | Notas |
|------|--------|-------|
| App ID (Bundle Identifier) | ✅ Existe | `com.lucas.KebabLocator2` — confirmar no Developer Portal |
| Distribution Certificate | ⬜ Verificar | Xcode > Settings > Accounts > Manage Certificates |
| Provisioning Profile (App Store Distribution) | ⬜ Verificar | Xcode > Signing & Capabilities > "Automatically manage signing" com team correto |

**Ação:** Xcode → Product → Archive → Validate App (valida signing automaticamente).

---

## 2. Build da App

| Item | Status | Notas |
|------|--------|-------|
| Versão e Build Number | ⚠️ Rever | Info.plist diz `1.0 / build 1`; Xcode project diz `MARKETING_VERSION=2`. Alinhar para `1.0 / build 1` |
| AdMob Test IDs substituídos | ⬜ FAZER | Ver `APP_STORE_METADATA.md` — seção AdMob |
| Build de produção (Archive) | ⬜ Fazer | Xcode → Product → Archive |
| Upload para App Store Connect | ⬜ Fazer | Xcode Organizer → Distribute App → App Store Connect |

**Versão recomendada para 1º lançamento:** `1.0` build `1`

---

## 3. Metadados e Assets (App Store Connect)

| Item | Status | Notas |
|------|--------|-------|
| Nome da app | ⬜ Preencher | "Kebab Locator" (ver metadata) |
| Subtítulo | ⬜ Preencher | Ver metadata |
| Descrição | ⬜ Preencher | Ver `APP_STORE_METADATA.md` |
| Texto Promocional | ⬜ Preencher | Ver metadata |
| Keywords | ⬜ Preencher | Ver metadata |
| URL de Suporte | ⬜ Precisas de URL | Ex: GitHub Issues ou email |
| URL de Privacidade | ⬜ OBRIGATÓRIO | Criar página de privacidade (ver nota abaixo) |
| Screenshots iPhone 6.5" | ⬜ Fazer | 1242×2688px — min 1, ideal 3-5 |
| Ícone 1024×1024 PNG | ⬜ Verificar | Sem transparência, sem arredondamento |
| Copyright | ⬜ Preencher | `© 2026 Lucas` |

---

## 4. Classificação e Compliance

| Item | Status | Notas |
|------|--------|-------|
| Content Rating | ⬜ Preencher | App Store Connect → App Information → App Rating |
| Privacy Nutrition Labels | ⬜ Preencher | Dados recolhidos: Localização (precisão), ID do dispositivo (AdMob/tracking) |
| Exportação de Criptografia | ⬜ Declarar | Responder "Sim, usa HTTPS standard" → exempto (EAR exemption) |
| NSUserTrackingUsageDescription | ✅ Info.plist | Já configurado |
| NSLocationWhenInUseUsageDescription | ✅ Info.plist | Já configurado |

---

## 5. Informações para Revisão da Apple

| Item | Valor |
|------|-------|
| Necessário login? | Não (app pública sem conta obrigatória) |
| Funcionalidades que precisam localização | Pesquisa de kebabs por proximidade |
| Notas para reviewer | Ver `APP_STORE_METADATA.md` → seção Review Notes |

---

## ⚠️ Antes de Submeter — Crítico

1. **Substituir AdMob Test IDs** por IDs reais de produção
2. **Criar Privacy Policy URL** (publicada via GitHub Pages neste repo)
3. **Alinhar versão** entre Info.plist e Xcode project settings
4. **Screenshots** — tirar no simulador iPhone 14 Pro Max (6.7") ou usar Xcode Simulator
