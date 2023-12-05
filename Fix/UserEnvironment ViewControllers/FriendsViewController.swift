//
//  MessageViewController.swift
//  Fix
//
//  Created by Devin on 2023/11/25.
//

import UIKit
import Firebase

class FriendsViewController: UIViewController {
    
    
    @IBOutlet var chatRoomsTableView: UITableView!
    
    private var conversationUsers: [User]?
    
    private var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search,
                                                            target: self,
                                                            action: #selector(composeTapped))
        setUpTableView()
        fetchConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        // get currentUser infos
        DatabaseManager.shared.getUser(uid: Auth.auth().currentUser?.uid) { result in
            switch result {
            case .success(let user):
                self.currentUser = user
                RealTimeDatabaseManager.shared.getAllConversationIDs(currentUser: self.currentUser!) { conversationIDs in
                    print("currentUser Conversations Id array: \(conversationIDs)")
                    DatabaseManager.shared.getUsersByIDs(userIDs: conversationIDs) { conversationUsers in
                        print("currentUser Conversations Users array: \(conversationUsers)")
                        self.conversationUsers = conversationUsers
                        self.chatRoomsTableView.reloadData()
                        self.listenAndUpateConversationUsers(currentUser: self.currentUser!)
                    }
                }
            case .failure(let error):
                self.currentUser = User(firstName: "Default", lastName: "User", uid: "defaultUID", email: "default@example.com")
                print(error.localizedDescription)
            }
        }
    }
    
    private func listenAndUpateConversationUsers(currentUser: User) {
        let realTimeDB = Database.database().reference().child("users")
        let messagesRef = realTimeDB.child(currentUser.uid).child("conversations")
        // Use .childAdded event to observe new messages
        messagesRef.observe(.childAdded) { [weak self] snapshot in
            RealTimeDatabaseManager.shared.getAllConversationIDs(currentUser: currentUser) { [weak self] conversationIDs in
                DatabaseManager.shared.getUsersByIDs(userIDs: conversationIDs) { [weak self] conversationUsers in
                    self?.conversationUsers = conversationUsers
                    self?.chatRoomsTableView.reloadData()
                }
            }
        }
        // Use .childChanged event to observe changes in existing messages
        messagesRef.observe(.childChanged) { [weak self] snapshot in
            RealTimeDatabaseManager.shared.getAllConversationIDs(currentUser: currentUser) { [weak self] conversationIDs in
                DatabaseManager.shared.getUsersByIDs(userIDs: conversationIDs) { [weak self] conversationUsers in
                    self?.conversationUsers = conversationUsers
                    self?.chatRoomsTableView.reloadData()
                }
            }
        }
    }
    
    
    @objc func composeTapped() {
        let vc = NewConversationViewController()
        vc.completion = { [weak self] targetUser in
            self?.createNewConversation(targetUser: targetUser)
            print(targetUser)
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    
    func createNewConversation(targetUser: User) {
        let vc = ChatViewController(otherUser: targetUser)
        vc.title = "\(targetUser.firstName) \(targetUser.lastName)"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func setUpTableView() {
        chatRoomsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        chatRoomsTableView.delegate = self
        chatRoomsTableView.dataSource = self
    }
    
    
    func fetchConversations() {
    }
}


extension ConversationsViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let conversationUsers = self.conversationUsers {
            print(conversationUsers)
            return conversationUsers.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let conversationUsers = self.conversationUsers {
            let name = "\(conversationUsers[indexPath.row].firstName) \(conversationUsers[indexPath.row].lastName)"
            let email = "\(conversationUsers[indexPath.row].email)"
            cell.textLabel?.text = "\(name) \(email)"
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        cell.textLabel?.text = "conversationUsers is nill"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let conversationUsers = self.conversationUsers {
            createNewConversation(targetUser: conversationUsers[indexPath.row])
        }
    }
    
}
