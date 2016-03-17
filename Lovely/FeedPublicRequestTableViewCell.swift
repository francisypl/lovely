//
//  FeedPublicRequestTableViewCell.swift
//  lovely
//
//  Created by Max Hudson on 3/12/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

protocol FeedPublicRequestTableViewCellDelegate {
    func showSend(recipient: User?)
}

class FeedPublicRequestTableViewCell: UITableViewCell {
    
    var delegate: FeedPublicRequestTableViewCellDelegate?
    var noteSender: User?
    
    @IBOutlet weak var fromProfilePicture: UIImageView!
    @IBOutlet weak var fromName: UILabel!
    @IBOutlet weak var dayType: UILabel!
    @IBOutlet weak var noteIcon: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var noteCopy: UILabel!
    @IBOutlet weak var sendLoveButton: UIButton!
    
    @IBAction func sendLoveButtonPressed(sender: AnyObject) {
        if let user = noteSender {
            self.delegate?.showSend(user)
        }
    }
    
}