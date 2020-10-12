//
//  ViewController.swift
//  Real Talk
//
//  Created by David Kumar
//  Copyright © 2020 David Kumar. All rights reserved.

import UIKit
import FirebaseAuth
import JGProgressHUD

class ViewController: UIViewController {
    
    private let throbber = JGProgressHUD(style: .dark)

    private let tableView: UITableView = {
        let table = UITableView()
        // initially hidden to avoid empty table display when no user conversation found
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    // label to be outputed when no conversation is detected
    private let defaultLabel: UILabel = {
        
        let label = UILabel()
        label.text = "No Conversations. Start chatting away!"
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 31, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // adding system icon for 'compose' to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapStartButton))
        view.addSubview(tableView)
        setTableView()
        getConversations()
    }
    
    // starting a new conversation when compose button hit 
    @objc private func didTapStartButton(){
        
        let vc = StartConversationViewController()
        let navigationVC = UINavigationController(rootViewController: vc)
        present(navigationVC, animated: true)
    }
    
    // adding a frame to tableView after adding it as subview
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool){
        
        super.viewDidAppear(animated)
        validateUserAuthorization()
    }

    private func validateUserAuthorization(){
        
        if FirebaseAuth.Auth.auth().currentUser == nil{
            
            let vc = LoginViewController()
            let navigationVC = UINavigationController(rootViewController: vc)
            
            // avoids card-like presentation of navigation controller
            navigationVC.modalPresentationStyle = .fullScreen
            
            present(navigationVC,animated: true)
        }
    }
    
    private func setTableView(){
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func getConversations(){
        tableView.isHidden = false
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    // returns number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // identifies cell to populate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = "hello_world"
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }
    
    // push user-selected chat screen onto view stack
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatViewController()
        vc.title = ""
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
}
