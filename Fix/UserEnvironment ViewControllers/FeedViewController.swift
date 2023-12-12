//
//  FeedViewController.swift
//  Fix
//
//  Created by Devin on 2023/11/25.
//

import UIKit
import Firebase
import FirebaseStorage

class FeedViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    let storage = Storage.storage()
    var storageRef: StorageReference? = nil
    var uid: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        getUser { (seenArray, error) in
            if let error = error {
                print(error)
            } else if let seenArray = seenArray {
                self.label.text = seenArray[0]
            }
            
        }
        self.storageRef = storage.reference()
        self.uid = Auth.auth().currentUser!.uid
        
    }

    
    func getUser(completion: @escaping ([String]?, Error?) -> Void) {
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser!.uid
        let dbCollection = db.collection("users")
        
        dbCollection.document(uid).getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            if let document = document, document.exists {
                let data = document.data()
                let seenArray = data?["seen"] as? [String] ?? []
                print(seenArray)
                completion(seenArray, nil)
            } else {
                print("document does not exist")
                completion(nil, nil)
            }
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
    
}
