//
//  LoginViewController.swift
//  Fix
//
//  Created by Devin on 2023/11/23.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var errorLabel: UILabel!
    
    @IBOutlet var loginButton: UIButton!

    @IBOutlet var forgetPasswordButton: UIButton!
    
    let toUserEnvironmentSegue = "toUserEnvironmentSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        errorLabel.alpha = 0
        passwordTextField.isSecureTextEntry = true
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        //Auth.auth().signIn(withEmail: "1@t.com", password: "123456Aa")
        //navigationController?.navigationBar.isHidden = true
        //goToUserEnvironment()
        
        // validate fields
        if isTextFieldEmpty(emailTextField) || isTextFieldEmpty(passwordTextField) {
            showError(errorLabel, "Enter email and password")
            return
        } else {
            errorLabel.alpha = 0
        }
        
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // log in
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.showError(self.errorLabel, "Password or email is incorrect")
                // Need to follow step on below link so it does not send fake error message caused by using simulator https://firebase.google.com/docs/app-check/ios/debug-provider
            } else {
                self.errorLabel.alpha = 0
                // hide navigation bar
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                // navigate to userEnvironment view and transfer user uid to userEnvironment
                self.goToUserEnvironment()
            }
        }
    }
    
    func goToUserEnvironment() {
        performSegue(withIdentifier: toUserEnvironmentSegue, sender: self)
    }
    
    
    @IBAction func forgetPasswordTapped(_ sender: Any) {
        let email = emailTextField.text ?? ""
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.showError(self.errorLabel, error.localizedDescription)
            } else {
                self.errorLabel.textColor = .black
                self.errorLabel.text = "Password reset email sent successfully"
                self.errorLabel.alpha = 1
                // disable button for 5 seconds
                self.forgetPasswordButton.isEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.forgetPasswordButton.isEnabled = true
                }
            }
        }
    }

    // Helper methods
    func showError(_ label: UILabel, _ errorMessage: String) {
        label.textColor = .systemRed
        label.text = errorMessage
        label.alpha = 1
    }
    
    func isTextFieldEmpty(_ textField: UITextField) -> Bool {
        return textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
    }
    
    
}
