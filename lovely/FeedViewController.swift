//
//  FeedViewController.swift
//  lovely
//
//  Created by Max Hudson on 3/9/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SendViewControllerDelegate, RequestViewControllerDelegate {
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var privacyToggle: UISegmentedControl!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var profileViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileName: UILabel!
    
    var isPublic = true
    var profileViewHeight: CGFloat = 200
    let feedFontSize: CGFloat = 13
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorInset = UIEdgeInsetsZero
        
        let refreshControl: UIRefreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
            
            return refreshControl
        }()
        
        tableView.addSubview(refreshControl)
        
        toolBar.clipsToBounds = true
        toolBar.backgroundColor = UIHelper.mainColor
        
        self.view.backgroundColor = UIHelper.mainColor
        
        profileView.backgroundColor = UIHelper.mainColor
        profileView.hidden = true
        profileViewHeightConstraint.constant = 0
        
        profileName.text = "Francis Yuen"
        
        requestButton.backgroundColor = UIHelper.darkMainColor
        
        if let state = AppState.getInstance() {
            state.refreshNotes(true)
            state.refreshNotes(false)
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
                return state.privateFeed.count
            }
        }
        
        return 0
    }
    
    /**
    * Builds cell content
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let state = AppState.getInstance()!
        let note = isPublic ? state.publicFeed[indexPath.row] : state.privateFeed[indexPath.row]
        
        if note.type == "note" {
            let cell = tableView.dequeueReusableCellWithIdentifier("Note") as! FeedNoteTableViewCell
            
            cell.fromName.text = "Francis Yuen"
            cell.fromName.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightSemibold);
            
            cell.noteIcon.image = UIImage(named: note.subType.rawValue + "-option")
            
            cell.toName.text = "Max Hudson"
            cell.toName.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightSemibold);
            
            cell.ageLabel.text = UIHelper.ago(note.date)
            cell.ageLabel.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightLight);
            
            cell.noteCopy.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightRegular);
            cell.noteCopy.text = note.message
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Request") as! FeedPublicRequestTableViewCell
            
            if let state = AppState.getInstance() {
                if note.sender.id == state.currentUser.id {
                    if note.isPublic {
                        cell.fromName.text = "Francis Yuen, I"
                    }
                    else {
                        cell.fromName.text = "I"
                    }
                }
                else {
                    cell.fromName.text = "Francis Yuen"
                }
            }
            
            cell.fromName.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightSemibold);
            
            cell.dayType.text = "had a " + note.subType.rawValue + " day"
            cell.dayType.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightRegular);
            
            cell.noteIcon.image = UIImage(named: note.subType.rawValue + "-option")
            
            cell.ageLabel.text = UIHelper.ago(note.date)
            cell.ageLabel.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightLight);
            
            cell.noteCopy.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightRegular);
            cell.noteCopy.text = note.message
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
        }
    }
    
    /**
     * Allows deleting of your notes
     */
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let state = AppState.getInstance() {
            let note = isPublic ? state.publicFeed[indexPath.row] : state.privateFeed[indexPath.row]
            
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
     * Handle delete element and event
     */
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?  {
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action , indexPath) -> Void in
            
            let state = AppState.getInstance()!
            let note = self.isPublic ? state.publicFeed[indexPath.row] : state.privateFeed[indexPath.row]
            
            note.delete()
            
            if self.isPublic {
                state.deletePublicNoteAtIndex(indexPath.row)
            }
            else {
                state.deletePrivateNoteAtIndex(indexPath.row)
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
        if let state = AppState.getInstance() {
            state.refreshNotes(isPublic)
        }
        
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    /**
     * Toggle private/public
     */
    @IBAction func privacyViewChanged(sender: AnyObject) {
        isPublic = !isPublic
        
        if privacyToggle.selectedSegmentIndex == 1 {
            profileViewHeightConstraint.constant = profileViewHeight
            profileView.hidden = false
        }
        else {
            profileViewHeightConstraint.constant = 0
            profileView.hidden = true
        }
        
        tableView.reloadData()
        
        self.view.layoutIfNeeded()
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let newVC = storyBoard.instantiateViewControllerWithIdentifier("SendViewController") as? SendViewController
        
        if newVC != nil {
            newVC!.delegate = self
            
            self.presentViewController(newVC!, animated: true, completion: nil)
        }
    }
    
    @IBAction func requestButtonPressed(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let newVC = storyBoard.instantiateViewControllerWithIdentifier("RequestViewController") as? RequestViewController
        
        if newVC != nil {
            newVC!.delegate = self
            
            self.presentViewController(newVC!, animated: true, completion: nil)
        }
    }
    
    @IBAction func settingsButtonPressed(sender: AnyObject) {
        UIHelper.showSettings(self)
    }
    
    /**
     * Reload feed
     */
    func noteCreated() {
        if let state = AppState.getInstance() {
            state.refreshNotes(true)
            state.refreshNotes(false)
        }
        
        tableView.reloadData()
    }
}