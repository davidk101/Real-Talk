//
//  StartConversationViewController.swift
//  Real Talk
//
//  Created by David Kumar
//  Copyright © 2020 David Kumar. All rights reserved.

import UIKit
import JGProgressHUD

class StartConversationViewController: UIViewController {
    
    private let throbber = JGProgressHUD(style: .dark)
    
    private let searchBar : UISearchBar = {
        
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users to start chatting with!"
        return searchBar
    }()
    
    // displaying user list in a tableView
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    // displaying label if no user found
    private let noneFound:UILabel = {
        let label = UILabel()
        label.isHidden = true 
        label.text = "User not found."
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 31)
        return label
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        // adding search bar to navigation bar
        navigationController?.navigationBar.topItem?.titleView = searchBar
        //adding cancel button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissMe))
        // showing keyboard when view loads
        searchBar.becomeFirstResponder()
    }
    
    @objc private func dismissMe(){
        dismiss(animated: true, completion: nil)
    }
}

extension StartConversationViewController: UISearchBarDelegate{
    
    // functionality to be added on clicking of search button on search bar 
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
