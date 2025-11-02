# Course Title: iOS App Development: From UIKit Fundamentals to Modern SwiftUI

## Revised Week-by-Week Outline (Integrating UIKit)

### Part 1: Swift & UIKit Foundation (Weeks 1-6)

| **Week** | **Topic** | **Lesson Breakdown (3 Hours)** | **Homework / Mini-Project** |
|----------|-----------|--------------------------------|-----------------------------|
| 1 | Xcode & Swift Basics | **Hour 1:** Course intro, Xcode setup, Intro to Storyboards.<br><br>**Hour 2:** Variables, Constants, Data Types.<br><br>**Hour 3:** Operators, if/else, and switch. | Build a Playground that performs simple calculations and logic. |
| 2 | Swift for UIKit | **Hour 1:** Functions and Optionals (if let, guard let).<br><br>**Hour 2:** Collections (Arrays, Dictionaries).<br><br>**Hour 3:** UIKit Concept: IBOutlet and IBAction. Connect a button in a storyboard to code. | Build a Storyboard app with a button that updates a label when pressed. |
| 3 | The ViewController Lifecycle | **Hour 1:** Create a new project without SwiftUI. Intro to UIViewController.<br><br>**Hour 2:** The view lifecycle: viewDidLoad(), viewDidAppear(\_:).<br><br>**Hour 3:** Adding views programmatically (e.g., UILabel, UIButton) in viewDidLoad(). | Build an app that creates and displays several UI elements entirely in code. |
| 4 | Navigation with UIKit | **Hour 1:** UINavigationController: pushing and popping ViewControllers.<br><br>**Hour 2:** Segues: show, present modally. Passing data forward with prepare(for:sender:).<br><br>**Hour 3:** Pattern: The Delegate Pattern explained. Passing data backwards between ViewControllers. | Build a two-screen app: a list of items on the first screen, tap one to see its detail on the second. |
| 5 | Tables & Lists (UITableView) | **Hour 1:** The core of iOS: UITableView.<br><br>**Hour 2:** UITableViewDataSource: numberOfRowsInSection, cellForRowAt.<br><br>**Hour 3:** UITableViewDelegate: handling row taps (didSelectRowAt). | Build a classic to-do list app using a UITableView and a Storyboard. |
| 6 | Data in UIKit | **Hour 1:** Model objects (struct). Creating a TodoItem model.<br><br>**Hour 2:** Populating the UITableView with an array of model objects.<br><br>**Hour 3:** Review & Q&A: The MVC (Model-View-Controller) pattern in your app. | Refactor the to-do list app to use a proper model layer. |

### Part 2: Transitioning to Modern SwiftUI (Weeks 7-12)

| **Week** | **Topic** | **Lesson Breakdown (3 Hours)** | **Homework / Mini-Project** |
|----------|-----------|--------------------------------|-----------------------------|
| 7 | Hello, SwiftUI! The Paradigm Shift | **Hour 1:** Contrast: Declarative UI vs. Imperative UI (UIKit). Why SwiftUI exists.<br><br>**Hour 2:** Create a new SwiftUI project. Explore the Canvas, Previews, and basic Views (Text, VStack, Image).<br><br>**Hour 3:** Modifiers: the building blocks of styling. | Recreate the simple profile screen from Week 4, but now in SwiftUI. |
| 8 | SwiftUI State & Data Flow | **Hour 1:** The magic of @State. Rebuilding the UIKit button+label example in 5 lines of code.<br><br>**Hour 2:** @Binding: creating a connection between parent and child views.<br><br>**Hour 3:** Contrast: Compare passing data with Bindings vs. UIKit's Delegates and prepare(for:sender:). | Build a SwiftUI app with a toggle in the parent view that controls a text state in a child view. |
| 9 | SwiftUI Lists & Navigation | **Hour 1:** List and ForEach. Incredibly simple compared to UITableView DataSource.<br><br>**Hour 2:** NavigationStack and NavigationLink.<br><br>**Hour 3:** Final Project Kick-off: Students choose to build their final project in either UIKit or SwiftUI, or a mix. | Rebuild the to-do list app from Week 5/6 in SwiftUI. Compare the line count and complexity. |
| 10 | Architecture & Networking | **Hour 1:** Managing complex state: @StateObject & ObservableObject (the SwiftUI equivalent of a ViewController's central data manager).<br><br>**Hour 2:** Networking with URLSession and async/await in SwiftUI.<br><br>**Hour 3:** Project Work Session. | Build an app that fetches data from an API and displays it in a SwiftUI List. |
| 11 | Integration & Polish | **Hour 1:** Using UIKit in SwiftUI: UIViewRepresentable (e.g., to use a MKMapView).<br><br>**Hour 2:** Using SwiftUI in UIKit: UIHostingController (putting a SwiftUI view inside a UIKit app).<br><br>**Hour 3:** Simple animations in SwiftUI (.animation() modifier). | Add a simple animation to any of the previous SwiftUI apps. |
| 12 | App Showcase & Next Steps | **Hour 1-2:** Final Project Presentations! (The Apple Developer Program is 99 USD per membership year. Prices may vary by region and are listed in local currency during the enrollment process.)<br><br>**Hour 3:** Course wrap-up. When to choose UIKit vs. SwiftUI. Overview of the App Store submission process. | Submit the final project. |

---

## Course Overview

This 12-week course provides a comprehensive journey from traditional UIKit development to modern SwiftUI approaches. Students will gain practical experience with both frameworks, understanding when and why to use each in real-world iOS development.

### Key Learning Outcomes:
- Master Swift programming fundamentals
- Build responsive iOS interfaces with UIKit
- Transition to declarative UI with SwiftUI
- Understand data flow and state management
- Implement navigation patterns in both frameworks
- Integrate UIKit and SwiftUI components
- Prepare apps for App Store submission

### Prerequisites:
- Basic programming knowledge
- macOS computer for Xcode development
- iPhone or iPad for testing (simulator available)

---

*Note: This course outline is designed to provide hands-on experience with both traditional and modern iOS development approaches, ensuring graduates are prepared for current industry needs.*
# Git command(example)
1. check status files : <br>
`git status`
2. Stage your changes (select files to commit)<br>
`git add Product.swift ProductTest.swift or git add . `

3. Commit your changes to local history with a message<br>
`git commit -m "Complete Product struct lab activity"`

4. Commit your changes to local history with a message<br>
`git status`

5. Push your local commits to GitHub<br>
`git push origin develop`
