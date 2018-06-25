//
//  Requests.swift
//  Show Me This
//
//  Created by Ravikiran Pathade on 6/18/18.
//  Copyright © 2018 Ravikiran Pathade. All rights reserved.
//

import Foundation

class Requests{
    var URL_WOLFRAM : String = "https://api.wolframalpha.com/v2/query?appid=8GT3GW-YJWQUVW9WL&output=json&input="
    
    func fetchImage(_ imageUrl : String, completionHandler : @escaping(_ success : Bool, _ imageData : Data) -> Void){
        
        let session = URLSession.shared
        let url = URL(string: imageUrl)
        if let url = url {
            let request = URLRequest(url: url)
            
            let task = session.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    completionHandler(false, Data())
                    return
                }
                
                completionHandler(true,data!)
            }
            task.resume()

        }
 
    }
    
    func fetchImages(_ query : String, completionHandler: @escaping(_ success : Bool, _ result : [String : [(String,String,String)]], _ keys : [String]) -> Void){
        let session = URLSession.shared
        //Format Query to check invalid input
        let q = query.replacingOccurrences(of: " ", with: "+").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = URL(string: URL_WOLFRAM+q.lowercased())
        let request = URLRequest(url: url!)
   
        let task = session.dataTask(with: request) { (data, response, error) in
            var tupleArray = [String : [(String,String,String)]]()
            var keyArray = [String]()
            guard error == nil else {
                completionHandler(false,tupleArray,keyArray)
                return
            }
            
            var parsedResult : [String:AnyObject]!
            
            do {
                try parsedResult = JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            }catch{
                print(error.localizedDescription)
            }

            if let queryResult = parsedResult["queryresult"] as? [String:AnyObject] {
                if let numpods = queryResult["numpods"] as? Int{
                    if let pods = queryResult["pods"] as? [[String:AnyObject]] {
                        for pod in pods {
                            if let title = pod["title"] as? String{
                                if let numsubpods = pod["numsubpods"] as? Int{
                                    if let subpods = pod["subpods"] as? [[String:AnyObject]] {
                                        var podArray = [(String,String,String)]()
                                        for subpod in subpods{
                                            if let subpodTitle = subpod["title"] as? String{
                                                if let subpodImage = subpod["img"] as? [String:AnyObject]{
                                                    if let imageUrl = subpodImage["src"] as? String{
                                                        if let subpodPlainString = subpod["plaintext"] as? String{
                                                            podArray.append((subpodTitle,imageUrl,subpodPlainString))
                                                        }
                                                    }
                                                  
                                                }
                                            }
                                           
                                        }
                                        tupleArray[title] = podArray
                                        keyArray.append(title)
                                    }
                              
                                }
                            }
                        }
                    }
                }
                completionHandler(true,tupleArray,keyArray)
            }else {
                completionHandler(false,tupleArray,keyArray)
            }
            
        }
        task.resume()
        
    }
}
