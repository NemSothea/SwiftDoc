# iOS Development Lesson: Passing Data Between View Controllers

## 📚 Lesson Overview

This lesson teaches students how to effectively pass data between view controllers in iOS applications, specifically focusing on transitioning from a table view to a detail view.

## 🎯 Learning Objectives

By the end of this lesson, students will be able to:

- **Understand** different methods of passing data between view controllers
- **Implement** table view selection handling
- **Use** both segue-based and programmatic navigation approaches
- **Apply** proper data encapsulation patterns
- **Debug** common data passing issues

## 📖 Lesson Content

### 1. Table View Basics
```swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let selectedItem = dataArray[indexPath.row]
    // Handle selection
}
```

**Key Concepts:**
- `indexPath.row` to access specific data
- `deselectRow` for better UX
- Data model access patterns

### 2. Segue-Based Data Passing

#### Method A: Using prepare(for:sender:)
```swift
// Step 1: Trigger segue
performSegue(withIdentifier: "showDetail", sender: selectedData)

// Step 2: Prepare data
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail",
       let destinationVC = segue.destination as? DetailViewController,
       let data = sender as? MyDataModel {
        destinationVC.receivedData = data
    }
}
```

#### Method B: Using IndexPath
```swift
var selectedIndexPath: IndexPath?

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedIndexPath = indexPath
    performSegue(withIdentifier: "showDetail", sender: self)
}

override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let indexPath = selectedIndexPath,
       let destinationVC = segue.destination as? DetailViewController {
        destinationVC.receivedData = dataArray[indexPath.row]
    }
}
```

### 3. Programmatic Navigation (Push)

#### Without Storyboard:
```swift
let detailVC = DetailViewController()
detailVC.selectedData = myData
navigationController?.pushViewController(detailVC, animated: true)
```

#### With Storyboard:
```swift
let storyboard = UIStoryboard(name: "Main", bundle: nil)
let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
detailVC.selectedData = myData
navigationController?.pushViewController(detailVC, animated: true)
```

## 🛠️ Key Skills Developed

### 1. **Data Management**
- Accessing data from collections using index paths
- Type casting and optional binding
- Data model design

### 2. **Navigation Patterns**
- Storyboard segues vs programmatic navigation
- Navigation controller stack management
- Transition animations

### 3. **Code Organization**
- Separation of concerns
- Clean data passing patterns
- Error handling and safety

### 4. **Debugging Skills**
- Identifying nil values
- Type mismatch issues
- Storyboard identifier configuration

## 💡 Common Pitfalls & Solutions

| Problem | Solution |
|---------|----------|
| `unexpectedly found nil` | Check Storyboard IDs and force casts |
| Data not appearing | Verify property names match |
| App crashes on push | Ensure navigation controller exists |
| Wrong data displayed | Debug indexPath logic |

## 🔍 Best Practices

### 1. **Safety First**
```swift
// Always use optional binding
if let detailVC = segue.destination as? DetailViewController {
    detailVC.data = selectedData
}

// Avoid force unwrapping
// ❌ destinationVC!.data = selectedData
```

### 2. **Clear Naming**
```swift
// Good
detailVC.userProfile = selectedUser

// Avoid
detailVC.data = selectedUser
```

### 3. **Separation of Concerns**
- Keep data processing in model layer
- View controllers should handle presentation only
- Use dependency injection

## 🚀 Advanced Topics (Optional)

### 1. **Dependency Injection**
```swift
class DetailViewController: UIViewController {
    var user: User?
    
    // Designated initializer
    convenience init(user: User) {
        self.init()
        self.user = user
    }
}
```

### 2. **Closure-Based Communication**
```swift
// For passing data back
detailVC.onDataUpdate = { [weak self] updatedData in
    self?.refreshData()
}
```

### 3. **Protocol-Oriented Approach**
```swift
protocol DataReceivable {
    func receive(data: Any)
}
```

## 📝 Assessment Criteria

Students should demonstrate:

- ✅ Proper handling of table view selection
- ✅ Correct implementation of data passing
- ✅ Error-free navigation between screens
- ✅ Clean, readable code organization
- ✅ Understanding of optional binding and type safety

## 🎓 Real-World Application

This pattern is used in:
- Social media apps (feed → post detail)
- E-commerce apps (product list → product detail)
- Settings apps (menu → detail settings)
- Any master-detail interface

## 🔗 Prerequisites

- Basic Swift knowledge
- Understanding of UITableView
- Familiarity with Storyboards
- Knowledge of Optionals

## 📚 Additional Resources

1. [Apple Documentation: UIViewController](https://developer.apple.com/documentation/uikit/uiviewcontroller)
2. [Apple Documentation: UITableViewDelegate](https://developer.apple.com/documentation/uikit/uitableviewdelegate)
3. [Swift Optionals Guide](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/thebasics/)

---

**Lesson Duration:** 2-3 hours  
**Difficulty Level:** Beginner/Intermediate  
**Project Type:** Hands-on coding exercise

This lesson provides foundational skills that are essential for virtually every iOS application! 🚀
