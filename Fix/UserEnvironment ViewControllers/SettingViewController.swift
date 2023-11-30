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
    
    let storage = Storage.storage()
    var storageRef: StorageReference? = nil
    var uid: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.storageRef = storage.reference()
        self.uid = Auth.auth().currentUser!.uid
        
        loadUserImage()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func logout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func goToMain() {
        performSegue(withIdentifier: "toMain", sender: self)
    }
    func loadUserImage() {
        let filePath = "\(Auth.auth().currentUser!.uid)/\("userPhoto")"
        self.storageRef?.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
            let userPhoto = UIImage(data: data!)
            self.profilePicture.image = userPhoto
        } )
    }
}
