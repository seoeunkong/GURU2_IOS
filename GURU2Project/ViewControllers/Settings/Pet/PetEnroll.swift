//
//  PetEnroll.swift
//  GURU2Project
//
//  Created by 공서은 on 2022/01/26.
//

import UIKit
import Firebase
import FirebaseDatabase

class PetEnroll:UIViewController{
    
    var ref: DatabaseReference!
    
    //해당 펫코드가 DB에 있는지 확인
    //펫코드를 사용자 DB에 추가하기
    
    @IBOutlet weak var completeBtn: UIButton!
    
    @IBOutlet weak var petCode: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        completeBtn.layer.cornerRadius = 30
        completeBtn.setTitleColor(.gray, for: .highlighted)
    }
    //키보드 숨기기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
   }
    
    func enrollCode(){
        let user = Auth.auth().currentUser
        if let user = user {
        //데이터베이스 연결
        ref = Database.database().reference()
        
                    
        let key = user.uid
            
        //firebase에서 해당 유저의 petcode를 찾음
            ref.child("users").child("\(key)").child("pets").observeSingleEvent(of: .value) { snapshot in
        let value = snapshot.value as? NSDictionary
        
        let DBhowmany = value?["petNum"] as? String ?? "0"
        let howmany = Int(DBhowmany)
            
          
            if let code = self.petCode.text{
                
                
                self.ref.child("pets").child("\(code)").observeSingleEvent(of: .value) { snapshot in
                let value = snapshot.value as? NSDictionary
                let DBpetcode = value?["PetCode"] as? String ?? ""
                print("펫코드: "+DBpetcode)
                //해당 펫코드가 DB에 있는 경우
                if DBpetcode != ""{
                
                if DBhowmany != "0" {
                    //기존에 등록한 동물이 있는 경우
                    self.ref.child("users/\(key)/pets/").updateChildValues(["pet"+"\(howmany!+1)":"\(code)"])
                    //등록된 펫 갯수 증가
                    self.ref.child("users/\(key)/pets/").updateChildValues(["petNum":"\(howmany!+1)"])
                }else{
                    
                    //기존에 등록한 동물이 없는 경우
                    self.ref.child("users/\(key)/pets/").updateChildValues(["pet"+"\(howmany!+1)":"\(code)"])
                    //등록된 펫 갯수 증가
                    self.ref.child("users/\(key)/pets/").updateChildValues(["petNum":"\(howmany!+1)"])
                }
                
                
                let alertVC = UIAlertController(title: "Complete", message: "새로운 반려동물 등록이 완료되었습니다.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "완료", style: .cancel, handler: self.ToMainUserSetting))
                self.present(alertVC, animated: true,completion: nil)
                }
                    else{
                        //해당 펫코드가 DB에 없는 경우
                        let alertVC = UIAlertController(title: "Error", message: "해당하는 반려동물이 없습니다. ", preferredStyle: .alert)
                        alertVC.addAction(UIAlertAction(title: "계속", style: .cancel, handler: nil))
                        self.present(alertVC, animated: true,completion: nil)
                    }
                }
            
            }else{
                let alertVC = UIAlertController(title: "Error", message: "정보를 다시 확인해주세요.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "계속", style: .cancel, handler: nil))
                self.present(alertVC, animated: true,completion: nil)
            }
        }
           
    }
 }
    //메인 설정화면으로 이동
    func ToMainUserSetting(alert: UIAlertAction!){
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func enrollBtn(_ sender: Any) {
        enrollCode()
    }
}
