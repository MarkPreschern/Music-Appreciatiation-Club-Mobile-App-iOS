//
//  MacApiRequest.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 9/16/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import Alamofire

extension UIViewController {

    // Requests data from the mac api given a urlName and httpMethod, waits for a callback
    func macRequest(urlName : String!, httpMethod : HTTPMethod!, header : HTTPHeaders?, successAlert : Bool!, attempt: Int!, callback: @escaping (JSONStandard?) -> Void) {
        let url = API_URL + urlName
        
        // sets the header based on input header
        var headers: HTTPHeaders = [:];
        if (header == nil) {
            headers = [
                "user_id" : "\(String(describing: userData.user_id!))",
                "authorization_token" : userData?.authorization_token ?? ""
            ]
        } else {
            headers = header!
            headers["user_id"] = "\(String(describing: userData.user_id!))"
            headers["authorization_token"] = userData?.authorization_token ?? ""
        }
        
        // sanitizes all api request headers
        for (key, value) in headers {
            headers[key] = value.sanitize()
        }
        
        // retry's the mac request
        func retry() {
            self.macRequest(urlName: urlName, httpMethod: httpMethod, header: header, successAlert: successAlert, attempt: attempt + 1, callback: callback)
        }
        
        // outputs, alerts, and calls back the error message
        func errorMessage(title: String!, description: String!, statusCode: String!) {
            let alert = createAlert(
                title: title,
                message: description,
                actionTitle: "Close")
            self.present(alert, animated: true, completion: nil)
            callback(["statusCode": statusCode as AnyObject])
        }
        
        Alamofire.request(url, method: httpMethod, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { response in
            do {
                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! JSONStandard
                print(readableJSON)
                if let statusCode = readableJSON["statusCode"] as? String {
                    if (statusCode == "200") {
                        if (successAlert) {
                            let alert = createAlert(title: "Success", message: readableJSON["message"] as? String, actionTitle: "Close")
                            self.present(alert, animated: true, completion: nil)
                        }
                        callback(readableJSON)
                    } else {
                        errorMessage(title: readableJSON["title"] as? String, description: readableJSON["description"] as? String, statusCode: statusCode)
                    }
                } else {
                    // makes another attempt if a backend error occured
                    if attempt > 1 {
                       errorMessage(title: "Request Failed", description: "Error occured during request", statusCode: "404")
                    } else {
                        retry()
                    }
                }
            } catch {
                // makes another attempt if an uncaught exception occurs
                print("Error info: \(error)")
                if attempt > 1 {
                   errorMessage(title: "Request Failed", description: "Error occured during request", statusCode: "404")
                } else {
                    retry()
                }
            }
        })
    }
}
