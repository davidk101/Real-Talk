//
//  LoginViewController.swift
//  Real Talk
//
//  Created by David Kumar
//  Copyright © 2020 David Kumar. All rights reserved.

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let throbber = JGProgressHUD(style: .dark)
    
    // adding UI elements
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
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
    
    private let loginButton: UIButton = {
        
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let FBloginButton: FBLoginButton = {
        let button = FBLoginButton()
        // requesting email and full name from facebook
        button.permissions = ["email","public_profile"]
        return button
    }()
    
    private let GoogleSignInButton = GIDSignInButton()
    
    private var userLoginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // adding observer to receive data from other VC
        userLoginObserver = NotificationCenter.default.addObserver(forName: Notification.Name(""), object: nil, queue: .main, using: {[weak self] _ in
            
            guard let strong_self = self else{
                return
            }
            strong_self.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        // adding Google sign-in capabilities
        GIDSignIn.sharedInstance()?.presentingViewController = self
        title = "Log In"
        // adding 'Register' button to navigation bar 
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegisterButton))
        
        loginButton.addTarget(self, action: #selector(didTapLoginButtonForm), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        FBloginButton.delegate = self
        
        // adding subviews
        view.addSubview(scrollView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(FBloginButton)
        scrollView.addSubview(GoogleSignInButton)
    
    }
    
    // adding observer
    deinit {
        if let observer = userLoginObserver{
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        emailField.frame = CGRect(x: 30, y: scrollView.frame.size.height + scrollView.frame.origin.y + 10, width: view.frame.size.width - 60, height: 52)
        
        passwordField.frame = CGRect(x: 30, y: emailField.frame.size.height + emailField.frame.origin.y + 10, width: view.frame.size.width - 60, height: 52)
        
        loginButton.frame = CGRect(x: 30, y: passwordField.frame.size.height + passwordField.frame.origin.y + 10 , width: view.frame.size.width - 60, height: 52)
        
        FBloginButton.frame = CGRect(x: 30, y: loginButton.frame.size.height + loginButton.frame.origin.y + 10, width: view.frame.size.width - 60, height: 52)

        GoogleSignInButton.frame = CGRect(x: 30, y: FBloginButton.frame.size.height + FBloginButton.frame.origin.y + 10 , width: view.frame.size.width - 60, height: 52)
    }
    
    // password and email validation
    @objc func didTapLoginButtonForm(){
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 8 else{
            alertLoginError()
            return
        }
        throbber.show(in: view)
        
        //Firebase login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self](authResult, error) in
            // capturing a weakly retained reference of self to avoid memory leaks
            guard let strong_self = self else{
                return
            }
            
            // making UI changes on the main thread
            DispatchQueue.main.async {
                strong_self.throbber.dismiss()
            }
            
            guard let result = authResult, error == nil else{
                return
            }
            let user = result.user
            print(user)
            strong_self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // custom alert message
    func alertLoginError(){
        
        let alert = UIAlertController(title: "Error", message: "Please enter all fields to log in", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    // user taps Register button on navigation bar
    @objc func didTapRegisterButton(){
        
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated:true)
    }
}

extension LoginViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField{
            // ensuring user needs not manually go to password field on tapping 'return'
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            // ensuring user need not manually tap 'Login' button 
            didTapLoginButtonForm()
        }
        return true
    }
}

extension LoginViewController: LoginButtonDelegate{
    
    // displays logout button if user already logged in - inapplicable to Real Talk as
    // LoginVC not displayed on each opening of the app - protocol stub remains empty
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
    // delegate function for the when the FBLogin Button did complete
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        // unwrapping token from FB
        guard let token = result?.token?.tokenString else{
            return
        }
        // requesting graph object from facebook to get name and email of logged in user
        let FBRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: token, version: nil, httpMethod: .get)
        
        // executing request and unwrapping data
        FBRequest.start(completionHandler: {connection, result, error in
            guard let result = result as? [String: Any], error == nil else{
                return
            }
            guard let fullName = result["name"] as? String, let email = result["email"] as? String else{
                return
            }
            
            let stringFormat = fullName.components(separatedBy: " ")
            guard stringFormat.count == 2 else{
                return
            }
            
            let firstName = stringFormat[0]
            let lastName = stringFormat[0]
            
            // checking if the user exists already in the RealTime DB
            DBManager.shared.doesUserExist(with: email, completion:{ exists in
                if !exists {
                    
                    // addign user to RealTime DB
                    DBManager.shared.insertUser(with: User(firstName: firstName, lastName: lastName, email: email))
                }
            })
            
            // retrieving an FIRAuthCredential for FB sign in through the FB token
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                
                guard let strong_self = self else{
                    return
                }
                
                guard authResult != nil, error == nil else{
                    //else block executed when MFA needed
                    return
                }
                strong_self.navigationController?.dismiss(animated: true, completion: nil)
            })
            
        })

    }
}
