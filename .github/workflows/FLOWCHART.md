# Sync Workflow Flowchart

This document contains flowcharts that visualize the sync process between `fibi-test` and `coi` repositories.

## Main Sync Workflow Flow

```mermaid
flowchart TD
    A[Push to fibi-test] --> B{Path Matches?}
    B -->|No| Z[Workflow Skipped]
    B -->|Yes| C[Checkout Repository]
    
    C --> D[Load Configuration]
    D --> E[Determine Base Commit]
    E --> F{Is Merge Commit?}
    F -->|Yes| G[Use HEAD^1]
    F -->|No| H[Use HEAD~1]
    
    G --> I[Check Changed Files]
    H --> I
    
    I --> J{Changes Detected?}
    J -->|No| Z
    J -->|Yes| K{What Changed?}
    
    K -->|Release CORE| L[Sync Release Folders]
    K -->|Sprint CORE| M[Sync Sprint Folders]
    K -->|ROUTINES YAML| N[Sync Routines from YAML]
    K -->|ROUTINES/BASE/CORE| O[Sync Direct Routines]
    
    L --> P[Clone COI Repository]
    M --> P
    N --> P
    O --> P
    
    P --> Q[Create Feature Branch]
    Q --> R[Copy Files to COI]
    R --> S{Files Changed?}
    
    S -->|No| T[Delete Feature Branch]
    S -->|Yes| U[Commit Changes]
    
    U --> V[Push Feature Branch]
    V --> W[Create Pull Request]
    W --> X[Add Labels]
    X --> Y[PR Ready for Review]
    
    T --> Z
    Y --> Z
    
    style A fill:#e1f5ff
    style Y fill:#d4edda
    style Z fill:#f8d7da
    style J fill:#fff3cd
    style S fill:#fff3cd
```

## Incremental Sync Process Detail

```mermaid
flowchart LR
    A[File Changed] --> B{File Type?}
    
    B -->|Release CORE| C[Find: Fibi-*-Release/BASE/CORE]
    B -->|Sprint CORE| D[Find: Sprint-*/BASE/CORE]
    B -->|ROUTINES YAML| E[Parse YAML for SQL paths]
    B -->|Direct SQL| F[ROUTINES/BASE/CORE/*/]
    
    C --> G[Copy to coi/DB/CORE/Release-Name/]
    D --> H[Copy to coi/DB/CORE/Sprint-Name/]
    E --> I[Find SQL Files]
    F --> J[Determine Type]
    
    I --> J
    J --> K{Type?}
    
    K -->|PROCEDURES| L[Copy to DB/ROUTINES/CORE/PROCEDURES/]
    K -->|FUNCTIONS| M[Copy to DB/ROUTINES/CORE/FUNCTIONS/]
    K -->|VIEWS| N[Copy to DB/ROUTINES/CORE/VIEWS/]
    K -->|TRIGGERS| O[Copy to DB/ROUTINES/CORE/TRIGGERS/]
    
    G --> P[Stage for Commit]
    H --> P
    L --> P
    M --> P
    N --> P
    O --> P
    
    P --> Q[Commit & Push]
    Q --> R[Create PR]
    
    style A fill:#e1f5ff
    style R fill:#d4edda
    style K fill:#fff3cd
```

## Full Sync Process Flow

```mermaid
flowchart TD
    A[Manual Trigger: Full Sync] --> B[Load Configuration]
    B --> C[Clone COI Repository]
    
    C --> D[Checkout Main Branch]
    D --> E[Create Feature Branch]
    
    E --> F[Find All Release Folders]
    F --> G[Find All Sprint Folders]
    G --> H[Find All Routines YAML]
    H --> I[Find All Direct SQL Files]
    
    G --> J[Sync Release CORE Files]
    F --> J
    
    J --> K[Sync Sprint CORE Files]
    K --> L[Sync Routines from YAML]
    L --> M[Sync Direct Routines]
    
    M --> N[Update YAML Paths in COI]
    N --> O{Any Changes?}
    
    O -->|No| P[Delete Feature Branch]
    O -->|Yes| Q[Stage Changes]
    
    Q --> R[Commit Changes]
    R --> S[Push Feature Branch]
    S --> T[Create Pull Request]
    T --> U[Add Full-Sync Labels]
    
    P --> V[End]
    U --> V
    
    style A fill:#e1f5ff
    style T fill:#d4edda
    style V fill:#f8d7da
    style O fill:#fff3cd
```

## Pull Request Creation Flow

```mermaid
flowchart TD
    A[Changes Committed] --> B[Push Feature Branch]
    B --> C{Branch Pushed?}
    
    C -->|Failed| D[Error & Exit]
    C -->|Success| E[Build PR Title]
    
    E --> F[Build PR Body]
    F --> G[Escape JSON]
    G --> H[Call GitHub API]
    
    H --> I{HTTP Response?}
    
    I -->|201/200| J[Extract PR URL]
    I -->|422| K[Check Existing PR]
    I -->|Other| L[Log Error]
    
    J --> M[Extract PR Number]
    M --> N[Add Labels via API]
    N --> O[PR Created Successfully]
    
    K --> P{PR Exists?}
    P -->|Yes| Q[Link to Existing PR]
    P -->|No| R[Log Manual Creation Link]
    
    L --> R
    R --> S[End with Warning]
    O --> T[End Successfully]
    Q --> T
    
    style A fill:#e1f5ff
    style O fill:#d4edda
    style T fill:#d4edda
    style D fill:#f8d7da
    style S fill:#fff3cd
    style I fill:#fff3cd
```

## Change Detection Logic

```mermaid
flowchart TD
    A[Get Changed Files] --> B[Filter by Path Patterns]
    
    B --> C{Contains Release?}
    B --> D{Contains Sprint?}
    B --> E{Contains ROUTINES YAML?}
    B --> F{Contains ROUTINES/BASE/CORE?}
    
    C -->|Yes| G[Set release_changed=true]
    D -->|Yes| H[Set sprint_changed=true]
    E -->|Yes| I[Set routines_yaml_changed=true]
    F -->|Yes| J[Set routines_base_core_changed=true]
    
    G --> K{Any Changes?}
    H --> K
    I --> K
    J --> K
    
    K -->|Yes| L[Set changed=true]
    K -->|No| M[Set changed=false]
    
    L --> N[Proceed with Sync]
    M --> O[Skip Workflow]
    
    style A fill:#e1f5ff
    style N fill:#d4edda
    style O fill:#f8d7da
    style K fill:#fff3cd
```

## Configuration Loading Flow

```mermaid
flowchart TD
    A[Script Starts] --> B[Source load-config.sh]
    B --> C{Config File Exists?}
    
    C -->|No| D[Use Default Values]
    C -->|Yes| E[Parse YAML Config]
    
    E --> F[Extract Repository Names]
    F --> G[Extract Branch Settings]
    G --> H[Extract Path Settings]
    H --> I[Extract Git Settings]
    
    I --> J[Export Variables]
    D --> J
    
    J --> K[Config Variables Available]
    K --> L[Script Continues]
    
    style A fill:#e1f5ff
    style K fill:#d4edda
    style L fill:#d4edda
    style D fill:#fff3cd
```

## Branch Naming Convention

```mermaid
flowchart LR
    A[Source Branch] --> B[Clean Branch Name]
    B --> C[Get Timestamp]
    C --> D{Sync Type?}
    
    D -->|Incremental| E[Category: core-sync]
    D -->|Full Sync| F[Category: full-core-sync]
    
    E --> G[Format: Fibi-Dev/core-sync/{branch}-{timestamp}]
    F --> H[Format: Fibi-Dev/full-core-sync/{branch}-{timestamp}]
    
    G --> I[Truncate to Max Length]
    H --> I
    I --> J[Feature Branch Created]
    
    style A fill:#e1f5ff
    style J fill:#d4edda
    style D fill:#fff3cd
```

## File Sync Decision Tree

```mermaid
flowchart TD
    A[File Detected] --> B{Location?}
    
    B -->|Release Folder| C[Fibi-*-Release/BASE/CORE]
    B -->|Sprint Folder| D[Sprint-*/BASE/CORE]
    B -->|ROUTINES YAML| E[**/BASE/CORE/*.yaml]
    B -->|Direct SQL| F[ROUTINES/BASE/CORE/*/*.sql]
    
    C --> G{File Type?}
    D --> G
    
    G -->|YAML| H[Copy to DB/CORE/{Folder}/]
    G -->|SQL| I[Extract from YAML Path]
    
    E --> J[Parse YAML]
    J --> K[Find SQL Files]
    K --> I
    
    F --> L{Determine Routine Type}
    I --> L
    
    L --> M{Type?}
    M -->|PROCEDURES| N[DB/ROUTINES/CORE/PROCEDURES/]
    M -->|FUNCTIONS| O[DB/ROUTINES/CORE/FUNCTIONS/]
    M -->|VIEWS| P[DB/ROUTINES/CORE/VIEWS/]
    M -->|TRIGGERS| Q[DB/ROUTINES/CORE/TRIGGERS/]
    
    H --> R[Destination]
    N --> R
    O --> R
    P --> R
    Q --> R
    
    R --> S[Copy File]
    S --> T[Stage for Commit]
    
    style A fill:#e1f5ff
    style T fill:#d4edda
    style M fill:#fff3cd
    style L fill:#fff3cd
```

## Complete End-to-End Flow

```mermaid
flowchart TB
    subgraph "Source Repository (fibi-test)"
        A1[Developer Commits] --> A2[Push to Repository]
    end
    
    subgraph "GitHub Actions Workflow"
        A2 --> B1[Workflow Triggered]
        B1 --> B2[Checkout Source]
        B2 --> B3[Load Configuration]
        B3 --> B4[Detect Changes]
        B4 --> B5{Changes Found?}
        B5 -->|No| END1[Skip]
        B5 -->|Yes| B6[Clone Destination]
    end
    
    subgraph "Sync Process"
        B6 --> C1[Create Feature Branch]
        C1 --> C2[Sync CORE Files]
        C2 --> C3[Sync ROUTINES Files]
        C3 --> C4[Stage Changes]
        C4 --> C5{Has Changes?}
        C5 -->|No| END2[Cleanup & Exit]
        C5 -->|Yes| C6[Commit Changes]
    end
    
    subgraph "PR Creation"
        C6 --> D1[Push Feature Branch]
        D1 --> D2[Create PR via API]
        D2 --> D3[Add Labels]
        D3 --> D4[PR Created]
    end
    
    subgraph "Destination Repository (coi)"
        D4 --> E1[PR Ready for Review]
        E1 --> E2[Team Reviews]
        E2 --> E3{Approved?}
        E3 -->|Yes| E4[Merge to Main]
        E3 -->|No| E5[Request Changes]
        E4 --> E6[Auto-Delete Branch]
        E5 --> E7[Update PR]
    end
    
    END1 --> FINAL[Process Complete]
    END2 --> FINAL
    E6 --> FINAL
    E7 --> E1
    
    style A1 fill:#e1f5ff
    style D4 fill:#d4edda
    style E4 fill:#d4edda
    style FINAL fill:#d4edda
    style B5 fill:#fff3cd
    style C5 fill:#fff3cd
    style E3 fill:#fff3cd
```

## Notes

- All flowcharts are created using Mermaid syntax
- These diagrams can be viewed in:
  - GitHub (renders automatically)
  - VS Code with Mermaid extension
  - Online Mermaid editors (mermaid.live)
  - Documentation sites (GitBook, etc.)

## Key Decision Points

1. **Path Matching**: Only files matching specific patterns trigger the workflow
2. **Change Detection**: Compares against base commit (handles merge commits)
3. **File Type Classification**: Routes files to correct destination based on type
4. **PR Creation**: Handles success, failure, and existing PR scenarios
5. **Branch Management**: Follows naming convention and auto-deletes after merge

