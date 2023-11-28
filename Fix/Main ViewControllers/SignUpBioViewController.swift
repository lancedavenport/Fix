//
//  SignUpBioViewController.swift
//  Fix
//
//  Created by Devin on 2023/11/27.
//

import UIKit

class SignUpBioViewController: UIViewController {
    
    var uid: String? = nil
    
    let toUserEnvironmentSegue = "toUserEnvironmentSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
