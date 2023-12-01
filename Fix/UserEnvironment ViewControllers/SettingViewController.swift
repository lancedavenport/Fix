//
//  SettingViewController.swift
//  Fix
//
//  Created by Devin on 2023/11/25.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabaseInternal


class SettingViewController: UIViewController {

    @IBOutlet weak var profilePicture: UIImageView!
    
    let toEditUserProfileSegue = "toEdituserProfileSegue"
    let toMainSegue = "toMainSegue"
    let storage = Storage.storage()
    var storageRef: StorageReference? = nil
    var uid: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.storageRef = storage.reference()
        self.uid = Auth.auth().currentUser!.uid
        profilePicture.setCircular()
        loadSavedUserImageTo(imageView: profilePicture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadSavedUserImageTo(imageView: profilePicture)
    }

    @IBAction func logoutTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        performSegue(withIdentifier: toMainSegue, sender: self)
    }
    
    @IBAction func editProfileTapped(_ sender: Any) {
        performSegue(withIdentifier: toEditUserProfileSegue, sender: self)
    }
    
    
    // helper methods
    func loadSavedUserImageTo(imageView: UIImageView) {
        let filePath = "\(Auth.auth().currentUser!.uid)/\("userPhoto")"
        self.storageRef?.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
            let userPhoto = UIImage(data: data!)
            imageView.image = userPhoto
        } )
    }
}
