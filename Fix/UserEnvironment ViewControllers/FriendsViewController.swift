import UIKit
import Firebase

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
        usersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "userCell")
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
extension SearchFriendsViewController: UITableViewDelegate, UITableViewDataSource {
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

