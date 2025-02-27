//
//  UserFollowerListController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 26.02.25.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

class UserFollowerListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UserFollowerCell.self, forCellReuseIdentifier: UserFollowerCell.identifier)
        return table
    }()
    
    var userID: String?
    private var followers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Followers"
        setupTableView()
        fetchFollowers()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func fetchFollowers() {
        guard let viewedUserID = userID else { return }
        let db = Firestore.firestore()
        let userFollowersRef = db.collection("followers").document(viewedUserID).collection("userFollowers")
        
        userFollowersRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user followers: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            let group = DispatchGroup()
            var users: [User] = []
            for document in documents {
                let userId = document.documentID
                group.enter()
                db.collection("users").document(userId).getDocument { userSnapshot, error in
                    defer { group.leave() }
                    if let error = error {
                        print("Error fetching user data: \(error.localizedDescription)")
                        return
                    }
                    
                    if let data = userSnapshot?.data(), let username = data["username"] as? String {
                        let profileImageUrl = data["profileImageUrl"] as? String
                        let user = User(id: userId, username: username, profileImageUrl: profileImageUrl)
                        users.append(user)
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.followers = users
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserFollowerCell.identifier, for: indexPath) as? UserFollowerCell else {
            return UITableViewCell()
        }
        let user = followers[indexPath.row]
        cell.configure(with: user)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = followers[indexPath.row]
        let userProfileVC = UserProfileViewController()
        userProfileVC.userID = selectedUser.id
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
}

class UserFollowerCell: UITableViewCell {
    static let identifier = "UserFollowerCell"
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(profileImageView.snp.trailing).offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with user: User) {
        usernameLabel.text = user.username
        if let urlString = user.profileImageUrl, let url = URL(string: urlString) {
            profileImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.circle"))
        } else {
            profileImageView.image = UIImage(systemName: "person.circle")
        }
    }
}
