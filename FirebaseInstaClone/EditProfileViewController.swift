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
    
    let bioTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "This is your bio"
        textField.textAlignment = .center
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 20)
        return textField
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
        
        fetchProfileData()
    }
    
    private func fetchProfileData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(userID)
        
        userRef.getDocument { [weak self] document, error in
            guard let self = self, let data = document?.data(), error == nil else {
                print("Failed to fetch user data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let bio = data["bio"] as? String {
                self.bioTextField.text = bio
            }
            
            if let profileImageUrl = data["profileImageUrl"] as? String, let url = URL(string: profileImageUrl) {
                self.loadImage(from: url)
            }
        }
    }
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self?.profileImageView.image = UIImage(data: data)
                self?.placeholderLabel.isHidden = true
            }
        }.resume()
    }
    
    private func setupViews() {
        view.addSubview(imageContainerView)
        imageContainerView.addSubview(profileImageView)
        imageContainerView.addSubview(placeholderLabel)
        view.addSubview(usernameLabel)
        view.addSubview(bioTextField)
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
        bioTextField.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(bioTextField.snp.bottom).offset(40)
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
        guard let selectedImage = profileImageView.image else {
            print("Error: No image selected.")
            return
        }
        uploadProfileImage(selectedImage) { [weak self] url in
            guard let self = self, let imageUrl = url?.absoluteString else {
                print("Failed to get download URL")
                return
            }
            
            let bioText = self.bioTextField.text?.isEmpty == false ? self.bioTextField.text! : self.bioTextField.placeholder ?? ""
            
            let data: [String: Any] = ["profileimageUrl": imageUrl, "bio": bioText]
            self.updateFirestoreData(data) {
                NotificationCenter.default.post(name: .didUpdateProfileImage, object: nil)
                self.navigationController?.popViewController(animated: true)
            }
        }
        handleSaveButtonTapped(selectedImage: selectedImage)
    }
    
    func handleSaveButtonTapped(selectedImage: UIImage) {
        uploadProfileImage(selectedImage) { [weak self] url in
            guard let self = self else { return }
            if let url = url {
                // Save the download URL to Firestore
                self.saveProfileImageUrlToFirestore(url: url)
                
                // Notify ProfileVC to reload the image
                NotificationCenter.default.post(name: .didUpdateProfileImage, object: nil)
                
                // Navigate back to ProfileVC
                self.navigationController?.popViewController(animated: true)
            } else {
                print("Failed to get download URL")
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("No image selected")
            return
        }
        profileImageView.image = selectedImage
        placeholderLabel.isHidden = true
    }
    
    func uploadProfileImage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("Error: Failed to convert image to JPEG data.")
            completion(nil)
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: No authenticated user found")
            completion(nil)
            return
        }
        
        let storageRef = Storage.storage().reference().child("profile_images").child("\(userID).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error.localizedDescription)")
                    completion(nil)
                } else if let url = url {
                    print("Successfully uploaded image. Download URL: \(url.absoluteString)")
                    completion(url)
                } else {
                    print("Unknown error occurred while fetching download URL")
                    completion(nil)
                }
            }
        }
    }
    
    func saveProfileImageUrlToFirestore(url: URL) {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let userRef = db.collection("users").document(userID)
        userRef.getDocument { document, error in
            if let error = error {
                print("Failed to fetch user document \(error.localizedDescription)")
                return
            }
            
            guard document?.exists == true else {
                print("Error: User document does not exist.")
                return
            }
            userRef.updateData(["profileImageUrl": url.absoluteString]) { error in
                if let error = error {
                    print("Failed to save profile image URL to Firestore: \(error)")
                } else {
                    print("Profile image URL successfully saved!")
                }
            }
        }
    }
    private func updateFirestoreData(_ data: [String: Any], completion: (() -> Void)? = nil) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(userID)
        userRef.updateData(data) { error in
            if let error = error {
                print("Failed to update Firestore: \(error)")
            } else {
                print("Successfully updated Firestore.")
                completion?()
            }
        }
    }
    
    func saveBioToFirestore(bio: String) {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let userRef = db.collection("users").document(userID)
        userRef.getDocument { document, error in
            if let error = error {
                print("Failed to fetch user document for bio \(error.localizedDescription)")
                return
            }
            
            guard document?.exists == true else {
                print("Error: User document does not exist.")
                return
            }
            
            userRef.updateData(["bio" : bio]) { error in
                if let error = error {
                    print("Failed to save bio to Firestore: \(error)")
                } else {
                    print("Bio successfully saved!  ")
                }
            }
        }
    }
    
    
    
}

