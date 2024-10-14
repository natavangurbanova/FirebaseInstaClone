//
//  ViewController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 15.09.24.
//

import UIKit
import FirebaseAuth
import SnapKit
import Firebase

class ViewController: UIViewController {
    
    let titleLabel: UILabel = {
      let label = UILabel()
        label.text = "Instagram Clone"
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
    
    let SignInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        //button.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        SignInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        view.addSubview(SignInButton)
    }
    
    func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(SignInButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.centerX.equalToSuperview()
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        
        SignInButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
            make.height.equalTo(50)
        }
    }
    
    @objc func signInTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Missing email or password ")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self ]    authResult, error in
            guard let strongSelf = self else { return }
            
            if let error = error {
                print("Sign in failed : \(error.localizedDescription)")
            } else {
                print("Sign iin successful!")
                
            let tabBarController = TabBarViewController()
                strongSelf.transitionToTabBarController(tabBarController)
            }
            
        }
        
    }
    
    func transitionToTabBarController(_ tabBarController: UITabBarController) {
            if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = tabBarController
            }
        }
    }
    
    

