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
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
  /* let commentBar = MessageInputBar()
   var refreshControl: UIRefreshControl!
   var showsCommentBar = false
   //var posts = String
   var posts = [PFObject]()
   
   var selectedPost: PFObject!
    */
    var posts = [PFObject]()
    var selectedPost: PFObject!
    var numberOfPost: Int!
    var refreshControl: UIRefreshControl!
    var showsCommentBar = false
    let feedLimit = 20
    let commentBar = MessageInputBar()
   override func viewDidLoad() {
         
         super.viewDidLoad()
         
         // Do any additional setup after loading the view.
         
         commentBar.inputTextView.placeholder = "Add a comment..."
         commentBar.sendButton.title = "Post"
         commentBar.delegate = self
         
         tableView.dataSource = self
         tableView.delegate = self
         
         tableView.keyboardDismissMode = .interactive
         
         let center = NotificationCenter.default
         center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
         
         refreshControl = UIRefreshControl()
         refreshControl.addTarget(self, action: #selector(loadPost), for: .valueChanged)
         tableView.insertSubview(refreshControl, at: 0)
         
     } // end viewDidLoad function
     
     override func viewDidAppear(_ animated: Bool) {
         
         super.viewDidAppear(animated)
         numberOfPost = 5
         loadPost()
         
     } // end viewDidAppear function
     
     @objc func loadPost() {
         
         let query = PFQuery(className: "Posts")
         query.includeKeys(["author", "comments", "comments.author"])
         query.limit = numberOfPost
         //        query.order(byDescending: "createdAt")
         
         query.findObjectsInBackground { (posts, error) in
             if posts != nil {
                 self.posts = posts!
                 self.tableView.reloadData()
                 self.refreshControl.endRefreshing()
             } else {
                 print("Oh No! We can't fetch any photos!: \(error)")
             }
         }
         
     } // end loadPost function
     
     func loadMorePost() {
         
         numberOfPost += 5
         loadPost()
         
     } // end loadMorePost function
     
     func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
         
         // Create the comment
         let comment = PFObject(className: "Comments")
         
         comment["text"] = text
         comment["post"] = selectedPost
         comment["author"] = PFUser.current()
         
         selectedPost.add(comment, forKey: "comments")
         
         selectedPost.saveInBackground { (success, error) in
             if success {
                 print("Comment saved")
             } else {
                 print("Error saving comment")
             }
         }
         
         tableView.reloadData()
         
         // Clear and dismiss the input bar
         commentBar.inputTextView.text = nil
         showsCommentBar = false
         becomeFirstResponder()
         commentBar.inputTextView.resignFirstResponder()
         
     } // end messageInputBar function
     
     @objc func keyboardWillBeHidden(note: Notification) {
         
         commentBar.inputTextView.text = nil
         showsCommentBar = false
         becomeFirstResponder()
         
     } // end keyboardWillBeHidden function
     
     override var inputAccessoryView: UIView? {
         
         return commentBar
         
     } // end inputAccessoryView function
     
     override var canBecomeFirstResponder: Bool {
         
         return showsCommentBar
         
     } // end canBecomeFirstResponder function
     
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         
         if posts.count < numberOfPost {
             if indexPath.row + 1 == posts.count {
                 loadMorePost()
             }
         }
         
     } // end tableView(willDisplay) function
     
     func numberOfSections(in tableView: UITableView) -> Int {
         
         return posts.count
         
     } // end numberOfSections function
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         
         let post = posts[section]
         let comments = (post["comments"] as? [PFObject]) ?? []
         
         return comments.count + 2
         
     } // end tableView(numberOfRowsInSection) function
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
         let post = posts[indexPath.section]
         let comments = (post["comments"] as? [PFObject]) ?? []
         
         if indexPath.row == 0 {
             let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
             let user = post["author"] as! PFUser
             
             cell.usernameLabel.text = user.username
             cell.captionLabel.text = post["caption"] as? String
             
             let imageFile = post["image"] as! PFFileObject
             let urlString = imageFile.url!
             let url = URL(string: urlString)!
             
             cell.photoView.af_setImage(withURL: url)
             
             return cell
         } else if indexPath.row <= comments.count {
             let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
             
             let comment = comments[indexPath.row - 1]
             cell.commentLabel.text = comment["text"] as? String
             
             let user = comment["author"] as! PFUser
             cell.nameLabel.text = user.username
             
             return cell
         } else {
             let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
             
             return cell
         }
         
     } // end tableView(cellForRowAt) function
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         
         let post = posts[indexPath.section]
         let comments = (post["comments"] as? [PFObject]) ?? []
         
         if indexPath.row == comments.count + 1 {
             showsCommentBar = true
             becomeFirstResponder()
             commentBar.inputTextView.becomeFirstResponder()
             
             selectedPost = post
         }
         
     } // end tableView(didSelectRowAt) function
     
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
   
   
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
       // let delegate = UIApplication.shared.delegate as! AppDelegate
        let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
        sceneDelegate.window?.rootViewController = loginViewController
        
    }
}//end logout function
