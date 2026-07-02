# 🥗 NutriLog

App de acompanhamento alimentar conectando **clientes** e **nutricionistas**.

**IFSC Campus Tubarão · ADS — Desenvolvimento para Dispositivos Móveis**

**Integrantes:** Haruan Rechia da Silva · Gabriel Gomes de Campos · Raul Nandi De Pieri

---

## Acesso

| Perfil | E-mail | Senha |
|---|---|---|
| Nutricionista (admin) | `nutricionista@gmail.com` | `Nutri123@` |
| Cliente | Cadastre-se no app | Sua senha |

**Requisito de senha:** mínimo 6 caracteres, letra maiúscula, número e caractere especial (ex: `Nutri@2026`)

---

## Como rodar

```bash
flutter pub get
flutter run
```

---

## Funcionalidades

### Cliente
- Splash com restauração automática de sessão (sem travar)
- Login com validação de e-mail e senha
- Cadastro com requisitos de senha em tempo real
- **Home:** boas-vindas, data atual, streak de dias e refeições do dia
  - Toque no `+` de cada refeição pendente → abre o Registrar com tipo pré-selecionado
  - Toque numa refeição já registrada → abre detalhe com comentário do nutricionista
- **Registrar:** câmera ou galeria + tipo de refeição + GPS + descrição
- **Histórico:** refeições agrupadas por dia, com foto miniatura e comentário do nutricionista
- **Perfil:** foto (câmera/galeria), estatísticas (total, streak, dias ativos), logout

### Nutricionista (Admin)
- Dashboard com métricas: total de clientes, refeições hoje, pendentes hoje
- Atividade recente: últimas refeições de todos os clientes em tempo real
- Lista de clientes com busca e indicador de status (ativo hoje / pendente)
- Perfil de cada cliente: histórico completo de refeições
- Detalhe de refeição: foto, dados, campo de feedback/comentário
- Plano alimentar: editor por refeição do dia para cada cliente
- Avisos: log de atividade recente

---

## Estrutura

```
lib/
├── main.dart
├── routes.dart
├── models/
│   ├── usuario_model.dart
│   ├── refeicao_model.dart
│   └── plano_alimentar_model.dart
├── providers/
│   ├── auth_provider.dart
│   ├── refeicao_provider.dart
│   └── nutri_provider.dart
├── services/
│   ├── auth_service.dart
│   └── local_storage_service.dart
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── cadastro_screen.dart
│   ├── home_screen.dart
│   ├── registrar_screen.dart
│   ├── historico_screen.dart
│   ├── perfil_screen.dart
│   └── nutricionista/
│       ├── nutri_scaffold.dart
│       ├── nutri_dashboard_screen.dart
│       ├── nutri_clientes_screen.dart
│       ├── nutri_cliente_perfil_screen.dart
│       ├── nutri_refeicao_detalhe_screen.dart
│       ├── nutri_plano_alimentar_screen.dart
│       ├── nutri_avisos_screen.dart
│       └── nutri_perfil_screen.dart
├── widgets/
│   ├── custom_text_field.dart
│   ├── primary_button.dart
│   ├── meal_card.dart
│   └── senha_requisitos.dart
└── utils/
    └── validadores.dart
```

## Tecnologias

- **Flutter / Dart** · **Provider** (AuthProvider + RefeicaoProvider + NutriProvider)
- **SharedPreferences** — persistência local (sessão + refeições + planos)
- **image_picker** — câmera e galeria · **geolocator** — GPS · **intl** — datas pt_BR

## Permissões Android (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

## Permissões iOS (Info.plist)

```xml
<key>NSCameraUsageDescription</key>
<string>O NutriLog precisa da câmera para fotografar suas refeições.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>O NutriLog acessa a galeria para foto de perfil.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>O NutriLog registra sua localização ao salvar refeições.</string>
```
