//
//  FollowingListViewController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 25.02.25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class FollowingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.reuseIdentifier)
        return table
    }()
    private var following: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Following"
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        fetchFollowing()
    }
    
    private func fetchFollowing() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let followingRef = db.collection("following").document(currentUserId).collection("userFollowing")
        
        followingRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching following list: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("No following found.")
                DispatchQueue.main.async {
                    self.following = []
                    self.tableView.reloadData()
                }
                return
            }
            
            let userIds = documents.map { $0.documentID }
            self.fetchUserDetails(for: userIds)
        }
    }
    
    private func fetchUserDetails(for userIds: [String]) {
        let db = Firestore.firestore()
        var users: [User] = []
        let group = DispatchGroup()
        
        for userId in userIds {
            group.enter()
            db.collection("users").document(userId).getDocument { snapshot, error in
                defer { group.leave() }
                
                if let error = error {
                    print("Error fetching user details: \(error.localizedDescription)")
                    return
                }
                
                guard let data = snapshot?.data(), let username = data["username"] as? String else { return }
                let profileImageUrl = data["profileImageUrl"] as? String
                let user = User(id: userId, username: username, profileImageUrl: profileImageUrl)
                users.append(user)
            }
        }
        
        group.notify(queue: .main) {
            self.following = users
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return following.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.reuseIdentifier, for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        
        let user = following[indexPath.row]
        cell.configure(with: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = following[indexPath.row]
        let userProfileVC = UserProfileViewController()
        userProfileVC.userID = selectedUser.id
        
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
}
