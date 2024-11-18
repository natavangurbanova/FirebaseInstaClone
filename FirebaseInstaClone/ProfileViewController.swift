//
//  ProfileViewController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 17.09.24.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .black
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.text = "Username"
        return label
    }()
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "This is your bio"
        return label
    }()
    
    let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit profile", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    let logOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        return button
    }()
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func loadProfileImage() {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userID).getDocument { document, error in
            if let document = document, document.exists {
                if let profileImageUrl = document.data()?["profileImageUrl"] as? String, let url = URL(string: profileImageUrl) {
                    self.profileImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.circle"))
                }
            } else {
                print("Error fetching profile image URL: \(String(describing: error))")
            }
        }
    }

    
    private func setupViews() {
        view.addSubview(profileImageView)
        view.addSubview(usernameLabel)
        view.addSubview(bioLabel)
        view.addSubview(editProfileButton)
        view.addSubview(logOutButton)
        editProfileButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        logOutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        editProfileButton.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
        logOutButton.snp.makeConstraints { make in
            make.top.equalTo(editProfileButton.snp.bottom).offset(20)
            make.center.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
        
    }
    
    @objc func editProfileTapped() {
        let editProfileVC = EditProfileViewController()
        //let navController = UINavigationController(rootViewController: editProfileVC)
       // navController.modalPresentationStyle = .fullScreen
        //self.present(navController, animated: true, completion: nil)
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    @objc func logOut() {
        do {
            try Auth.auth().signOut()
            let loginViewController = ViewController()
            let navController = UINavigationController(rootViewController: loginViewController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print("Error signing out %@", signOutError)
        }
    }

    
}
