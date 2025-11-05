# The ViewController Lifecycle

## 🌟 Key Takeaways:

- **viewDidLoad**: Perfect for one-time setup and initial API calls
- **viewWillAppear**: Great for refreshing data that might have changed
- **viewDidAppear**: Good for animations and non-critical API calls
- **viewWillDisappear**: Use for saving state and pausing activities
- **viewDidDisappear**: Use for cleanup and canceling requests

This structure ensures your app loads data efficiently while providing a smooth user experience!

## 1. **viewDidLoad() - Initial Setup & API Call**

```swift
class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var users: [User] = []
    let apiService = APIService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // One-time setup
        setupTableView()
        setupUI()
        
        // Kick off initial API call
        fetchUsers()
    }
    
    private func setupTableView() {
        userTableView.dataSource = self
        userTableView.delegate = self
        userTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
    }
    
    private func setupUI() {
        title = "User Profiles"
        loadingIndicator.hidesWhenStopped = true
        errorLabel.isHidden = true
    }
    
    private func fetchUsers() {
        loadingIndicator.startAnimating()
        errorLabel.isHidden = true
        
        apiService.fetchUsers { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                
                switch result {
                case .success(let users):
                    self?.users = users
                    self?.userTableView.reloadData()
                case .failure(let error):
                    self?.errorLabel.text = "Error: \(error.localizedDescription)"
                    self?.errorLabel.isHidden = false
                }
            }
        }
    }
}
```

## 2. **viewWillAppear() - Refresh Data**

```swift
class MessagesViewController: UIViewController {
    
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var unreadBadge: UILabel!
    
    var messages: [Message] = []
    let messageService = MessageService()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh data every time the view appears
        // (useful when returning from another screen)
        refreshMessages()
        updateUnreadBadge()
    }
    
    private func refreshMessages() {
        messageService.getLatestMessages { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newMessages):
                    self?.messages = newMessages
                    self?.messagesTableView.reloadData()
                case .failure(let error):
                    print("Failed to refresh messages: \(error)")
                }
            }
        }
    }
    
    private func updateUnreadBadge() {
        let unreadCount = messages.filter { !$0.isRead }.count
        unreadBadge.text = "\(unreadCount)"
        unreadBadge.isHidden = unreadCount == 0
    }
}
```

## 3. **Complete Example with All Lifecycle Methods**

```swift
class ProductDetailViewController: UIViewController {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    
    var productId: String
    var product: Product?
    let productService = ProductService()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // One-time setup
        setupUI()
        setupGestureRecognizers()
        
        // Initial API call
        loadProductDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh product availability when returning to this screen
        checkProductAvailability()
        
        // Analytics - track screen view
        Analytics.trackScreenView("Product Detail")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start animations that should begin when view is visible
        startProductImageAnimation()
        
        // Load related products (lower priority)
        loadRelatedProducts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Save user's viewing progress
        saveViewingHistory()
        
        // Pause any ongoing animations
        pauseProductImageAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Clean up resources
        cancelPendingRequests()
    }
    
    // MARK: - API Methods
    
    private func loadProductDetails() {
        showLoading(true)
        
        productService.fetchProduct(id: productId) { [weak self] result in
            DispatchQueue.main.async {
                self?.showLoading(false)
                
                switch result {
                case .success(let product):
                    self?.product = product
                    self?.updateUI(with: product)
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    private func checkProductAvailability() {
        productService.checkAvailability(productId: productId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let isAvailable):
                    self?.updateAvailabilityUI(isAvailable)
                case .failure:
                    // Silently fail for non-critical updates
                    break
                }
            }
        }
    }
    
    private func loadRelatedProducts() {
        // This is a lower priority call that we start when the view is already visible
        productService.fetchRelatedProducts(productId: productId) { result in
            // Handle related products (maybe show in a collection view)
        }
    }
    
    // MARK: - UI Updates
    
    private func setupUI() {
        title = "Product Details"
        loadingView.layer.cornerRadius = 8
    }
    
    private func updateUI(with product: Product) {
        titleLabel.text = product.name
        priceLabel.text = product.formattedPrice
        descriptionLabel.text = product.description
        
        // Load product image
        if let imageUrl = product.imageUrl {
            loadProductImage(from: imageUrl)
        }
    }
    
    private func loadProductImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.productImageView.image = image
            }
        }.resume()
    }
    
    private func showLoading(_ show: Bool) {
        loadingView.isHidden = !show
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load product: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.loadProductDetails()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        productImageView.addGestureRecognizer(tapGesture)
        productImageView.isUserInteractionEnabled = true
    }
    
    private func startProductImageAnimation() {
        // Start any entrance animations
        UIView.animate(withDuration: 0.5) {
            self.productImageView.alpha = 1.0
        }
    }
    
    private func pauseProductImageAnimation() {
        // Pause animations when view disappears
        productImageView.layer.removeAllAnimations()
    }
    
    private func saveViewingHistory() {
        // Save to UserDefaults or send to analytics
        UserDefaults.standard.set(Date(), forKey: "lastViewedProduct_\(productId)")
    }
    
    private func cancelPendingRequests() {
        // Cancel any ongoing URLSession tasks
        URLSession.shared.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
    }
    
    @objc private func imageTapped() {
        // Handle image tap
    }
}
```

## 4. **API Service Helper**

```swift
class APIService {
    
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        guard let url = URL(string: "https://api.example.com/users") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let users = try JSONDecoder().decode([User].self, from: data)
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

enum APIError: Error {
    case noData
    case invalidResponse
}

// Model
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}
```
```
// Add this to your view controller to test
class TestViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("1. viewDidLoad called")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("2. viewWillAppear called - animated: \(animated)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("3. viewDidAppear called - animated: \(animated)")
    }
    
    // Test by:
    // 1. Running the app
    // 2. Pushing another VC then popping back
    // 3. Presenting modally then dismissing
}```

## Mock Data API Server that can use to play around without develop or host a backend api
1. https://jsonplaceholder.typicode.com/


## Commit Emoji :
1. https://gist.github.com/parmentf/035de27d6ed1dce0b36a
2. https://gitmoji.dev/
