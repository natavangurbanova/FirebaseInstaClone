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
import SDWebImage

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
        NotificationCenter.default.addObserver(self, selector: #selector(reloadProfileData), name: .didUpdateProfileImage, object: nil)

        view.backgroundColor = .white
        setupViews()
    }
    @objc func reloadProfileData() {
        loadProfileData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfileData()
    }
    
    func loadProfileData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(userID).getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let document = document, document.exists {
                let data = document.data()
                
                // Fetch username and bio
                self.usernameLabel.text = data?["username"] as? String ?? "No username"
                self.bioLabel.text = data?["bio"] as? String ?? "No bio"
                
                // Fetch and load profile image
                if let profileImageUrl = data?["profileImageUrl"] as? String, let url = URL(string: profileImageUrl) {
                    print("Profile Image URL: \(profileImageUrl)") // Debug log
                    self.profileImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.circle"))
                } else {
                    print("No profileImageUrl found")
                    self.profileImageView.image = UIImage(systemName: "person.circle")
                }
            } else {
                print("Document does not exist: \(String(describing: error))")
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
extension Notification.Name {
    static let didUpdateProfileImage = Notification.Name("didUpdateProfileImage")
}

