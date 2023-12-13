//
//  FeedViewController.swift
//  Fix
//
//  Created by Devin on 2023/11/25.
//

import UIKit
import Firebase
import FirebaseStorage
import SwiftUI

class FeedViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userBio: UILabel!
    @IBOutlet weak var swipeNoOutlet: UIButton!
    @IBOutlet weak var swipeYesOutlet: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    let storage = Storage.storage()
    var storageRef: StorageReference? = nil
    var uid: String? = nil
    var userSeen: [String]! = []
    var users = [User]()
    var hasFetched = false
    var notSeen: [String]! = []
    var userShown: String = ""
    var userLiked: [String]! = []
    
    func getAllUsers(completion: @escaping () -> Void) {
        DatabaseManager.shared.getUsers { [weak self] result in
            switch result {
            case .success(let usersCollection):
                self?.hasFetched = true
                self?.users = usersCollection
                self!.findNewPerson()
            case .failure(let error):
                // Handle the error (e.g., show an alert to the user)
                print("Failed to get users: \(error.localizedDescription)")
            }
            completion()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        getUserSeen { (seenArray, error) in
            if let error = error {
                print(error)
            } else if let seenArray = seenArray {
                self.userSeen = seenArray
            }
            
        }
        self.storageRef = storage.reference()
        self.uid = Auth.auth().currentUser!.uid
        self.swipeYesOutlet.tintColor = UIColor.systemGreen
        self.swipeNoOutlet.tintColor = UIColor.systemRed
        getAllUsers() {
            self.showNewPerson { (bio, error) in
                if let error = error {
                    print(error)
                } else if let bio = bio {
                    print("Success")
                }
            }
        }
    }
    
    
    
    @IBAction func swipeYes(_ sender: Any) {
        if isMatch(myUID: self.uid!, theirUID: self.userShown) {
            
        }
        updateUserLiked()
        updateUserSeen()
        
        self.showNewPerson { (bio, error) in
            if let error = error {
                print(error)
            } else if let bio = bio {
                print("Success")
            }
        }
        
        
        
    }
    
    @IBAction func swipeNo(_ sender: Any) {
        updateUserSeen()
        
        self.showNewPerson { (bio, error) in
            if let error = error {
                print(error)
            } else if let bio = bio {
                print("Success")
            }
        }
    }
    
    
    
    // Helper funcs
    func updateUserLiked() {
        DispatchQueue.main.async {
            self.userLiked.append(self.userShown)
            
            let db = Firestore.firestore()
            let uid = Auth.auth().currentUser!.uid
            let dbCollection = db.collection("users")
            
            dbCollection.document(uid).updateData(["liked": self.userLiked!]) { error in
                if let error = error {
                    print(error)
                }
            }
        }
    }
    
    
    func updateUserSeen() {
        DispatchQueue.main.async {
            self.userSeen.append(self.userShown)
            if !self.notSeen.isEmpty {
                self.notSeen.remove(at: 0)
                
                if !self.notSeen.isEmpty {
                    self.userShown = self.notSeen[0]
                    let db = Firestore.firestore()
                    let uid = Auth.auth().currentUser!.uid
                    let dbCollection = db.collection("users")
                    
                    dbCollection.document(uid).updateData(["seen": self.userSeen!]) { error in
                        if let error = error {
                            print(error)
                        }
                    }
                    
                } else {
                    let filePath = "default/noMorePeople.jpeg"
                    Storage.storage().reference().child(filePath).getData(maxSize: 10*1024*1024) { data, error in
                        if let error = error {
                            print("error loading default image from firbase storage: \(error.localizedDescription)")
                            self.swipeNoOutlet.isEnabled = false
                            self.swipeYesOutlet.isEnabled = false
                        } else {
                            self.userImage.image = UIImage(data: data!)
                            self.userBio.text = "No more people to swipe on"
                            self.nameLabel.text = "No more people to swipe on"
                            self.swipeNoOutlet.isEnabled = false
                            self.swipeYesOutlet.isEnabled = false
                        }
                    }
                    let db = Firestore.firestore()
                    let uid = Auth.auth().currentUser!.uid
                    let dbCollection = db.collection("users")
                    dbCollection.document(uid).updateData(["seen": self.userSeen!]) { error in
                        if let error = error {
                            print(error)
                        }
                    }
                }
                
                
            } else {
                
                let filePath = "default/noMorePeople.jpeg"
                Storage.storage().reference().child(filePath).getData(maxSize: 10*1024*1024) { data, error in
                    if let error = error {
                        print("error loading default image from firbase storage: \(error.localizedDescription)")
                        self.swipeNoOutlet.isEnabled = false
                        self.swipeYesOutlet.isEnabled = false
                    } else {
                        self.userImage.image = UIImage(data: data!)
                        self.userBio.text = "No more people to swipe on"
                        self.nameLabel.text = "No more people to swipe on"
                        self.swipeNoOutlet.isEnabled = false
                        self.swipeYesOutlet.isEnabled = false
                    }
                }
                let db = Firestore.firestore()
                let uid = Auth.auth().currentUser!.uid
                let dbCollection = db.collection("users")
                dbCollection.document(uid).updateData(["seen": self.userSeen!]) { error in
                    if let error = error {
                        print(error)
                    }
                }
            }
        }
    }
    
    
    func isMatch(myUID: String, theirUID: String) -> Bool {
        var myMatches: [String] = []
        var theirLikes: [String] = []
        var theirMatches: [String] = []
        var matched: Bool = false
        
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser!.uid
        let dbCollection = db.collection("users")
        
        dbCollection.document(theirUID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching data for other user: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                print("Document for other user does not exist")
                return
            }
            
            let data = document.data()
            theirLikes = data?["liked"] as? [String] ?? []
            theirMatches = data?["matches"] as? [String] ?? []
            print(theirLikes)
            
            // Check for a match
            if theirLikes.contains(myUID) {
                myMatches.append(theirUID)
                dbCollection.document(uid).updateData(["matches": myMatches]) { error in
                    if let error = error {
                        print("Error updating my matches: \(error.localizedDescription)")
                    }
                }
                theirMatches.append(myUID)
                dbCollection.document(theirUID).updateData(["matches": theirMatches]) { error in
                    if let error = error {
                        print("Error updating other user's matches: \(error.localizedDescription)")
                    }
                }
                matched = true
            }
        }
        return matched
    }
    
    
    func findNewPerson() {
        for user in self.users {
            var useruid = user.uid
            if !self.userSeen.contains(useruid) && useruid != self.uid {
                self.notSeen.append(useruid)
            }
        }
        self.userShown = self.notSeen[0]
    }
    
    func showNewPerson(completion: @escaping (String?, Error?) -> Void){
        let filePath = "\(self.userShown)/\("userPhoto")"
        self.storageRef?.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
            let userPhoto = UIImage(data: data!)
            self.userImage.image = userPhoto
        } )
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser!.uid
        let dbCollection = db.collection("users")
        
        dbCollection.document(self.userShown).getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                var bio = data?["bio"] as? String ?? "No bio found"
                var name = data?["first_name"] as? String ?? "No name found"
                self.userBio.text = bio
                self.nameLabel.text = name
                completion(bio, nil)
            } else {
                print("document does not exist")
                completion(nil, nil)
            }
        }
        
        
        
        return
    }
    
    func getUserSeen(completion: @escaping ([String]?, Error?) -> Void) {
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser!.uid
        let dbCollection = db.collection("users")
        
        dbCollection.document(uid).getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                let seenArray = data?["seen"] as? [String] ?? []
                completion(seenArray, nil)
            } else {
                print("document does not exist")
                completion(nil, nil)
            }
        }
    }
    
}
