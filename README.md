graph TD
    subgraph "UI Layer (View)"
        style UI fill:#e8f5e9,stroke:#43a047,stroke-width:2px
        A[ChatScreen.dart] --> B[MessageBubble.dart]
        A --> C[ChatInputArea.dart]
        A --> D[ChatDrawer.dart]
    end

    subgraph "Presentation Layer (Logic)"
        style Logic fill:#e3f2fd,stroke:#1e88e5,stroke-width:2px
        A -- "User Input" --> E[_ChatScreenState]
        E -- "Updates UI" --> A
        E[Controller Logic] 
    end

    subgraph "Data Layer (Services)"
        style Data fill:#f3e5f5,stroke:#8e24aa,stroke-width:2px
        E -- "Calls" --> F[GeminiService]
        E -- "Calls" --> G[FileExtractorService]
        E -- "Calls" --> H[ChatPdfService]
        E -- "Save/Load" --> I[ChatRepository]
    end

    subgraph "External Sources"
        style Ext fill:#fff3e0,stroke:#fb8c00,stroke-width:2px
        F -- "API" --> J[Google Gemini AI]
        G -- "API" --> K[Cloudmersive / ML Kit]
        I -- "Cloud" --> L[Firebase Firestore]
        H -- "Local" --> M[File System / PDF]
    end
