//
//  FeedNoteTableViewCell.swift
//  lovely
//
//  Created by Max Hudson on 3/9/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

protocol FeedNoteTableViewCellDelegate {
    func showSend(recipient: User?)
    func showNote(note: Note)
}

class FeedNoteTableViewCell: UITableViewCell {
    
    var delegate: FeedNoteTableViewCellDelegate?
    var note: Note!
    
    @IBOutlet weak var fromProfilePicture: UIImageView!
    @IBOutlet weak var fromName: UILabel!
    @IBOutlet weak var noteIcon: UIImageView!
    @IBOutlet weak var toName: UILabel!
    @IBOutlet weak var dayType: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var noteCopy: UILabel!
    @IBOutlet weak var sendLove: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var privateIndicator: UIImageView!
    
    @IBAction func sendLoveButtonPressed(sender: AnyObject) {
        if let sender = note?.sender {
            self.delegate?.showSend(sender)
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
    
    @IBAction func commentButtonPressed(sender: AnyObject) {
        self.delegate?.showNote(note)
    }
}