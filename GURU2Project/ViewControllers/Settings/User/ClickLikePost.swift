//
//  ClickLikePost.swift
//  GURU2Project
//
//  Created by 공서은 on 2022/02/01.
//

import UIKit
import FirebaseDatabase
import Firebase
import Photos

class ClickLikePost:UIViewController, UITableViewDataSource, UITableViewDelegate{
   
    
    @IBOutlet weak var numofLikes: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var contentsText: UILabel!
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
        
        if postimage != ""{
            postimageUpload(postimage)
        }
        
        addGestureRecognizer()
        
        Numoflike()
        tableView.flashScrollIndicators()
        
    }
    
    
    func Numoflike(){
        
        let user = Auth.auth().currentUser
            
        if let user = user {
           
        var headDB : DatabaseReference  = Database.database().reference()
            headDB.child("posts").child("\(self.codeinfo)").observe(DataEventType.value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let DBchowmany = value?["howmanycomments"] as? String ?? "0"
                let DBchowmanylikes = value?["howmanylikes"] as? String ?? "0"
                
                self.numofLikes.text = DBchowmanylikes
                })
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
               //좋아요를 취소한 경우
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
                   //좋아요를 누른 경우
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
        if bRec == true {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }else{
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    
   
    @IBAction func likeBtn(_ sender: Any) {
        
        DatabaseUpdate_like()
        sizeImagebtn()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return self.commentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "clicklikecell", for: indexPath) as? ClickLikeCell else {
             return UITableViewCell()
         }
        
        var p:Int = 0
        let data = self.commentData[indexPath.row]
   
        if data.commentcode != ""{
       
        cell.commentText.text = data.comments
        cell.writerText.text = data.writer
        cell.commentTimeText.text = data.time
        
            if data.image != "" {
        //이미지 넣기
        let imageurl = URL(string: "\(data.image)")!
           
        let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [imageurl], options: nil)

        if let photo = fetchResult.firstObject {
                
                PHImageManager.default().requestImage(for: photo, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) {
                    image, info in

                    cell.writerImage.image = image
                }
            }
            }else{
                cell.writerImage.image = UIImage(named: "no-image-icon.png")
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
                let like = UIImage(named: "아이콘_커뮤_좋아요.png")
                bntLike.setImage(resizeImage(image: like!, width: 30, height: 30), for: .normal)
            }
    }
    
  
    
}

class ClickLikeCell:UITableViewCell{
    
    @IBOutlet weak var writerImage: UIImageView!
    @IBOutlet weak var commentTimeText: UILabel!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var writerText: UILabel!
}
