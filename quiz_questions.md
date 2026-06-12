# Prek Leap National Institute of Agriculture


# Advanced iOS Quiz
14 Questions · Multiple Choice + Complete the Code

Student Name : ...............................



---

**1.** In MVVM (iOS 13+), which property wrapper should a view use when it CREATES and OWNS the ViewModel for its entire lifetime?

- A. `@ObservedObject var vm: FarmViewModel`
- B. `@StateObject private var vm: FarmViewModel`
- C. `@EnvironmentObject var vm: FarmViewModel`
- D. `@State private var vm = FarmViewModel()`

---

**2.** Why should you use NSPredicate on a @FetchRequest instead of Swift `.filter{}` to show only expense transactions?

- A. NSPredicate is faster to write and has cleaner syntax
- B. NSPredicate filters inside SQLite, loading only matching rows into memory
- C. Swift `.filter{}` cannot compare String properties
- D. `.filter{}` requires a different managedObjectContext

---

**3.** What does the `@NSManaged` attribute tell the Swift compiler when applied to a CoreData property?

- A. The property is immutable after creation
- B. The property's storage is handled by CoreData's Objective-C runtime, not Swift
- C. The property will be automatically saved every second
- D. The property is excluded from the `.xcdatamodeld` schema

---

**4.** In iOS 13+, what is the correct way to navigate programmatically to a detail view from code (not just from a tap)?

- A. `NavigationStack { }.navigationDestination(for: UUID.self)`
- B. `NavigationLink(tag: id, selection: $selectedID) { DetailView() } label: { EmptyView() }`
- C. `NavigationLink(destination: DetailView()) { Text("Go") }`
- D. `@Environment(\.dismiss) var dismiss`

---

**5.** Which class and method do you call first before scheduling a local notification in iOS 13+?

- A. `NotificationCenter.default.post(name:object:)`
- B. `UNUserNotificationCenter.current().requestAuthorization(options:completionHandler:)`
- C. `UNNotificationRequest.schedule(after:repeats:)`
- D. `UserDefaults.standard.set(true, forKey: "notificationsAllowed")`

---

**6.** What does `@ViewBuilder` enable in a generic container like `DashboardSection<Content: View>`?

- A. It allows the struct to inherit from UIView
- B. It lets the caller pass a closure returning multiple SwiftUI views without wrapping in a Group
- C. It enables live-preview rendering in Xcode Canvas
- D. It replaces the need for @EnvironmentObject in child views

---

**7.** What is the primary advantage of extracting repeated `.padding().background().cornerRadius()` into a custom ViewModifier?

- A. ViewModifiers run on a background thread and improve performance
- B. Styling is centralised — changing the modifier updates every view that applies it
- C. ViewModifiers bypass the SwiftUI layout system for faster rendering
- D. ViewModifiers allow you to call UIKit methods directly

---

**8.** In iOS 13+, which API is used to generate a formatted PDF report with text and tables?

- A. `ImageRenderer` — capture a SwiftUI view as a PDF
- B. `UIGraphicsPDFRenderer` — draw text, tables, and graphics into a PDF context
- C. `PDFDocument` from PDFKit with `appendPage()`
- D. `ShareLink` with a URL to a pre-built template

---

**9.** *(Complete the Code — Week 2 CoreData)* What belongs on the blank line to persist the record across app restarts?

```swift
func addTransaction(
    amount: Double, note: String,
    type: String, category: String
) {
    let t = Transaction(context: context)
    t.amount   = amount
    t.note     = note
    t.type     = type
    t.category = category
    t.id       = UUID()
    _______________   // <- what goes here?
}
```

- A. `context.insert(t)`
- B. `context.refresh(t, mergeChanges: true)`
- C. `saveContext()`
- D. `context.fetch(Transaction.fetchRequest())`

---

**10.** *(Complete the Code — Week 7 Photos)* What should `picker.delegate` be set to?

```swift
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = _______________
        return picker
    }
}
```

- A. `self`
- B. `context.coordinator`
- C. `UIImagePickerController()`
- D. `Coordinator(self)`

---

**11.** Before running Product → Archive in Xcode to upload to TestFlight, what must you select in the device/scheme destination picker?

- A. iPhone 15 Pro (Simulator)
- B. My Mac (Designed for iPad)
- C. Any iOS Device (arm64)
- D. Generic iOS Device (x86_64)

---

**12.** Why must `LaunchScreen.storyboard` contain only static images — no Swift code, no animations, no `@IBOutlet` connections?

- A. Xcode strips all code from storyboard files during archive
- B. The OS renders the launch screen before the app process starts — no Swift runtime is available yet
- C. Animations in storyboards require iOS 16+ and break backward compatibility
- D. App Store review tools flag storyboards that reference Swift classes

---

**13.** What is the correct order of Git's three storage areas when you save a code change permanently?

- A. Repository → Staging Area → Working Directory
- B. Working Directory → Repository → Staging Area
- C. Staging Area → Working Directory → Repository
- D. Working Directory → Staging Area → Repository

---

**14.** Which single Git command creates a new branch `feature/login` AND immediately switches to it?

- A. `git branch feature/login`
- B. `git merge feature/login`
- C. `git switch -c feature/login`
- D. `git push -u origin feature/login`

---

