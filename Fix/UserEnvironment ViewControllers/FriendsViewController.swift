import UIKit
import Firebase


// Define your custom PossibleFriendView
class PossibleFriendView: UIView {
    // Add your UI elements here (e.g., labels, buttons)
    var nameLabel: UILabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Setup nameLabel and other UI elements
        addSubview(nameLabel)
        // Layout your nameLabel and other elements
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Method to configure view with user data
    func configure(with user: User) {
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        // Configure other elements if needed
    }
}

// Define your custom UITableViewCell
class FriendTableViewCell: UITableViewCell {
    var possibleFriendView = PossibleFriendView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(possibleFriendView)
        // Layout your possibleFriendView within the cell
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Configure the cell with a User object
    func configureWithUser(_ user: User) {
        possibleFriendView.configure(with: user)
    }
}
class FriendsViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet var usersTableView: UITableView!
    private var allUsers: [User] = []
    private var filteredUsers: [User] = []
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSearchController()
        setUpTableView()
        fetchAllUsers()
    }
    
    // MARK: - UI Setup
    private func setUpSearchController() {
        // Setup for the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Users"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setUpTableView() {
            usersTableView.register(FriendTableViewCell.self, forCellReuseIdentifier: "FriendCell")
            usersTableView.delegate = self
            usersTableView.dataSource = self
        }
    
    // MARK: - Data Handling
    private func fetchAllUsers() {
        DatabaseManager.shared.getUsers { [weak self] result in
            switch result {
            case .success(let users):
                // Successfully got the users
                self?.allUsers = users
                self?.filteredUsers = users
                self?.usersTableView.reloadData()
            case .failure(let error):
                // Handle error scenario
                print("Error fetching users: \(error)")
            }
        }
    }

    
    private func filterUsers(for searchText: String) {
        filteredUsers = allUsers.filter { user in
            return user.firstName.lowercased().contains(searchText.lowercased()) ||
                   user.lastName.lowercased().contains(searchText.lowercased())
        }
        
        usersTableView.reloadData()
    }
    
    // MARK: - Navigation
    private func navigateToUserProfile(for user: User) {
        // Navigate to the selected user's profile or chat
    }
}

// MARK: - TableView Delegate and DataSource
extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        let user = filteredUsers[indexPath.row]
        cell.textLabel?.text = "\(user.firstName) \(user.lastName)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigateToUserProfile(for: filteredUsers[indexPath.row])
    }
}

// MARK: - Search Results Updating
extension FriendsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterUsers(for: searchText)
    }
}

