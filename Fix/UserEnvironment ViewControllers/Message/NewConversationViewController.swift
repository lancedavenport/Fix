//
//  NewConversationViewController.swift
//  Fix
//
//  Created by Devin on 2023/12/1.
//

import UIKit
import Firebase

class NewConversationViewController: UIViewController {
    
    public var completion: ((User) -> (Void))?
    private var users = [User]()
    private var hasFetched = false
    private var results = [User]()

    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search users, space for all"
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self,
        forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "no result"
        label.font = .systemFont(ofSize: 21)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = .white
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
     }

    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let u = results[indexPath.row]
        cell.textLabel?.text = "\(u.firstName) \(u.lastName) - \(u.email)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // start conversation
        let targetUser = results[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.completion?(targetUser)
        }
    }
    
}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        self.searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        if hasFetched {
            // filter
            filterUsers(with: query)
        } else {
            // fetch then filter
            DatabaseManager.shared.getUsers { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    // Handle the error (e.g., show an alert to the user)
                    print("Failed to get users: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func filterUsers(with term: String) {
        guard let currentUserEmail = Auth.auth().currentUser?.email, hasFetched else {
            return
        }

        let results: [User] = users.compactMap { user in
            let fullName = "\(user.firstName) \(user.lastName)"
            let email = user.email
            
            if email == currentUserEmail {
                return nil
            }
            
            let isFullNameMatch = term.isEmpty || fullName.lowercased().contains(term.lowercased())
            let isEmailMatch = email.lowercased().contains(term.lowercased())
            
            if isFullNameMatch || isEmailMatch {
                return user
            } else {
                return nil
            }
        }
        self.results = results
        
        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty {
            noResultsLabel.isHidden = false
            tableView.isHidden = true
        }
        else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
}
