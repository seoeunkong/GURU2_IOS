//
//  UserSetting.swift
//  GURU2Project
//
//  Created by 공서은 on 2022/01/24.
//

import UIKit
import Firebase
import FirebaseDatabase

class UserSetting:UIViewController{
    
    //닉네임 변경
    @IBOutlet weak var preUsername: UITextField!
    @IBOutlet weak var newUsername: UITextField!
    
   //이메일 변경
    @IBOutlet weak var preEmail: UITextField!
    @IBOutlet weak var newEmail: UITextField!
    @IBOutlet weak var pw: UITextField!
    
    //비밀번호 변경
    @IBOutlet weak var newPw: UITextField!
    @IBOutlet weak var prePw: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //기존 프로필 이름과 비교 및 업데이트
    func userInfo_name(){
        
        let user = Auth.auth().currentUser
        if let user = user {
        //데이터베이스 연결
        var headDB : DatabaseReference  = Database.database().reference()
        
        //키값을 받음
        let key = user.uid
        //firebase에서 해당 유저의 이메일과 이름을 찾음
        headDB.child("users").child("\(key)").observeSingleEvent(of: .value) {snapshot in
                let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? ""
            let DBemail = value?["email"] as? String ?? ""
            let DBpostnum = value?["howmanypost"] as? String ?? "0"
            let howmanypost = Int(DBpostnum)
            
            if self.preUsername.text != username{
                //기존 닉네임과 기입한 닉네임이 다른 경우
                let alertVC = UIAlertController(title: "Error", message: "기존 닉네임이 다릅니다.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "계속", style: .cancel, handler: nil))
                self.present(alertVC, animated: true,completion: nil)
            }
            else{
                //DB 이름 수정
                if let newname = self.newUsername.text{
                //있는 데이터를 수정할 때 updateChildValues
                headDB.child("users/\(key)/").updateChildValues(["username":"\(newname)"])
                }
                
                let alertVC = UIAlertController(title: "Complete", message: "닉네임 수정이 완료되었습니다.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "완료", style: .cancel, handler: self.MoveToUserSettingHandler))
                self.present(alertVC, animated: true,completion: nil)
            }
            
            //게시물 닉네임 변경
            for i in 0...howmanypost! {
                headDB.child("users").child("\(key)").child("post").observeSingleEvent(of: .value) {snapshot in
                    let value_post = snapshot.value as? NSDictionary
                    let DBpostcode = value_post?["postcode"+"\(i)"] as? String ?? ""
                    
                    if let newname = self.newUsername.text{
                        headDB.child("posts/\(DBpostcode)/").updateChildValues(["Writer":"\(newname)"])
                    }
                }
            }
            
                }
            
                        }
                        
                    }
                    
                
        
     
    
    //기존 프로필 이메일과 비교 및 업데이트
    func userInfo_email(){
        
        
        let user = Auth.auth().currentUser
        if let user = user {
        //데이터베이스 연결
        var headDB : DatabaseReference  = Database.database().reference()
        
        //키값을 받음
        let key = user.uid
    
        //firebase에서 해당 유저의 이메일과 이름을 찾음
            headDB.child("users").child("\(key)").observeSingleEvent(of: .value) { snapshot in
                let value = snapshot.value as? NSDictionary
            let DBemail = value?["email"] as? String ?? ""
            let DBpw = value?["pw"] as? String ?? ""
        
            //기존 이메일과 기입한 이메일이 다른 경우, 비밀번호가 다른 경우
            if self.preEmail.text != DBemail {
                let alertVC = UIAlertController(title: "Error", message: "정보가 다릅니다.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "계속", style: .cancel, handler: nil))
                self.present(alertVC, animated: true,completion: nil)
                
                
                if self.pw.text != DBpw{
                    let alertVC = UIAlertController(title: "Error", message: "정보가 다릅니다.", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "계속", style: .cancel, handler: nil))
                    self.present(alertVC, animated: true,completion: nil)
                }
            }
            else{
                
                //정보가 맞는 경우
                let credential = EmailAuthProvider.credential(withEmail: DBemail, password: DBpw)
                if self.preEmail.text != nil && self.newEmail.text != nil, self.pw.text != nil {
                if let emailtext = self.newEmail.text{
                   
                        user.updateEmail(to: emailtext) { error in
                              if let error = error {
                                  print(error)
                              } else {
                                  
                                  headDB.child("users/\(key)/").updateChildValues(["email":"\(emailtext)"])
                                  let alertVC = UIAlertController(title: "Complete", message: "이메일 수정이 완료되었습니다.", preferredStyle: .alert)
                                  alertVC.addAction(UIAlertAction(title: "완료", style: .cancel, handler: self.MoveToUserSettingHandler))
                                  self.present(alertVC, animated: true,completion: nil)
                            }
                      }
                }
                    
                }
            }
                
            }
                }
        
     }
    
    
    //기존 비밀번호 비교 및 업데이트
    func userInfo_pw(){
        
        let user = Auth.auth().currentUser
        if let user = user {
        //데이터베이스 연결
        var headDB : DatabaseReference  = Database.database().reference()
        
        //키값을 받음
        let key = user.uid
    
        //firebase에서 해당 유저의 이메일과 비밀번호를 찾음
            headDB.child("users").child("\(key)").observeSingleEvent(of: .value) { snapshot in
                let value = snapshot.value as? NSDictionary
            let DBemail = value?["email"] as? String ?? ""
            let DBpw = value?["pw"] as? String ?? ""
        
            if self.prePw.text != DBpw{
                //기존 이메일과 기입한 이메일이 다른 경우, 비밀번호가 다른 경우
                let alertVC = UIAlertController(title: "Error", message: "정보가 다릅니다.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "계속", style: .cancel, handler: nil))
                self.present(alertVC, animated: true,completion: nil)
            }
            else{
                //정보가 맞는 경우
                let credential = EmailAuthProvider.credential(withEmail: DBemail, password: DBpw)
                if self.prePw.text != nil && self.newPw.text != nil {
                if let pwtext = self.newPw.text{
                    
                    user.updatePassword(to: pwtext) { Error in
                        if let error = Error {
                            print(error)
                        } else {
                            headDB.child("users/\(key)/").updateChildValues(["pw":"\(pwtext)"])
                            let alertVC = UIAlertController(title: "Complete", message: "비밀번호 수정이 완료되었습니다.", preferredStyle: .alert)
                            alertVC.addAction(UIAlertAction(title: "완료", style: .cancel, handler: self.MoveToUserSettingHandler))
                            self.present(alertVC, animated: true,completion: nil)
                      }
                    }
                }
                    
                }
            }
                
            }
                }
        
     }
    
    
    
    //창 닫기 버튼
    @IBAction func closeBtn(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    //닉네임 변경 완료 버튼
    @IBAction func completeBtn(_ sender: Any) {
        userInfo_name()
        
    }
    
    //사용자 설정 페이지로 이동
    func MoveToUserSettingHandler(alert: UIAlertAction!) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    //이메일 변경 완료 버튼
    @IBAction func emailChange(_ sender: Any) {
        userInfo_email()
    }
    
    //비밀번호 변경 완료 버튼
    @IBAction func changePw(_ sender: Any) {
        userInfo_pw()
    }
    
    
}
