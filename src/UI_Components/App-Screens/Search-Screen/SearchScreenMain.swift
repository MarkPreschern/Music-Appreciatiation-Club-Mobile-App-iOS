//
//  SearchScreenMain.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 3/14/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import Alamofire

// Represents information in a cell of the table view
struct ItemData {
    let name : String!
    let mainImage : UIImage!
}


// Represents the search screen. Holds information regarding:
// - Songs and albums available on spotify
// - ability to choose songs and albums weekly
class SearchScreenMain: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var view_outlet: UIView! // main view
    @IBOutlet weak var searchTextBox_outlet: SearchTextBox! //search text box
    @IBOutlet weak var tableView: UITableView! // table view
    
    var items = [ItemData]() // list of items in the table view
    typealias JSONStandard = [String : AnyObject]
    
    let defaultURL = "" // default url for when the view first loads in
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view_outlet.layer.borderWidth = 1
        self.view_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        self.searchTextBox_outlet.delegate = self
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.tableView.dataSource = self
        
        self.callAlimo(url: self.defaultURL)
    }
    
    // Dismisses text field on 'return' key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    //calls the spotify url
    func callAlimo(url : String) {
        AF.request(url).responseJSON(completionHandler: {
            response in
            self.parseData(JSONData: response.data!)
        })
    }
    
    //reads the json produced by the call to the spotify url
    func parseData(JSONData : Data) {
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            if let tracks = readableJSON["tracks"] as? JSONStandard {
                if let items = tracks["items"] as? [JSONStandard] {
                    for i in 0..<items.count {
                        let item = items[i]
                        let name = item["name"] as! String
                        if let album = item["album"] as? JSONStandard {
                            if let images = album["images"] as? [JSONStandard] {
                                let imageData = images[0]
                                let mainImageURL = URL(string: imageData["url"] as! String)
                                let mainImageData = NSData(contentsOf: mainImageURL!)
                                let mainImage = UIImage(data: mainImageData! as Data)
                                
                                self.items.append(ItemData.init(name: name, mainImage: mainImage))
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error info: \(error)")
        }
    }
}

// extension of search screen main allows for updating of the table view
extension SearchScreenMain: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        //sets the label
        let mainLabel = cell?.viewWithTag(1) as! UILabel
        mainLabel.text = self.items[indexPath.row].name
        //sets the image
        let mainImageView = cell?.viewWithTag(2) as! UIImageView
        mainImageView.image = self.items[indexPath.row].mainImage
        
        return cell!
    }
}
