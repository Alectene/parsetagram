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
   let commentBar = MessageInputBar()
   var refreshControl: UIRefreshControl!
   var showsCommentBar = false
   //var posts = String
   var posts = [PFObject]()
   
   var selectedPost: PFObject!
   
   override func viewDidLoad() {
       super.viewDidLoad()
       commentBar.inputTextView.placeholder = "Add a comment....."
       commentBar.sendButton.title = "Post"
       commentBar.delegate = self
       
       tableView.delegate = self
       tableView.dataSource = self
       tableView.keyboardDismissMode = .interactive //dismisses keyboard
       // Do any additional setup after loading the view.
       let center = NotificationCenter.default
       center.addObserver(self, selector: #selector(keyboardWillbeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
    tableView.insertSubview(refreshControl, at: 0)
    
   }//end viewDidLoad function
   
    // Implement the delay method
       func run(after wait: TimeInterval, closure: @escaping () -> Void) {
           let queue = DispatchQueue.main
           queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
       }

       // Call the delay method in your onRefresh() method
       func refresh() {
           run(after: 2) {
               self.refreshControl.endRefreshing()
           }
       }

       //function to refresh
       @objc func onRefresh(){
           run(after: 2) {
               self.refreshControl.endRefreshing()
           }
    
    
    }
    @objc func keyboardWillbeHidden(note: Notification){
       commentBar.inputTextView.text = nil
       showsCommentBar = false
       becomeFirstResponder()
   }
   
   override var inputAccessoryView: UIView{
       return commentBar
   }
   
   override var canBecomeFirstResponder: Bool{
       return showsCommentBar
   }
   
   
   override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
       
       
       let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
       query.limit = 20
       query.findObjectsInBackground{ (posts, error) in
           if posts != nil{
               self.posts = posts!
               self.tableView.reloadData()
           }
       }
   }// end ViewDidAppear function
   
   func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
       //create comment
      
       let comment = PFObject(className: "Comments")
       
       comment["text"] = text
    comment["post"] = selectedPost
    comment["author"] = PFUser.current()
       //comment["author"] = PFUser.current()
       selectedPost.add(comment, forKey: "comments")
       selectedPost.saveInBackground{(success, error) in
           if success{
               print("comment saved!")
               
           }else{
                print("Error12: \(String(describing: error))")
               
           }
           
           
       }
       
       tableView.reloadData()
       //clear and dismiss bar
       commentBar.inputTextView.text = nil
       showsCommentBar = false
       becomeFirstResponder()
       commentBar.inputTextView.resignFirstResponder()
   }//end messageInputBar function
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       let post = posts[section]
       let comments = (post["comments"] as? [PFObject]) ?? []
       return comments.count + 2
   }//end numberOfRowsInSection
   
   func numberOfSections(in tableView: UITableView) -> Int {
       return posts.count
   }
   
   
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let post = posts[indexPath.section]
       let comments = (post["comments"] as? [PFObject]) ?? []
       
       
       if indexPath.row == 0{
       let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell")  as! PostCell
       
      
       let user = post["author"] as! PFUser
       cell.usernameLabel.text = user.username
       
       cell.captionLabel.text = post["caption"] as! String
       
       
       let imageFile = post["image"] as! PFFileObject
       let urlString = imageFile.url
       let url = URL(string: urlString!)!
       
       cell.photoView.af_setImage(withURL: url)
       
       return cell
       }else if indexPath.row <= comments.count{
           let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
           
           let comment = comments[indexPath.row - 1]
           cell.commentLabel.text = comment["text"] as? String
           let user = comment ["author"] as! PFUser
           cell.nameLabel.text = user.username
           return cell
           
           
       }else{
           let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
           return cell;
       }
   }//end cellForRowAt function
    
   //creates new columns
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      // let post = posts[indexPath.row]
       let post = posts[indexPath.section]
       //let comment = PFObject(className: "Comments")
       let comments = (post["comments"] as? [PFObject]) ?? []
       //let comment = comments[indexPath.row]
       if indexPath.row == comments.count + 1{
           showsCommentBar = true
           becomeFirstResponder()
           commentBar.inputTextView.becomeFirstResponder()
           selectedPost = post
       }
      
           
       }
   
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
       // let delegate = UIApplication.shared.delegate as! AppDelegate
        let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
        sceneDelegate.window?.rootViewController = loginViewController
        
    }
}//end logout function
