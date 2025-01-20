//
//  TabBarViewController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 17.09.24.
//

import UIKit
import SnapKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        let feedVC = FeedViewController()
        let profileVC = ProfileViewController()
        let uploadVC = UploadViewController()
        
        let feedNavController = UINavigationController(rootViewController: feedVC)
        let profileNavController = UINavigationController(rootViewController: profileVC)
        let uploadNavController = UINavigationController(rootViewController: uploadVC)
        
        feedVC.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "house.fill"), tag: 0)
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 1)
        uploadVC.tabBarItem = UITabBarItem(title: "Upload", image: UIImage(systemName: "plus.app"), tag: 2)
        viewControllers = [feedNavController, profileNavController, uploadNavController]
        
        
    }
    
    
    
    
    
    
    
}
