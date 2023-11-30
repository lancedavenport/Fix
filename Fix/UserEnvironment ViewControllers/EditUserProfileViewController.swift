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
    
    var uid: String? = nil
    

    @IBOutlet weak var errorText: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var editPassword: UITextField!
    @IBOutlet weak var userBio: UITextField!
    
    let storage = Storage.storage()
    var storageRef: StorageReference? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.storageRef = storage.reference()
        self.uid = Auth.auth().currentUser!.uid
        errorText.alpha = 0
    }
    
    @IBAction func changePhoto(_ sender: Any) {
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
    
    @IBAction func confirmChanges(_ sender: Any) {
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
                        print(error.localizedDescription)
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
                    self.showError(self.errorText, "Photo saved but failed to save bio to db: \(error.localizedDescription)")
                } else {
                    self.errorText.text = "Successfully created and added users bio to db."
                    self.errorText.textColor = UIColor.black
                    self.errorText.alpha = 1
                }
            }
        }
        
        goToSettings()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // Helper functions
    
    func showError(_ label: UILabel, _ errorMessage: String) {
        label.textColor = .systemRed
        label.text = errorMessage
        label.alpha = 1
    }
    
    func goToSettings() {
        performSegue(withIdentifier: "toSettings", sender: self)
    }
    func isTextFieldEmpty(_ textField: UITextField) -> Bool {
        return textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
    }
    
    func isPasswordValid(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])[A-Za-z\\d]{8,}")
        return passwordTest.evaluate(with: password)
    }
}
