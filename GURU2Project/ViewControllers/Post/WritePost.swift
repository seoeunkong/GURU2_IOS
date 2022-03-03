//
//  WritePost.swift
//  GURU2Project
//
//  Created by 공서은 on 2022/01/29.
//

import UIKit
import Firebase
import FirebaseDatabase
import Photos

class WritePost:UIViewController{
    
    let imagePickerController = UIImagePickerController()
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var contentsText: UITextView!
    @IBOutlet weak var postimage: UIImageView!
    
    @IBOutlet weak var filter01: UIButton!
    @IBOutlet weak var filter02: UIButton!
    @IBOutlet weak var filter03: UIButton!
    @IBOutlet weak var filter04: UIButton!
    @IBOutlet weak var filter05: UIButton!
    @IBOutlet weak var filter06: UIButton!
    
    @IBOutlet var writeView: UIView!
    
    
    var imageurl:URL = URL(fileURLWithPath: "")
    
    var ref: DatabaseReference!
    var postcode:String = ""
    
    var filter:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentsText.layer.borderColor = UIColor.gray.cgColor
        contentsText.layer.borderWidth = 0.1
        contentsText.layer.cornerRadius = 20.0
        
        filter01.setTitle("click", for: .selected)
        
       
    }
    
    //DB에 업데이트
    func DatabaseUpdate(){
        let user = Auth.auth().currentUser
        if let user = user {
        //데이터베이스 연결
        ref = Database.database().reference()
        
       
        let str = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789#@!"
        let size = 4
        postcode = str.createRandomStr(length: size)
            
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var current_date_string = formatter.string(from: Date())
            print(current_date_string)
            
            
        let key = user.uid
        
        ref.child("users").child("\(key)").observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? NSDictionary
            let DBhowmanypost = value?["howmanypost"] as? String ?? "0"
            let howmanypost = Int(DBhowmanypost)
            let DBuser = value?["username"] as? String ?? "0"
            let DBimage_writer = value?["image"] as? String ?? ""
            
            if let title = self.titleText.text, let contents = self.contentsText.text {
                
                if title != "", contents != "", self.filter != 0 {
                    let post = ["Title":"\(title)", "Contents":"\(contents)","PostCode":"\(self.postcode)","Filter":"\(self.filter)","Time":"\(current_date_string)","Writer":"\(DBuser)","Image":"\(DBimage_writer)","Postimage":"\(self.imageurl)"]
                    let childUpdates = ["/posts/\(self.postcode)/": post]
                
            
                    self.ref.child("users/\(key)/post/").updateChildValues(["postcode"+"\(howmanypost!+1)":"\(self.postcode)"])
                self.ref.child("users/\(key)/").updateChildValues(["howmanypost":"\(howmanypost!+1)"])
                    
                self.ref.child("Entirepost").observeSingleEvent(of: .value) { snapshot in
                        let value = snapshot.value as? NSDictionary
                        let DBehowmanypost = value?["howmanypost"] as? String ?? "0"
                        let ehowmanypost = Int(DBehowmanypost)
                    self.ref.child("Entirepost").updateChildValues(["postcode"+"\(ehowmanypost!+1)":"\(self.postcode)"])
                self.ref.child("Entirepost").updateChildValues(["howmanypost":"\(ehowmanypost!+1)"])
                }
                
                self.ref.updateChildValues(childUpdates)
                
                
                let alertVC = UIAlertController(title: "Complete", message: "글 작성이 완료되었습니다.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "완료", style: .cancel, handler: self.ToPostView))
                self.present(alertVC, animated: true,completion: nil)
                
            
            }else{
                let alertVC = UIAlertController(title: "Error", message: "내용을 다시 확인해주세요.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "계속", style: .cancel, handler: nil))
                self.present(alertVC, animated: true,completion: nil)
            }
            }
        }
    }
        
 }
    func openLibrary(){

        self.imagePickerController.delegate = self
        self.imagePickerController.sourceType = .photoLibrary
        present(self.imagePickerController, animated: true, completion: nil)
    }

    func openCamera(){
    
        self.imagePickerController.delegate = self
        self.imagePickerController.sourceType = .camera
        present(self.imagePickerController, animated: true, completion: nil)

    }
    
    
    
    func ToColorChange(_ Btn:UIButton, color:UIColor, for state: UIControl.State){
        
        Btn.backgroundColor = color
    }
    
    func ToColorDisabled(_ Btn:UIButton){
        
        Btn.backgroundColor = .none
    }
    
    func ToPostView(alert: UIAlertAction!){
        var vc = storyboard?.instantiateViewController(withIdentifier: "PostView")
        vc!.modalTransitionStyle = .coverVertical
        vc!.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
    }
    
    //키보드 숨기기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
   }

    @IBAction func filter01Btn(_ sender: Any) {
        ToColorChange(filter01, color: .lightGray, for: .selected)
        ToColorDisabled(filter02)
        ToColorDisabled(filter03)
        ToColorDisabled(filter04)
        ToColorDisabled(filter05)
        ToColorDisabled(filter06)
        filter = 1
    }
    
    @IBAction func filter02Btn(_ sender: Any) {
        ToColorChange(filter02, color: .lightGray, for: .selected)
        ToColorDisabled(filter01)
        ToColorDisabled(filter03)
        ToColorDisabled(filter04)
        ToColorDisabled(filter05)
        ToColorDisabled(filter06)
        filter = 2
    }
    
    @IBAction func filter03Btn(_ sender: Any) {
        ToColorChange(filter03, color: .lightGray, for: .selected)
        ToColorDisabled(filter01)
        ToColorDisabled(filter02)
        ToColorDisabled(filter04)
        ToColorDisabled(filter05)
        ToColorDisabled(filter06)
        filter = 3
    }
    
    @IBAction func filter04Btn(_ sender: Any) {
        ToColorChange(filter04, color: .lightGray, for: .selected)
        ToColorDisabled(filter01)
        ToColorDisabled(filter03)
        ToColorDisabled(filter02)
        ToColorDisabled(filter05)
        ToColorDisabled(filter06)
        filter = 4
    }
    
    @IBAction func filter05Btn(_ sender: Any) {
        ToColorChange(filter05, color: .lightGray, for: .selected)
        ToColorDisabled(filter01)
        ToColorDisabled(filter03)
        ToColorDisabled(filter04)
        ToColorDisabled(filter02)
        ToColorDisabled(filter06)
        filter = 5
    }
    @IBAction func filter06Btn(_ sender: Any) {
        ToColorChange(filter06, color: .lightGray, for: .selected)
        ToColorDisabled(filter01)
        ToColorDisabled(filter03)
        ToColorDisabled(filter04)
        ToColorDisabled(filter05)
        ToColorDisabled(filter02)
        filter = 6
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    //사진 등록하기
    @IBAction func photoBtn(_ sender: Any) {
        let alert = UIAlertController(title: "프로필 사진 변경", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "카메라 열기", style: .default, handler: { (_) in
            self.openCamera()
          }))
        
        alert.addAction(UIAlertAction(title: "사진앨범에서 가져오기", style: .default, handler: { (_) in
            self.openLibrary()
        
          }))
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (_) in }))
        self.present(alert, animated: true, completion:nil)
    }
   
    
    
    @IBAction func completeBtn(_ sender: Any) {
        DatabaseUpdate()
        
    }
   
    
}


extension WritePost : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageurl01 = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
             imageurl = imageurl01
            
        }
        if let imagepost = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            postimage.image = imagepost
            
        }
        
      // imageDBUpdate(urlimage_contents)
        picker.dismiss(animated: true, completion: nil) //dismiss를 직접 해야함
        
    }

}

