//
//  SignUpViewController.swift
//  Fix
//
//  Created by Devin on 2023/11/23.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase

class SignUpViewController: UIViewController {

    // Outlets for the user input fields.
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    @IBOutlet weak var comfirmPasswordTextField: UITextField!
    
    // Outlet for the sign-up button.
    @IBOutlet weak var signUpButton: UIButton!
    
    // Outlet for displaying error messages.
    @IBOutlet weak var errorLabel: UILabel!
    
    // Identifier for the segue to the next screen.
    let toSignUpBioSegue = "toSignUpBioSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initial setup for the view.
        errorLabel.alpha = 0  // Initially hide the error label.
        passWordTextField.isSecureTextEntry.toggle()  // Secure entry for password.
        comfirmPasswordTextField.isSecureTextEntry.toggle()  // Secure entry for password confirmation.
    }
    
    func validateFields() -> String? {
        // Validation logic for each field.
        if isTextFieldEmpty(firstNameTextField) || isTextFieldEmpty(lastNameTextField) {
            return "Enter your first and last name"
        }
        if isTextFieldEmpty(emailTextField) {
            return "Enter your email address"
        }
        if let email = emailTextField.text, !isValidEmailAddr(strToValidate: email) {
            return "Enter a correct email address"
        }
        if isTextFieldEmpty(passWordTextField) {
            return "Enter a password to use"
        }
        if let password = passWordTextField.text, !isPasswordValid(password) {
            return "Password needs to contain at least one digit, one upper case letter, one lower case letter, and be 8 characters long"
        }
        if isTextFieldEmpty(comfirmPasswordTextField) {
            return "Confirm your password"
        }
        if let pw = passWordTextField.text, let cpw = comfirmPasswordTextField.text, pw != cpw {
            return "Your password confirmation does not match your password"
        }
        return nil
        // Returns a string if there is an error, or nil if everything is fine.
    }
    
    // Action for the sign-up button.
    @IBAction func signUpTapped(_ sender: Any) {
        // Check for validation errors.
        if let error = validateFields() {
            showError(errorLabel, error)  // Show the error if present.
            return
        }
        
        // goToSignUpBio()
        
        // validate SignUp screen's information fields, print error if needed
        if isTextFieldEmpty(firstNameTextField) || isTextFieldEmpty(lastNameTextField){
            showError(errorLabel, "Enter your first and last name")
            return
        }
        if isTextFieldEmpty(emailTextField) {
            showError(errorLabel, "Enter your email address")
            return
        }
        if let email = emailTextField.text, !isValidEmailAddr(strToValidate: email) {
            showError(errorLabel, "Enter a correct email address")
            return
        }
        if isTextFieldEmpty(passWordTextField) {
            showError(errorLabel, "Enter a passord to use")
            return
        }
        if let password = passWordTextField.text, !isPasswordValid(password) {
            showError(errorLabel, "Password need to contain at least one digit, one upper case letter, one lower case letter, and be 8 characters long")
            return
        }
        if isTextFieldEmpty(comfirmPasswordTextField) {
            showError(errorLabel, "Comfirm your password")
            return
        }
        if let pw = passWordTextField.text, let cpw = comfirmPasswordTextField.text, pw != cpw {
            showError(errorLabel, "Your password comfirmation does not match your password")
            return
        }
        
        errorLabel.alpha = 0
        
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passWordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // create user
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showError(self.errorLabel, "Error creating user: \(error.localizedDescription)")
            } else {
                // success creating user, store user info to database
                let db = Firestore.firestore()
                let uid = authResult!.user.uid
                let dbCollection = db.collection("users")
                
                let userData: [String: Any] = [
                    "first_name": firstName,
                    "last_name": lastName,
                    "uid": uid,
                    "email": email,
                    "bio": "",
                    "seen": [],
                    "matches": [],
                    "friends": []
                ]
                
                dbCollection.document(uid).setData(userData) { error in
                    if let error = error {
                        self.showError(self.errorLabel, "User created but failed to save data to db: \(error.localizedDescription)")
                    } else {
                        self.errorLabel.text = "Successfully created and added new user data to db."
                        self.errorLabel.textColor = UIColor.black
                        self.errorLabel.alpha = 1
                    }
                }
                
                let realTimeDB = Database.database().reference()
                realTimeDB.child("users").child(uid).setValue(true) { (error, ref) in
                    if let error = error {
                        self.showError(self.errorLabel, "User created but failed to save data to real-time db: \(error.localizedDescription)")
                    } else {
                        self.errorLabel.text = "Successfully created and added new user data to db and real-time db."
                        self.errorLabel.textColor = UIColor.black
                        self.errorLabel.alpha = 1
                    }
                }
                                                        
                //hide navigation bar
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                // navigate to userEnvironment view and transfer user uid to userEnvironment
                self.goToSignUpBio()
            }
        }
    }
    
    // Navigates to the next part of the sign-up process.
    func goToSignUpBio() {
        performSegue(withIdentifier: toSignUpBioSegue, sender: self)
    }
    
    // Helper methods
    
    // Displays an error message on the specified label.
    func showError(_ label: UILabel, _ errorMessage: String) {
        label.text = errorMessage
        label.alpha = 0
        UIView.animate(withDuration: 1.0) {
            label.alpha = 1
        }
    }
    
    // Checks if a text field is empty.
    func isTextFieldEmpty(_ textField: UITextField) -> Bool {
        return textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    }
    
    // Validates an email address.
    func isValidEmailAddr(strToValidate: String) -> Bool {
      let emailValidationRegex = "^[\\p{L}0-9!#$%&'*+\\/=?^_`{|}~-][\\p{L}0-9.!#$%&'*+\\/=?^_`{|}~-]{0,63}@[\\p{L}0-9-]+(?:\\.[\\p{L}0-9-]{2,7})*$"

      let emailValidationPredicate = NSPredicate(format: "SELF MATCHES %@", emailValidationRegex)

      return emailValidationPredicate.evaluate(with: strToValidate)
    }
    
    // ensure password Is at least 8 characters long. Contains at least one lowercase letter, one uppercase letter, and one digit.
    func isPasswordValid(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])[A-Za-z\\d]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
}
