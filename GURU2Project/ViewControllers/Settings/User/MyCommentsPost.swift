//
//  MyCommentsPost.swift
//  GURU2Project
//
//  Created by 공서은 on 2022/02/01.
//

import UIKit
import Firebase
import FirebaseDatabase

class MyCommentsPost:UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var myPostdata:[PostData] = []
    
    var userinfo:String = ""
    var filterinfo:String = ""
    var titleinfo:String = ""
    var contentsinfo:String = ""
    var timeinfo:String = ""
    var codeinfo:String = ""
    var imageinfo:String = ""
    var postimageinfo:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DatabaseInfo()
        tableView.flashScrollIndicators()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableView.reloadData()
        
    }
    
    //사용자가 등록한 게시글
    func DatabaseInfo(){
        
        let user = Auth.auth().currentUser
        
        if let user = user {
       
            var headDB : DatabaseReference  = Database.database().reference()
                    
            headDB.child("users").child("\(user.uid)").child("comments").observe(DataEventType.value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                let DBehowmany = value?["howmanycomments"] as? String ?? ""
                let howmany = Int(DBehowmany) ?? 0
                
                for i in 0...howmany {
                    
                    
                    headDB.child("users").child("\(user.uid)").child("comments").child("comment"+"\(i)").observe(DataEventType.value, with: { (snapshot) in
                        let value_comment = snapshot.value as? NSDictionary
                        let DBepostcode = value_comment?["postcode"] as? String ?? "x"
                        
                    if DBepostcode != "x"{
                        
                    headDB.child("posts").child("\(DBepostcode)").observe(DataEventType.value, with: { (snapshot) in
                        
                    let value_post = snapshot.value as? NSDictionary
                    let DBtitle = value_post?["Title"] as? String ?? ""
                    let DBcontents = value_post?["Contents"] as? String ?? ""
                    let DBfilter = value_post?["Filter"] as? String ?? ""
                    let DBwriter = value_post?["Writer"] as? String ?? ""
                    let DBtime = value_post?["Time"] as? String ?? ""
                    let DBimage = value_post?["Image"] as? String ?? ""
                    let DBpostimage = value_post?["Postimage"] as? String ?? ""
                        self.myPostdata.append(PostData(DBtitle, DBfilter, DBcontents,DBwriter,DBtime,DBepostcode,DBimage,DBpostimage))
                    self.tableView.reloadData()
                       
                        
                        })
                        
                    }
                })
            }
        })
        }
        
 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myPostdata.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableMyCommentCell", for: indexPath) as? TableMyCommentCell else {
             return UITableViewCell()
         }
        
        var p:Int = 0
        let data = self.myPostdata[indexPath.row]
   
        if data.code != ""{
        cell.titleText.text = data.title
        cell.contentsText.text = data.contents
        
        let user = Auth.auth().currentUser
            
        if let user = user {
           
        var headDB : DatabaseReference  = Database.database().reference()
            headDB.child("posts").child("\(data.code)").observe(DataEventType.value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let DBchowmany = value?["howmanycomments"] as? String ?? "0"
                let DBchowmanylikes = value?["howmanylikes"] as? String ?? "0"
                
                cell.commentText.text = DBchowmany
                cell.likeText.text = DBchowmanylikes
                })
            }
            
            
        
        for i in 0...indexPath.row {
            if self.myPostdata[i].code == data.code {
                    p += 1
                        if p >= 2 {
                            self.myPostdata.remove(at: i)
                                self.tableView.reloadData()
                        }
                    }
                }
                
            } else{
                self.myPostdata.remove(at: indexPath.row)
                    self.tableView.reloadData()
            }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.height / 7
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clickdata = myPostdata[indexPath.row]
        self.userinfo = clickdata.writer
        self.titleinfo = clickdata.title
        self.contentsinfo = clickdata.contents
        self.timeinfo = clickdata.time
        self.filterinfo = clickdata.filter
        self.codeinfo = clickdata.code
        self.imageinfo = clickdata.image
        self.postimageinfo = clickdata.postimage
        
        guard let vc = self.storyboard?.instantiateViewController(identifier: "ClickCommentPost") as? ClickCommentPost else {
                    return
                }
        
        
        vc.userinfo = userinfo
        vc.titleinfo = titleinfo
        vc.contentsinfo = contentsinfo
        vc.codeinfo = codeinfo
        vc.timeinfo = timeinfo
        vc.filterinfo = filterinfo
        vc.postData = myPostdata
        vc.row = indexPath.row
        vc.writerimage = imageinfo
        vc.postimage = postimageinfo
        
        
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
        
        
        
    }
     
    
    
    
    @IBAction func backBtn(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
}

class TableMyCommentCell:UITableViewCell{
    
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var contentsText: UILabel!
    @IBOutlet weak var likeiconImage: UIImageView!
    @IBOutlet weak var likeText: UILabel!
    @IBOutlet weak var commentIconImage: UIImageView!
    @IBOutlet weak var commentText: UILabel!
}
