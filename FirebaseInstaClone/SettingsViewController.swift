//
//  SettingsViewController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 15.10.24.
//

import Foundation
import SnapKit
import Firebase

class SettingsViewController: UIViewController {
 
    let logOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        view.addSubview(logOutButton)
        logOutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
    }
    
    func setupConstraints() {
        logOutButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }
    
    @objc func logOut() {
        do {
            try Auth.auth().signOut()
            let loginViewController = ViewController()
            let navController = UINavigationController(rootViewController: loginViewController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    
    
    
    
    
}


