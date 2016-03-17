//
//  IntroductionViewController.swift
//  lovely
//
//  Created by Max Hudson on 3/15/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

class IntroductionViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var doneButton: UIButton!
    
    var imageNames = [
        "intro-send-love.png",
        "intro-request.png",
        "intro-feed.png",
        "intro-private-feed.png",
        "intro-journal.png"
    ]
    
    var captions = [
        "Send love and fist bumps to your friends publicly or privately",
        "Let your friends know how your day was",
        "See who your friends are sending love",
        "See love that has been sent to you privately",
        "Keep memories of what you love about yourself"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.numberOfPages = imageNames.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor(white: 0.9, alpha: 1)
        pageControl.currentPageIndicatorTintColor = UIColor(white: 0.7, alpha: 1)
        
        configureScrollView()
        
        doneButton.backgroundColor = UIHelper.mainColor
        doneButton.layer.cornerRadius = 3
        doneButton.clipsToBounds = true
    }
    
    func configureScrollView() {
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        
        let pageWidth = self.view.frame.width
        
        for i in 0..<imageNames.count {
            let captionFrame = CGRect(x: pageWidth * CGFloat(i) + 40, y: 0, width: pageWidth - 80, height: 60)
            
            let caption = UILabel(frame: captionFrame)
            caption.text = captions[i]
            caption.numberOfLines = 0
            caption.lineBreakMode = .ByWordWrapping
            caption.textAlignment = .Center
            caption.font = UIFont.systemFontOfSize(15, weight: UIFontWeightRegular)
            caption.textColor = UIColor(white: 0.3, alpha: 1)
            
            let captionWidthConstraint = NSLayoutConstraint(item: caption, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: pageWidth - 80)
            
            caption.addConstraint(captionWidthConstraint)
            
            scrollView.addSubview(caption)
            
            let imageFrame = CGRect(x: pageWidth * CGFloat(i) + 40, y: 60, width: pageWidth - 80, height: scrollView.frame.height - 60)
            
            let imageView = UIImageView(frame: imageFrame)
            imageView.image = UIImage(named: imageNames[i])
            imageView.contentMode = .ScaleAspectFit
            scrollView.addSubview(imageView)
        }
        
        scrollView.pagingEnabled = true
        scrollView.contentSize = CGSizeMake(pageWidth * CGFloat(imageNames.count), scrollView.frame.height)
        
        pageControl.addTarget(self, action: Selector("changePage:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPointMake(x, 0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(true, forKey: "shownIntroduction")
        userDefaults.synchronize()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}