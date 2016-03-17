//
//  ProfileTableViewCell.swift
//  lovely
//
//  Created by Max Hudson on 3/14/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

protocol ProfileViewDelegate {
    func showSend(recipient: User?)
}

class ProfileTableViewCell: UITableViewCell {
    
    var delegate: ProfileViewDelegate?
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var journalButton: UIButton!
    
    @IBAction func journalButtonPressed(sender: AnyObject) {
        if let state = AppState.getInstance() {
            self.delegate?.showSend(state.getJournal())
        }
    }
    
}