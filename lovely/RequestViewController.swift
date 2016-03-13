//
//  RequestViewController.swift
//  lovely
//
//  Created by Max Hudson on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

protocol RequestViewControllerDelegate {
    func noteCreated()
}

class RequestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var delegate: SendViewControllerDelegate?
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var recipientField: PaddedTextField!
    @IBOutlet weak var recipientFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noteContent: KMPlaceholderTextView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendButtonHeightContstraint: NSLayoutConstraint!
    @IBOutlet weak var longType: UIButton!
    @IBOutlet weak var sadType: UIButton!
    @IBOutlet weak var goodType: UIButton!
    @IBOutlet weak var publicToggle: UISegmentedControl!
    @IBOutlet weak var userTable: UITableView!
    @IBOutlet weak var userTableBottomContstraint: NSLayoutConstraint!
    @IBOutlet weak var recipientList: UICollectionView!
    @IBOutlet weak var recipientListHeightConstraint: NSLayoutConstraint!
    
    var subType = NoteSubType.Long
    var friends : [User] = []
    var userList : [User] = []
    var recipients : [User] = []
    var recipientListBottomLayer : CALayer!
    
    let disabledTypeAlpha : CGFloat = 0.3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideNotification", name: UIKeyboardWillHideNotification, object: nil)
        
        self.view.backgroundColor = UIHelper.mainColor
        
        toolBar.clipsToBounds = true
        toolBar.backgroundColor = UIHelper.mainColor
        
        setupRecipientField()
        
        noteContent.placeholder = "Why was your day long?"
        noteContent.textContainerInset = UIEdgeInsetsMake(15, 17, 15, 17)
        noteContent.delegate = self
        
        sendButton.backgroundColor = UIHelper.darkMainColor
        
        sadType.alpha = disabledTypeAlpha
        goodType.alpha = disabledTypeAlpha
        
        userTable.delegate = self
        userTable.dataSource = self
        userTable.estimatedRowHeight = 80
        userTable.rowHeight = UITableViewAutomaticDimension
        userTable.separatorInset = UIEdgeInsetsZero
        
        noteContent.becomeFirstResponder()
        
        userTable.hidden = true
        
        //initially public
        recipientField.hidden = true
        recipientFieldHeightConstraint.constant = 0
        recipientList.hidden = true
        recipientListHeightConstraint.constant = 0
        
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
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0, recipientField.frame.height - 1, recipientField.frame.width, 1)
        bottomLine.backgroundColor = UIColor(white: 0.85, alpha: 1).CGColor
        
        recipientField.layer.addSublayer(bottomLine)
        
        //collectionView
        let layout: UICollectionViewFlowLayout = LeftAlignedFlowLayout()
        layout.minimumInteritemSpacing = 5;
        layout.minimumLineSpacing = 5;
        layout.estimatedItemSize = CGSize(width: 100, height: 100)
        layout.sectionInset = UIEdgeInsetsMake(10, 20, 10, 20)
        
        recipientList.removeFromSuperview()
        recipientList.dataSource = self
        recipientList.delegate = self
        recipientList.backgroundColor = UIColor.whiteColor()
        recipientList.setCollectionViewLayout(layout, animated: false)
        self.view.addSubview(recipientList)
        
        recipientListBottomLayer = CALayer()
        recipientList.layer.addSublayer(recipientListBottomLayer)
        
        resizeRecipientList()
    }
    
    @IBAction func privacyChanged(sender: AnyObject) {
        let isPublic = publicToggle.selectedSegmentIndex == 0
        
        if (isPublic) {
            recipientField.hidden = true
            recipientFieldHeightConstraint.constant = 0
            
            recipientList.hidden = true
            recipientListHeightConstraint.constant = 0
        }
        else {
            recipientField.hidden = false
            recipientFieldHeightConstraint.constant = 50
            
            recipientList.hidden = false
            resizeRecipientList()
        }
        
        validateNote()
    }
    
    func resizeRecipientList() {
        validateNote()
        
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(0.05 * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) {
            var height : CGFloat = 0
            
            if self.recipients.count == 1 {
                height = 45
            }
            else if self.recipients.count > 0 {
                height = self.recipientList.collectionViewLayout.collectionViewContentSize().height + CGFloat(1)
            }
            
            self.recipientListHeightConstraint.constant = height
            
            self.recipientListBottomLayer.frame = CGRectMake(0, height - 1, self.recipientList.frame.width, 1)
            self.recipientListBottomLayer.backgroundColor = UIColor(white: 0.85, alpha: 1).CGColor
        }
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
        
        return cell
    }
    
    /**
     * User selection
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        recipients.append(userList[indexPath.row])
       
        recipientList.reloadData()
        
        resizeRecipientList()
        
        recipientField.text = ""
        
        noteContent.hidden = false
        bottomView.hidden = false
        recipientList.hidden = false
        
        userTable.hidden = true
        
        noteContent.becomeFirstResponder()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipients.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = recipientList.dequeueReusableCellWithReuseIdentifier("Recipient", forIndexPath: indexPath) as! RecipientCollectionViewCell
        
        let user = recipients[indexPath.row]
        
        cell.nameButton.setTitle(user.name, forState: .Normal)
        cell.nameButton.backgroundColor = UIHelper.lightMainColor
        cell.nameButton.layer.cornerRadius = 3
        cell.nameButton.clipsToBounds = true
        cell.nameButton.adjustsImageWhenHighlighted = false
        cell.nameButton.enabled = false
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        recipients.removeAtIndex(indexPath.row)
        
        recipientList.reloadData()
        
        resizeRecipientList()
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
        
        resetUserList(search)
        
        userTable.reloadData()
    }
    
    /**
     * User tapped on search box
     */
    @IBAction func beganEditingRecipient(sender: AnyObject) {
        resetUserList("")
        
        if userList.count > 0 {
            recipientField.text = ""
            
            noteContent.hidden = true
            bottomView.hidden = true
            recipientList.hidden = true
            
            userTable.hidden = false
            
            searchUsers()
        }
    }
    
    func resetUserList(search: String) {
        userList.removeAll()
        
        for friend in friends {
            let name = friend.name.lowercaseString
            
            //checks for string match and non-intersection with recipient list
            if (name.rangeOfString(search) != nil || search == "") && recipients.indexOf({$0.id == friend.id}) == nil {
                userList.append(friend)
            }
        }
    }
    
    /**
     * Validate note fields on note content update
     */
    func textViewDidChange(textView: UITextView) {
        validateNote()
    }
    
    /**
     * Changes subType to long
     */
    @IBAction func longTypePressed(sender: AnyObject) {
        subType = NoteSubType.Long
        
        longType.alpha = 1
        sadType.alpha = disabledTypeAlpha
        goodType.alpha = disabledTypeAlpha
        
        sendButton.setTitle("I had a long day", forState: UIControlState.Normal)
        noteContent.placeholder = "Why was your day long?"
    }
    
    /**
     * Changes subType to sad
     */
    @IBAction func sadTypePressed(sender: AnyObject) {
        subType = NoteSubType.Sad
        
        sadType.alpha = 1
        longType.alpha = disabledTypeAlpha
        goodType.alpha = disabledTypeAlpha
        
        sendButton.setTitle("I had a sad day", forState: UIControlState.Normal)
        noteContent.placeholder = "Why was your day sad?"
    }
    
    /**
     * Changes subType to good
     */
    @IBAction func goodTypePressed(sender: AnyObject) {
        subType = NoteSubType.Good
        
        goodType.alpha = 1
        longType.alpha = disabledTypeAlpha
        sadType.alpha = disabledTypeAlpha
        
        sendButton.setTitle("I had a good day", forState: UIControlState.Normal)
        noteContent.placeholder = "Why was your day good?"
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
        if (noteContent.text! != "" && (publicToggle.selectedSegmentIndex == 0 || recipients.count > 0)) {
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
        let isPublic = publicToggle.selectedSegmentIndex == 0
        
        if isPublic {
            let note = Note(message: noteContent.text, recipient: AppState.getPublicUser(), isPublic: isPublic, type: "request", subType: subType)
            
            note.send()
        }
        else {
            for recipient in recipients {
                let note = Note(message: noteContent.text, recipient: recipient, isPublic: isPublic, type: "request", subType: subType)
                
                note.send()
            }
        }
        
        if (self.delegate != nil) {
            self.delegate!.noteCreated()
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}