# Week 09 — Advanced UI & Animations

**Project:** SmartFarmerAssistant  
**Branch:** advancedoc  
**Topic:** Making the App Feel Polished and Professional

---

## Learning Objectives

By the end of this week, students will be able to:

- Create custom `ViewModifier`s to centralise repeated styling
- Build reusable components (`FarmCard`, `PrimaryButton`, `SectionHeader`) that enforce visual consistency
- Apply subtle SwiftUI animations — fade-in for lists, scale-press for buttons
- Implement pull-to-refresh with skeleton loading states
- Write dark-mode-safe code using semantic system colours
- Add basic VoiceOver accessibility labels and hints

---

## New Files — `Components/`

| File | Purpose |
|------|---------|
| `ViewModifiers.swift` | 5 modifiers + `View` extension methods |
| `FarmCard.swift` | Generic card container with icon header |
| `PrimaryButton.swift` | 3 button variants (Primary, Secondary, IconAction) |
| `SectionHeader.swift` | Section header + `LoadingRowView` + `EmptyStateView` |

### ViewModifiers

```swift
// Apply consistent card styling
VStack { ... }.farmCard()

// Staggered entrance animation
cardView.fadeIn(delay: 0.2)

// Tactile press feedback on any tappable view
Button { }.scalePress()

// Full-screen loading overlay
content.loadingOverlay(isLoading: viewModel.isLoading)

// Combined VoiceOver label + hint
card.accessibilityCard(label: "P&L Card", hint: "Shows monthly profit and loss")
```

### FarmCard

```swift
FarmCard(title: "ចំណូល / ចំណាយ",
         icon: "dollarsign.circle.fill",
         iconColor: .green) {
    // any SwiftUI content
}
```

### PrimaryButton

```swift
PrimaryButton(title: "បន្ថែម", icon: "plus.circle.fill", color: .green) {
    showAddSheet = true
}

SecondaryButton(title: "បោះបង់", color: .red) { dismiss() }

IconActionButton(icon: "pencil", color: .blue) { editMode = true }
```

### SectionHeader

```swift
SectionHeader(title: "ប្រតិបត្តិការថ្មីៗ",
              icon: "dollarsign.circle.fill",
              color: .green,
              actionTitle: "មើលទាំងអស់",
              action: { selectedTab = 1 })
```

---

## Modified Views

### `DashboardTabView`

| Feature | Implementation |
|---------|---------------|
| Staggered fade-in | `.fadeIn(delay: 0.1 … 0.5)` on each section |
| Pull-to-refresh | `.refreshable { }` on `ScrollView` |
| Dark mode background | `.background(Color(.systemGroupedBackground).ignoresSafeArea())` |
| Accessibility | `.accessibilityLabel` on navigation + P&L card |

### `PestGuideTabView`

| Feature | Implementation |
|---------|---------------|
| Per-row fade-in | `.fadeIn(delay: Double(index) * 0.05)` |
| Skeleton loading | `LoadingRowView()` × 5 when `isLoading` is true |
| Pull-to-refresh | `.refreshable` toggles `isLoading` |
| VoiceOver | `.accessibilityLabel(pest.name ?? "")` per row |

### `FinanceTabView`

| Feature | Implementation |
|---------|---------------|
| Staggered cards | `.fadeIn(delay: 0.1/0.2/0.3)` on `SummaryCard` |
| Pull-to-refresh | `.refreshable` on `FilteredTransactionList` |
| Button animation | `.scalePress()` on toolbar add button |

---

## Animation Patterns

### Staggered List Entrance

```swift
// DashboardTabView — 5 sections, 0.1 s apart
monthlyProfitLossCard    .fadeIn(delay: 0.1)
recentTransactionsSection.fadeIn(delay: 0.2)
upcomingActivitiesSection.fadeIn(delay: 0.3)
latestJournalSection     .fadeIn(delay: 0.4)
quickActionsSection      .fadeIn(delay: 0.5)
```

### Per-Row Fade in Lists

```swift
// PestGuideTabView — each row 0.05 s later
ForEach(Array(displayedPests.enumerated()), id: \.element.objectID) { index, pest in
    NavigationLink(destination: PestDetailView(pest: pest)) {
        PestRowView(pest: pest)
    }
    .fadeIn(delay: Double(index) * 0.05)
}
```

### Skeleton Loading

```swift
if isLoading {
    List { ForEach(0..<5, id: \.self) { _ in LoadingRowView() } }
} else {
    List { /* real content */ }
        .refreshable { isLoading = true; await refresh(); isLoading = false }
}
```

---

## Dark Mode

SwiftUI's semantic colour names automatically adapt to dark mode:

| Name | Light | Dark |
|------|-------|------|
| `Color(.systemBackground)` | White | Dark grey |
| `Color(.systemGroupedBackground)` | Light grey | Near black |
| `Color(.systemGray4)` | Mid grey | Lighter grey |
| `.primary` | Black | White |
| `.secondary` | Grey | Lighter grey |

**Rule:** Use semantic names; avoid hardcoded hex for backgrounds and text.

Test in Simulator: **Features → Toggle Appearance** (`Cmd+Shift+A`)

---

## Accessibility

```swift
// Combine card elements into one VoiceOver stop
.accessibilityElement(children: .combine)
.accessibilityLabel("ចំណេញ / ខាត \(pl.formattedCurrency)")

// Per-row label in lists
.accessibilityLabel(pest.name ?? "")

// Custom modifier for cards
.accessibilityCard(label: "...", hint: "...")
```

**Dynamic Type:** Use `.font(.headline)`, `.font(.caption)` — not fixed `Pt` sizes — so text scales with user settings.

---

## Project Structure

```
Week09/
├── SmartFarmerAssistantFinish/
│   └── SmartFarmerAssistantFinish/
│       ├── Components/                          ← NEW (Week 9)
│       │   ├── ViewModifiers.swift
│       │   ├── FarmCard.swift
│       │   ├── PrimaryButton.swift
│       │   └── SectionHeader.swift
│       ├── Dashboard/Views/DashboardTabView.swift  ← updated
│       ├── Finance/Views/FinanceTabView.swift       ← updated
│       └── PestDisease/Views/PestGuideTabView.swift ← updated
├── generate_slides.py
├── Week09_Advanced_UI_Animations.pptx
└── README.md
```

---

## Slide Deck

`Week09_Advanced_UI_Animations.pptx` — 12 slides covering:

1. Title
2. Agenda
3. Custom ViewModifiers concept
4. FadeIn & ScalePress modifiers (with code)
5. FarmCard generic component
6. PrimaryButton & SectionHeader
7. Slide & list animation patterns
8. Pull-to-refresh & skeleton loading
9. Dark mode colour system
10. Accessibility modifiers
11. Before / After comparison
12. Summary & Week 10 preview

---

## Running the Slide Generator

```bash
pip install python-pptx   # one-time
python3 generate_slides.py
```
