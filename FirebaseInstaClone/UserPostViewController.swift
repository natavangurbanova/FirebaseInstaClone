//
//  UserPostViewController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 12.02.25.
//

import UIKit
import SnapKit
import SDWebImage
import FirebaseAuth
import FirebaseFirestore

class UserPostViewController: UIViewController {
    
    var post: Post!
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        button.tintColor = .red
        return button
    }()
    
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        configureUI()
        let testRef = Firestore.firestore().collection("posts").document(post.userID).collection("userPosts").document(post.id)

        testRef.setData(["testField": "testValue"], merge: true) { error in
            if let error = error {
                print("Firestore write error: \(error.localizedDescription)")
            } else {
                print("Firestore write successful!")
            }
        }

    }
    
    
    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(likeButton)
        view.addSubview(likesLabel)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        likeButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(30)
        }
        likesLabel.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton)
            make.leading.equalTo(likeButton.snp.trailing).offset(10)
        }
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    private func configureUI() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        if let url = URL(string: post.imageUrl) {
            imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
        }
        
        let db = Firestore.firestore()
        let postRef = db.collection("posts").document(post.userID).collection("userPosts").document(post.id)
        
        postRef.getDocument { snapshot, error in
            if let data = snapshot?.data() {
                let fetchedLikes = data["likes"] as? Int ?? 0
                let fetchedLikedBy = data["likedBy"] as? [String] ?? []
                
                DispatchQueue.main.async {
                    self.post.likes = fetchedLikes
                    self.post.likedBy = fetchedLikedBy
                    self.likesLabel.text = "\(fetchedLikes) Likes"
                    self.likeButton.isSelected = fetchedLikedBy.contains(userID)
                }
            }
        }
    }
    
    @objc func likeButtonTapped() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        if post.likedBy.contains(userID) {
            post.likes -= 1
            post.likedBy.removeAll() { $0 == userID }
            likeButton.isSelected = false
        } else {
            post.likes += 1
            post.likedBy.append(userID)
            likeButton.isSelected = true
        }
        likesLabel.text = "\(post.likes) Likes"
        updateLikeCountInFirestore()
    }
    
    private func updateLikeCountInFirestore() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in!")
            return
        }
        
        let db = Firestore.firestore()
        let postRef = db.collection("posts").document(post.userID).collection("userPosts").document(post.id)
        
        postRef.getDocument { snapshot, error in
            if let error = error {
                print("Firestore read error: \(error.localizedDescription)")
                return
            }
            
            guard let document = snapshot, document.exists,
                  var currentLikes = document.data()?["likes"] as? Int,
                  var likedByUsers = document.data()?["likedBy"] as? [String] else {
                print("Post document missing or data incorrect")
                return
            }
            
            if likedByUsers.contains(userID) {
                currentLikes -= 1
                likedByUsers.removeAll { $0 == userID }
            } else {
                currentLikes += 1
                likedByUsers.append(userID)
            }
            
            postRef.updateData([
                "likes": currentLikes,
                "likedBy": likedByUsers
            ]) { error in
                if let error = error {
                    print("Error updating like count: \(error.localizedDescription)")
                } else {
                    print("Like count updated successfully in Firestore")
                }
            }
        }
    }
}
