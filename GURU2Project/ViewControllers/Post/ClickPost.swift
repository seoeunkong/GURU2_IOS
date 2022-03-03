//
//  ClickPost.swift
//  GURU2Project
//
//  Created by 공서은 on 2022/01/29.
//

import UIKit
import Firebase
import FirebaseDatabase
import Photos

class ClickPost:UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var likesPost: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var contentsText: UILabel!
    @IBOutlet weak var comments: UITextField!
    @IBOutlet weak var numberofcoments: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    
    var bRec:Bool = true
    @IBOutlet weak var bntLike: UIButton!
    
    var ref: DatabaseReference!
    
    var commentData:[CommentsData] = []
    var postData:[PostData] = []
    
    var row:Int = 0
    var trow:Int = 0
    
    var userinfo:String = ""
    var filterinfo:String = ""
    var titleinfo:String = ""
    var contentsinfo:String = ""
    var timeinfo:String = ""
    var codeinfo:String = ""
    var writerimage:String = ""
    var postimage:String = ""
    
    
    
    var mypost:Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName.text = userinfo
        titleText.text = titleinfo
        contentsText.text = contentsinfo
        date.text = timeinfo
        
        DatabaseInfo()
        commentData.removeAll()
        imageUpload(writerimage)
        
        if postimage != "./ -- file:///"{
            postimageUpload(postimage)
        }
        
        addGestureRecognizer()
        Numoflike()
        
        tableView.flashScrollIndicators()
        
    }
    
    //키보드 숨기기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
   }
    
    //좋아요 수
    func Numoflike(){
        
        let user = Auth.auth().currentUser
            
        if let user = user {
           
        var headDB : DatabaseReference  = Database.database().reference()
            headDB.child("posts").child("\(self.codeinfo)").observe(DataEventType.value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let DBchowmany = value?["howmanycomments"] as? String ?? "0"
                let DBchowmanylikes = value?["howmanylikes"] as? String ?? "0"
                
                self.likesPost.text = DBchowmanylikes
                })
            }
    }
    
    
    
    //DB에 업데이트
    func DatabaseUpdate(){
        let user = Auth.auth().currentUser
        if let user = user {
        //데이터베이스 연결
        ref = Database.database().reference()
        
        let str = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789#@!*&"
        let size = 3
        let commentcode = str.createRandomStr(length: size)
            
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var current_date_string = formatter.string(from: Date())
            
            
        let key = user.uid
        
        ref.child("users").child("\(key)").observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? NSDictionary
            let DBhowmanycomments = value?["howmanycomments"] as? String ?? "0"
            let howmanycomments = Int(DBhowmanycomments)
            let DBuser = value?["username"] as? String ?? "0"
            let DBimage = value?["image"] as? String ?? ""
            
            if let comment = self.comments.text {
                
                if comment != "" {
                    let post_user = ["postcode":"\(self.codeinfo)", "commentscode":"\(commentcode)"]
                    let childUpdates = ["/users/\(key)/comments/comment\(howmanycomments!+1)/": post_user]
                
                self.ref.child("users/\(key)/comments/").updateChildValues(["howmanycomments":"\(howmanycomments!+1)"])
                    
                self.ref.child("posts").child("\(self.codeinfo)").observeSingleEvent(of: .value) { snapshot in
                        let value = snapshot.value as? NSDictionary
                        let DBehowmanycomments_post = value?["howmanycomments"] as? String ?? "0"
                        let howmanycomments_post = Int(DBehowmanycomments_post)
                        let DBehowmanylikes = value?["howmanylikes"] as? String ?? "0"
                        let howmanylikes = Int(DBehowmanylikes)
                    
                    let post = ["Comments":"\(comment)", "CommentsCode":"\(commentcode)","Time":"\(current_date_string)","Writer":"\(DBuser)","Image":"\(DBimage)"]
                let childUpdates_post = ["/posts/\(self.codeinfo)/comment\(howmanycomments_post!+1)/": post]
                self.ref.child("posts").child("\(self.codeinfo)").updateChildValues(["howmanycomments":"\(howmanycomments_post!+1)"])
                    self.ref.updateChildValues(childUpdates_post)
                    
                
                }
                
                self.ref.updateChildValues(childUpdates)
                
                
            
                
            
            }else{
                let alertVC = UIAlertController(title: "Error", message: "내용을 다시 확인해주세요.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "계속", style: .cancel, handler: nil))
                self.present(alertVC, animated: true,completion: nil)
            }
            }
        }
    }
        
 }
    
    func DatabaseUpdate_like(){
        let user = Auth.auth().currentUser
        if let user = user {
        //데이터베이스 연결
        ref = Database.database().reference()
        let key = user.uid
            
        self.ref.child("users").child("\(key)").child("like").observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let DBhowmanylikes = value?["howmanylikes"] as? String ?? "0"
            let howmanylikes = Int(DBhowmanylikes)
            
            self.ref.child("posts").child("\(self.codeinfo)").observeSingleEvent(of: .value) { snapshot in
                    let value_post = snapshot.value as? NSDictionary
                    let DBehowmanylikes_post = value_post?["howmanylikes"] as? String ?? "0"
                    let howmanylikes_post = Int(DBehowmanylikes_post)
                
            if self.bRec {
               
                for i in 0...howmanylikes!{
                   let whichpost = value?["like"+"\(i)"] as? String ?? "0"
                    if self.codeinfo == whichpost{
                        
                        if i < howmanylikes!{
                            let bcode = value?["like"+"\(howmanylikes)"] as? String ?? ""
                            let bcode_state = value?["likestate"+"\(howmanylikes)"] as? String ?? ""
                            self.ref.child("users").child("\(key)").child("like").child("like"+"\(howmanylikes)").removeValue()
                            self.ref.child("users").child("\(key)").child("like").updateChildValues(["like"+"\(howmanylikes!-1)":bcode])
                            self.ref.child("users").child("\(key)").child("like").child("likestate"+"\(howmanylikes)").removeValue()
                            self.ref.child("users").child("\(key)").child("like").updateChildValues(["likestate"+"\(howmanylikes!-1)":bcode_state])
                            self.ref.child("users/\(key)/like/").updateChildValues(["howmanylikes":"\(howmanylikes!-1)"])
                            
                            
                        }else {
                            
                            self.ref.child("users").child("\(key)").child("like").child("like"+"\(i)").removeValue()
                            self.ref.child("users").child("\(key)").child("like").child("likestate"+"\(i)").removeValue()
                            self.ref.child("users/\(key)/like/").updateChildValues(["howmanylikes":"\(howmanylikes!-1)"])
                            
                        }
                    }
                    
                }
                    
                self.ref.child("posts").child("\(self.codeinfo)").updateChildValues(["howmanylikes":"\(howmanylikes_post!-1)"])
                
                
                } else {
                   
                    self.ref.child("users/\(key)/like/").updateChildValues(["howmanylikes":"\(howmanylikes!+1)"])
                    self.ref.child("users/\(key)/like/").updateChildValues(["like"+"\(howmanylikes!+1)":"\(self.codeinfo)"])
                    self.ref.child("users/\(key)/like/").updateChildValues(["likestate"+"\(howmanylikes!+1)":"\(self.bRec)"])
                    self.ref.child("posts").child("\(self.codeinfo)").updateChildValues(["howmanylikes":"\(howmanylikes_post!+1)"])
                    
                    }
            }
            }
        
        }
        
    }
    
    
    func DatabaseInfo(){
        
        let user = Auth.auth().currentUser
        var likes:Bool = false
        
        if let user = user {
       
            var headDB : DatabaseReference  = Database.database().reference()
                    
                
            headDB.child("posts").child("\(self.codeinfo)").observe(DataEventType.value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                let DBhowmany = value?["howmanycomments"] as? String ?? ""
                let howmany = Int(DBhowmany) ?? 0
                
                self.numberofcoments.text = "댓글("+"\(howmany)"+")"
                for i in 0...howmany {
                    
                    headDB.child("posts").child("\(self.codeinfo)").child("comment"+"\(i)").observe(DataEventType.value, with: { (snapshot) in
                        
                    let value = snapshot.value as? NSDictionary
                    let DBcomment = value?["Comments"] as? String ?? ""
                    let DBcommentcode = value?["CommentsCode"] as? String ?? ""
                    let DBwriter = value?["Writer"] as? String ?? ""
                    let DBtime = value?["Time"] as? String ?? ""
                    let DBimage = value?["Image"] as? String ?? ""
                
                    self.commentData.append(CommentsData(self.codeinfo, DBcomment, DBwriter, DBtime, DBcommentcode,DBimage))
                            self.tableView.reloadData()
                        })
            }
        })
            
            headDB.child("users").child("\(user.uid)").child("like").observe(DataEventType.value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let DBhowmanylikes = value?["howmanylikes"] as? String ?? "0"
                let howmanylikes = Int(DBhowmanylikes)
                
               
                if self.bRec {
                        let like = UIImage(named: "아이콘_커뮤_좋아요_비활성화.png")
                    self.bntLike.setImage(self.resizeImage(image: like!, width: 30, height: 30), for: .normal)
                    } else {
                        let like = UIImage(named: "아이콘_커뮤_좋아요.png")
                        self.bntLike.setImage(self.resizeImage(image: like!, width: 30, height: 30), for: .normal)
                    }
                
                for i in 0...howmanylikes!{
                   
                    let DBlikespost = value?["like"+"\(i)"] as? String ?? "0"
                    if DBlikespost == self.codeinfo {
                        let DBlikesstate = value?["likestate"+"\(i)"] as? Bool ?? true
            
                        self.bRec = DBlikesstate
                        self.sizeImagebtn()
                       
                    }
                    
                }
            })
        }
 }
    
    //본인이 쓴 글을 찾기
    func DatabaseCheck() {
        
        let user = Auth.auth().currentUser
        
        if let user = user {
            
            var headDB : DatabaseReference  = Database.database().reference()
            
            headDB.child("users").child("\(user.uid)").observeSingleEvent(of: .value) { snapshot in
            
                let value = snapshot.value as? NSDictionary
                let DBhowmany = value?["howmanypost"] as? String ?? ""
                let howmany = Int(DBhowmany) ?? 0
                
                headDB.child("users").child("\(user.uid)").child("post").observeSingleEvent(of: .value) { snapshot in
                    
                for i in 0...howmany {
                    
                        let value = snapshot.value as? NSDictionary
                        let DBpostcode = value?["postcode"+"\(i)"] as? String ?? ""
                        
                        if self.codeinfo == DBpostcode {
                            self.mypost = true
                        }
                    }
                    self.showActionSheet(self.mypost)
                }
            }
        }
    }
    
    func DatabaseDelete(_ row:Int){
       
        let user = Auth.auth().currentUser
        
        if let user = user {
            let key = user.uid
           
            var headDB : DatabaseReference  = Database.database().reference()
            headDB.child("posts").child("\(self.codeinfo)").removeValue()
       
            headDB.child("users").child("\(key)").observeSingleEvent(of: .value) { snapshot in
                let value = snapshot.value as? NSDictionary
                let pDBhowmany = value?["howmanypost"] as? String ?? ""
                let howmany = Int(pDBhowmany) ?? 0
                let bhowmany = howmany
                
                headDB.child("users/\(key)/").updateChildValues(["howmanypost":"\(howmany-1)"])

                for i in 0...bhowmany {
                    
                    if self.trow < bhowmany{
                        
                        headDB.child("users").child("\(key)").child("post").observeSingleEvent(of: .value) { snapshot in
                        let value = snapshot.value as? NSDictionary
                        let bcode = value?["postcode"+"\(bhowmany)"] as? String ?? ""
                        
                        headDB.child("users").child("\(key)").child("post").child("postcode"+"\(bhowmany)").removeValue()
                        headDB.child("users").child("\(key)").child("post").updateChildValues(["postcode"+"\(bhowmany-1)":bcode])
                        
                        
                        }
                    }else {
                        
                        
                        headDB.child("users").child("\(key)").child("post").child("postcode"+"\(row+1)").removeValue()
                    }
                    
                }
                
                
                self.presentingViewController?.dismiss(animated:true)
                 
                
            }
            
            headDB.child("Entirepost").observeSingleEvent(of: .value) { snapshot in
                let value = snapshot.value as? NSDictionary
                let eDBhowmany = value?["howmanypost"] as? String ?? ""
                let ehowmany = Int(eDBhowmany) ?? 0
                let ebhowmany = ehowmany
                
                headDB.child("Entirepost").updateChildValues(["howmanypost":"\(ehowmany-1)"])
                
                
                for i in 0...ebhowmany {
                    if self.trow < ebhowmany{
                       
                        let bcode = value?["postcode"+"\(ebhowmany)"] as? String ?? ""
                        headDB.child("Entirepost").child("postcode"+"\(ebhowmany)").removeValue()
                        headDB.child("Entirepost").updateChildValues(["postcode"+"\(ebhowmany-1)":bcode])
                        
                    
                    }else {
                        headDB.child("Entirepost").child("postcode"+"\(row+1)").removeValue()
                    }
                    
                }
            }
            //사용자DB에서 댓글 지우기
            headDB.child("users").child("\(key)").child("comments").observeSingleEvent(of: .value) { snapshot in
                let valueu = snapshot.value as? NSDictionary
                let eDBhowmany = valueu?["howmanycomments"] as? String ?? ""
                let ehowmany = Int(eDBhowmany) ?? 0
                let ebhowmany = ehowmany
                
                var numbers:Int = 0
                
                for i in 0...ebhowmany {
                    headDB.child("users").child("\(key)").child("comments").child("comment"+"\(i)").observeSingleEvent(of: .value) { snapshot in
                        let value = snapshot.value as? NSDictionary
                        let pcode = value?["postcode"] as? String ?? ""
        
                        if self.codeinfo == pcode{
                           
                            if self.trow < ebhowmany{
                               
                                let ccode = valueu?["commentscode"] as? String ?? ""
                                let postcode = valueu?["postcode"] as? String ?? ""
                                
                                headDB.child("users").child("\(key)").child("comments").child("comment"+"\(ebhowmany)").removeValue()
                                let post_user = ["postcode":"\(postcode)", "commentscode":"\(ccode)"]
                                let childUpdates = ["/users/\(key)/comments/comment\(ebhowmany-1)/": post_user]
                                
                                headDB.child("users").updateChildValues(["howmanypost":"\(ehowmany-1)"])
                                
                                self.ref.updateChildValues(childUpdates)
                                numbers += 1
                                
                                
                                }
                            else {
                                
                                headDB.child("users").child("\(key)").child("comments").child("comment"+"\(row+1)").removeValue()
                                numbers += 1
                            }
                            }
                        
                        headDB.child("users").child("\(key)").child("comments").updateChildValues(["howmanycomments":"\(ehowmany-numbers)"])
                        
                        
                    }
                    
                }
                
                headDB.child("users").child("\(user.uid)").child("like").observe(DataEventType.value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    let DBhowmanylikes = value?["howmanylikes"] as? String ?? "0"
                    let howmanylikes = Int(DBhowmanylikes)
                    
                    for i in 0...howmanylikes!{
                       let whichpost = value?["like"+"\(i)"] as? String ?? "0"
                        if self.codeinfo == whichpost{
                            
                            if i < howmanylikes!{
                                let bcode = value?["like"+"\(howmanylikes)"] as? String ?? ""
                                let bcode_state = value?["likestate"+"\(howmanylikes)"] as? String ?? ""
                                self.ref.child("users").child("\(key)").child("like").child("like"+"\(howmanylikes)").removeValue()
                                self.ref.child("users").child("\(key)").child("like").updateChildValues(["like"+"\(howmanylikes!-1)":bcode])
                                self.ref.child("users").child("\(key)").child("like").child("likestate"+"\(howmanylikes)").removeValue()
                                self.ref.child("users").child("\(key)").child("like").updateChildValues(["likestate"+"\(howmanylikes!-1)":bcode_state])
                                self.ref.child("users/\(key)/like/").updateChildValues(["howmanylikes":"\(howmanylikes!-1)"])
                                
                                
                            }else {
                                
                                self.ref.child("users").child("\(key)").child("like").child("like"+"\(i)").removeValue()
                                self.ref.child("users").child("\(key)").child("like").child("likestate"+"\(i)").removeValue()
                                self.ref.child("users/\(key)/like/").updateChildValues(["howmanylikes":"\(howmanylikes!-1)"])
                                
                            }
                        }
                    }
                })
            }
        
        }
        
 }
    
   //글쓴이 사진 업로드
    func imageUpload(_ url:String){
        if url != "" {
                let imageurl = URL(string: "\(url)")!
                let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [imageurl], options: nil)

                if let photo = fetchResult.firstObject {
                    
                    PHImageManager.default().requestImage(for: photo, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) {
                        image, info in

                        self.image.image = image
                    }
                }
        }else{
            self.image.image = UIImage(named: "설정_아이콘_기본프로필 (1).png")
        }
    }
    
    //게시글 사진 업로드
    func postimageUpload(_ url:String){
        
        let imageurl = URL(string: "\(url)")!
        let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [imageurl], options: nil)

        if let photo = fetchResult.firstObject {
                    
        PHImageManager.default().requestImage(for: photo, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) {
                        image, info in

            self.postImage.image = image
                    }
                }
    }
    
    //이미지 뷰 클릭
    func addGestureRecognizer() {
            let tapGestureRecognizer
      = UITapGestureRecognizer(target: self,
                               action: #selector(self.tappedUIImageView(_:)))
            self.postImage.addGestureRecognizer(tapGestureRecognizer)
            self.postImage.isUserInteractionEnabled = true
    }
    
    //게시판 글 메뉴 팝업창
    func showActionSheet(_ mypost:Bool) {
            let alert = UIAlertController(title: "게시글 메뉴", message: nil, preferredStyle: .actionSheet)
        
        if mypost == true {
            
            alert.addAction(UIAlertAction(title: "게시글 삭제", style: .destructive, handler: { (_) in
                
                self.trow = self.row + 1
                self.DatabaseDelete(self.row)
               

                    
               
                
              }))
        }else{
            alert.addAction(UIAlertAction(title: "게시글 신고", style: .destructive, handler: { (_) in
                  print("신고")
              }))
        }
            alert.addAction(UIAlertAction(title: "URL 공유", style: .default, handler: { (_) in
                var objectsToShare = [String]()
                let url = "https://guru2project.page.link"
                objectsToShare.append(url)
                
                let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
                
            }))

            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (_) in
                
            }))
        
        self.present(alert, animated: true, completion:nil)

        }
    
    //좋아요 버튼크기에 맞게 이미지 크기 변경
    func resizeImage(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
         UIGraphicsBeginImageContext(CGSize(width: width, height: height))
         image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
         let newImage = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
         return newImage!
     }
    
    //사진 클릭시 사진 크기 변경
    @objc func tappedUIImageView(_ gesture: UITapGestureRecognizer) {
        let imageView = gesture.view as! UIImageView
            let newImageView = UIImageView(image: imageView.image)
            newImageView.frame = UIScreen.main.bounds
            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullscreenImage(_:)))
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
    }
    
    //사진 배경 선택시 원상태로 변경
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func menuBtn(_ sender: Any) {
        
        DatabaseCheck()
        
    }
    
    @IBAction func sendComments(_ sender: Any) {
       DatabaseUpdate()
        
        
    }
    @IBAction func likeBtn(_ sender: Any) {
        
        DatabaseUpdate_like()
        sizeImagebtn()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return self.commentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentscell", for: indexPath) as? CommentsCell else {
             return UITableViewCell()
         }
        
        var p:Int = 0
        let data = self.commentData[indexPath.row]
   
        if data.commentcode != ""{
       
        cell.commentsText.text = data.comments
        cell.commentsUser.text = data.writer
        cell.commentsTime.text = data.time
        
        //이미지 넣기
        let imageurl = URL(string: "\(data.image)")!
           
        let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [imageurl], options: nil)

        if let photo = fetchResult.firstObject {
                
                PHImageManager.default().requestImage(for: photo, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) {
                    image, info in

                    cell.commentsImage.image = image
                }
            }
            
        
        for i in 0...indexPath.row {
                if self.commentData[i].commentcode == data.commentcode {
                p += 1
                    if p >= 2 {
                        self.commentData.remove(at: i)
                            self.tableView.reloadData()
                    }
                }
            }
            
        } else{
            self.commentData.remove(at: indexPath.row)
                self.tableView.reloadData()
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.height / 3
        
    }
    
    func ToUpdateCell(alert: UIAlertAction!){
        DatabaseInfo()
       
    }
    
    //좋아요 버튼 이미지 변경
    func sizeImagebtn(){
        
        bRec = !bRec
        if bRec {
                let like = UIImage(named: "아이콘_커뮤_좋아요_비활성화.png")
                bntLike.setImage(resizeImage(image: like!, width: 30, height: 30), for: .normal)
            } else {
                let like = UIImage(named: "아이콘_커뮤_좋아요.png")
                bntLike.setImage(resizeImage(image: like!, width: 30, height: 30), for: .normal)
            }
    }
    
  
    
}

class CommentsCell: UITableViewCell {
    
    @IBOutlet weak var commentsImage: UIImageView!
    @IBOutlet weak var commentsUser: UILabel!
    @IBOutlet weak var commentsText: UILabel!
    @IBOutlet weak var commentsTime: UILabel!
}

