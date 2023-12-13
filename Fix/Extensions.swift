//
//  extensions.swift
//  Fix
//
//  Created by Devin on 2023/11/30.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import MessageKit

extension UIImageView {
    // Sets the UIImageView to be circular. This is typically used for profile images.
    // Note: Ensure the UIImageView has equal width and height to maintain the circular shape.
    func setCircular() {
        self.contentMode = .scaleAspectFill
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}

// Represents a user with essential properties like name, uid, and email.
struct User {
    let firstName: String
    let lastName: String
    let uid: String
    let email: String
}

// used for Firestore Database
final class DatabaseManager {
    static let shared = DatabaseManager()

        private let db = Firestore.firestore()

        private init() {}

        // Fetches and returns a list of users from the Firestore Database.
        func getUsers(completion: @escaping (Result<[User], Error>) -> Void) {
            let usersCollection = db.collection("users")

            usersCollection.getDocuments { (querySnapshot, error) in
                // Handle errors in fetching documents.
                if let error = error {
                    completion(.failure(error))
                    return
                }

                // Parse documents to User objects.
                let users = querySnapshot?.documents.compactMap { document in
                    return self.parseUser(from: document)
                } ?? []
                completion(.success(users))
            }
        }

        // Fetches a user by UID from the Firestore Database.
        func getUser(uid: String?, completion: @escaping (Result<User, Error>) -> Void) {
            let usersCollection = db.collection("users")
            
            // Ensure UID is valid.
            guard let uid = uid, !uid.isEmpty else {
                let uidError = NSError(domain: "Firestore", code: 400, userInfo: [NSLocalizedDescriptionKey: "UID is nil or empty"])
                completion(.failure(uidError))
                return
            }
            
            let userDocument = usersCollection.document(uid)
            
            // Fetch user document.
            userDocument.getDocument { document, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = document, document.exists, let user = self.parseUser(from: document) else {
                    let notFoundError = NSError(domain: "Firestore", code: 404, userInfo: nil)
                    completion(.failure(notFoundError))
                    return
                }
                
                completion(.success(user))
            }
        }
    
        // Helper method to parse a Firestore document to a User object.
        private func parseUser(from document: DocumentSnapshot) -> User? {
            guard let userData = document.data(),
                  let firstName = userData["first_name"] as? String,
                  let lastName = userData["last_name"] as? String,
                  let email = userData["email"] as? String,
                  let uid = userData["uid"] as? String else {
                return nil
            }
            return User(firstName: firstName, lastName: lastName, uid: uid, email: email)
        }
    
    func getUsersByIDs(userIDs: [String], completion: @escaping ([User]) -> Void) {
        var users: [User] = []

        // Use a DispatchGroup to wait for all async calls to complete
        let dispatchGroup = DispatchGroup()

        for userID in userIDs {
            dispatchGroup.enter()

            getUser(uid: userID) { result in
                defer {
                    dispatchGroup.leave()
                }
                switch result {
                case .success(let user):
                    users.append(user)
                case .failure(let error):
                    print("Error fetching user with UID \(userID): \(error.localizedDescription)")
                }
            }
        }
        // Notify when all async calls are done
        dispatchGroup.notify(queue: .main) {
            completion(users)
        }
    }
    
}

final class FBStorageManager {
    
    static let shared = FBStorageManager()
    
    private let storage = Storage.storage()
    
    private init() {}
    
    public func getUserProfileImage(uid: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let storageRef = storage.reference()
        let imagePath = "\(uid)/userPhoto"

        let imageRef = storageRef.child(imagePath)

        // Download in memory with a maximum allowed size of 1MB (adjust as needed)
        imageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                completion(.failure(error))
                print("Error downloading image: \(error.localizedDescription)")
            } else {
                // Successfully downloaded data, convert it to UIImage
                if let imageData = data, let image = UIImage(data: imageData) {
                    completion(.success(image))
                } else {
                    let decodingError = NSError(domain: "Image Decoding Error", code: 0, userInfo: nil)
                    completion(.failure(decodingError))
                }
            }
        }
    }
    
}


// used for messaging, Firebase Realtime Database
final class RealTimeDatabaseManager {

    static let shared = RealTimeDatabaseManager()

    private init() {}
    
    public func sendMessage(currentUser: User, otherUser: User, message: Message) {
        
        let senderId = message.sender.senderId
        let senderName = message.sender.displayName
        let messageId = message.messageId
        
        let messageDate = message.sentDate
        let sentDate = ChatViewController.dateFormatter.string(from: messageDate)
        
        let messageText: String
            switch message.kind {
            case .text(let text):
                messageText = text
            default:
                // Handle other message types if needed
                messageText = ""
            }
        
        let receiverId = otherUser.uid
        let receiverName = otherUser.firstName
        
        let newMessage: [String: Any] = [
            "senderId": senderId,
            "senderName": senderName,
            "receiverId": receiverId,
            "receiverName": receiverName,
            "messageId": messageId,
            "sentDate": sentDate,
            "messageText": messageText
        ]
        
        let realTimeDB = Database.database().reference().child("users")
        
        // store message to currUser
        let currMessagesRef = realTimeDB.child(currentUser.uid).child("conversations").child(otherUser.uid)
        // Check if the "messages" array exists
        currMessagesRef.observeSingleEvent(of: .value) { snapshot in
            if var messagesArray = snapshot.value as? [[String: Any]] {
                // If the array exists, append the new message
                messagesArray.append(newMessage)
                currMessagesRef.setValue(messagesArray)
            } else {
                // If the array doesn't exist, create it with the new message
                currMessagesRef.setValue([newMessage])
            }
        }
        
        // store message to otherUser
        let otherMessagesRef = realTimeDB.child(otherUser.uid).child("conversations").child(currentUser.uid)
        // Check if the "messages" array exists
        otherMessagesRef.observeSingleEvent(of: .value) { snapshot in
            if var messagesArray = snapshot.value as? [[String: Any]] {
                // If the array exists, append the new message
                messagesArray.append(newMessage)
                otherMessagesRef.setValue(messagesArray)
            } else {
                // If the array doesn't exist, create it with the new message
                otherMessagesRef.setValue([newMessage])
            }
        }
    }
    
    
    public func getAllConversationIDs(currentUser: User, completion: @escaping ([String]) -> Void) {
        let realTimeDB = Database.database().reference().child("users")
        let userConversationRef = realTimeDB.child(currentUser.uid).child("conversations")

        var conversationIDs: [String] = []

        // Observe a single event to get a snapshot of the "conversations" node
        userConversationRef.observeSingleEvent(of: .value) { snapshot, error in
            if let error = error {
                // Handle the case when there's an error
                print("Error retrieving conversation Ids for currentUser: \(error)")
                completion([])
            } else if let conversations = snapshot.value as? [String: Any] {
                // Extract the node IDs (keys) from the conversations
                conversationIDs = Array(conversations.keys)
                completion(conversationIDs)
            }
        }
    }
    
    
    func fetchAndCreateMessages(currentUserUID: String, otherUserUID: String, completion: @escaping ([Message]) -> Void) {
        let realTimeDB = Database.database().reference().child("users")
        let messagesRef = realTimeDB.child(currentUserUID).child("conversations").child(otherUserUID)

        messagesRef.observeSingleEvent(of: .value) { snapshot, error in
            guard let messagesData = snapshot.value as? [[String: String]] else {
                completion([])
                return
            }

            var messages: [Message] = []

            for messageData in messagesData {
                guard
                    let senderId = messageData["senderId"],
                    let senderName = messageData["senderName"],
                    let messageId = messageData["messageId"],
                    let sentDateString = messageData["sentDate"],
                    let messageText = messageData["messageText"],
                    let sentDate = ChatViewController.dateFormatter.date(from: sentDateString)
                else {
                    continue
                }
                let sender = Sender(senderId: senderId, displayName: senderName) // Update with actual display name
                let message = Message(sender: sender, messageId: messageId, sentDate: sentDate, kind: .text(messageText))
                messages.append(message)
            }
            completion(messages)
        }
    }}

