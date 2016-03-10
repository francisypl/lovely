//
//  DBTest.swift
//  lovely
//
//  Created by Max Hudson on 3/9/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

class HomeModel: NSObject, NSURLSessionDataDelegate {
    
    //properties
    var data : NSMutableData = NSMutableData()
    
    ///URL TO PULL FROM
    let urlPath: String = "http://54.187.56.45/ios-api/notes.php"
    
    //////CONNECT TO DB
    func downloadItems() {
        
        let url: NSURL = NSURL(string: urlPath)!
        var session: NSURLSession!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTaskWithURL(url)
        
        task.resume()
        
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        self.data.appendData(data);
        
    }
    
    /////DOWNLOAD DATA
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            print("Failed to download data")
        }else {
            print("Data downloaded")
            parseJSON()
        }
        
    }
    
    //////PARSE DATA
    func parseJSON() {
        
        var jsonResult: NSMutableArray = NSMutableArray()
        
        do{
            jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data, options:NSJSONReadingOptions.AllowFragments) as! NSMutableArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement: NSDictionary = NSDictionary()
        
        for (var i = 0; i < jsonResult.count; i++) {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            /////print specific element
            print(jsonElement["text"] as? String)
        }
        
    }
}