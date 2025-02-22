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
    var likes: Int
    var likedBy: [String]
    let userID: String
    
    init(id: String, imageUrl: String, caption: String, likes: Int = 0, likedBy: [String] = [], userID: String) {
        self.id = id
        self.imageUrl = imageUrl
        self.caption = caption
        self.likes = likes
        self.likedBy = likedBy
        self.userID = userID
    }
}
