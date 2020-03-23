//
//  HttpRequestController.swift
//  skillCounter
//
//  Created by 田中江樹 on 2017-04-21.
//  Copyright © 2017 Koki. All rights reserved.
//

import Foundation
import UIKit

class HttpRequest {
    let condition = NSCondition()
    
    /**
     Send GET request asynchronously
     - Parameters: urlString: String, funcs: @escaping ([String : Any]
     */
    func sendGetRequestAsync(urlString: String, funcs: @escaping ([String : Any]) -> Void)
    {
        var parsedData: [String : Any] = [:]
        var r = URLRequest(url: URL(string: urlString)!)
        r.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: r) { (data, response, error) in
            
            if (error == nil) {
//                _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                
                do {
                    parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
                } catch let error as NSError {
                    print(error)
                }
                
                funcs(parsedData)
            }
        }
        task.resume()
    }
    
    /**
     Send GET request synchronically
     - Parameters: urlString: String
     */
    func sendGetRequestSync(urlString: String) -> [[String : Any]]
    {
        var parsedData: [[String : Any]] = [[:]]
        var r = URLRequest(url: URL(string: urlString)!)
        r.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: r) { (data, response, error) in
            
            if error == nil {
                do {
                    parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String : Any]]
                } catch let error as NSError {
                    print(error)
                }
            }
            
            self.condition.signal()
            self.condition.unlock()
        }
        self.condition.lock()
        task.resume()
        self.condition.wait()
        self.condition.unlock()
        return parsedData
    }
    
    /**
     Send POST request asynchronously
     - Parameters: urlString: String, post: String, funcs: @escaping ([String : Any]
     */
    func sendPostRequestAsync(urlString: String, post: String, funcs: @escaping ([String : Any]) -> Void)
    {
        var parsedData: [String : Any] = [:]
        var r = URLRequest(url: URL(string: urlString)!)
        r.httpMethod = "POST"
        r.httpBody = post.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: r) { (data, response, error) in
            
            if error == nil {
                do {
                    parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
                } catch let error as NSError {
                    print(error)
                }
            }
            funcs(parsedData)
        }
        task.resume()
    }
    
    
    
    /**
     Send POST request synchronically
     - Parameters: urlString: String, post: String
     */
    func sendPostRequestSync(urlString: String, post: String) -> [[String : Any]]
    {
        var parsedDatas: [[String : Any]] = [[:]]
        var r = URLRequest(url: URL(string: urlString)!)
        r.httpMethod = "POST"
        r.httpBody = post.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: r) { (data, response, error) in
            
            if error == nil {
                do {
                    parsedDatas = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String : Any]]
                } catch let error as NSError {
                    print(error)
                }
            }
            
            self.condition.signal()
            self.condition.unlock()
        }
        self.condition.lock()
        task.resume()
        self.condition.wait()
        self.condition.unlock()
        
        return parsedDatas
    }
    
    func sendPostRequestSync2(urlString: String, post: String) -> String?
    {
        var parsedData: String? = ""
        var r = URLRequest(url: URL(string: urlString)!)
        r.httpMethod = "POST"
        r.httpBody = post.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: r) { (data, response, error) in
            
            if error == nil {
                parsedData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as String?
            }
            
            self.condition.signal()
            self.condition.unlock()
        }
        self.condition.lock()
        task.resume()
        self.condition.wait()
        self.condition.unlock()
        
        return parsedData
    }
}
