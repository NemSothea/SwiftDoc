# 🗓️ Complete 12-Week Intermediate Course Outline

> **Minimum Deployment Target: iOS 13+** — All APIs and frameworks used in this course are compatible with iOS 13 and above.

### Phase 1: Foundation & Architecture (Weeks 1-3)

#### Week 1: Project Setup & MVVM Architecture
- **Topic:** Laying the foundation with clean architecture
- **Lesson Breakdown:**
    - Setting up the Xcode project with proper folder structure and iOS 13+ deployment target
    - Introduction to MVVM with `ObservableObject` and `@Published` properties (iOS 13+)
    - Creating the core data models: `Transaction`, `FarmActivity`, `Pest`, `JournalEntry`
    - Building a `FarmManager` (main view model) to coordinate all features
    - **Live Coding:** Create all data models and the main `FarmViewModel` class using `ObservableObject`
- **Mini-Project:**
    - Set up the project with folders: `Models`, `ViewModels`, `Views`, `Utilities`
    - Implement the `FarmViewModel` with `@Published` arrays for each data type
    - Create a main tab view with placeholders for 4 tabs (Finance, Calendar, Guide, Journal)

#### Week 2: CoreData Persistence
- **Topic:** Saving data permanently with CoreData (iOS 13+)
- **Lesson Breakdown:**
    - Setting up the `.xcdatamodeld` schema for all four models
    - Configuring `NSPersistentContainer` and `NSManagedObjectContext`
    - Using `@FetchRequest` for automatic UI updates
    - Basic CRUD operations (Create, Read, Update, Delete) with CoreData
    - **Live Coding:** Implement all four CoreData entities, test saving and fetching
- **Mini-Project:**
    - Complete CoreData implementation for all models
    - Add sample data on first launch using a seed method
    - Verify data persists after app restart

#### Week 3: Navigation & Tab Coordination
- **Topic:** Building a professional navigation system
- **Lesson Breakdown:**
    - `NavigationView` and `NavigationLink` for each tab (iOS 13+)
    - Creating a `NavigationCoordinator` using `@State` and `@Binding` to manage navigation state
    - Passing data between screens (e.g., from list to detail)
    - Deep linking simulation: Opening to a specific transaction via `NavigationLink` tag/selection
    - **Live Coding:** Build a navigation system where each tab has independent navigation state
- **Mini-Project:**
    - Implement a `NavigationCoordinator` for the Finance tab
    - Create list → detail navigation for transactions
    - Add "Edit" functionality with proper navigation

---

### Phase 2: Core Features (Weeks 4-7)

#### Week 4: Finance Tracker Module (Project 1)
- **Topic:** Building the expense and income tracking system
- **Lesson Breakdown:**
    - Creating the transaction list with filtering (expense/income/all)
    - Building an "Add Transaction" form with category picker
    - Implementing real-time calculations (total expenses, income, profit)
    - Formatting currency for local users (Riel and Dollar support)
    - **Live Coding:** Build the complete Finance tab with add/edit/delete
- **Mini-Project:**
    - Complete Finance tab with all CRUD operations
    - Add a summary card showing current balance, total expenses, total income
    - Implement category filtering (Seeds, Fertilizer, Labor, Tools, Sales)

#### Week 5: Calendar & Reminders Module (Project 2)
- **Topic:** Scheduling activities with local notifications
- **Lesson Breakdown:**
    - Building a calendar view with `DatePicker` and custom grid
    - Creating the `FarmActivity` model with date, type, notes
    - Requesting notification permissions
    - Scheduling local notifications with `UNUserNotificationCenter`
    - Handling notification tap to open specific activity
    - **Live Coding:** Build the Calendar tab with activity list and "Add Reminder" screen
- **Mini-Project:**
    - Complete the Calendar tab with activity CRUD
    - Schedule notifications for each activity (1 day before, on the day)
    - Test notifications work when app is closed

#### Week 6: Pest & Disease Guide Module (Project 3)
- **Topic:** Building an offline reference library
- **Lesson Breakdown:**
    - Designing the `Pest` CoreData entity with name, symptoms, treatment, image name
    - Creating a searchable list with a custom `TextField` search bar (iOS 13+, no `.searchable` dependency)
    - Implementing detail view with expandable sections using `@State` toggles
    - Pre-loading data from a bundled JSON file on first launch
    - Making it work completely offline
    - **Live Coding:** Build the Pest Guide tab with search and category filtering
- **Mini-Project:**
    - Create a JSON file with at least 10 pests/diseases
    - Load this data into CoreData on first launch
    - Implement search and category tabs (Insects, Fungal, Bacterial)

#### Week 7: Daily Journal Module (Project 4)
- **Topic:** Digital notebook with rich text and weather
- **Lesson Breakdown:**
    - Building the `JournalEntry` CoreData entity with date, content, weather, photos
    - Creating a timeline view of entries (reverse chronological)
    - Implementing weather selection (Sunny, Rainy, Cloudy, Windy)
    - Adding photos from library using `UIImagePickerController` wrapped in `UIViewControllerRepresentable` (iOS 13+)
    - Search and filter by date/weather using a custom `TextField` search bar
    - **Live Coding:** Build the Journal tab with entry list and add/edit screen
- **Mini-Project:**
    - Complete Journal tab with photo attachment
    - Implement weather picker with SF Symbols
    - Add search functionality to find entries by text

---

### Phase 3: Integration & Polish (Weeks 8-10)

#### Week 8: Dashboard & Cross-Module Integration
- **Topic:** Creating a unified home screen showing all data
- **Lesson Breakdown:**
    - Building a dashboard tab with summary cards
    - Showing recent transactions, upcoming activities, latest journal entry
    - Displaying total profit/loss for current month
    - Creating "Quick Actions" buttons for common tasks
    - **Live Coding:** Build a dashboard that pulls data from all four modules
- **Mini-Project:**
    - Create a Home tab with 4-6 summary cards
    - Add navigation from each card to the relevant tab
    - Show upcoming reminders for the next 7 days

#### Week 9: Advanced UI & Animations
- **Topic:** Making the app feel polished and professional
- **Lesson Breakdown:**
    - Creating custom `ViewModifier`s for consistent styling
    - Building reusable components: `FarmCard`, `PrimaryButton`, `SectionHeader`
    - Adding subtle animations: fade-in for lists, scale for buttons
    - Implementing pull-to-refresh and loading states
    - Dark mode support and accessibility
    - **Live Coding:** Refactor the app with a design system and add animations
- **Mini-Project:**
    - Create a design system file with colors, fonts, spacing
    - Build 3 reusable components and replace throughout app
    - Add at least 3 animations (list appearance, button taps, transitions)

#### Week 10: Data Export & Reports
- **Topic:** Generating useful reports for farmers
- **Lesson Breakdown:**
    - Creating monthly profit/loss reports with custom bar charts built using `GeometryReader` and `Shape` (iOS 13+, no Swift Charts dependency)
    - Exporting data as CSV or PDF for sharing
    - Implementing `UIActivityViewController` for sharing reports (iOS 13+)
    - Building a simple PDF generator with `PDFKit` (iOS 11+)
    - **Live Coding:** Add a Reports section to Finance tab with charts and export
- **Mini-Project:**
    - Create a monthly profit bar chart using `GeometryReader` and `Rectangle` shapes
    - Add "Share Report" button that exports CSV
    - Generate a simple PDF summary of the month

---

### Phase 4: Distribution & Completion (Weeks 11-12)

#### Week 11: Backup & Restore(Skip this lesson)
- **Topic:** Helping farmers never lose their valuable data
- **Lesson Breakdown:**
    - Understanding the importance of data backup for farmers
    - Implementing export/import of all CoreData records to JSON
    - Using `UIDocumentPickerViewController` wrapped in `UIViewControllerRepresentable` to save/load backup files (iOS 13+)
    - Adding automatic reminder to backup weekly
    - Cloud backup basics (iCloud Drive integration)
    - **Live Coding:** Build a Backup & Restore section in Settings
- **Mini-Project:**
    - Complete backup feature that exports all CoreData records to JSON
    - Implement restore that clears and re-imports from backup file
    - Test backup/restore across multiple devices

#### Week 12: Final Polish & TestFlight Distribution
- **Topic:** Preparing for real farmer testing
- **Lesson Breakdown:**
    - Adding app icon and launch screen (farm-themed)
    - Configuring app name and bundle ID
    - TestFlight setup for beta testing
    - Creating a simple user guide within the app
    - Planning for feedback collection
    - **Live Coding:** Prepare and archive app for TestFlight
- **Final Project:**
    - Complete all remaining polish items
    - Submit app to TestFlight
    - Prepare final presentation/demo
    - Write README with features and architecture

---

## 🎯 Summary: What Students Will Build

By the end of this 12-week course, students will have a **complete, production-ready agricultural app** with:

| Module | Features | Week Completed |
|--------|----------|----------------|
| **Finance Tracker** | Income/expense tracking, profit reports, categories | Week 4 |
| **Calendar & Reminders** | Activity scheduling, local notifications | Week 5 |
| **Pest & Disease Guide** | Offline reference library with search | Week 6 |
| **Daily Journal** | Notes with photos and weather | Week 7 |
| **Dashboard** | Unified view of all farm data | Week 8 |
| **Reports & Charts** | Visual profit/loss analysis | Week 10 |
| **Backup & Restore** | Data safety and portability | Week 11 |
| **TestFlight** | Real-world testing with farmers | Week 12 |

---

## ✅ Why This Works Perfectly for Your Course

1. **Unified project** - Students build ONE impressive app, not four small ones
2. **Progressive complexity** - Each week adds new skills while reinforcing old ones
3. **Real-world value** - Actual farmers could use this app
4. **Portfolio-ready** - A complete app with multiple features demonstrates comprehensive skills
5. **Cultural relevance** - Designed specifically for Cambodian small-scale farmers
6. **SMART goals met** - Specific, Measurable, Achievable, Realistic, Timely
