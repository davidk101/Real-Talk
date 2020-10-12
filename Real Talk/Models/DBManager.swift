//
//  DBManager.swift
//  Real Talk
//
//  Created by David Kumar
//  Copyright © 2020 David Kumar. All rights reserved.
import Foundation
import FirebaseDatabase

// class cannot be subclassed
final class DBManager{
    
    static let shared = DBManager()
    
    private let database = Database.database().reference()
    
}

extension DBManager{
    
    public func doesUserExist(with email: String, completion: @escaping ((Bool) -> (Void))){
        
        // since @ and . not permitted in RealTime DB storage 
        var allowedEmail = email.replacingOccurrences(of: "@", with: "-")
        allowedEmail = email.replacingOccurrences(of: ".", with: "-")
        
        // checking if email exists already in DB
        database.child(allowedEmail).observeSingleEvent(of: .value, with:{ snapshot in
            guard snapshot.value as? String != nil else{
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    // inserting new user to database
    public func insertUser(with user: User){
        
        database.child(user.allowedEmail).setValue(["firstName": user.firstName,"lastName": user.lastName])
    }
}
struct User{
    
    let firstName: String
    let lastName: String
    let email: String
    
    var allowedEmail: String{
        var allowedEmail = email.replacingOccurrences(of: "@", with: "-")
        allowedEmail = email.replacingOccurrences(of: ".", with: "-")
        return allowedEmail
        
    }
}
