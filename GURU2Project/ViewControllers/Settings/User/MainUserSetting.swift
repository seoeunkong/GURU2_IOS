//
//  MainUserSetting.swift
//  GURU2Project
//
//  Created by 공서은 on 2022/01/25.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import Firebase

class MainUserSetting:UIViewController{
    
    @IBOutlet weak var myInfo: UIStackView!
    @IBOutlet weak var petInfo: UIStackView!
    @IBOutlet weak var likeInfo: UIStackView!
    @IBOutlet weak var commentInfo: UIStackView!
    
    var imageurl:URL = URL(fileURLWithPath: "")
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var petImage: UIImageView!
    
    let imagePickerController = UIImagePickerController()
    
    var settingVC:SettingViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //stack 디자인
        designStack_myinfo()
        designStack_petinfo()
        designStack_likeinfo()
        designStack_commentinfo()
         
    }
    
    func designStack_myinfo(){
        let RoundedView : UIView = UIView(frame: CGRect(x: -30, y: -10, width: self.view.frame.size.width - 35, height: 315))
        RoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.9])
        RoundedView.layer.masksToBounds = false
        RoundedView.layer.cornerRadius = 15
        RoundedView.layer.borderWidth = 2.0
        RoundedView.layer.borderColor = CGColor.init(red: 153.0 / 255.0, green: 202.0 / 255.0, blue: 183.0 / 255.0, alpha: 1.0)
        
        
        myInfo.addSubview(RoundedView)
        myInfo.sendSubviewToBack(RoundedView)
    }
    
    func designStack_petinfo(){
        let RoundedView : UIView = UIView(frame: CGRect(x: -30, y: -15, width: self.view.frame.size.width - 35, height: 150))
        RoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.9])
        RoundedView.layer.masksToBounds = false
        RoundedView.layer.cornerRadius = 15
        RoundedView.layer.borderWidth = 2.0
        RoundedView.layer.borderColor = CGColor.init(red: 210.0 / 255.0, green: 187.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
        
        
        petInfo.addSubview(RoundedView)
        petInfo.sendSubviewToBack(RoundedView)
    }
    
    func designStack_likeinfo(){
        let RoundedView : UIView = UIView(frame: CGRect(x: -30, y: -15, width: self.view.frame.size.width - 35, height: 100))
        RoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.9])
        RoundedView.layer.masksToBounds = false
        RoundedView.layer.cornerRadius = 15
        RoundedView.layer.borderWidth = 2.0
        RoundedView.layer.borderColor = CGColor.init(red: 239.0 / 255.0, green: 184.0 / 255.0, blue: 173.0 / 255.0, alpha: 1.0)
        
        
        likeInfo.addSubview(RoundedView)
        likeInfo.sendSubviewToBack(RoundedView)
    }
    
    func designStack_commentinfo(){
        let RoundedView : UIView = UIView(frame: CGRect(x: -30, y: -15, width: self.view.frame.size.width - 35, height: 100))
        RoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.9])
        RoundedView.layer.masksToBounds = false
        RoundedView.layer.cornerRadius = 15
        RoundedView.layer.borderWidth = 2.0
        RoundedView.layer.borderColor = CGColor.init(red: 110.0 / 255.0, green: 144.0 / 255.0, blue: 182.0 / 255.0, alpha: 1.0)
        
        
        commentInfo.addSubview(RoundedView)
        commentInfo.sendSubviewToBack(RoundedView)
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


    @IBAction func Logout(_ sender: Any) {
        let user = Auth.auth()
        do {
         try user.signOut()
            let alertVC = UIAlertController(title: "Complete", message: "로그아웃이 완료되었습니다.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "완료", style: .cancel, handler: ToLogin(alert:)))
            self.present(alertVC, animated: true,completion: nil)
            
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func imageChange(_ sender: Any) {
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
    
    func ToLogin(alert: UIAlertAction!) {
        self.settingVC.dismissView()
        self.presentingViewController?.dismiss(animated: true)
//            var storyboard: UIStoryboard = UIStoryboard(
//                name: "SignUp",
//                bundle: nil
//            )
//            var vc = storyboard.instantiateViewController(withIdentifier: "SignUpView")
//            vc.modalTransitionStyle = .coverVertical
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true, completion: nil)
        
        
        
            
        /*
        let preVC = self.presentingViewController
        guard let vc = preVC as? SignUpViewController else
        {print("no"+"\(preVC)")
            return
         }
        print("ok"+"\(vc)")
        self.present(vc, animated: true, completion: nil)
         */
        /*
        let currentVC = ViewController.signUpViewController
        currentVC.view.frame = UIApplication.shared.windows[0].frame
        currentVC.didMove(toParent: self)
        self.addChild(currentVC)
        self.view.addSubview(currentVC.view)
         */
        /*
        guard let pvc = self.presentingViewController else { return }
        pvc.present(SignUpViewController(), animated: true, completion: nil)
         
        
        self.dismiss(animated: true) {
          pvc.present(SignUpViewController(), animated: true, completion: nil)
        }
        
        */
        /*
        var storyboard: UIStoryboard = UIStoryboard(
            name: "SignUp",
            bundle: nil
        )
        var vc = storyboard.instantiateViewController(withIdentifier: "SignUpView")
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
*/
       
    }
    
    //imageurl를 db에 업데이트
    func imageDBUpdate(_ url:URL){
        let user = Auth.auth().currentUser
        
        if let user = user {
            let key = user.uid
            var headDB : DatabaseReference  = Database.database().reference()
            
            headDB.child("users").child("\(key)").updateChildValues(["image":"\(imageurl)"])
        }
        
    }
    
    //뒤로가기 버튼
    @IBAction func backBtn(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func editPetView(_ sender: Any) {
        var vc = storyboard?.instantiateViewController(withIdentifier: "PetInfoView")
        vc!.modalTransitionStyle = .coverVertical
        vc!.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
    }
}


extension MainUserSetting : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageurl01 = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
            imageurl = imageurl01
            
        }
        
       imageDBUpdate(imageurl)
        picker.dismiss(animated: true, completion: nil) //dismiss를 직접 해야함
        
    }

}



