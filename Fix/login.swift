//
//  login.swift
//  Fix
//
//  Created by Lance Davenport on 11/14/23.
//

import Foundation
import UIKit

class login: UIViewController {

    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var test: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func signup(_ sender: UIButton) {
        let test1: String? = String("\(email.text!) + \(password.text!)")
        test.text = test1
    }

}


