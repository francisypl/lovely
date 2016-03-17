//
//  HttpHelper.swift
//  lovely
//
//  Created by Max Hudson on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import Foundation

struct HttpHelper {
    static let host = "https://weflowapp.com/lovely-api/"
    static let privateToken = "mkeib909asdm23klsd*"
    
    static func formatPostParams(params: [String: String]) -> NSData {
        var postString = "private-token=" + privateToken;
        
        for (key, value) in params {
            postString += "&" + key + "=" + value
        }

        return postString.dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    static func post_async(params: [String: String], url: String, callback: ((response: String) -> ())?) {
        let request = NSMutableURLRequest(URL: NSURL(string: host + url)!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = formatPostParams(params)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            if error == nil {
                if let output = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String {
                    if callback != nil {
                        callback!(response: output)
                    }
                }
            }
        }).resume()
    }
    
    /**
     Sends synchronous post request to page on server
    */
    static func post(params : [String: String], url : String) -> String {
        let request = NSMutableURLRequest(URL: NSURL(string: host + url)!)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = formatPostParams(params)
        
        let data = requestSynchronousData(request)
        let strData = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
        
        return strData
    }
    
    static func requestSynchronousData(request: NSURLRequest) -> NSData? {
        var data: NSData? = nil
        let semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            taskData, _, error -> () in
            data = taskData
            if data == nil, let error = error {print(error)}
            dispatch_semaphore_signal(semaphore);
        })
        
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return data
    }
    
    /**
    Converts JSON string to [[String: AnyObject]]
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
    
    /**
     Converts JSON string to [[String: AnyObject]]
     */
    static func jsonToDictionary(text: String) -> [String: AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String: AnyObject]
                return json
            }
            catch {
                print("Something went wrong")
            }
        }
        
        return nil
    }
}