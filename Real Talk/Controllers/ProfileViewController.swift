//
//  ProfileViewController.swift
//  Real Talk
//
//  Created by David Kumar
//  Copyright © 2020 David Kumar. All rights reserved.

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //registering cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    // populating cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    // adding functionality to selected cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // removing highlight from cell
        tableView.deselectRow(at: indexPath, animated: true)
        
        // presenting action sheet
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: UIAlertAction.Style.destructive, handler: {[weak self] (UIAlertAction) in
            // capturing a weakly retained reference of self to avoid memory leaks
            guard let strong_self = self else{
                return
            }
            // logging user out from FB session
            FBSDKLoginKit.LoginManager.logOut()
            
            // signing user out from Google session
            GIDSignIn.sharedInstance()?.signOut()
        
            // logging user out from Firebase session
            do{
                try FirebaseAuth.Auth.auth().signOut()
                
                let vc = LoginViewController()
                let navigationVC = UINavigationController(rootViewController: vc)
                
                // avoids card-like presentation of navigation controller
                navigationVC.modalPresentationStyle = .fullScreen
                
                strong_self.present(navigationVC,animated: true)
            }
            catch{
                
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet,animated: true)
    }
}
