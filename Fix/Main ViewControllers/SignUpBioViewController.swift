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
    
    var uid: String? = "123"
    
    @IBOutlet weak var imageView: UIImageView!
    
    let storage = Storage.storage()
    var storageRef: StorageReference? = nil
    
    let toUserEnvironmentSegue = "toUserEnvironmentSegue"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.storageRef = storage.reference()
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image

            var data = Data()
            data = imageView.image!.jpegData(compressionQuality: 0.8)!
            let filePath = "\(Auth.auth().currentUser!.uid )/\("userPhoto")"
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            self.storageRef?.child(filePath).putData(data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
            
            print(image)
        } else
            {
            // Error
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    // store user entered bio, etc, then navigate to userEnvironment TabController
    @IBAction func nextTapped(_ sender: Any) {
        // store user Bio info to database
        
        goToUserEnvironment()
    }
    
    func goToUserEnvironment() {
        performSegue(withIdentifier: toUserEnvironmentSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toUserEnvironmentSegue {
            if let tabBarVC = segue.destination as? UserEnvironmentTabBarController {
                tabBarVC.uid = uid
            } else {
                return
            }
        }
    }


}
