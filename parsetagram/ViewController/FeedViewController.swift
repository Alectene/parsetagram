//
//  FeedViewController.swift
//  parsetagram
//
//  Created by Alec Tenefrancia on 1/30/20.
//  Copyright © 2020 Alec Tenefrancia. All rights reserved.
// functionality here is that it shows the feed, gets the API from parse and puts it onto the corresponding parts, such as username, caption & photo label
//user can also pull to refresh

import UIKit
import Parse
import AlamofireImage
import Alamofire

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var posts = [PFObject]()
    var numberofPost: Int!
    var refreshControl: UIRefreshControl! //to refresh
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //shows 5 posts before need to reload
        numberofPost = 5
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        //below to refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }// end viewDidLoad function, loading function
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        loadPost()
    }// end viewDidAppear function, makes more post appear
    
    @objc func loadPost() {
           let query = PFQuery(className: "Posts")
           query.includeKey("author")
           query.limit = numberofPost
           
           query.findObjectsInBackground { (posts, error) in
               if posts != nil {
                   self.posts = posts!
                   self.tableView.reloadData()
               }
           }
       } // end loadPost function, loads more of the posts
    
    func loadMorePost() {
        numberofPost += 5
        loadPost()
    } // end loadMorePost function, loads more post
    
    
    // Call the delay method in your onRefresh() method
    @objc func onRefresh() {
        run(after: 2) {
            self.refreshControl.endRefreshing()
        }
    } // end onRefresh function
    
    // Implement the delay method
    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
        
    } // end run function
    
  /*  override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className:"Posts")
        query.includeKey("author")
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
        
        
    }*/
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row + 1 == posts.count {
            loadMorePost()
        }
        
    } // end tableView(willDisplay) function
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }// end tableView(numberOfRowsInSection) function
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        
        let post = posts[indexPath.row]
        let user = post["author"] as! PFUser
        
        cell.usernameLabel.text = user.username
        
        cell.captionLabel.text = post["caption"] as! String
        
        //let imageFile = post["image"] as! PFFileObject
        
        let imageFile = post["image"] as? PFFileObject
        let urlString = imageFile?.url
        let url = URL(string: urlString!)!
        
        cell.photoView.af_setImage(withURL: url)
        
        
        return cell
    }// end tableView(cellForRowAt) function

    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()

                let main = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")

                let delegate = UIApplication.shared.delegate as! AppDelegate

                delegate.window?.rootViewController = loginViewController
        
        
        
    }
    
}
