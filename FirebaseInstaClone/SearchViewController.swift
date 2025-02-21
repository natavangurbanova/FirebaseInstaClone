//
//  SearchViewController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 11.02.25.
//

import UIKit
import SnapKit
import FirebaseFirestore

struct User {
    let id: String
    let username: String
    let profileImageUrl: String?
}

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type to search"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.rightViewMode = .always
        return textField
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "magnifyingglass")
        button.setImage(image, for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return button
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        return table
    }()
    
    var searchResults: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupSearchTextField()
        setupTableView()
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    
    private func setupSearchTextField() {
        searchTextField.rightView = searchButton
        view.addSubview(searchTextField)
        
        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.reuseIdentifier)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            
        }
    }
    
    @objc private func searchButtonTapped() {
        guard let queryText = searchTextField.text, !queryText.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("Search query is empty.")
            return
        }
        searchUsers(with: queryText)
    }
    
    private func searchUsers(with query: String) {
        let db = Firestore.firestore()
        
        db.collection("users").whereField("username", isEqualTo: query).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error searching users: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot, !snapshot.documents.isEmpty else {
                print("No matching users found.")
                DispatchQueue.main.async {
                    self.searchResults = []
                    self.tableView.reloadData()
                }
                return
            }
            
            let users = snapshot.documents.compactMap { document -> User? in
                let data = document.data()
                guard let username = data["username"] as? String else { return nil }
                let userId = document.documentID
                let profileImageUrl = data["profileImageUrl"] as? String
                return User(id: userId, username: username, profileImageUrl: profileImageUrl)
            }
            
            DispatchQueue.main.async {
                self.searchResults = users
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.reuseIdentifier, for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        
        let user = searchResults[indexPath.row]
        cell.configure(with: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = searchResults[indexPath.row]
        let userProfileVC = UserProfileViewController()
        userProfileVC.userID = selectedUser.id
        
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
}
