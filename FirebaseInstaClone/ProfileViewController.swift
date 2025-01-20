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

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        label.numberOfLines = 1
        label.textAlignment = .center
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
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let postsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "0\nPosts"
        label.numberOfLines = 2
        return label
    }()
    
    private let followersLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "0\nFollowers"
        label.numberOfLines = 2
        return label
    }()
    
    private let followingLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "0\nFollowing"
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var statsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stack.axis = .horizontal
        stack.layer.borderColor = UIColor.lightGray.cgColor
        stack.layer.borderWidth = 1.0
        stack.layer.cornerRadius = 5
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    private var posts: [Post] = []
    private var collectionView: UICollectionView!
    
    private let placeholderView = UIView()
        private let cameraImageView: UIImageView = {
            let imageView = UIImageView(image: UIImage(systemName: "camera"))
            imageView.tintColor = .gray
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        private let sharePhotosLabel: UILabel = {
            let label = UILabel()
            label.text = "Share photos"
            label.font = UIFont.boldSystemFont(ofSize: 24)
            label.textColor = .darkGray
            return label
        }()
        private let sharePhotosDescriptionLabel: UILabel = {
            let label = UILabel()
            label.text = "When you share photos, they will appear on your profile"
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .gray
            label.textAlignment = .center
            label.numberOfLines = 0
            return label
        }()

    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadProfileData), name: .didUpdateProfileImage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadProfileData), name: .didUpdateProfileData, object: nil)

        view.backgroundColor = .white
        setupViews()
        setupStackView()
        setupPlaceholderView()
        setupCollectionView()
        loadPosts()
    }
    @objc func reloadProfileData() {
        loadProfileData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfileData()
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
            updatePostCount(for: currentUserId)
            updateFollowerCount(for: currentUserId)
            updateFollowingCount(for: currentUserId)
    }
    
    func updatePostCount(for userID: String) {
        let postsRef = Firestore.firestore().collection("posts").whereField("ownerId", isEqualTo: userID)
        postsRef.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let count = snapshot?.documents.count {
                self.postsLabel.text = "\(count)\nPosts"
                self.collectionView.reloadData()
                self.placeholderView.isHidden = count > 0
            } else {
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
        }
    }

    func updateFollowerCount(for userID: String) {
        let followersRef = Firestore.firestore().collection("users").document(userID).collection("followers")
        followersRef.getDocuments { snapshot, error in
            if let count = snapshot?.documents.count {
                self.followersLabel.text = "\(count)\nFollowers"
            } else {
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
        }
    }
    func updateFollowingCount(for userID: String) {
        let followingRef = Firestore.firestore().collection("users").document(userID).collection("following")
        followingRef.getDocuments { snapshot, error in
            if let count = snapshot?.documents.count {
                self.followingLabel.text = "\(count)\nFollowing"
            } else {
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
        }
    }

    
    func loadProfileData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(userID).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                let data = document.data()
                
                // Use username from Firestore or fallback to defaultUsername
                self.usernameLabel.text = data?["username"] as? String ?? "No username"

                
                // Fetch bio
                self.bioLabel.text = data?["bio"] as? String ?? "Add your bio"
                
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
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(16)
            make.width.height.equalTo(100)
        }
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(30)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-16)
        }
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(16)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(16)
            make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.trailing).offset(-16)
        }
        editProfileButton.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(20)
            make.leading.equalTo(profileImageView.snp.trailing).offset(30)
            //make.width.equalTo(120)
            make.height.equalTo(30)
            //make.trailing.equalTo(logOutButton.snp.leading).offset(-10)
        }
        logOutButton.snp.makeConstraints { make in
            make.top.equalTo(editProfileButton)
            //make.top.equalTo(usernameLabel.snp.bottom).offset(20)
            make.leading.equalTo(editProfileButton.snp.trailing).offset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-20)
            make.width.equalTo(editProfileButton)
            //make.width.equalTo(80)
            //make.height.equalTo(40)
        }
    }
    
    private func setupPlaceholderView() {
            view.addSubview(placeholderView)
            placeholderView.snp.makeConstraints { make in
                make.top.equalTo(statsStackView.snp.bottom).offset(20)
                make.left.right.equalToSuperview().inset(20)
                make.bottom.equalToSuperview().inset(50) // Adjust as needed
            }
            
            placeholderView.addSubview(cameraImageView)
            cameraImageView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(30)
                make.width.height.equalTo(50)
            }

            placeholderView.addSubview(sharePhotosLabel)
            sharePhotosLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(cameraImageView.snp.bottom).offset(16)
            }

            placeholderView.addSubview(sharePhotosDescriptionLabel)
            sharePhotosDescriptionLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(sharePhotosLabel.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(20)
            }
        }
    
    private func setupStackView() {
        view.addSubview(statsStackView)
        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-16)
            make.height.equalTo(50)
        }
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cellSize = (view.frame.width - 2) / 3
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: "PostCell")
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    private func loadPosts() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("posts").document(userID).collection("userPosts").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
               if let error = error {
                   print("Error fetching posts: \(error.localizedDescription)")
                   return
               }
                    self.posts = snapshot?.documents.compactMap { doc -> Post in
                        let data = doc.data()
                        //let imageUrl = data["imageUrl"] as? String ?? ""
                        return Post(id: doc.documentID, imageUrl: data["imageUrl"] as? String ?? "", caption: data["caption"] as? String ?? "")
                    } ?? []
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return posts.count
       }

       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! PostCell
           let post = posts[indexPath.row]
           cell.configure(with: post.imageUrl)
           return cell
       }

       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           let post = posts[indexPath.row]
           let fullImageVC = FullImageViewController()
           fullImageVC.postImageURL = post.imageUrl
           navigationController?.pushViewController(fullImageVC, animated: true)
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
    static let didUpdateProfileData = Notification.Name("didUpdateProfileData")
}

