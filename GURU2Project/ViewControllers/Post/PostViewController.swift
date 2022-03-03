//
//  PostViewController.swift
//  GURU2Project
//
//  Created by 김진원 on 2022/01/20.
//

import UIKit
import Firebase
import FirebaseDatabase
import DropDown
import CoreMedia

class PostViewController:UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    @IBOutlet weak var sortingBtn: UIButton!
    @IBOutlet weak var filterBtn: UIButton!
   
    @IBOutlet weak var tableView: UITableView!
    
    var postData:[PostData] = []
    var postData_filter:[PostData] = []
    
    
    var howmany:Int = 0
    
    var userinfo:String = ""
    var filterinfo:String = ""
    var titleinfo:String = ""
    var contentsinfo:String = ""
    var timeinfo:String = ""
    var codeinfo:String = ""
    var imageinfo:String = ""
    var postimageinfo:String = ""
    
    var DBchowmany:String = ""
    
    //let dropDown_sorting = DropDown()
    let dropDown_filter = DropDown()
    
    //회원정보 수정 버튼
    lazy var button: UIButton = { let button = UIButton()
        
       
        let width: CGFloat = 90
        let height: CGFloat = 45
        
        
        let posX: CGFloat = self.view.bounds.width/2 - width/2
        let posY: CGFloat = self.view.bounds.height/2 - (height/2 - 170)
        
        // Set the button installation coordinates and size.
        button.frame = CGRect(x: posX, y: posY, width: width, height: height)
        // Set the background color of the button.
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 2
        // Round the button frame.
        button.layer.masksToBounds = true
        // Set the radius of the corner.
        button.layer.cornerRadius = 20.0
        // Set the title (normal).
       
        button.setImage(UIImage(named: "아이콘_커뮤_글쓰기"), for: .normal)
         
        // Tag a button.
        button.tag = 1
        return button
        
    }()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       DatabaseInfo()
        
        self.view.addSubview(self.button)
        self.button.addTarget(self, action: #selector(ToPosting), for: .touchUpInside)
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        postData.removeAll()
        DatabaseInfo()
        tableView.reloadData()
    }
    
    
    //필터
    func dropDown_filtering(){
        
        var p:Int = 0
        
        dropDown_filter.anchorView = filterBtn
        dropDown_filter.dataSource = ["병원", "여행","질병","사료","산책","장난감"]
        
        dropDown_filter.bottomOffset = CGPoint(x: 0, y:(dropDown_filter.anchorView?.plainView.bounds.height)!)
        dropDown_filter.width = 100
        dropDown_filter.selectionAction = { [unowned self] (index: Int, item: String) in
            
           // self.dropDown_filter.clearSelection()
        
        
        let user = Auth.auth().currentUser
        
        if let user = user {
            var headDB : DatabaseReference  = Database.database().reference()
            
            headDB.child("Entirepost").observe(DataEventType.value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                let DBehowmany = value?["howmanypost"] as? String ?? ""
                self.howmany = Int(DBehowmany) ?? 0
                
                self.postData.removeAll()
                
                for i in 0...self.howmany{
                    let DBpostcode = value?["postcode"+"\(i)"] as? String ?? "x"
                    if DBpostcode != "x"{
                       
                    headDB.child("posts").child("\(DBpostcode)").observe(DataEventType.value, with: { (snapshot) in
                        
                        let value = snapshot.value as? NSDictionary
                        let DBtitle = value?["Title"] as? String ?? ""
                        let DBcontents = value?["Contents"] as? String ?? ""
                        let DBfilter = value?["Filter"] as? String ?? ""
                        let DBwriter = value?["Writer"] as? String ?? ""
                        let DBtime = value?["Time"] as? String ?? ""
                        let DBimage = value?["Image"] as? String ?? ""
                        let DBpostimage = value?["Postimage"] as? String ?? ""
                   
                    if "\(index+1)" == DBfilter {
                        self.postData.append(PostData(DBtitle, DBfilter, DBcontents,DBwriter,DBtime,DBpostcode,DBimage,DBpostimage))
                        self.tableView.reloadData()
                    }else{
                        p+=1
                        
                        if p == i {
                            self.postData.removeAll()
                            self.tableView.reloadData()
                        }
                    }
                        })
                        
                    }
                }
            })
        }
          
        }
        
        dropDown_filter.show()
        self.tableView.reloadData()
    }
    
    //사용자가 등록한 게시글
    func DatabaseInfo(){
        
        let user = Auth.auth().currentUser
        
        if let user = user {
       
            var headDB : DatabaseReference  = Database.database().reference()
                    
            headDB.child("Entirepost").observe(DataEventType.value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                let DBehowmany = value?["howmanypost"] as? String ?? ""
                self.howmany = Int(DBehowmany) ?? 0
                
                for i in 0...self.howmany {
                    
                    let DBpostcode = value?["postcode"+"\(i)"] as? String ?? "x"
                    
                    if DBpostcode != "x"{
                       
                    headDB.child("posts").child("\(DBpostcode)").observe(DataEventType.value, with: { (snapshot) in
                        
                    let value = snapshot.value as? NSDictionary
                    let DBtitle = value?["Title"] as? String ?? ""
                    let DBcontents = value?["Contents"] as? String ?? ""
                    let DBfilter = value?["Filter"] as? String ?? ""
                    let DBwriter = value?["Writer"] as? String ?? ""
                    let DBtime = value?["Time"] as? String ?? ""
                    let DBimage = value?["Image"] as? String ?? ""
                    let DBpostimage = value?["Postimage"] as? String ?? ""
                    self.postData.append(PostData(DBtitle, DBfilter, DBcontents,DBwriter,DBtime,DBpostcode,DBimage,DBpostimage))
                    self.tableView.reloadData()
                       
                        
                        })
                        
                    }
            }
        })
        }
        
 }
    
                                           
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return self.postData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postcell", for: indexPath) as? TableCell else {
             return UITableViewCell()
         }
        
        
        var p:Int = 0
        let data = self.postData[indexPath.row]
   
        if data.code != ""{
        cell.titleText.text = data.title
        cell.contentsText.text = data.contents
            
        let user = Auth.auth().currentUser
            
        if let user = user {
           
        var headDB : DatabaseReference  = Database.database().reference()
            headDB.child("posts").child("\(data.code)").observe(DataEventType.value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                self.DBchowmany = value?["howmanycomments"] as? String ?? "0"
                let DBchowmanylikes = value?["howmanylikes"] as? String ?? "0"
                
                cell.commentText.text = self.DBchowmany
                cell.likeText.text = DBchowmanylikes
                })
            }
            
            
        
        for i in 0...indexPath.row {
            if self.postData[i].code == data.code {
                    p += 1
                        if p >= 2 {
                            self.postData.remove(at: i)
                                self.tableView.reloadData()
                        }
                    }
                }
                
            } else{
                self.postData.remove(at: indexPath.row)
                    self.tableView.reloadData()
            }
        
        
        return cell
    }
    
    //키보드 숨기기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
   }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.height / 7
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clickdata = postData[indexPath.row]
        self.userinfo = clickdata.writer
        self.titleinfo = clickdata.title
        self.contentsinfo = clickdata.contents
        self.timeinfo = clickdata.time
        self.filterinfo = clickdata.filter
        self.codeinfo = clickdata.code
        self.imageinfo = clickdata.image
        self.postimageinfo = clickdata.postimage
        
        guard let vc = self.storyboard?.instantiateViewController(identifier: "clickpostView") as? ClickPost else {
                    return
                }
        
        
        vc.userinfo = userinfo
        vc.titleinfo = titleinfo
        vc.contentsinfo = contentsinfo
        vc.codeinfo = codeinfo
        vc.timeinfo = timeinfo
        vc.filterinfo = filterinfo
        vc.postData = postData
        vc.row = indexPath.row
        vc.writerimage = imageinfo
        vc.postimage = postimageinfo
        
        
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
        
        
        
    }
    
    //게시판의 글쓰기 화면으로 이동
    @objc func ToPosting(){
        var vc = storyboard?.instantiateViewController(withIdentifier: "writepostView")
        vc!.modalTransitionStyle = .coverVertical
        vc!.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
         
    }
    @IBAction func sortingBtn(_ sender: Any) {
      //  dropDown_sort()
    }
    @IBAction func filterBtn(_ sender: Any) {
        dropDown_filtering()
    }
}


class TableCell:UITableViewCell{
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var contentsText: UILabel!
    @IBOutlet weak var likeIcon: UIImageView!
    @IBOutlet weak var likeText: UILabel!
    @IBOutlet weak var commentIcon: UIImageView!
    @IBOutlet weak var commentText: UILabel!
}
