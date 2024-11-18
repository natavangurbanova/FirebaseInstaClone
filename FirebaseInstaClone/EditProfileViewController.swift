//
//  EditProfileViewController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 28.10.24.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imageContainerView = UIView()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
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
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupGestureRecognizer()
        
        self.title = "Edit profile"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupViews() {
        view.addSubview(imageContainerView)
        imageContainerView.addSubview(profileImageView)
        imageContainerView.addSubview(placeholderLabel)
        view.addSubview(usernameLabel)
        view.addSubview(bioLabel)
        view.addSubview(saveButton)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        imageContainerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.width.height.equalTo(100)
        }
        [profileImageView, placeholderLabel].forEach {
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageContainerView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
    }
    
    private func setupGestureRecognizer() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func profileImageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func saveButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        
        profileImageView.image = selectedImage
        uploadProfileImage(selectedImage) { [weak self] url in
            if let url = url {
                 self?.saveProfileImageUrlToFirestore(url: url)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
       
        picker.dismiss(animated: true, completion: nil)
    }
    func uploadProfileImage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let imageDate = image.jpegData(compressionQuality: 0.75) else { return }
        
        let storageRef = Storage.storage().reference().child("profile_images/\(Auth.auth().currentUser?.uid ?? "user")_profile.jpg")
       // let metaData = StorageMetadata()
        //metaData.contentType = "image/jpeg"
        storageRef.putData(imageDate, metadata: nil) { metadata, error in
            if let error = error {
                print("Error: Failed to upload image \(error.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { url, error in
                if let url = url {
                    completion(url)
                } else {
                    completion(nil)
                }
            }
        }
    }
    func saveProfileImageUrlToFirestore(url: URL) {
            let db = Firestore.firestore()
            guard let userID = Auth.auth().currentUser?.uid else { return }
            
            db.collection("users").document(userID).updateData(["profileImageUrl": url.absoluteString]) { error in
                if let error = error {
                    print("Failed to save profile image URL to Firestore: \(error)")
                } else {
                    print("Profile image URL successfully saved!")
                }
            }
        }
    }
