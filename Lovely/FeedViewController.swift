//
//  FeedViewController.swift
//  lovely
//
//  Created by Max Hudson on 3/9/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SendViewControllerDelegate, RequestViewControllerDelegate, ProfileViewDelegate, FeedNoteTableViewCellDelegate {
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var privacyToggle: UISegmentedControl!
    @IBOutlet weak var footerView: UIView!
    
    var isPublic = true
    var isLoading = false
    let feedFontSize: CGFloat = 13
    var refreshControl: UIRefreshControl!
    var privateTableOffset: CGFloat = 0
    var publicTableOffset: CGFloat = 0
    var extraPrivateCells = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorInset = UIEdgeInsetsZero
        //tableView.backgroundColor = UIColor.clearColor()
        
        refreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
            
            return refreshControl
            }()
        
        tableView.addSubview(refreshControl)
        
        toolBar.clipsToBounds = true
        toolBar.backgroundColor = UIHelper.mainColor
        
        self.view.backgroundColor = UIHelper.mainColor
        
        footerView.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        considerPresentingIntroduction()
        considerPresentingNotificationRequest()
    }
    
    func reloadTable() {
        self.tableView.reloadData()
    }
    
    func considerPresentingNotificationRequest() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if userDefaults.valueForKey("notificationsRequested") == nil {
            UIHelper.showNotificationRequest(self)
        }
        
    }
    
    func considerPresentingIntroduction() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if userDefaults.valueForKey("shownIntroduction") == nil {
            UIHelper.showIntroduction(self)
        }
        
    }
    
    /**
     * Returns cell count
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let state = AppState.getInstance() {
            if isPublic {
                return state.publicFeed.count
            }
            else {
                return state.privateFeed.count + extraPrivateCells
            }
        }
        
        return 0
    }
    
    /**
     * Builds cell content
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let state = AppState.getInstance()!
        
        if !isPublic && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("Profile") as! ProfileTableViewCell
            
            cell.backgroundColor = UIHelper.mainColor
            
            cell.profilePicture.image = state.currentUser.image
            cell.profilePicture.layer.borderColor = UIColor.whiteColor().CGColor;
            cell.profilePicture.layer.borderWidth = 1;
            cell.profilePicture.layer.masksToBounds = true;
            cell.profilePicture.circle()
            
            cell.nameLabel.text = state.currentUser.name
            
            cell.journalButton.layer.shadowColor = UIColor.blackColor().CGColor
            cell.journalButton.layer.shadowOffset = CGSizeMake(0, 0)
            cell.journalButton.layer.shadowRadius = 5
            cell.journalButton.layer.shadowOpacity = 0.2
            
            cell.delegate = self
            
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
        }
        else if !isPublic && indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("RequestButtonCell")!
            
            cell.backgroundColor = UIHelper.darkMainColor
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
        }
        else {
            let note = isPublic ? state.publicFeed[indexPath.row] : state.privateFeed[indexPath.row - extraPrivateCells]
            let IAmSender = note.sender.id == state.currentUser.id
            let IAmRecipient = note.recipient.id == state.currentUser.id
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Note") as! FeedNoteTableViewCell
            
            cell.note = note
            
            cell.fromProfilePicture.image = IAmSender && !IAmRecipient ? state.currentUser.image : note.sender.image
            cell.fromProfilePicture.contentMode = .ScaleAspectFit
            cell.fromProfilePicture.circle()
            
            if note.type == "note" {
                if IAmSender {
                    cell.fromName.text = "You"
                }
                else {
                    cell.fromName.text = note.sender.name
                }
            }
            else {
                if IAmSender {
                    if !note.isPublic {
                        let recipientName = IAmSender || !IAmRecipient ? note.recipient.name : "You"
                        cell.fromName.text = recipientName + ", I"
                    }
                    else {
                        cell.fromName.text = "I"
                    }
                }
                else {
                    cell.fromName.text = note.sender.name
                }
            }
            
            cell.fromName.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightSemibold);
            
            cell.noteIcon.image = UIImage(named: note.subType.rawValue + "-option")
            
            cell.dayType.text = ""
            cell.toName.text = ""
            
            if note.type == "note" {
                cell.toName.text = IAmSender || !IAmRecipient ? note.recipient.name : "You"
                cell.toName.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightSemibold);
            }
            else {
                cell.dayType.text = "had a " + note.subType.rawValue + " day"
                cell.dayType.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightRegular);
            }
            
            cell.ageLabel.text = UIHelper.ago(note.date)
            cell.ageLabel.font = UIFont.systemFontOfSize(11, weight: UIFontWeightLight);
            
            cell.noteCopy.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightRegular);
            cell.noteCopy.text = note.message
            
            cell.likeButton.alpha = 0.5
            cell.likeButton.setTitleColor(UIHelper.darkMainColor, forState: .Normal)
            cell.likeButton.titleLabel?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightRegular)
            
            cell.commentButton.alpha = 0.5
            
            if note.liked {
                cell.likeButton.setImage(UIImage(named: "like-active.png"), forState: .Normal)
                cell.likeButton.alpha = 0.8
            }
            else {
                cell.likeButton.setImage(UIImage(named: "like.png"), forState: .Normal)
            }
            
            if note.likes > 0 {
                cell.likeButton.setTitle(" "+String(note.likes), forState: .Normal)
            }
            else {
                cell.likeButton.setTitle("", forState: .Normal)
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maxOffset - offset) <= 40 {
            appendItems()
        }
    }
    
    /**
     * Adds items to the end of the table if there are items to be added
     * Attempts to avoid showing loading icon if no notes will be loaded
     */
    func appendItems() {
        if (!isLoading) {
            if let state = AppState.getInstance() {
                let notes = isPublic ? state.publicFeed.count : state.privateFeed.count
                let outOfNotes = isPublic ? state.outOfPublicNotes : state.outOfPrivateNotes
                
                let load = notes >= 50 && !outOfNotes
                
                if load && state.readyForUserControl {
                    footerView.hidden = !load
                    isLoading = true
                    
                    state.appendNotes(self.isPublic) { Void -> () in
                        self.tableView.reloadData()
                        
                        self.isLoading = false
                        self.footerView.hidden = true
                    }
                }
            }
        }
    }
    
    /**
     * Table cell tap event
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !isPublic && indexPath.row == 1 {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            
            if let newVC = storyBoard.instantiateViewControllerWithIdentifier("RequestViewController") as? RequestViewController {
                newVC.delegate = self
                
                self.presentViewController(newVC, animated: true, completion: nil)
            }
        }
    }
    
    /**
     * Allows deleting of your notes
     */
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if !isPublic && indexPath.row < extraPrivateCells {
            return false
        }
        
        if let state = AppState.getInstance() {
            let note = isPublic ? state.publicFeed[indexPath.row] : state.privateFeed[indexPath.row - extraPrivateCells]
            
            if note.sender.id == state.currentUser.id {
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
            
            let state = AppState.getInstance()!
            let note = self.isPublic ? state.publicFeed[indexPath.row] : state.privateFeed[indexPath.row - self.extraPrivateCells]
            
            note.delete()
            
            if self.isPublic {
                state.deletePublicNoteAtIndex(indexPath.row)
            }
            else {
                state.deletePrivateNoteAtIndex(indexPath.row - self.extraPrivateCells)
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
        })
        
        deleteAction.backgroundColor = UIHelper.deleteColor
        
        return [deleteAction]
    }
    
    /**
     * Repulls notes & refreshes data
     */
    func handleRefresh(refreshControl: UIRefreshControl) {
        if !AppState.internetConnectIsAvaliable() {
            UIHelper.showConnectionLostErrorMessage(self)
            refreshControl.endRefreshing()
            return
        }
        
        if let state = AppState.getInstance() {
            if state.readyForUserControl {
                state.refreshNotes(isPublic, callback: { Void -> () in
                    self.tableView.reloadData()
                    refreshControl.endRefreshing()
                })
            }
        }
    }
    
    /**
     * Toggle private/public
     */
    @IBAction func privacyViewChanged(sender: AnyObject) {
        if isPublic {
            publicTableOffset = tableView.contentOffset.y
            readNotifications()
        }
        else {
            privateTableOffset = tableView.contentOffset.y
        }
        
        isPublic = !isPublic
        tableView.reloadData()
        
        if isPublic {
            tableView.scrollRectToVisible(CGRect(x: tableView.contentOffset.x, y: publicTableOffset, width: tableView.frame.width, height: tableView.frame.height), animated: false)
        }
        else {
            tableView.scrollRectToVisible(CGRect(x: tableView.contentOffset.x, y: privateTableOffset, width: tableView.frame.width, height: tableView.frame.height), animated: false)
        }
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        showSend(nil)
    }
    
    @IBAction func settingsButtonPressed(sender: AnyObject) {
        UIHelper.showSettings(self)
    }
    
    func showSend(recipient: User?) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        if let newVC = storyBoard.instantiateViewControllerWithIdentifier("SendViewController") as? SendViewController {
            newVC.delegate = self
            newVC.recipient = recipient
            
            self.presentViewController(newVC, animated: true, completion: nil)
        }
    }
    
    /**
     * Mark notifications as read
     */
    func readNotifications() {
        privacyToggle.setTitle("Private", forSegmentAtIndex: 1)
        privacyToggle.apportionsSegmentWidthsByContent = true
        
        if let state = AppState.getInstance() {
            state.notificationCount = 0
        }
    }
    
    /**
     * Reload feed
     */
    func noteCreated() {
        if let state = AppState.getInstance() {
            if state.readyForUserControl {
                state.refreshNotes(true, callback: self.reloadTable)
                state.refreshNotes(false, callback: self.reloadTable)
            }
        }
        
        tableView.reloadData()
    }
    
    /**
     * Displays a message
     */
    func showMessage(message: String, type: MessageType) {
        UIHelper.showMessage(message, vc: self, type: type)
    }
}