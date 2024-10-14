//
//  ProfileViewController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 17.09.24.
//

import UIKit
import SnapKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Profile"
        
        setupLayout()
        
    }
    
    private func setupLayout() {
        let label = UILabel()
        label.text = "Welcome to your Profile"
        label.textColor = .black
        view.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    
    
    
    
}
