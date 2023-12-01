//
//  extensions.swift
//  Fix
//
//  Created by Devin on 2023/11/30.
//

import Foundation
import UIKit

extension UIImageView {
    func setCircular() {
        self.contentMode = .scaleAspectFill
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}
