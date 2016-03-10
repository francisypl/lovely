//
//  HttpHelper.swift
//  lovely
//
//  Created by Max Hudson on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import Foundation

struct HttpHelper {
    static let host = "http://54.187.56.45/ios-api/"
    
    /**
    Sends post request to page on server
    */
    static func post(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: host + url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var postString = "";
        
        for (key, value) in params {
            if postString != "" {
                postString += "&"
            }
            
            postString += key + "=" + value
        }
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            
        let task = session.dataTaskWithRequest(request, completionHandler: {
                data, response, error -> Void in
            
            if (error != nil) {
                postCompleted(succeeded: false, msg: error!.localizedDescription)
            }
            else {
                let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                
                postCompleted(succeeded: true, msg: strData as! String)
            }
        })
        
        task.resume()
    }
    
    /**
    Converts JSON string to [[String: AnyObject]]
     
    Sample usage:

    print(HttpHelper.post(["username": "uname", "token": "asdfasdf"], url: "notes.php", postCompleted: {(succeeded, msg) -> () in
        if succeeded {
            if let notesData = HttpHelper.jsonToDictionaryArray(msg) {
                for noteData in notesData {
                    print(noteData)
                }
            }
        }
    }))
    */
    static func jsonToDictionaryArray(text: String) -> [[String: AnyObject]]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [[String: AnyObject]]
                return json
            }
            catch {
                print("Something went wrong")
            }
        }
    
        return nil
    }
}