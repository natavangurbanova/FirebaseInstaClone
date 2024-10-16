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
        let settingsVC = SettingsViewController()
        
        feedVC.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "house.fill"), tag: 0)
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 1)
        settingsVC.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 2)
        self.viewControllers = [feedVC, profileVC, settingsVC]
        
        
    }
    
    
    
    
    
    
    
}
