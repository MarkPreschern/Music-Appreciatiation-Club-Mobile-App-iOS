//
//  MacApiRequest.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 9/16/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import Alamofire
import JASON

extension UIViewController {

    // Requests data from the mac api given a urlName and httpMethod, waits for a callback
    func macRequest(urlName : String!, httpMethod : HTTPMethod!, callback: @escaping (JSONStandard?) -> Void) {
        let url = "https://50pnu03u26.execute-api.us-east-2.amazonaws.com/MacTesting/api.mac.com/" + urlName
        let headers : HTTPHeaders = [
            "name" : userData?.user_name ?? "",
            "nuid" : userData?.user_nuid ?? ""
        ]
        
        Alamofire.request(url, method: httpMethod, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJASON(completionHandler: {
            response in
            // asyncronously parses the json data, waiting for a response to continue
            DispatchQueue.global(qos: .userInteractive).async {
                if let json = response.result.value {
                    let statusCode = json["statusCode"].stringValue
                    if let jsonData = json["body"].dictionary {
                        if (statusCode == "200") {
                            callback(jsonData)
                        } else {
                            let alert = createAlert(title: jsonData["title"] as? String, message: jsonData["description"] as? String, actionTitle: "close")
                            self.present(alert, animated: true, completion: nil)
                            callback(jsonData)
                        }
                    }
                }
            }
        })
    }
}
