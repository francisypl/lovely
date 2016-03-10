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
    
    let feedFontSize:CGFloat = 13;
    
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
    }
    
    /**
    * Returns cell count
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    /**
    * Builds cell content
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Note") as! FeedNoteTableViewCell
        
        cell.fromName.text = "Francis Yuen"
        cell.fromName.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightSemibold);
        
        cell.noteIcon.image = UIImage(named: "heart")
        
        cell.toName.text = "Max Hudson"
        cell.toName.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightSemibold);
        
        cell.ageLabel.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightLight);
        
        cell.noteCopy.font = UIFont.systemFontOfSize(feedFontSize, weight: UIFontWeightRegular);
        cell.noteCopy.text = "This is text that is supposed to span more than one line."
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}