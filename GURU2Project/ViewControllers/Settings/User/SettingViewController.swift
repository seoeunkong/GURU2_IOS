//
//  SettingViewController.swift
//  GURU2Project
//
//  Created by 김진원 on 2022/01/20.
//

import UIKit
import Firebase
import FirebaseDatabase
import Photos

class SettingViewController:UIViewController{
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var emailAddress: UILabel!
    
    var viewController:ViewController!
    
    let width: CGFloat = 300
    let height: CGFloat = 100
    
    
    //회원정보 수정 버튼
    lazy var button: UIButton = { let button = UIButton()
        
        // Define the size of the button
        let width: CGFloat = 350
        let height: CGFloat = 130
        
        // Define coordinates to be placed. // (center of screen)
        let posX: CGFloat = self.view.bounds.width/2 - width/2
        let posY: CGFloat = self.view.bounds.height/2 - (height/2 + 60)
        
        // Set the button installation coordinates and size.
        button.frame = CGRect(x: posX, y: posY, width: width, height: height)
        // Set the background color of the button.
        button.backgroundColor = UIColor(red: 153.0/255.0, green: 202.0/255.0, blue: 183.0/255.0, alpha: 1.0)
        // Round the button frame.
        button.layer.masksToBounds = true
        // Set the radius of the corner.
        button.layer.cornerRadius = 20.0
        // Set the title (normal).
    

        button.setTitle("회원정보 수정", for: .normal)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
       // button.setTitle("등록된 회원 정보를 수정할 수 있습니다.", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.borderColor = CGColor.init(red: 153.0/255.0, green: 202.0/255.0, blue: 183.0/255.0, alpha: 1.0)
        button.layer.borderWidth = 2
        
        // Set the title (highlighted).
        
      //  button.setTitle("Button (highlighted)", for: .highlighted)
        
        button.setTitleColor(.gray, for: .highlighted)
         
        // Tag a button.
        button.tag = 1
        return button
        
    }()
    
    //새로운 반려동물 등록 버튼
    lazy var button2: UIButton = { let button2 = UIButton()
        
        // Define the size of the button
        let width: CGFloat = 350
        let height: CGFloat = 130
        
        // Define coordinates to be placed.
        let posX: CGFloat = self.view.bounds.width/2 - width/2
        let posY: CGFloat = self.view.bounds.height/2 - (height/2 - 100)
        
        // Set the button installation coordinates and size.
        button2.frame = CGRect(x: posX, y: posY, width: width, height: height)
        // Set the background color of the button.
        button2.backgroundColor = UIColor(red: 210.0 / 255.0, green: 187.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
        // Round the button frame.
        button2.layer.masksToBounds = true
        // Set the radius of the corner.
        button2.layer.cornerRadius = 20.0
        // Set the title (normal).
        button2.setTitle("새로운 반려동물 등록", for: .normal)
        button2.titleLabel?.lineBreakMode = .byWordWrapping
        button2.titleLabel?.textAlignment = .center
        button2.setTitleColor(.white, for: .normal)
        button2.layer.borderColor = CGColor.init(red: 239.0 / 255.0, green: 184.0 / 255.0, blue: 173.0 / 255.0, alpha: 1.0)
        
        // Tag a button.
        button2.tag = 2
        button2.setTitleColor(.gray, for: .highlighted)
        return button2
        
    }()
    
    //기존 반려동물 등록 버튼
    lazy var button3: UIButton = { let button3 = UIButton()
        
        
        let fontSize = UIFont.boldSystemFont(ofSize: 18)

        // Define the size of the button
        let width: CGFloat = 350
        let height: CGFloat = 130
        
        // Define coordinates to be placed.
        let posX: CGFloat = self.view.bounds.width/2 - width/2
        let posY: CGFloat = self.view.bounds.height/2 - (height/2 - 260)
        
        // Set the button installation coordinates and size.
        button3.frame = CGRect(x: posX, y: posY, width: width, height: height)
        // Set the background color of the button.
        button3.backgroundColor = UIColor(red: 239.0 / 255.0, green: 184.0 / 255.0, blue: 173.0 / 255.0, alpha: 1.0)
        // Round the button frame.
        button3.layer.masksToBounds = true
        // Set the radius of the corner.
        button3.layer.cornerRadius = 20.0
        // Set the title (normal).
        button3.setTitle("기존 반려동물 등록", for: .normal)
        
        button3.titleLabel?.lineBreakMode = .byWordWrapping
        button3.titleLabel?.textAlignment = .center
        
        button3.layer.borderColor = CGColor.init(red: 153.0/255.0, green: 202.0/255.0, blue: 183.0/255.0, alpha: 1.0)
        
        button3.setTitleColor(.white, for: .normal)
        // Tag a button.
        button3.tag = 3
        button3.setTitleColor(.gray, for: .highlighted)
        return button3
        
    }()
    
    //사용자 프로필 이름,이메일 설정_image는 나중에..
    func userSetting(){
        
        let user = Auth.auth().currentUser
        print(user?.uid)
        if let user = user {
        //데이터베이스 연결
        var headDB : DatabaseReference  = Database.database().reference()
        
        //키값을 받음
        let key = user.uid
        //firebase에서 해당 유저의 이메일과 이름을 찾음
            
            headDB.child("users").child("\(key)").observe(DataEventType.value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let username = value?["username"] as? String ?? ""
                let useremail = value?["email"] as? String ?? ""
                
            self.userName.text = username
            self.emailAddress.text = useremail
            })
            
          }
             
     }


    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        self.view.addSubview(self.button)
        self.view.addSubview(self.button2)
        self.view.addSubview(self.button3)
        
        self.button.addTarget(self, action: #selector(ToUserSetting), for: .touchUpInside)
        self.button2.addTarget(self, action: #selector(ToNewPetSetting), for: .touchUpInside)
        self.button3.addTarget(self, action: #selector(ToPetSetting), for: .touchUpInside)

       userSetting()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        imageUpload()
        userSetting()
    }
    
    func imageUpload(){
        
        let user = Auth.auth().currentUser
        
        if let user = user {
            let key = user.uid
            var headDB : DatabaseReference  = Database.database().reference()
            
            headDB.child("users").child("\(key)").observe(DataEventType.value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let image = value?["image"] as? String ?? "" //"assets-library://asset/asset.JPG?id=0B034B76-5995-438A-81DD-102D26C83AB0&ext=JPG"
                
                if image != ""{
                    
                let imageurl = URL(string: "\(image)")!
                
                let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [imageurl], options: nil)

                if let photo = fetchResult.firstObject {
                    
                    PHImageManager.default().requestImage(for: photo, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) {
                        image, info in

                        self.userImage.image = image
                    }
                }
                }else{
                   
                    self.userImage.image = UIImage(named: "설정_아이콘_기본프로필 (1).png")
                }
            })
            
        }
    
    }
    
    
    //회원정보 수정 화면으로 이동
    @objc func ToUserSetting(){
        
        //
//        var vc = storyboard?.instantiateViewController(withIdentifier: "UserSettingView")
//        vc!.modalTransitionStyle = .coverVertical
//        vc!.modalPresentationStyle = .fullScreen
//        self.present(vc!, animated: true, completion: nil)
        
        var vc = storyboard?.instantiateViewController(withIdentifier: "UserSettingView") as? MainUserSetting
        vc!.modalTransitionStyle = .coverVertical
        vc!.modalPresentationStyle = .fullScreen
        vc!.settingVC = self
        self.present(vc!, animated: true, completion: nil)
        print("touser")
    }
    
    //새 반려동물 등록 화면으로 이동
    @objc func ToNewPetSetting(){
        var vc = storyboard?.instantiateViewController(withIdentifier: "NewPetEnrollView")
        vc!.modalTransitionStyle = .coverVertical
        vc!.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
    }
    
    //기존 반려동물 등록 화면으로 이동
    @objc func ToPetSetting(){
        var vc = storyboard?.instantiateViewController(withIdentifier: "PetEnrollView")
        vc!.modalTransitionStyle = .coverVertical
        vc!.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
    }
    
    func dismissView(){
        self.viewController.showSignIn()
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
}



