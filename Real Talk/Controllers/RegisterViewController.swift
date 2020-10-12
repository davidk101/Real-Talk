//
//  RegisterViewController.swift
//  Real Talk
//
//  Created by David Kumar
//  Copyright © 2020 David Kumar. All rights reserved.
import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let throbber = JGProgressHUD(style: .dark)
    
    // defining UI elements
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    private let firstNameField: UITextField = {
        
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First Name"
        
        // avoiding flush-left text
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
        
    }()
    private let lastNameField: UITextField = {
        
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last Name"
        
        // avoiding flush-left text
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let emailField: UITextField = {
        
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email address"
        
        // avoiding flush-left text
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password"
        
        // avoiding flush-left text
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        field.isSecureTextEntry = true
        return field
    }()
    
    private let registerButton: UIButton = {
        
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        
        // adding 'Register' button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegisterButton))
        
        // adding functionality to button tap
        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        
        // setting delegates
        emailField.delegate = self
        passwordField.delegate = self
        
        // adding subviews
        view.addSubview(scrollView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
    }
    // defining subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        firstNameField.frame = CGRect(x: 30, y: (scrollView.frame.size.height - 100)/2, width: scrollView.frame.size.width - 60, height: 52)
        
        lastNameField.frame = CGRect(x: 30, y: (firstNameField.frame.size.height - 100)/2, width: firstNameField.frame.size.width - 60, height: 52)
        
        emailField.frame = CGRect(x: 30, y:(lastNameField.frame.size.height - 100)/2, width: lastNameField.frame.size.width - 60, height: 52)
        
        passwordField.frame = CGRect(x: 30, y: (emailField.frame.size.height - 100)/2, width: emailField.frame.size.width - 60, height: 52)
        
        registerButton.frame = CGRect(x: 30, y: (passwordField.frame.size.height - 100)/2, width: passwordField.frame.size.width - 60, height: 52)
    }
    
    // password and email validation
    @objc func didTapRegisterButtonForm(){
        
        // removing keyboard
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        // validation criterion: no fields empty & password > 8 characters
        guard let firstName = firstNameField.text, let lastName = lastNameField.text, let email = emailField.text, let password = passwordField.text, !firstName.isEmpty,!lastName.isEmpty,!email.isEmpty, !password.isEmpty, password.count >= 8 else{
            
            self.alertLoginError(message: "")
            return
        }
        
        throbber.show(in: view)
        
        //Firebase login
        DBManager.shared.doesUserExist(with: email, completion: {[weak self ] exists in
            // capturing a weakly retained reference of self to avoid memory leaks
            guard let strong_self = self else{
                return
            }
             // making UI changes on the main thread
            DispatchQueue.main.async {
                strong_self.throbber.dismiss()
            }
            
            guard !exists else{
                // the email already exists in DB
                self?.alertLoginError(message: "Account with that email already exists.")
                return
            }

            FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                // capturing a weakly retained reference of self to avoid memory leaks
                guard let strong_self = self else{
                    return
                }
                guard authResult != nil, error == nil else{
                    return
                }
                //adding user to DB
                DBManager.shared.insertUser(with: User(firstName: firstName, lastName: lastName, email: email))
                
                strong_self.navigationController?.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    // custom error alert 
    func alertLoginError(message: String){
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    // called on tapping the register button on the navigation bar
    @objc func didTapRegisterButton(){
        
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated:true)
    }
}

extension RegisterViewController: UITextFieldDelegate{
    
    // function delegate called on pressing the 'return' button on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField{
            // ensuring user need not manually tap password field on tapping 'return'
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            // ensuring user need not manually tap 'Register' button 
            didTapRegisterButtonForm()
        }
        return true
    }
}
