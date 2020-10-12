//
//  ChatViewController.swift
//  Real Talk
//
//  Created by David Kumar
//  Copyright © 2020 David Kumar. All rights reserved.

import UIKit
import MessageKit
import CoreLocation

// defining message bubble properties
struct Message: MessageType{
    
    var sender: SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind
}
// defining message sender properties
struct Sender: SenderType{
    
    var photoUrl: String
    
    var senderId: String
    
    var displayName: String
}

class ChatViewController: MessagesViewController {
    
    private var messages = [Message]()
    
    // test value for debugging purposes
    private let testSender = Sender(photoUrl: "123", senderId: "123", displayName: "David K")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages.append(Message(sender: testSender, messageId: "123", sentDate: Date(), kind: .text("Hello world")))
        
        // setting delegates
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
}

extension ChatViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate{
    // returning SenderType
    func currentSender() -> SenderType {
        return testSender
    }
    
    // returning MessageType
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        // MessageKit classifies messages into sections and not rows unlike traditional tableView
        messages[indexPath.section]
    }
    
    // returning number of sections
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
}
