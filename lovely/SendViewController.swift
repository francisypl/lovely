//
//  SendViewController.swift
//  lovely
//
//  Created by Max Hudson on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

class SendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var recipientField: PaddedTextField!
    @IBOutlet weak var noteContent: KMPlaceholderTextView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
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
        
        noteContent.hidden = true
        bottomView.hidden = true
        
        ////////fake
        friends.append(User(id: 1, fbId: 1, name: "Max Hudson", email: "", image: UIImage()))
        friends.append(User(id: 2, fbId: 1, name: "Francis Yuen", email: "", image: UIImage()))
        friends.append(User(id: 3, fbId: 1, name: "Kiana Nafisi", email: "", image: UIImage()))
        friends.append(User(id: 4, fbId: 1, name: "Eric Woods", email: "", image: UIImage()))
        
        //friends = getFriends()
        
        userList = friends
        
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
        
        recipientField.becomeFirstResponder()
        
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
        
        //cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    /**
     * User selection
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        recipient = userList[indexPath.row]
        
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
        print(recipient != nil, noteContent.text! != "")
        if (recipient != nil && noteContent.text! != "") {
            sendButton.hidden = false
        }
        else {
            sendButton.hidden = true
        }
    }
    
    /**
    * Attempt to send message
    */
    @IBAction func send(sender: AnyObject) {
        let recipient = User(id: -1, fbId: -1, name: "user", email: "", image: UIImage())
        let isPublic = publicToggle.selectedSegmentIndex == 0
        
        let note = Note(message: noteContent.text, recipient: recipient, isPublic: isPublic, type: "note", subType: subType)
        
        note.send()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}