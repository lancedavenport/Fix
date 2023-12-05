//
//  EditUserProfileViewController.swift
//  Fix
//
//  Created by Lance Davenport on 11/29/23.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class EditUserProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var errorText: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var editPassword: UITextField!
    @IBOutlet weak var userBio: UITextField!
    
    var uid: String? = nil
    
    var userChangedImage = false
    
    let storage = Storage.storage()
    
    var storageRef: StorageReference? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        profilePicture.setCircular()
        errorText.alpha = 0
        self.storageRef = storage.reference()
        self.uid = Auth.auth().currentUser!.uid
        loadSavedUserImageTo(imageView: profilePicture)
    }
    
    
    @IBAction func changePhotoTapped(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = true
        self.present(image, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profilePicture.image = image
        }
        userChangedImage = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func confirmChangesTapped(_ sender: Any) {
        if userChangedImage {
            var data = Data()
            data = profilePicture.image!.jpegData(compressionQuality: 0.8)!
            let filePath = "\(Auth.auth().currentUser!.uid)/\("userPhoto")"
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            self.storageRef?.child(filePath).putData(data, metadata: metaData){(metaData,error) in
                if let error = error {
                    self.showError(self.errorText, "\(error.localizedDescription)")
                    return
                }
            }
        }
        
        if !isTextFieldEmpty(editPassword) && isTextFieldEmpty(confirmPassword){
            showError(errorText, "Please confirm your password")
            return
        }
    
        if !isTextFieldEmpty(editPassword) && !isTextFieldEmpty(confirmPassword){
            if let pw = editPassword.text, let cpw = confirmPassword.text, pw != cpw {
                showError(errorText, "Your password comfirmation does not match your password")
                return
            } else {
                let password = confirmPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                if !isPasswordValid(password) {
                    showError(errorText, "Password need to contain at least one digit, one upper case letter, one lower case letter, and be 8 characters long")
                    return
                }
                Auth.auth().currentUser?.updatePassword(to: password) { (error) in
                    if let error = error {
                        self.showError(self.errorText, "fail to update password:  \(error.localizedDescription)")
                        return
                    }
                }
            }
        }
        
        if !isTextFieldEmpty(userBio) {
            let db = Firestore.firestore()
            let uid = Auth.auth().currentUser!.uid
            let dbCollection = db.collection("users")
            
            dbCollection.document(uid).updateData(["bio" : userBio.text!]) { error in
                if let error = error {
                    self.showError(self.errorText, "Failed to save bio to db: \(error.localizedDescription)")
                }
            }
        }
        
        errorText.textColor = .black
        errorText.text = "Updates made is successfully saved"
        errorText.alpha = 1
    }

    // Helper functions
    
    func loadSavedUserImageTo(imageView: UIImageView) {
        let filePath = "\(Auth.auth().currentUser!.uid)/\("userPhoto")"
        self.storageRef?.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
            let userPhoto = UIImage(data: data!)
            imageView.image = userPhoto
        } )
    }
    
    func showError(_ label: UILabel, _ errorMessage: String) {
        label.textColor = .systemRed
        label.text = errorMessage
        label.alpha = 1
    }

    func isTextFieldEmpty(_ textField: UITextField) -> Bool {
        return textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
    }
    
    func isPasswordValid(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])[A-Za-z\\d]{8,}")
        return passwordTest.evaluate(with: password)
    }
}
