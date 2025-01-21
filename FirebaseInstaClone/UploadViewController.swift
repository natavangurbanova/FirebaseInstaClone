//
//  UploadViewController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 19.12.24.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let uploadButton: UIButton = {
        let button = UIButton()
        button.setTitle("Upload", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupButton()
    }
    
    private func setupButton() {
        view.addSubview(uploadButton)
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
        
        uploadButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }
    
    @objc func uploadButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            self.selectedImage = image
            uploadImageToFirebase(image: image)
        }
    }
    
    private func uploadImageToFirebase(image: UIImage) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("posts/\(userID)/\(UUID().uuidString).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to get image data")
            return
        }
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error.localizedDescription)")
                    return
                }
                if let url = url {
                    self.savePostToFirestore(imageUrl: url.absoluteString)
                }
            }
        }
    }
    
    private func savePostToFirestore(imageUrl: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let postData: [String: Any] = [
            "ownerId": userID,
            "imageUrl": imageUrl,
            "caption": "",
            "timestamp": Timestamp(date: Date())
        ]
        
        db.collection("posts").addDocument(data: postData) { error in
            if let error = error {
                print("Error saving post: \(error.localizedDescription)")
            } else {
                print("Post saved successfully!")
                self.updateProfilePostCount()
                self.tabBarController?.selectedIndex = 1 // Switch to Profile tab after upload
            }
        }
    }
    
    private func updateProfilePostCount() {
        if let tabBarVC = self.tabBarController,
           let profileVC = (tabBarVC.viewControllers?[1] as? UINavigationController)?.topViewController as? ProfileViewController,
           let userID = Auth.auth().currentUser?.uid {
            profileVC.updatePostCount(for: userID)
        }
    }
}
