import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class SignUpBioViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var uid: String? {
        return Auth.auth().currentUser?.uid
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var errorText: UILabel!
    @IBOutlet weak var userBio: UITextField!
    
    let storage = Storage.storage()
    var storageRef: StorageReference? {
        return storage.reference()
    }
    
    let toUserEnvironmentSegue = "toUserEnvironmentSegue"

    override func viewDidLoad() {
        super.viewDidLoad()
        errorText.alpha = 0
        imageView.setCircular()
        loadDefaultImage()
    }
    
    private func loadDefaultImage() {
        let filePath = "default/picture.jpg"
        Storage.storage().reference().child(filePath).getData(maxSize: 10*1024*1024) { [weak self] data, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showError("Error loading default image from Firebase storage: \(error.localizedDescription)")
            } else if let data = data, let image = UIImage(data: data) {
                self.imageView.image = image
            }
        }
    }
    
    @IBAction func saveImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
        }
        dismiss(animated: true)
    }
    
    func showError(_ errorMessage: String) {
        DispatchQueue.main.async {
            self.errorText.textColor = .systemRed
            self.errorText.text = errorMessage
            self.errorText.alpha = 1
        }
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        storeUserInfo()
    }
    
    private func storeUserInfo() {
        guard let bioText = userBio.text, !bioText.isEmpty else {
            showError("Bio cannot be empty.")
            return
        }
        storeBioInDatabase(bioText)
        if let image = imageView.image {
            uploadImage(image)
        }
    }
    
    private func storeBioInDatabase(_ bioText: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid!).updateData(["bio" : bioText]) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.showError("Photo saved but failed to save bio to db: \(error.localizedDescription)")
            } else {
                self.showMessage("Successfully created and added user's bio to db.")
            }
        }
    }
    
    private func uploadImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let filePath = "\(uid!)/userPhoto"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"

        storageRef?.child(filePath).putData(data, metadata: metaData) { [weak self] metaData, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showError(error.localizedDescription)
            } else {
                // Handle successful upload if needed
            }
        }
    }
    
    private func showMessage(_ message: String) {
        DispatchQueue.main.async {
            self.errorText.text = message
            self.errorText.textColor = .black
            self.errorText.alpha = 1
        }
    }
    
    private func goToUserEnvironment() {
        performSegue(withIdentifier: toUserEnvironmentSegue, sender: self)
    }
}
