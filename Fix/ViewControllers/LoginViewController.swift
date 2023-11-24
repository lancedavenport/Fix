//
//  LoginViewController.swift
//  Fix
//
//  Created by Devin on 2023/11/23.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        errorLabel.alpha = 0
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        // validate fields
        if isTextFieldEmpty(emailTextField) || isTextFieldEmpty(passwordTextField) {
            showError(errorLabel, "Enter email and password")
            //need to follow step on below link so it does not send fake error message caused by using simulator https://firebase.google.com/docs/app-check/ios/debug-provider
            return
        } else {
            errorLabel.alpha = 0
        }
        
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // log in
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.showError(self.errorLabel, error.localizedDescription)
            } else {
                // store user id and info
                // navigate to userEnvironment view
            }
        }
        
    }
    
    // Helper functions
    func showError(_ label: UILabel, _ errorMessage: String) {
        label.text = errorMessage
        label.alpha = 1
    }
    
    func isTextFieldEmpty(_ textField: UITextField) -> Bool {
        return textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
    }
    
    
}
