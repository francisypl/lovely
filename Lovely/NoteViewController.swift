//
//  NoteViewController.swift
//  lovely
//
//  Created by Max Hudson on 3/18/16.
//  Copyright © 2016 Max Hudson. All rights reserved.
//

import UIKit

class NoteViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var note : Note!
    var comments = [Comment]()
    
    //Note
    @IBOutlet weak var statusBarBackground: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var fromProfilePicture: UIImageView!
    @IBOutlet weak var sendLove: UIButton!
    @IBOutlet weak var fromName: UILabel!
    @IBOutlet weak var noteIcon: UIImageView!
    @IBOutlet weak var toName: UILabel!
    @IBOutlet weak var dayType: UILabel!
    @IBOutlet weak var noteCopy: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var privateIndicator: UIImageView!
    
    //Comment table
    @IBOutlet weak var commentTable: UITableView!
    
    //Comment bar
    @IBOutlet weak var commentBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var commentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideNotification", name: UIKeyboardWillHideNotification, object: nil)
        
        statusBarBackground.backgroundColor = UIHelper.mainColor
        
        navBar.barTintColor = UIHelper.mainColor
        navBar.clipsToBounds = true
        
        buildNote()
        
        commentTable.delegate = self
        commentTable.dataSource = self
        commentTable.estimatedRowHeight = 80
        commentTable.rowHeight = UITableViewAutomaticDimension
        commentTable.separatorInset = UIEdgeInsetsZero
        commentTable.tableFooterView = UIView()
        
        commentField.autocapitalizationType = UITextAutocapitalizationType.Sentences
        
        DatabaseWrapper.getComments(note) { (comments: [Comment]) -> () in
            dispatch_async(dispatch_get_main_queue()) {
                self.comments = comments
                self.commentTable.reloadData()
            }
        }
    }
    
    func buildNote() {
        let state = AppState.getInstance()!
        
        let IAmSender = note.sender.id == state.currentUser.id
        let IAmRecipient = note.recipient.id == state.currentUser.id
        
        
        fromProfilePicture.image = IAmSender && !IAmRecipient ? state.currentUser.image : note.sender.image
        fromProfilePicture.contentMode = .ScaleAspectFit
        fromProfilePicture.circle()
        
        sendLove.hidden = true
        
        if note.type == "note" {
            if IAmSender {
                fromName.text = "You"
            }
            else {
                fromName.text = note.sender.name
            }
        }
        else {
            if IAmSender {
                if !note.isPublic {
                    let recipientName = IAmSender || !IAmRecipient ? note.recipient.name : "You"
                    fromName.text = recipientName + ", I"
                }
                else {
                    fromName.text = "I"
                }
            }
            else {
                fromName.text = note.sender.name
                sendLove.hidden = false
            }
        }
        
        fromName.font = UIFont.systemFontOfSize(UIHelper.standardFontSize, weight: UIFontWeightSemibold);
        
        noteIcon.image = UIImage(named: note.subType.rawValue + "-option")
        
        dayType.text = ""
        toName.text = ""
        
        if note.type == "note" {
            toName.text = IAmSender || !IAmRecipient ? note.recipient.name : "You"
            toName.font = UIFont.systemFontOfSize(UIHelper.standardFontSize, weight: UIFontWeightSemibold);
        }
        else {
            dayType.text = "had a " + note.subType.rawValue + " day"
            dayType.font = UIFont.systemFontOfSize(UIHelper.standardFontSize, weight: UIFontWeightRegular);
        }
        
        ageLabel.text = UIHelper.ago(note.date)
        ageLabel.font = UIFont.systemFontOfSize(11, weight: UIFontWeightLight);
        
        noteCopy.font = UIFont.systemFontOfSize(UIHelper.standardFontSize, weight: UIFontWeightRegular);
        noteCopy.text = note.message
        
        likeButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 12)
        likeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 1.5, right: 0)
        
        if note.liked {
            likeButton.setTitleColor(UIHelper.darkMainColor, forState: .Normal)
            likeButton.setImage(UIImage(named: "like-active.png"), forState: .Normal)
        }
        else {
            likeButton.setTitleColor(UIColor(white: 0.5, alpha: 1), forState: .Normal)
            likeButton.setImage(UIImage(named: "like.png"), forState: .Normal)
        }
        
        if note.likes > 0 {
            likeButton.setTitle(" "+String(note.likes), forState: .Normal)
        }
        else {
            likeButton.setTitle("", forState: .Normal)
        }
        
        if note.isPublic {
            privateIndicator.hidden = true
        }
        else {
            privateIndicator.hidden = false
        }
        
        self.view.layoutIfNeeded()
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, noteView.frame.height - 0.5, noteView.frame.width, 0.5)
        bottomLine.backgroundColor = UIColor(white: 0.75, alpha: 1).CGColor
        
        noteView.layer.addSublayer(bottomLine)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Comment") as! CommentTableViewCell
        let comment = comments[indexPath.row]
        
        cell.commentLabel.text = comment.message
        cell.profilePicture.circle()
        
        comment.joinFb() { () -> () in
            cell.nameLabel.text = comment.user?.name
            cell.profilePicture.image = comment.user?.image
            
            cell.ageLabel.text = UIHelper.ago(comment.date)
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    
    /**
     * Allows deleting of your notes
     */
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let state = AppState.getInstance() {
            if comments[indexPath.row].userId == state.currentUser.id {
                return true
            }
        }
        
        return false
    }
    
    /**
     * Set deletable
     */
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    /**
     * Mandatory implementation method even though it doesn't need to be used...
     */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    /**
     * Handle delete element and event
     */
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?  {
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action , indexPath) -> Void in
            
            DatabaseWrapper.deleteComment(self.comments[indexPath.row])
            self.comments.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
        })
        
        deleteAction.backgroundColor = UIHelper.deleteColor
        
        return [deleteAction]
    }
    
    /**
     * Moves comment bar up
     */
    func keyboardWillShowNotification(notification: NSNotification) {
        let keyboardEndFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let convertedKeyboardEndFrame = view.convertRect(keyboardEndFrame, fromView: view.window)
        
        commentBarBottomConstraint.constant = CGRectGetMaxY(view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame)
    }
    
    /**
     * Moves comment bar down
     */
    func keyboardWillHideNotification() {
        commentBarBottomConstraint.constant = 0
    }
    
    @IBAction func commentButtonPressed(sender: AnyObject) {
        DatabaseWrapper.comment(commentField.text!, note: note) { (comment: Comment) -> () in
            dispatch_async(dispatch_get_main_queue()) {
                self.comments.append(comment)
                self.commentTable.reloadData()
                
                self.commentField.text = ""
                
                self.note.comments++
                
                //scroll to bottom
            }
        }
    }
    
    @IBAction func likeButtonPressed(sender: AnyObject) {
        note.liked = !note.liked
        
        if note.liked {
            likeButton.setImage(UIImage(named: "like-active"), forState: .Normal)
            likeButton.setTitleColor(UIHelper.darkMainColor, forState: .Normal)
            
            note.likes++
            
            DatabaseWrapper.likeNote(note)
        }
        else {
            likeButton.setImage(UIImage(named: "like"), forState: .Normal)
            likeButton.setTitleColor(UIColor(white: 0.5, alpha: 1), forState: .Normal)
            
            note.likes--
            
            DatabaseWrapper.unlikeNote(note)
        }
        
        if note.likes > 0 {
            likeButton.setTitle(" "+String(note.likes), forState: .Normal)
        }
        else {
            likeButton.setTitle("", forState: .Normal)
        }
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}