//
//  NewsScreenMainViewController.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 3/6/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit
import Alamofire

// represents a post as it's post id, title,
struct Post {
    let post_id: Int!
    let title: String!
    let content: String!
    let date_created: String!
    let user_id: Int!
    let user_name: String!
    let role_name: String!
    let user_image: UIImage?
}

// Represents the news screen. Holds information regarding:
// - club related news and reminders
class NewsScreenMain: UIViewController, UITableViewDelegate {
    
    var posts = [Post]()
    
    @IBOutlet weak var view_outlet: UIView!
    @IBOutlet weak var table_outlet: UITableView!
    @IBOutlet weak var addPost_outlet: UIButton!
    @IBOutlet weak var viewPost_outlet: UIView!
    
    // initialization on view loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets task bar border
        self.view_outlet.layer.addBorder(edge: UIRectEdge.top, color: UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1), thickness: 1)
        
        //sets view border
        self.viewPost_outlet.layer.borderWidth = 1
        self.viewPost_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        //sets table outlet's datasource to this class's extension
        self.table_outlet.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.table_outlet.dataSource = self
        self.table_outlet.delegate = self
        
        // addPost button isn't visible or enabled for normal users
        if userData.access_name == "User" {
            addPost_outlet.isHidden = true
            addPost_outlet.isEnabled = false
        }
        
        self.loadPosts()
    }
    
    // loads in post data from the MAC API
    func loadPosts() {
        self.macRequest(urlName: "posts", httpMethod: .get, header: nil, successAlert: false, attempt: 0, callback: { jsonData -> Void in
            if let statusCode = jsonData?["statusCode"] as? String {
                if statusCode == "200" {
                    if let items = jsonData?["posts"] as? [JSONStandard] {
                        if items.count == 0 {
                            self.removeSpinner()
                        }
                        for i in 0..<items.count {
                            // sets the date
                            let item = items[i]
                            let dateList = (item["date_created"] as! String).components(separatedBy: "-")
                            let day = dateList[2].components(separatedBy: "T")[0]
                            let date = dateList[1] + "/" + day + "/" + dateList[0]
                            
                            // sets the image
                            let imageEncoded = (items[0]["image_data"] as? String)?.removingPercentEncoding
                            let imageData : NSData? = (imageEncoded != nil) ? NSData(base64Encoded: imageEncoded!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) : nil
                            let mainImage : UIImage? = (imageEncoded != nil) ? UIImage(data: imageData! as Data)! : nil
                            
                            let post = Post(post_id: item["post_id"] as? Int,
                                            title: item["title"] as? String,
                                            content: item["content"] as? String,
                                            date_created: date,
                                            user_id: item["user_id"] as? Int,
                                            user_name: item["user_name"] as? String,
                                            role_name: item["role_name"] as? String,
                                            user_image: imageEncoded == nil ? nil : mainImage)
                            
                            self.posts.append(post)
                            self.table_outlet.reloadData()
                        }
                    } else {
                    let alert = createAlert(
                        title: "Request Failed",
                        message: "Error occured during request, couldn't locate items",
                        actionTitle: "Close")
                    self.present(alert, animated: true, completion: nil)
                    self.removeSpinner()
                    }
                } else {
                self.removeSpinner()
                }
            } else {
                self.removeSpinner()
            }
        })
    }
    
    @IBAction func addPostClicked(_ sender: Any) {
        let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "CreatePostID")
        self.present(nextVC, animated:true, completion: nil)
    }
    
    // handles when a user clicks the trash icon, prompting the user to delete the pick
    @objc func trash(gesture: VoteTapGesture) {
        if (gesture.view as? UIImageView) != nil {
            let alert = UIAlertController(title: "Delete Post", message: "Are you sure you want to delete this post? This action cannot be undone.", preferredStyle: UIAlertController.Style.alert)
            // handles if the user clicks "no"
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            // handles if the user clicks "yes"
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                let header: HTTPHeaders = [
                    "post_id": String(self.posts[gesture.index].post_id),
                ]
                self.macRequest(urlName: "deletePost", httpMethod: .post, header: header, successAlert: true, attempt: 0, callback: { response -> Void in
                    if let statusCode = response?["statusCode"] as? String {
                        if statusCode == "200" {
                            self.posts.remove(at: gesture.index)
                            self.table_outlet.reloadData()
                        }
                    }
                })
            }))
            // presents the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// extension handles table data
extension NewsScreenMain: UITableViewDataSource {
    
    //sets the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    //updates table view data including the image and label
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as? PostCell
        //sets the user name and user role
        let username = cell?.viewWithTag(1) as! UILabel
        username.text = posts[indexPath.row].user_name + ", " + posts[indexPath.row].role_name
        //sets the content
        let content = cell?.viewWithTag(3) as! UILabel
        content.text = posts[indexPath.row].content
        //sets the date
        let date = cell?.viewWithTag(4) as! UILabel
        date.text = posts[indexPath.row].date_created
        // sets the image
        let image = cell?.viewWithTag(5) as! UIImageView
        if posts[indexPath.row].user_image != nil {
            image.image = posts[indexPath.row].user_image
        }
        
        // if the user is authorized to delete the post
        if userData.user_id == self.posts[indexPath.row].user_id ||
            userData.role_name == "Developer" ||
            (userData.role_name == "Admin" && self.posts[indexPath.row].role_name != "Developer" && self.posts[indexPath.row].role_name != "Admin") {
            // creates a trash icon image gesture recognizer
            let tapGestureTrash = VoteTapGesture(target: self, action: #selector(NewsScreenMain.trash(gesture:)))
            tapGestureTrash.index = indexPath.row
            cell?.trash_outlet.addGestureRecognizer(tapGestureTrash)
        } else {
            cell?.trash_outlet.isHidden = true
            cell?.trash_outlet.isUserInteractionEnabled = false
        }
                
        return cell ?? UITableViewCell()
    }
}

// custom table cell containing trash icon outlet
class PostCell: UITableViewCell {
    @IBOutlet weak var trash_outlet: UIImageView!
}
