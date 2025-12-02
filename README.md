graph TD
    subgraph "Presentation Layer (UI)"
        style Presentation Layer fill:#e3f2fd,stroke:#1565c0,stroke-width:2px
        User((User)) -->|Interacts| View[ChatScreen.dart]
        View -->|Events (Tap, Scroll)| ViewModel[_ChatScreenState]
        ViewModel -->|Updates State| View
    end

    subgraph "Domain Layer (Business Logic)"
        style Domain Layer fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
        ViewModel -->|Calls| ExtractService[FileExtractorService]
        ViewModel -->|Calls| AIService[GeminiService]
        ViewModel -->|Calls| PDFService[ChatPdfService]
    end

    subgraph "Data Layer (External & Storage)"
        style Data Layer fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px
        AIService -->|API Request| GoogleGemini[Google AI API]
        ExtractService -->|File I/O| LocalStorage[Phone Storage]
        ExtractService -->|API Request| Cloudmersive[Cloudmersive API]
        ViewModel -->|Read/Write| Firestore[Firebase Firestore]
    end
