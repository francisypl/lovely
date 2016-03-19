//
//  SendViewController.swift
//  lovely
//
//  Created by Max Hudson on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

protocol SendViewControllerDelegate {
    func noteCreated()
}

class SendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var delegate: SendViewControllerDelegate?
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var recipientField: PaddedTextField!
    @IBOutlet weak var noteContent: KMPlaceholderTextView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendButtonHeightContstraint: NSLayoutConstraint!
    @IBOutlet weak var loveType: UIButton!
    @IBOutlet weak var fistType: UIButton!
    @IBOutlet weak var publicToggle: UISegmentedControl!
    @IBOutlet weak var userTable: UITableView!
    @IBOutlet weak var userTableBottomContstraint: NSLayoutConstraint!
    
    var subType = NoteSubType.Love
    var friends : [User] = []
    var userList : [User] = []
    var recipient : User?
    
    let disabledTypeAlpha : CGFloat = 0.3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideNotification", name: UIKeyboardWillHideNotification, object: nil)
        
        self.view.backgroundColor = UIHelper.mainColor
        
        toolBar.clipsToBounds = true
        toolBar.backgroundColor = UIHelper.mainColor
        
        setupRecipientField()
        
        noteContent.placeholder = "What's it for?"
        noteContent.textContainerInset = UIEdgeInsetsMake(15, 17, 15, 17)
        noteContent.delegate = self
        
        sendButton.backgroundColor = UIHelper.darkMainColor
        
        fistType.alpha = disabledTypeAlpha
        
        userTable.delegate = self
        userTable.dataSource = self
        userTable.estimatedRowHeight = 80
        userTable.rowHeight = UITableViewAutomaticDimension
        userTable.separatorInset = UIEdgeInsetsZero
        
        if let state = AppState.getInstance() {
            if recipient != nil {
                recipientField.text = recipient!.name
                
                userTable.hidden = true
                
                noteContent.becomeFirstResponder()
                
                if recipient!.id == state.currentUser.id {
                    publicToggle.enabled = false
                    publicToggle.selectedSegmentIndex = 1
                }
            }
            else {
                noteContent.hidden = true
                bottomView.hidden = true
                
                recipientField.becomeFirstResponder()
            }
            
            for (_, friend) in state.friendsList {
                friends.append(friend)
            }
            
            userList = friends
        }
        
        validateNote()
    }
    
    /**
    * Sets up recipientField
    */
    func setupRecipientField() {
        recipientField.backgroundColor = UIColor.whiteColor()
        recipientField.autocapitalizationType = UITextAutocapitalizationType.Words
        
        recipientField.leftTextMargin = 20
        recipientField.setNeedsLayout()
        recipientField.layoutIfNeeded()
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, recipientField.frame.height - 1, recipientField.frame.width, 1.0)
        bottomLine.backgroundColor = UIColor(white: 0.85, alpha: 1).CGColor
        
        recipientField.layer.addSublayer(bottomLine)
    }
    
    /**
     * Moves content panel up
     */
    func keyboardWillShowNotification(notification: NSNotification) {
        let keyboardEndFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let convertedKeyboardEndFrame = view.convertRect(keyboardEndFrame, fromView: view.window)
        
        bottomViewBottomConstraint.constant = CGRectGetMaxY(view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame)
    }
    
    /**
     * Moves content panel down
     */
    func keyboardWillHideNotification() {
        bottomViewBottomConstraint.constant = 0
    }
    
    /**
     * Unload view
     */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
    * Delegate method for row count
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    /**
     * Build cells
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("User") as! UserTableViewCell
        
        let user = userList[indexPath.row]
        
        cell.nameLabel.text = user.name
        cell.nameLabel.font = UIFont.systemFontOfSize(16, weight: UIFontWeightRegular);
        
        cell.profilePicture.image = user.image
        cell.profilePicture.circle()
        
        return cell
    }
    
    /**
     * User selection
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        recipient = userList[indexPath.row]
        
        if let state = AppState.getInstance() {
            if recipient!.id == state.currentUser.id {
                publicToggle.selectedSegmentIndex = 1
                publicToggle.enabled = false
            }
        }
        
        recipientField.text = recipient!.name
        
        noteContent.hidden = false
        bottomView.hidden = false
        
        userTable.hidden = true
        
        noteContent.becomeFirstResponder()
    }
    
    /**
    * User typed in recipient box
    */
    @IBAction func searchUsers(sender: AnyObject) {
        searchUsers()
    }
    
    /**
    * Search friends for string and reload table
    */
    func searchUsers() {
        let search = recipientField.text!.lowercaseString
        
        userList.removeAll()
        
        for friend in friends {
            let name = friend.name.lowercaseString
            
            if name.rangeOfString(search) != nil || search == "" {
                userList.append(friend)
            }
        }
        
        userTable.reloadData()
    }
    
    /**
    * User tapped on search box
    */
    @IBAction func beganEditingRecipient(sender: AnyObject) {
        recipientField.text = ""
        
        publicToggle.enabled = true
        
        noteContent.hidden = true
        bottomView.hidden = true
        
        userTable.hidden = false
        
        searchUsers()
    }
    
    /**
     * Validate note fields on note content update
     */
    func textViewDidChange(textView: UITextView) {
        validateNote()
    }
    
    /**
     * Changes subType to love
     */
    @IBAction func loveTypePressed(sender: AnyObject) {
        subType = NoteSubType.Love
        
        loveType.alpha = 1
        fistType.alpha = disabledTypeAlpha
        
        sendButton.setTitle("Send Love", forState: UIControlState.Normal)
        recipientField.placeholder = "Love Recipient"
        //noteContent.placeholder = "Why are you sending love?"
    }
    /**
     * Changes subType to fist
     */
    @IBAction func fistTypePressed(sender: AnyObject) {
        subType = NoteSubType.FistBump
        
        fistType.alpha = 1
        loveType.alpha = disabledTypeAlpha
        
        sendButton.setTitle("Send Fist Bump", forState: UIControlState.Normal)
        recipientField.placeholder = "Fist Bump Recipient"
    }
    
    /**
    * Hides view
    */
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * Verifies required fields are set
     */
    func validateNote() {
        if (recipient != nil && noteContent.text! != "") {
            sendButton.hidden = false
            sendButtonHeightContstraint.constant = 45
        }
        else {
            sendButton.hidden = true
            sendButtonHeightContstraint.constant = 0
        }
    }
    
    /**
    * Attempt to send message
    */
    @IBAction func send(sender: AnyObject) {
        //let recipient = User(id: -1, fbId: "", name: "user", email: "")
        let isPublic = publicToggle.selectedSegmentIndex == 0
        
        let note = Note(message: noteContent.text, recipient: recipient!, isPublic: isPublic, type: "note", subType: subType)
        
        note.send() { () -> () in
            if (self.delegate != nil) {
                self.delegate!.noteCreated()
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}