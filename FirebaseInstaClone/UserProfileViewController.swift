//
//  UserProfileViewController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 11.02.25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore
import SDWebImage

class UserProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var userID: String?
    private var isFollowing = false
    private var posts: [Post] = []
    
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
        label.text = "username"
        return label
    }()
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "No bio"
        label.textAlignment = .center
        return label
    }()
    
    let followButton: UIButton = {
        let button = UIButton()
        button.setTitle("Follow", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let postsLabel = UserProfileViewController.createStatLabel(text: "0\nPosts")
    private let followersLabel = UserProfileViewController.createStatLabel(text: "0\nFollowers")
    private let followingLabel = UserProfileViewController.createStatLabel(text: "0\nFollowing")
    
    
    private lazy var statsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    private let placeholderStackView: UIStackView = {
        let imageView = UIImageView(image: UIImage(systemName: "camera.fill"))
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
        }
        let titleLabel = UILabel()
        titleLabel.text = "No shared photos"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.isHidden = true
        
        return stackView
    }()
    
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupStackView()
        setupPlaceholderView()
        setupCollectionView()
        loadProfileData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfUserIsFollowed()
        loadProfileData()
    }
    
    private func setupViews() {
        view.addSubview(profileImageView)
        view.addSubview(usernameLabel)
        view.addSubview(bioLabel)
        view.addSubview(followButton)
        followButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(16)
            make.width.height.equalTo(100)
        }
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(30)
        }
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(16)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(16)
            make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.trailing).offset(-16)
        }
        followButton.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(20)
            make.leading.equalTo(profileImageView.snp.trailing).offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(30)
        }
    }
    
    private func setupStackView() {
        view.addSubview(statsStackView)
        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
    }
    
    private func setupPlaceholderView() {
        view.addSubview(placeholderStackView)
        placeholderStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(statsStackView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 100, height: 100)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UserPostCell.self, forCellWithReuseIdentifier: UserPostCell.identifier)
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    @objc func followButtonTapped() {
        guard let currentUserId = Auth.auth().currentUser?.uid, let userID = userID else {
            print("Error: Current user ID or user ID is nil.")
            return
        }
        
        let db = Firestore.firestore()
        let followersRef = db.collection("followers").document(userID).collection("userFollowers").document(currentUserId)
        
        followersRef.getDocument { snapshot, error in
            if let error = error {
                print("Error checking follow status: \(error.localizedDescription)")
                return
            }
            
            if snapshot?.exists == true {
                followersRef.delete { error in
                    if let error = error {
                        print("Error unfollowing user: \(error.localizedDescription)")
                        return
                    }
                    
                    db.collection("following").document(currentUserId).collection("userFollowing").document(userID).delete { error in
                        if let error = error {
                            print("Error removing from following list: \(error.localizedDescription)")
                            return
                        }
                        
                        self.followButton.setTitle("Follow", for: .normal)
                        self.followButton.backgroundColor = .black
                        self.loadProfileData()
                    }
                }
            } else {
                followersRef.setData([:]) { error in
                    if let error = error {
                        print("Error following user: \(error.localizedDescription)")
                        return
                    }
                    
                    db.collection("following").document(currentUserId).collection("userFollowing").document(userID).setData([:]) { error in
                        if let error = error {
                            print("Error adding to following list: \(error.localizedDescription)")
                            return
                        }
                        
                        self.followButton.setTitle("Following", for: .normal)
                        self.followButton.backgroundColor = .gray
                        self.loadProfileData()
                    }
                }
            }
        }
    }
    
    private func checkIfUserIsFollowed() {
        guard let currentUserId = Auth.auth().currentUser?.uid, let userID = userID else {
            print("Error: Current user ID or user ID is nil.")
            return
        }
        
        let db = Firestore.firestore()
        let followersRef = db.collection("followers").document(userID).collection("userFollowers").document(currentUserId)
        
        followersRef.getDocument { snapshot, error in
            if let error = error {
                print("Error checking follow status: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                if snapshot?.exists == true {
                    self.followButton.setTitle("Following", for: .normal)
                    self.followButton.backgroundColor = .gray
                } else {
                    self.followButton.setTitle("Follow", for: .normal)
                    self.followButton.backgroundColor = .black
                }
            }
        }
    }
    
    private func loadProfileData() {
        guard let userID = userID else {
            print("Error: User ID is nil.")
            return
        }
        
        let db = Firestore.firestore()
        
        // Fetch user profile data
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                return
            }
            
            if let data = snapshot?.data() {
                self.usernameLabel.text = data["username"] as? String ?? "No username"
                self.bioLabel.text = data["bio"] as? String ?? "No bio"
                
                if let profileImageUrl = data["profileImageUrl"] as? String {
                    self.profileImageView.sd_setImage(with: URL(string: profileImageUrl), placeholderImage: UIImage(systemName: "person.circle"))
                } else {
                    self.profileImageView.image = UIImage(systemName: "person.circle")
                }
            } else {
                print("User profile data not found for userID: \(userID)")
            }
        }
        
        // Fetch user posts
        db.collection("posts").document(userID).collection("userPosts").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user posts: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No posts found for user.")
                return
            }
            
            self.posts = documents.compactMap { doc -> Post? in
                let data = doc.data()
                guard let imageUrl = data["imageUrl"] as? String,
                      let timestamp = data["timestamp"] as? Timestamp else {
                    return nil
                }
                return Post(imageUrl: imageUrl, timestamp: timestamp.dateValue())
            }
            
            DispatchQueue.main.async {
                self.postsLabel.text = "\(self.posts.count)\nPosts"
                self.placeholderStackView.isHidden = !self.posts.isEmpty
                self.collectionView.reloadData()
            }
        }
    }

        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return posts.count
        }
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserPostCell.identifier, for: indexPath) as? UserPostCell else {
                return UICollectionViewCell()
            }
            let post = posts[indexPath.row]
            cell.configure(with: post.imageUrl)
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let post = posts[indexPath.row]
            let fullUsersImageVC = FullUsersImageViewController()
            fullUsersImageVC.postImageURL = post.imageUrl
            navigationController?.pushViewController(fullUsersImageVC, animated: true)
        }
        
        static func createStatLabel(text: String) -> UILabel {
            let label = UILabel()
            label.textAlignment = .center
            label.font = .boldSystemFont(ofSize: 14)
            label.text = text
            label.numberOfLines = 2
            return label
        }
        private func updateUI() {
            let hasPosts = !posts.isEmpty
            placeholderStackView.isHidden = hasPosts
            collectionView.isHidden = !hasPosts
        }
    }
    extension UIImageView {
        func loadImage(from urlString: String) {
            guard let url = URL(string: urlString) else { return }
            self.sd_setImage(with: url, completed: nil)
        }
    }
