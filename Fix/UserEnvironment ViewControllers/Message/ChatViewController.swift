//
//  ChatViewController.swift
//  Fix
//
//  Created by Devin on 2023/11/30.
//

import UIKit
import MessageKit
import Firebase
import InputBarAccessoryView

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    //var photoUrl: String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    private var currentUser: User?
    private var otherUser: User
    
    private var selfSender: Sender?
    
    private var isNewConversation = true
    
    private var messages = [Message]()
    
    init(otherUser: User) {
        self.otherUser = otherUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        
        DatabaseManager.shared.getUser(uid: Auth.auth().currentUser?.uid) { result in
            switch result {
            case .success(let user):
                self.currentUser = user
                self.selfSender = Sender(senderId: user.uid, displayName: "\(user.firstName) \(user.lastName)")
                RealTimeDatabaseManager.shared.fetchAndCreateMessages(currentUserUID: self.currentUser!.uid, otherUserUID: self.otherUser.uid) { messages in
                    self.messages = messages
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: true)
                    self.listenAndUpateMessages(currentUser: self.currentUser!, otherUser: self.otherUser)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        // Set up MessagesCollectionView
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        messagesCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    private func listenAndUpateMessages(currentUser: User, otherUser: User) {
        let realTimeDB = Database.database().reference().child("users")
        let messagesRef = realTimeDB.child(currentUser.uid).child("conversations").child(otherUser.uid)
        // Use .childAdded event to observe new messages
        messagesRef.observe(.childAdded) { [weak self] snapshot in
            RealTimeDatabaseManager.shared.fetchAndCreateMessages(currentUserUID: currentUser.uid, otherUserUID: otherUser.uid) { [weak self] messages in
                self?.messages = messages
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
        
        // Use .childChanged event to observe changes in existing messages
        messagesRef.observe(.childChanged) { [weak self] snapshot in
            RealTimeDatabaseManager.shared.fetchAndCreateMessages(currentUserUID: currentUser.uid, otherUserUID: otherUser.uid) { [weak self] messages in
                self?.messages = messages
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
    
}


extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard let selfSender = self.selfSender,
              let currentUser = currentUser,
              let messageId = self.createMessageId() else {
            return
        }

        let message = Message(sender: selfSender,
                                   messageId: messageId,
                                   sentDate: Date(),
                                   kind: .text(text))
        RealTimeDatabaseManager.shared.sendMessage(currentUser: currentUser, otherUser: otherUser, message: message)
        inputBar.inputTextView.text = ""
    }
    
    func createMessageId() -> String? {
        guard let currentUser = self.currentUser else {
            return nil
        }
        let dateString = Self.dateFormatter.string(from: Date())
        let uniqueMessageId = "\(currentUser.email)_\(otherUser.email)_\(dateString)"
        return uniqueMessageId
    }
    
}


extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    var currentSender: MessageKit.SenderType {
        if let selfSender = self.selfSender {
            return selfSender
        }
        fatalError("selfSender in ChatViewController is nil")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
