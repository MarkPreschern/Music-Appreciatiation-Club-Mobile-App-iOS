//
//  NewsScreenMainViewController.swift
//  Music-Appreciation-Mobile-App-iOs
//
//  Created by Mark Preschern on 3/6/19.
//  Copyright © 2019 Mark Preschern. All rights reserved.
//

import UIKit

// represents a post as it's post id, title,
struct Post {
    let post_id: Int!
    let title: String!
    let content: String!
    let date_created: String!
    let user_name: String!
    let role_name: String!
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
        self.view_outlet.layer.borderWidth = 1
        self.view_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        //sets view border
        self.viewPost_outlet.layer.borderWidth = 1
        self.viewPost_outlet.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        //sets table outlet's datasource to this class's extension
        self.table_outlet.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
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
        self.macRequest(urlName: "posts", httpMethod: .get, header: nil, successAlert: false, callback: { jsonData -> Void in
            if let statusCode = jsonData?["statusCode"] as? String {
                if statusCode == "200" {
                    if let items = jsonData?["posts"] as? [JSONStandard] {
                        if items.count == 0 {
                            self.removeSpinner()
                        }
                        for i in 0..<items.count {
                            let item = items[i]
                            
                            let post = Post(post_id: item["post_id"] as? Int,
                                            title: item["title"] as? String,
                                            content: item["content"] as? String,
                                            date_created: item["date"] as? String,
                                            user_name: item["user_name"] as? String,
                                            role_name: item["user_name"] as? String)
                            
                            self.posts.append(post)
                            if i == items.count - 1 {
                                self.table_outlet.reloadData()
                                self.removeSpinner()
                            }
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

}

// extension handles table data
extension NewsScreenMain: UITableViewDataSource {
    
    //sets the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    //updates table view data including the image and label
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "popularCell")
        //sets the user name and user role
        let username = cell?.viewWithTag(1) as! UILabel
        username.text = posts[indexPath.row].user_name + ", " + posts[indexPath.row].role_name
        //sets the title
        let rolename = cell?.viewWithTag(2) as! UILabel
        rolename.text = posts[indexPath.row].title
        //sets the content
        let title = cell?.viewWithTag(3) as! UILabel
        title.text = posts[indexPath.row].content
        //sets the date
        let date = cell?.viewWithTag(4) as! UILabel
        date.text = posts[indexPath.row].date_created
                
        return cell ?? UITableViewCell()
    }
}
