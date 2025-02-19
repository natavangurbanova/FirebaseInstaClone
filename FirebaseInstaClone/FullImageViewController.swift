//
//  FullImageViewController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 17.01.25.
//

import UIKit
import SnapKit
import SDWebImage
import FirebaseAuth
import FirebaseFirestore

class FullImageViewController: UIViewController {
    
    var post: Post!
    weak var delegate: FullImageViewControllerDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .red
        return button
    }()
    
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        configureUI()
    }
    
    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(likeButton)
        view.addSubview(likesLabel)
        view.addSubview(moreButton)
        
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
        moreButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(30)
        }
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
    }
    
    private func configureUI() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        if let url = URL(string: post.imageUrl) {
            imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
        }
        likesLabel.text = "\(post.likes) Likes"
        likeButton.isSelected = post.likedBy.contains(userID)
    }
    
    @objc func likeButtonTapped() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        if post.likedBy.contains(userID) {
            print("User has already liked this post")
            return
        }
        post.likes += 1
        post.likedBy.append(userID)
        likesLabel.text = "\(post.likes) Likes"
        likeButton.isSelected = true
        
        updateLikeCountInFirestore()
        delegate?.didUpdatePost(post)
    }
    
    @objc private func moreButtonTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { [weak self] _ in
            self?.deletePost()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func deletePost() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let postRef = db.collection("posts").document(userID).collection("userPosts").document(post.id)
        postRef.delete { [weak self] error in
            if let error = error {
                print("Error deleting post: \(error.localizedDescription)")
            } else {
                print("Post deleted successfully")
                self?.delegate?.didDeletePost(self?.post)
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func updateLikeCountInFirestore() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        let postRef =  db.collection("posts").document(userID).collection("userPosts").document(post.id)
        postRef.updateData([
            "likes" : post.likes,
            "likedBy": post.likedBy
        ]) { error in
            if let error = error {
                print("Error updating like count: \(error.localizedDescription)")
            } else {
                print("Like count updated successfully in Firestore")
            }
        }
    }
}
protocol FullImageViewControllerDelegate: AnyObject {
    func didUpdatePost(_ post: Post)
    func didDeletePost(_ post: Post?)
}
