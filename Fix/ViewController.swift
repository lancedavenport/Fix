//
//  ViewController.swift
//  Fix
//
//  Created by Lance Davenport on 11/6/23.
//

import UIKit

class ViewController: UIViewController {

    
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
