//
//  FeedViewController.swift
//  lovely
//
//  Created by Max Hudson on 3/9/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var privacyToggle: UISegmentedControl!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var profileViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileName: UILabel!
    
    var publicFeed = true
    var profileViewHeight: CGFloat = 200
    let feedFontSize: CGFloat = 13
    var publicFeedNotes : [Note] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorInset = UIEdgeInsetsZero
        
        toolBar.clipsToBounds = true
        toolBar.backgroundColor = UIHelper.mainColor
        
        self.view.backgroundColor = UIHelper.mainColor
        
        profileView.backgroundColor = UIHelper.mainColor
        profileView.hidden = true
        profileViewHeightConstraint.constant = 0
        
        profileName.text = "Francis Yuen"
        
        requestButton.backgroundColor = UIHelper.darkMainColor
        
        publicFeedNotes = AppState.getNotes(true) //TODO
    }
    
    /**
    * Returns cell count
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return publicFeedNotes.count
    }
    
    /**
    * Builds cell content
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Note") as! FeedNoteTableViewCell
        
        let note = publicFeedNotes[indexPath.row]
        
        cell.fromName.text = "Francis Yuen"
        cell.fromName.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightSemibold);
        
        cell.noteIcon.image = UIImage(named: note.subType.rawValue + "-option")
        
        cell.toName.text = "Max Hudson"
        cell.toName.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightSemibold);
        
        cell.ageLabel.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightLight);
        
        cell.noteCopy.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightRegular);
        cell.noteCopy.text = note.message
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    @IBAction func privacyViewChanged(sender: AnyObject) {
        publicFeed = !publicFeed
        
        if privacyToggle.selectedSegmentIndex == 1 {
            profileViewHeightConstraint.constant = profileViewHeight
            profileView.hidden = false
        }
        else {
            profileViewHeightConstraint.constant = 0
            profileView.hidden = true
        }
        
        self.view.layoutIfNeeded()
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        UIHelper.showSend(self)
    }
    
    @IBAction func requestButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func settingsButtonPressed(sender: AnyObject) {
    }
    
}