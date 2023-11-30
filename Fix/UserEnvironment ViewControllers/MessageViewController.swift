//
//  MessageViewController.swift
//  Fix
//
//  Created by Devin on 2023/11/25.
//

import UIKit
import Firebase

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var chatRoomsTableView: UITableView!
    
    let messageRoomNames:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatRoomsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        chatRoomsTableView.delegate = self
        chatRoomsTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return messageRoomNames.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // show chat messages
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
