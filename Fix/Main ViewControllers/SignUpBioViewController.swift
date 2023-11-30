//
//  SignUpBioViewController.swift
//  Fix
//
//  Created by Devin on 2023/11/27.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class SignUpBioViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var uid: String? = nil
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var errorText: UILabel!
    
    @IBOutlet weak var userBio: UITextField!
    
    let storage = Storage.storage()
    var storageRef: StorageReference? = nil
    
    let toUserEnvironmentSegue = "toUserEnvironmentSegue"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.storageRef = storage.reference()
        self.uid = Auth.auth().currentUser!.uid
        errorText.alpha = 0
    }
    
    @IBAction func saveImage(_ sender: UIButton) {
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        image.allowsEditing = true
        
        self.present(image, animated: true) 
        {
            
        }
    }
    
    @IBAction func saveData(_ sender: Any) {
        
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser!.uid
        let dbCollection = db.collection("users")
        
        dbCollection.document(uid).updateData(["bio" : userBio.text!]) { error in
            if let error = error {
                self.showError(self.errorText, "Photo saved but failed to save bio to db: \(error.localizedDescription)")
            } else {
                self.errorText.text = "Successfully created and added users bio to db."
                self.errorText.textColor = UIColor.black
                self.errorText.alpha = 1
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image

            var data = Data()
            data = imageView.image!.jpegData(compressionQuality: 0.8)!
            let filePath = "\(Auth.auth().currentUser!.uid)/\("userPhoto")"
            let metaData = StorageMetadata()

            metaData.contentType = "image/jpg"
            self.storageRef?.child(filePath).putData(data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else {
                    
                }
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
        
    func showError(_ label: UILabel, _ errorMessage: String) {
            label.textColor = .systemRed
            label.text = errorMessage
            label.alpha = 1
    }
    // store user entered bio, etc, then navigate to userEnvironment TabController
    @IBAction func nextTapped(_ sender: Any) {
        // store user Bio info to database
        goToUserEnvironment()
    }
    
    func goToUserEnvironment() {
        performSegue(withIdentifier: toUserEnvironmentSegue, sender: self)
    }

}
