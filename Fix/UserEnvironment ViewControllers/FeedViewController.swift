//
//  FeedViewController.swift
//  Fix
//
//  Created by Devin on 2023/11/25.
//

import UIKit

class FeedViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let uid = getUid() {
            label.text = uid
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //Helper methods
    
    func getUid() -> String? {
        if let tabBarController = tabBarController as? UserEnvironmentTabBarController {
            if let uid = tabBarController.uid {
                return uid
            }
            return nil
        }
        return nil
    }
    
}
