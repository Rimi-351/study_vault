graph TD
    %% --- STYLING (The Colors) ---
    classDef ui fill:#dcfce7,stroke:#166534,stroke-width:2px,color:#14532d;
    classDef logic fill:#dbeafe,stroke:#1e40af,stroke-width:2px,color:#1e3a8a;
    classDef service fill:#f3e8ff,stroke:#6b21a8,stroke-width:2px,color:#581c87;
    classDef data fill:#ffedd5,stroke:#c2410c,stroke-width:2px,color:#7c2d12;

    %% --- NODES & LAYERS ---
    subgraph "UI Layer (View)"
        direction TB
        A[ChatScreen.dart]:::ui
        B[MessageBubble.dart]:::ui
        C[ChatInputArea.dart]:::ui
        D[ChatDrawer.dart]:::ui
    end

    subgraph "Presentation Layer (ViewModel)"
        direction TB
        E[_ChatScreenState]:::logic
        note[("Manages State: _messages, _isTyping")]:::logic
    end

    subgraph "Domain Layer (Business Logic)"
        direction TB
        F[GeminiService]:::service
        G[FileExtractorService]:::service
        H[ChatPdfService]:::service
    end

    subgraph "Data Layer (External)"
        direction TB
        I[Google Gemini API]:::data
        J[Cloudmersive API]:::data
        K[Google ML Kit (OCR)]:::data
        L[Firebase Firestore]:::data
        M[Local File System]:::data
    end

    %% --- CONNECTIONS ---
    A -->|Builds| B
    A -->|Builds| C
    A -->|Builds| D
    
    A -->|User Action| E
    E -->|Updates| A
    E -.- note

    E -->|Requests| F
    E -->|Requests| G
    E -->|Requests| H

    F -->|Http| I
    G -->|Http| J
    G -->|Native| K
    G -->|I/O| M
    E -->|Read/Write| L
