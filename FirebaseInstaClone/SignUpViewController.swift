//
//  SignUpViewController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 16.10.24.
//

import Foundation
import SnapKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign Up Screen"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let passwordConfirmTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm your password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let SignUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .systemIndigo
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        
    }
    
    func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(passwordConfirmTextField)
        view.addSubview(SignUpButton)
        SignUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
    }
    @objc func signUpButtonTapped() {
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = passwordConfirmTextField.text, !confirmPassword.isEmpty else {
            print("Please fill in all fields.")
            return
        }
        
        guard password == confirmPassword else {
            print("Passwords do not match.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Sign up failed: \(error.localizedDescription)")
                return
            }
            
            self.createUserDocument(withEmail: email)
            print("User successfully signed up!")
            
            self.transitionToSignInVC()
            
        }
        
    }
    
    func createUserDocument(withEmail email: String) {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let defaultUsername = email.components(separatedBy: "@").first ?? "No username"
        
        db .collection("users").document(userID).setData([
            "profileImageUrl": "",
            "username": defaultUsername,
            "bio": "Add your bio"
        ]) { error in
            if let error = error  {
                print("Error creating user document: \(error.localizedDescription)")
            } else {
                print("User document created successfully with username: \(defaultUsername)!")
            }
        }
    }
    
    func transitionToSignInVC() {
        let SignInVC = SignInViewController()
        navigationController?.pushViewController(SignInVC, animated: true)
    }
    
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.centerX.equalToSuperview()
        }
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        passwordConfirmTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        SignUpButton.snp.makeConstraints { make in
            make.top.equalTo(passwordConfirmTextField.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
    
    
}
