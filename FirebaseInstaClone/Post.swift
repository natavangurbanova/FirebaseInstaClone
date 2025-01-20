//
//  Post.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 16.01.25.
//

import Foundation
import UIKit
import SnapKit

struct Post {
    let id: String
    let imageUrl: String
    let caption: String
    
    init(id: String, imageUrl: String, caption: String) {
        self.id = id
        self.imageUrl = imageUrl
        self.caption = caption
    }
}
