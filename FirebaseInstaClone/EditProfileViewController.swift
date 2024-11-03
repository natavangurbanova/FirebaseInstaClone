//
//  EditProfileViewController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 28.10.24.
//

import Foundation
import SnapKit
import FirebaseAuth
import Firebase

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imageContainerView = UIView()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .black
        return imageView
    }()
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose an image"
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.text = "This is your bio"
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        
        self.title = "Edit profile"
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        
    }
    
    func setupViews() {
        view.addSubview(imageContainerView)
        imageContainerView.addSubview(profileImageView)
        imageContainerView.addSubview(placeholderLabel)
        view.addSubview(usernameLabel)
        view.addSubview(bioLabel)
        view.addSubview(editButton)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        
        imageContainerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.width.height.equalTo(100)
        }
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageContainerView.snp.bottom).offset(20)
            make.right.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
        }
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        editButton.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
    }
    
    @objc func editButtonTapped() {
        
    }
    
    
    
    
    
    
    
    
}
