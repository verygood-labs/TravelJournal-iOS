# iOS Session 14: Journal Themes & Preview System

**Status**: 📋 Planning  
**Date Planned**: February 2026  
**Dependencies**: Backend Session 14 (Theme API), Journal Editor (Complete)

---

## Overview

Implement the iOS preview screen with data-driven theming. Users can preview their journal with different visual themes before publishing. The selected theme persists as `draftThemeId` and becomes `themeId` on publish.

### Core Principle

**One set of themed card components** used in both preview (user-selected theme) and public journal view (published theme). Theme data flows from API → ViewModel → Environment → Cards.

```
┌─────────────────────────────────────────────────────────┐
│                   JournalEditorView                     │
│  ┌─────────────────┐    ┌─────────────────────────────┐ │
│  │   Edit Mode     │    │       Preview Mode          │ │
│  │                 │    │                             │ │
│  │ EditorBlockCard │    │  ┌─────────────────────┐   │ │
│  │ EditorBlockCard │    │  │  ThemePickerBar     │   │ │
│  │ EditorBlockCard │    │  └─────────────────────┘   │ │
│  │      ...        │    │  ┌─────────────────────┐   │ │
│  │                 │    │  │ JournalPreviewView  │   │ │
│  │                 │    │  │  ThemedMomentCard   │   │ │
│  │                 │    │  │  ThemedRecCard      │   │ │
│  │                 │    │  │  ThemedPhotoCard    │   │ │
│  │                 │    │  │       ...           │   │ │
│  │                 │    │  └─────────────────────┘   │ │
│  └─────────────────┘    └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## Scope

### In Scope

- [ ] Theme models matching backend DTOs
- [ ] ThemeService for fetching system themes
- [ ] Theme picker UI in preview mode
- [ ] Themed preview cards (Moment, Recommendation, Photo, Tip, Divider)
- [ ] Themed journal header
- [ ] Preview screen layout with theme context
- [ ] Draft theme selection persistence (API call)
- [ ] 3 hardcoded fallback themes (offline support)

### Out of Scope (Future)

- Custom theme creation
- Theme thumbnails from API
- Public journal view (separate feature)
- Theme caching/persistence layer

---

## File Structure

```
TravelJournal-iOS/
├── Models/
│   └── Theme/
│       ├── JournalTheme.swift           # Main theme model
│       ├── ThemeTypography.swift        # Font configuration
│       ├── ThemeColors.swift            # Color palette
│       ├── ThemeStyle.swift             # Global style options
│       ├── ThemeBlocks.swift            # Block-specific styles
│       └── ThemeEnums.swift             # StampStyle, DividerLineStyle, HeaderStyle
│
├── Services/
│   └── ThemeService.swift               # API + fallback themes
│
├── ViewModels/
│   └── JournalEditorViewModel.swift     # Add theme state (modify existing)
│
└── Views/
    └── Editor/
        ├── Preview/
        │   ├── JournalPreviewView.swift        # Main preview container
        │   ├── ThemePickerBar.swift            # Horizontal theme selector
        │   └── ThemedCards/
        │       ├── ThemedJournalHeader.swift   # Trip header with theme
        │       ├── ThemedMomentCard.swift      # Moment block
        │       ├── ThemedRecommendationCard.swift
        │       ├── ThemedPhotoCard.swift
        │       ├── ThemedTipCard.swift
        │       └── ThemedDividerView.swift
        │
        └── JournalEditorView.swift       # Wire up preview mode (modify)
```

---

## Implementation Order

| Order | Task                      | Depends On       | Est. Time |
| ----- | ------------------------- | ---------------- | --------- |
| 1     | Theme Models              | -                | 30 min    |
| 2     | Theme Enums               | -                | 15 min    |
| 3     | ThemeService + Fallbacks  | Models           | 30 min    |
| 4     | ThemedMomentCard          | Models           | 45 min    |
| 5     | ThemedRecommendationCard  | Models           | 45 min    |
| 6     | ThemedPhotoCard           | Models           | 20 min    |
| 7     | ThemedTipCard             | Models           | 20 min    |
| 8     | ThemedDividerView         | Models           | 15 min    |
| 9     | ThemedJournalHeader       | Models           | 30 min    |
| 10    | ThemePickerBar            | Service          | 30 min    |
| 11    | JournalPreviewView        | Cards 4-9        | 45 min    |
| 12    | ViewModel Updates         | Service, Preview | 30 min    |
| 13    | Wire up JournalEditorView | All above        | 20 min    |

**Total Estimated Time**: ~6 hours

---

## Models

### JournalTheme.swift

```swift
struct JournalTheme: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let slug: String
    let description: String?
    let isSystem: Bool
    let typography: ThemeTypography
    let colors: ThemeColors
    let blocks: ThemeBlocks
    let style: ThemeStyle
}
```

### ThemeTypography.swift

```swift
struct ThemeTypography: Codable, Equatable {
    let headingFont: String    // "system-serif", "Playfair Display", etc.
    let bodyFont: String       // "system", "IBM Plex Mono", etc.
    let labelFont: String      // "system", "Special Elite", etc.
}
```

### ThemeColors.swift

```swift
struct ThemeColors: Codable, Equatable {
    let primary: String        // Hex color
    let secondary: String
    let background: String
    let cardBackground: String
    let textPrimary: String
    let textSecondary: String
    let textMuted: String
    let accent: String
    let border: String

    // Convenience computed properties for SwiftUI Color
    var primaryColor: Color { Color(hex: primary) }
    var secondaryColor: Color { Color(hex: secondary) }
    // ... etc
}
```

### ThemeStyle.swift

```swift
struct ThemeStyle: Codable, Equatable {
    let showPaperTexture: Bool
    let showGridLines: Bool
    let cardBorderRadius: Int
    let cardShadow: Bool
    let headerStyle: HeaderStyle
}
```

### ThemeBlocks.swift

```swift
struct ThemeBlocks: Codable, Equatable {
    let moment: MomentBlockStyle
    let recommendation: RecommendationBlockStyle
    let photo: PhotoBlockStyle
    let tip: TipBlockStyle
    let divider: DividerBlockStyle
}

struct MomentBlockStyle: Codable, Equatable {
    let cardBackground: String
    let stampStyle: StampStyle
    let stampColor: String
}

struct RecommendationBlockStyle: Codable, Equatable {
    let cardBackground: String
    let stay: CategoryBadgeStyle
    let eat: CategoryBadgeStyle
    let `do`: CategoryBadgeStyle
    let shop: CategoryBadgeStyle
}

struct CategoryBadgeStyle: Codable, Equatable {
    let background: String
    let text: String
}

struct PhotoBlockStyle: Codable, Equatable {
    let borderColor: String
    let borderRadius: Int
}

struct TipBlockStyle: Codable, Equatable {
    let background: String
    let borderColor: String
    let iconColor: String
}

struct DividerBlockStyle: Codable, Equatable {
    let lineColor: String
    let lineStyle: DividerLineStyle
}
```

### ThemeEnums.swift

```swift
enum StampStyle: String, Codable {
    case rubber
    case minimal
    case vintage
}

enum DividerLineStyle: String, Codable {
    case solid
    case dashed
    case dotted
}

enum HeaderStyle: String, Codable {
    case standard
    case passport
    case minimal
}
```

---

## ThemeService

```swift
actor ThemeService {
    static let shared = ThemeService()

    private var cachedThemes: [JournalTheme]?

    // MARK: - API

    func getSystemThemes() async throws -> [JournalTheme] {
        if let cached = cachedThemes {
            return cached
        }

        do {
            let themes: [JournalTheme] = try await APIClient.shared.get("/api/themes")
            cachedThemes = themes
            return themes
        } catch {
            // Return fallback themes if API fails
            return Self.fallbackThemes
        }
    }

    func setDraftTheme(tripId: UUID, themeId: UUID) async throws {
        try await APIClient.shared.patch(
            "/api/trips/\(tripId)/draft-theme",
            body: ["themeId": themeId.uuidString]
        )
    }

    // MARK: - Fallback Themes

    static let fallbackThemes: [JournalTheme] = [
        .default,
        .passport,
        .retro
    ]
}

// MARK: - Built-in Themes

extension JournalTheme {
    static let `default` = JournalTheme(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        name: "Default",
        slug: "default",
        description: "Clean, minimal design",
        isSystem: true,
        typography: ThemeTypography(
            headingFont: "system-serif",
            bodyFont: "system",
            labelFont: "system"
        ),
        colors: ThemeColors(
            primary: "#1a1a2e",
            secondary: "#c9a227",
            background: "#ffffff",
            cardBackground: "#f8f9fa",
            textPrimary: "#1a1a2e",
            textSecondary: "#666666",
            textMuted: "#888888",
            accent: "#c9a227",
            border: "#e0e0e0"
        ),
        blocks: ThemeBlocks(/* ... */),
        style: ThemeStyle(
            showPaperTexture: false,
            showGridLines: false,
            cardBorderRadius: 12,
            cardShadow: true,
            headerStyle: .standard
        )
    )

    static let passport = JournalTheme(/* ... */)
    static let retro = JournalTheme(/* ... */)
}
```

---

## Theme Environment

Pass theme through SwiftUI environment for clean access in nested views:

```swift
// ThemeEnvironment.swift
private struct JournalThemeKey: EnvironmentKey {
    static let defaultValue: JournalTheme = .default
}

extension EnvironmentValues {
    var journalTheme: JournalTheme {
        get { self[JournalThemeKey.self] }
        set { self[JournalThemeKey.self] = newValue }
    }
}

// Usage in preview
JournalPreviewView(blocks: viewModel.blocks)
    .environment(\.journalTheme, selectedTheme)
```

---

## Key Components

### ThemePickerBar

Horizontal scrolling theme selector at top of preview:

```
┌─────────────────────────────────────────────────────────┐
│  ┌─────────┐  ┌─────────┐  ┌─────────┐                 │
│  │ Default │  │Passport │  │  Retro  │                 │
│  │  ━━━━━  │  │  ━ ━ ━  │  │  .....  │  ←  scroll     │
│  │   ✓     │  │         │  │         │                 │
│  └─────────┘  └─────────┘  └─────────┘                 │
└─────────────────────────────────────────────────────────┘
```

### JournalPreviewView

Main preview container that:

1. Shows ThemePickerBar at top
2. Renders ThemedJournalHeader
3. Maps `EditorBlock` array to themed card components
4. Applies theme via environment

### ThemedMomentCard

Renders moment blocks with theme-driven:

- Card background color
- Stamp style (rubber/minimal/vintage)
- Stamp color
- Typography
- Border radius

---

## ViewModel Changes

Add to `JournalEditorViewModel`:

```swift
// Theme state
@Published var availableThemes: [JournalTheme] = []
@Published var selectedTheme: JournalTheme = .default
@Published var isLoadingThemes = false

// Load themes when entering preview mode
func loadThemes() async {
    isLoadingThemes = true
    do {
        availableThemes = try await ThemeService.shared.getSystemThemes()
        // If trip has draft theme, select it
        if let draftThemeId = trip.draftThemeId,
           let theme = availableThemes.first(where: { $0.id == draftThemeId }) {
            selectedTheme = theme
        }
    } catch {
        availableThemes = ThemeService.fallbackThemes
    }
    isLoadingThemes = false
}

// Save theme selection
func selectTheme(_ theme: JournalTheme) {
    selectedTheme = theme
    Task {
        try? await ThemeService.shared.setDraftTheme(tripId: tripId, themeId: theme.id)
    }
}
```

---

## Testing Approach

### Unit Tests

- [ ] JournalTheme decoding from JSON
- [ ] ThemeColors hex → Color conversion
- [ ] ThemeService fallback behavior

### UI Tests (Manual)

- [ ] Theme picker shows 3 themes
- [ ] Selecting theme updates preview immediately
- [ ] Each card type renders correctly with each theme
- [ ] Paper texture shows/hides based on theme
- [ ] Grid lines show/hide based on theme

### Preview Providers

Each themed card should have SwiftUI previews showing all 3 themes:

```swift
#Preview("Default Theme") {
    ThemedMomentCard(block: .sample)
        .environment(\.journalTheme, .default)
}

#Preview("Passport Theme") {
    ThemedMomentCard(block: .sample)
        .environment(\.journalTheme, .passport)
}

#Preview("Retro Theme") {
    ThemedMomentCard(block: .sample)
        .environment(\.journalTheme, .retro)
}
```

---

## Open Questions

1. **Font loading**: How to handle custom fonts (Playfair Display, Special Elite)?
   - Option A: Bundle fonts in app
   - Option B: Use system font fallbacks initially

2. **Paper texture asset**: Need to create/source paper texture image for Passport theme

3. **Grid line rendering**: Use overlay pattern or actual lines?

4. **Offline behavior**: Show cached themes or fallbacks when offline?

---

## Design References

See mockups in `/docs/`:

- `passport-book-popart.jsx` - Passport theme style
- `siargao-journal.jsx` - Example journal layout
- `journal-01-destinations.jsx` - Journal destination cards

---

## Next Steps

1. Start with Theme Models (Task 1-2)
2. Build ThemeService with hardcoded fallbacks (Task 3)
3. Create ThemedMomentCard as first themed component (Task 4)
4. Iterate on remaining cards
5. Wire up preview screen
