//
//  FeedViewController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 17.09.24.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore
import SDWebImage

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var posts: [Post] = []
    
    private let feedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Feed"
        
        setupCollectionView()
        fetchPosts()
    }
    
    private func setupCollectionView() {
        view.addSubview(feedCollectionView)
        
        feedCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.horizontalEdges.equalToSuperview()
        }
        
        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self
        feedCollectionView.register(FeedCell.self, forCellWithReuseIdentifier: "FeedCell")
    }
    
    private func fetchPosts() {
        let db = Firestore.firestore()

        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        print("Current user ID: \(currentUserID)")

        let followingRef = db.collection("following").document(currentUserID).collection("userFollowing")

        followingRef.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching following users: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("User is not following anyone. Clearing posts.")
                self.posts.removeAll()
                DispatchQueue.main.async {
                    self.feedCollectionView.reloadData()
                }
                return
            }

            let followingIDs = documents.map { $0.documentID }
            print("Fetched following IDs: \(followingIDs)")

            self.posts.removeAll() // Clear before fetching

            let group = DispatchGroup() // Synchronize multiple async calls

            for userID in followingIDs {
                group.enter()
                let userPostsRef = db.collection("posts").document(userID).collection("userPosts")

                userPostsRef.getDocuments { snapshot, error in
                    defer { group.leave() } // Ensure group exits even if there's an error

                    if let error = error {
                        print("🔥 Error fetching posts for user \(userID): \(error.localizedDescription)")
                        return
                    }

                    guard let documents = snapshot?.documents else { return }

                    let newPosts = documents.compactMap { doc -> Post? in
                        let data = doc.data()
                        print("Post data: \(data)")

                        guard let imageUrl = data["imageUrl"] as? String,
                              let caption = data["caption"] as? String,
                              let likes = data["likes"] as? Int,
                              let userID = data["userID"] as? String else {
                            print("Skipping post due to missing fields: \(data)")
                            return nil
                        }

                        let id = doc.documentID
                        let likedBy = data["likedBy"] as? [String] ?? []

                        return Post(
                            id: id,
                            imageUrl: imageUrl,
                            caption: caption,
                            likes: likes,
                            likedBy: likedBy,
                            userID: userID
                        )
                    }

                    self.posts.append(contentsOf: newPosts)
                }
            }

            group.notify(queue: .main) {
                print("Fetched \(self.posts.count) posts in total.")
                self.feedCollectionView.reloadData()
            }
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath) as! FeedCell
        let post = posts[indexPath.item]
        cell.configure(with: post)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 350)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension FeedViewController: FeedCellDelegate {
    func didTapLikeButton(on post: Post) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        var updatedPost = post
        
        if post.likedBy.contains(userID) {
            updatedPost.likes -= 1
            updatedPost.likedBy.removeAll { $0 == userID }
        } else {
            updatedPost.likes += 1
            updatedPost.likedBy.append(userID)
        }
        
        db.collection("posts").document(post.id).updateData([
            "likes": updatedPost.likes,
            "likedBy": updatedPost.likedBy
        ]) { error in
            if let error = error {
                print("Error updating likes: \(error.localizedDescription)")
            } else {
                if let index = self.posts.firstIndex(where: { $0.id == post.id }) {
                    self.posts[index] = updatedPost
                    DispatchQueue.main.async {
                        self.feedCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                }
            }
        }
    }
}
