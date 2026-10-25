# StudyVault 🎓

> **Your intelligent AI study companion** — extract text from multi-format study materials, generate structured quizzes and summaries with Google Gemini, and engage in interactive, context-aware AI learning sessions.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Google Gemini](https://img.shields.io/badge/Google%20Gemini-8E75C2?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

---

## 📖 Overview

**StudyVault** is a modern cross-platform Flutter application engineered for students and educators. It streamlines studying by transforming raw textbooks, lecture slides, notes, and photos into actionable learning materials. Using advanced generative AI powered by **Google Gemini** and hybrid document parsing, StudyVault allows users to extract content, ask questions about specific documents, generate comprehensive multiple-choice questions (MCQs), and export shareable study summaries as PDFs.

---

## ✨ Key Features

- **🔐 Seamless Authentication**
  - Instant guest/anonymous sign-in powered by **Firebase Authentication** for immediate onboarding without registration barriers.
- **📄 Multi-Format Text Extraction**
  - **PDF Documents:** Local high-fidelity text extraction via Syncfusion PDF.
  - **Images & Photos:** On-device Optical Character Recognition (OCR) using **Google ML Kit Text Recognition** (supports `.jpg`, `.jpeg`, `.png`).
  - **Office Documents:** Cloud-based autodetect conversion for Word (`.doc`, `.docx`), PowerPoint (`.ppt`, `.pptx`), and Excel (`.xls`, `.xlsx`) via the **Cloudmersive API**.
  - **Plain Text / CSV:** Direct local decoding for quick ingestion.
- **🧠 AI Study Material Generator**
  - Generate 30+ high-quality Multiple Choice Questions (MCQs) complete with options, correct answers, and conceptual explanations.
  - Generates concise bullet-point study summaries from dense documents.
  - Exports generated question sets and notes directly to formatted **PDFs** ready to print or share via WhatsApp/email.
- **💬 Context-Aware AI Chatbot**
  - Conversational study assistant powered by **Google Gemini (`gemini-2.5-pro`)**.
  - Attach documents directly to chat queries so the AI references your specific course syllabus or readings.
  - Code syntax highlighting and rich Markdown rendering for technical subjects.
  - Full chat history synchronized with **Cloud Firestore** and exportable to PDF.

---

## 🏗️ Architecture & Tech Stack

StudyVault follows a **feature-first** modular architecture designed for maintainability, testability, and clean separation of concerns:

```
lib/
├── features/
│   ├── auth/                  # Authentication & splash screens
│   │   └── presentation/      # LoginScreen, SplashScreen
│   ├── chat/                  # Interactive AI chat module
│   │   ├── presentation/      # ChatScreen, MessageBubbles, CodeBlockBuilder
│   │   └── services/          # ChatPdfService (PDF export)
│   ├── generate/              # MCQ & study material generator
│   │   └── presentation/      # GenerateScreen (file picker, generation UI)
│   └── home/                  # Central dashboard navigation
│       └── presentation/      # HomeScreen
├── shared/
│   ├── models/                # Core domain models (FileModel, Message)
│   └── services/              # Core business services
│       ├── file_extractor_service.dart   # Hybrid local/cloud file parser
│       └── gemini_service.dart           # Google Gemini generative AI client
├── firebase_options.dart      # FlutterFire client configuration
└── main.dart                  # Application entry point & provider scopes
```

### Core Technologies

| Category | Technology / Package | Purpose |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (Dart SDK `>=3.4.0 <4.0.0`) | Cross-platform UI toolkit |
| **State Management** | `flutter_riverpod: ^2.6.1` | Reactive, testable application state |
| **Backend & Auth** | `firebase_core`, `firebase_auth`, `cloud_firestore` | Authentication & persistent study history |
| **Generative AI** | `google_generative_ai: ^0.4.6` | Google Gemini Pro integration |
| **OCR & Vision** | `google_mlkit_text_recognition: ^0.13.0` | On-device image text extraction |
| **Document Processing** | `syncfusion_flutter_pdf: ^27.2.5`, `http: ^1.2.0` | Local PDF parsing & Cloudmersive Office API |
| **PDF Generation & Share** | `pdf: ^3.11.1`, `printing: ^5.13.1`, `share_plus: ^10.1.4` | Document styling, PDF export, and OS share sheet |
| **Markdown Rendering** | `flutter_markdown: ^0.7.1`, `flutter_highlighter` | Styled chat bubbles and code syntax blocks |

---

## 📋 Prerequisites

Before setting up the project, ensure you have the following:

1. **Flutter SDK** (Version `>= 3.4.0`) — [Install Flutter](https://docs.flutter.dev/get-started/install)
2. **Dart SDK** (Bundled with Flutter)
3. **Android Studio** or **VS Code** with Flutter & Dart extensions installed
4. **Firebase Account** — [Firebase Console](https://console.firebase.google.com/)
5. **API Keys**:
   - **Google Gemini API Key:** Obtain from [Google AI Studio](https://aistudio.google.com/)
   - **Cloudmersive API Key:** Obtain from [Cloudmersive Management Portal](https://account.cloudmersive.com/keys)

---

## 🔐 Environment Configuration

StudyVault uses **Flutter's native compile-time environment injection** (`--dart-define-from-file=.env`).

> [!IMPORTANT]
> **Why native compile-time configuration?**  
> Unlike traditional setups that register `.env` as a Flutter asset in `pubspec.yaml` (which packages your secrets inside the compiled APK in plaintext), StudyVault injects environment variables at compile-time. `.env` is **never bundled as an asset** and is excluded from Git tracking.

### Step 1: Create your local `.env` file

Copy the provided template to create your local `.env` file:

```bash
cp .env.example .env
```

*(On Windows PowerShell: `Copy-Item .env.example .env`)*

### Step 2: Populate your credentials

Open `.env` and paste your active API keys:

```env
# Local Environment Configuration (Never commit to Git!)
GEMINI_API_KEY=AIzaSyYourGeminiApiKeyHere
CLOUDMERSIVE_API_KEY=your-cloudmersive-uuid-key-here
```

---

## 🚀 Running & Building the App

### Running via CLI

Always provide the `--dart-define-from-file=.env` flag when launching the app:

```powershell
# Run in debug mode on connected device / emulator
flutter run --dart-define-from-file=.env

# Run in profile mode
flutter run --profile --dart-define-from-file=.env

# Run in release mode
flutter run --release --dart-define-from-file=.env
```

### Running via Visual Studio Code (`F5`)

Pre-configured debug targets are included in [`.vscode/launch.json`](.vscode/launch.json).

1. Open the project folder in **VS Code**.
2. Press `Ctrl + Shift + D` (or `Cmd + Shift + D` on macOS) to open the **Run & Debug** tab.
3. Select **"StudyVault (Debug with .env)"** from the dropdown.
4. Press **`F5`** to launch the app with environment variables automatically applied.

### Building Release Artifacts

```powershell
# Build Android APK
flutter build apk --release --dart-define-from-file=.env

# Build Android App Bundle (for Google Play Store)
flutter build appbundle --release --dart-define-from-file=.env

# Build Web release
flutter build web --release --dart-define-from-file=.env
```

---

## 🧪 Testing & Code Quality

The project includes unit, widget, and automated security environment regression tests.

```powershell
# 1. Run static analysis (verifies types, deprecations, and lint rules)
flutter analyze --no-pub

# 2. Run the complete test suite
flutter test --no-pub
```

### Security Test Coverage

The test suite in [`test/security_env_test.dart`](test/security_env_test.dart) validates security requirements:
- Asserts that `GeminiService` safely throws a `StateError` when `GEMINI_API_KEY` is missing or empty.
- Verifies that error messages and stack traces **never leak or print secret values**.
- Validates fail-safe configuration handling in `FileExtractorService`.

---

## 🛡️ Security Architecture & Best Practices

1. **Git Protection:**
   - [`.gitignore`](.gitignore) is preconfigured to exclude `.env`, `.env.*`, `secrets.*`, Android keystores (`*.keystore`, `*.jks`, `key.properties`), local machine configs (`local.properties`), and backup directories.
   - [`.env.example`](.env.example) is explicitly whitelisted to serve as a safe placeholder template for other contributors.

2. **Firebase Client Configuration:**
   - [`lib/firebase_options.dart`](lib/firebase_options.dart) and [`android/app/google-services.json`](android/app/google-services.json) contain public client identifiers (`AIzaSy...`), which route mobile network traffic to your Firebase project.
   - **Database Security:** Cloud Firestore security does not rely on hiding client keys; it relies on **Cloud Firestore Security Rules**. Ensure your Firestore rules require user authentication (`request.auth != null`) before deploying to production.
   - **API Restrictions:** Configure API restrictions in the [Google Cloud Console](https://console.cloud.google.com/apis/credentials) to restrict client keys strictly to Firebase Auth, Firestore, and Storage.

3. **Production Deployment Advisory:**
   - In production releases, calling third-party generative AI and document conversion endpoints directly from client devices with privileged personal API keys introduces quota exhaustion risks if the client binary is decompiled.
   - For commercial production, it is recommended to route Gemini and Cloudmersive operations through a backend API gateway or **Firebase Cloud Functions**, keeping proprietary credentials stored securely in **Google Cloud Secret Manager**.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Ensure all tests and static analysis pass (`flutter analyze && flutter test`).
5. Push to the branch (`git push origin feature/AmazingFeature`).
6. Open a Pull Request.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
