# 🥗 NutriLog

Aplicativo de acompanhamento alimentar que conecta **clientes** e **nutricionistas**. O cliente registra suas refeições do dia a dia (com foto, descrição, horário e localização via GPS), e o nutricionista acompanha esses registros em tempo real, comenta e monta planos alimentares personalizados.

Projeto desenvolvido como trabalho final da disciplina de **Desenvolvimento para Dispositivos Móveis**, do curso de Análise e Desenvolvimento de Sistemas — **IFSC Campus Tubarão**.

## Integrantes

- Haruan Rechia da Silva
- Gabriel Gomes de Campos
- Raul Nandi De Pieri

## Tecnologias utilizadas

- **Flutter / Dart** — framework principal, multiplataforma (Android/iOS)
- **Provider** — gerenciamento de estado (AuthProvider + RefeicaoProvider)
- **Firebase Authentication** — autenticação de usuários (e-mail/senha)
- **Cloud Firestore** — banco de dados em tempo real
- **Firebase Storage** — armazenamento das fotos das refeições
- **SharedPreferences** — persistência local (sessão e refeições sem Firebase)
- **image_picker** — acesso à câmera e galeria do dispositivo
- **geolocator** — GPS para captura automática da localização nas refeições
- **intl** — formatação de data em português (pt_BR)

## Estrutura do projeto

```
lib/
├── main.dart                    # Ponto de entrada, inicializa Providers
├── routes.dart                  # Rotas nomeadas centralizadas (AppRoutes)
├── models/
│   ├── usuario_model.dart       # Modelo do usuário (cliente/nutricionista)
│   └── refeicao_model.dart      # Modelo de refeição + enum TipoRefeicao
├── providers/
│   ├── auth_provider.dart       # Estado de autenticação (sessão, login, logout)
│   └── refeicao_provider.dart   # Estado das refeições (streak, filtros por dia)
├── services/
│   ├── auth_service.dart        # Firebase Auth + fallback local
│   └── local_storage_service.dart  # SharedPreferences (sessão + refeições)
├── screens/
│   ├── splash_screen.dart       # Tela de abertura com restauração de sessão
│   ├── login_screen.dart        # Login com validação de e-mail e senha
│   ├── cadastro_screen.dart     # Cadastro com requisitos de senha em tempo real
│   ├── home_screen.dart         # Home: boas-vindas, data, refeições do dia
│   ├── registrar_screen.dart    # Registro: câmera, tipo, descrição, GPS
│   ├── historico_screen.dart    # Histórico agrupado por dia com miniaturas
│   └── perfil_screen.dart       # Perfil: foto, estatísticas, dados, logout
├── widgets/
│   ├── custom_text_field.dart   # Campo de texto com suporte a Form/validator
│   ├── primary_button.dart      # Botão principal com estado de loading
│   ├── meal_card.dart           # Card de refeição reutilizável
│   └── senha_requisitos.dart    # Indicador visual dos requisitos de senha
└── utils/
    └── validadores.dart         # Validações: e-mail, senha, nome, confirmação
```

## Validação de senha

A senha deve atender todos os requisitos abaixo (exibidos em tempo real na tela de cadastro):

- ✅ Mínimo 6 caracteres
- ✅ Pelo menos uma letra maiúscula
- ✅ Pelo menos um número
- ✅ Pelo menos um caractere especial (ex: `@`, `!`, `#`, `$`)

Exemplo de senha válida: `Nutri@2026`

## Requisitos do professor atendidos

| Requisito | Como é atendido |
|---|---|
| Telas e navegação com rotas nomeadas | 7 rotas nomeadas em `AppRoutes`: splash, login, cadastro, home, registrar, historico, perfil |
| Gerenciamento de estado | `AuthProvider` (sessão) + `RefeicaoProvider` (refeições) com Provider |
| Autenticação | Firebase Auth com e-mail/senha + fallback local via SharedPreferences |
| Armazenamento de dados | Cloud Firestore (estruturado) + SharedPreferences (local) + Firebase Storage (fotos) |
| Uso de sensor (câmera) | `image_picker` na tela de registro para fotografar refeições |
| Uso de sensor (GPS) | `geolocator` captura automaticamente a localização ao registrar |
| Widgets próprios | `CustomTextField`, `PrimaryButton`, `MealCard`, `SenhaRequisitos` |
| Organização do projeto | Separação em screens, widgets, models, providers, services, utils |
| Criatividade e extensão | Painel de streak, requisitos de senha em tempo real, fallback offline |

## Como rodar o projeto

### 1. Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado
- VS Code com extensão Flutter instalada

### 2. Clonar e instalar dependências

```bash
git clone <url-do-repositorio>
cd nutrilog
flutter pub get
```

### 3. Rodar sem Firebase (modo desenvolvimento)

O app funciona imediatamente sem configurar o Firebase, usando armazenamento local:

```bash
flutter run
```

Os dados (usuários e refeições) serão salvos no dispositivo via SharedPreferences.

### 4. Ativar Firebase (produção)

1. Instale o FlutterFire CLI: `dart pub global activate flutterfire_cli`
2. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
3. Ative **Authentication → E-mail/senha** e **Cloud Firestore**
4. Na raiz do projeto: `flutterfire configure`
5. Descomente as linhas do Firebase em `lib/main.dart`

### 5. Permissões Android

No arquivo `android/app/src/main/AndroidManifest.xml`, adicione:

```xml
<!-- Câmera -->
<uses-permission android:name="android.permission.CAMERA" />
<!-- GPS -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### 6. Permissões iOS

No arquivo `ios/Runner/Info.plist`, adicione:

```xml
<key>NSCameraUsageDescription</key>
<string>O NutriLog precisa da câmera para fotografar suas refeições.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>O NutriLog acessa a galeria para que você escolha uma foto de perfil.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>O NutriLog usa sua localização para registrar onde cada refeição foi feita.</string>
```

## Status do desenvolvimento

- [x] Splash screen com restauração automática de sessão
- [x] Tela de Login com validação de e-mail e senha
- [x] Tela de Cadastro com requisitos de senha em tempo real
- [x] Tela Home com boas-vindas, data, refeições do dia e streak
- [x] Barra de navegação inferior fixa com 4 botões
- [x] Tela de Registro com câmera, seleção de tipo, GPS e descrição
- [x] Tela de Histórico agrupado por dia com miniatura das fotos
- [x] Tela de Perfil com foto de perfil, estatísticas e logout
- [x] Armazenamento local via SharedPreferences (sem Firebase)
- [x] Firebase Auth + Firestore (com fallback local)
- [ ] Painel do nutricionista (próxima etapa)
- [ ] Comentários do nutricionista nas refeições
- [ ] Editor de Plano Alimentar
- [ ] Notificações em tempo real

## Etapas de entrega

| Etapa | Data | Status |
|---|---|---|
| 1ª etapa | 18/06/2026 | ✅ Concluída — ideia, protótipo e repositório |
| 2ª etapa | 25/06/2026 | ✅ Concluída — login, cadastro, home, histórico, perfil, câmera e GPS |
| 3ª etapa (final) | 02/07/2026 | 🔄 Em andamento |
