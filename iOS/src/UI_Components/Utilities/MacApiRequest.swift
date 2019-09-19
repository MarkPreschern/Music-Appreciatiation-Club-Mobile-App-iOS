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
    func macRequest(urlName : String!, httpMethod : HTTPMethod!, header : HTTPHeaders?, callback: @escaping (JSONStandard?) -> Void) {
        let url = "https://50pnu03u26.execute-api.us-east-2.amazonaws.com/MacTesting/api.mac.com/" + urlName
        
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
        
        Alamofire.request(url, method: httpMethod, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON(completionHandler: { response in
            do {
                var readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! JSONStandard
                print(readableJSON)
                if let statusCode = readableJSON["statusCode"] as? String {
                    if (statusCode == "200") {
                        callback(readableJSON)
                    } else {
                        let alert = createAlert(title: readableJSON["title"] as? String, message: readableJSON["description"] as? String, actionTitle: "close")
                        self.present(alert, animated: true, completion: nil)
                        callback(["statusCode": statusCode as AnyObject])
                    }
                } else {
                    let alert = createAlert(
                        title: "Request Failed",
                        message: "Error occured during request",
                        actionTitle: "Try Again")
                    self.present(alert, animated: true, completion: nil)
                }
            } catch {
                print("Error info: \(error)")
                let alert = createAlert(
                    title: "Request Failed",
                    message: "Error occured during request",
                    actionTitle: "Try Again")
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
}
