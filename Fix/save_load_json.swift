//
//  save_load_json.swift
//  Fix
//
//  Created by Lance Davenport on 11/16/23.
//

import Foundation
import UIKit


class save_load_jason: UIViewController {
    let filename = "userdata.json"

    func fileUrl() -> URL {
        let documentURL = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentURL.appendingPathComponent("data.json")
    }
    
    func addJson(data: person) {
    
        var datatoSave: [person] = []
        if var oldWords:[person] = getJsonData() as [person]? {
            oldWords.append(data)
            datatoSave = oldWords
        } else {
            datatoSave.append(data)
        }
              
          
        let anotherSorted = datatoSave.sorted(by: {
                  (a, b) in
            return a.name < b.name
        })
              
        let url = fileUrl()
        if let jsonData = try? JSONSerialization.data(withJSONObject: anotherSorted, options: []) {
            try? jsonData.write(to: url)
            print(data)
        } else {
            print("Failed to save")
        }
    }
    func getJsonData() -> [person]? {
        let url = fileUrl()
        let responseData: Data? = try? Data(contentsOf: url)
        if let responseData = responseData {
            let json = try? JSONSerialization.jsonObject(with: responseData, options: [])
            if let dictionary: [person] = json as? [person] {
                return dictionary
            }
        }
        return nil
    }
  
}

