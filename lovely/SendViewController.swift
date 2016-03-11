//
//  SendViewController.swift
//  lovely
//
//  Created by Max Hudson on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

class SendViewController: UIViewController {
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var recipientField: PaddedTextField!
    @IBOutlet weak var noteContent: KMPlaceholderTextView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var loveType: UIButton!
    @IBOutlet weak var fistType: UIButton!
    
    var type = "love"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideNotification", name: UIKeyboardWillHideNotification, object: nil)
        
        self.view.backgroundColor = UIHelper.mainColor
        
        toolBar.clipsToBounds = true
        toolBar.backgroundColor = UIHelper.mainColor
        
        recipientField.backgroundColor = UIColor.whiteColor()
        
        recipientField.leftTextMargin = 20
        recipientField.setNeedsLayout()
        recipientField.layoutIfNeeded()
        
        recipientField.becomeFirstResponder()
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, recipientField.frame.height - 1, recipientField.frame.width, 1.0)
        bottomLine.backgroundColor = UIColor(white: 0.85, alpha: 1).CGColor
        
        recipientField.layer.addSublayer(bottomLine)
        
        noteContent.placeholder = "What's it for?"
        noteContent.textContainerInset = UIEdgeInsetsMake(15, 17, 15, 17)
        
        sendButton.backgroundColor = UIHelper.darkMainColor
        
        fistType.alpha = 0.5
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
    
    @IBAction func loveTypePressed(sender: AnyObject) {
        type = "love"
        
        loveType.alpha = 1
        fistType.alpha = 0.3
        
        sendButton.setTitle("Send Love", forState: UIControlState.Normal)
        recipientField.placeholder = "Love Recipient"
    }
    
    
    @IBAction func fistTypePressed(sender: AnyObject) {
        type = "fist"
        
        fistType.alpha = 1
        loveType.alpha = 0.3
        
        sendButton.setTitle("Send Fist Bump", forState: UIControlState.Normal)
        recipientField.placeholder = "Fist Bump Recipient"
    }
    
    /**
    * Hides view
    */
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}