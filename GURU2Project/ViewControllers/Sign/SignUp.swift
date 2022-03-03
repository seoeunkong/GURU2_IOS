//
//  EmailSignUp.swift
//  GURU2Project
//
//  Created by 공서은 on 2022/01/22.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import GoogleSignIn

class SignUp:UIViewController{
    
    var ref: DatabaseReference!
    var refHandle : DatabaseHandle!
    var ref2:DatabaseReference!
    
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var nameTextfield: UITextField!
    
    var signUpView:SignUpViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextfield.clearButtonMode = .whileEditing
        passwordTextfield.clearButtonMode = .whileEditing
        
        signupBtn.layer.cornerRadius = 30
        googleBtn.layer.cornerRadius = 30
        googleBtn.layer.borderColor = UIColor.black.cgColor
        googleBtn.layer.borderWidth = 0.5
        signupBtn.setTitleColor(.gray, for: .highlighted)
        googleBtn.setTitleColor(.white, for: .highlighted)

        
    }
    
    
    //회원가입 버튼
    @IBAction func SignupBtn(_ sender: Any) {
       
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!
                ) { (user, error) in
                    if user !=  nil{
                        //회원가입 성공한 경우
                        let alertVC = UIAlertController(title: "Complete", message: "회원가입이 완료되었습니다.", preferredStyle: .alert)
                        alertVC.addAction(UIAlertAction(title: "완료", style: .cancel, handler: self.MoveToSettingHandler))
                        self.present(alertVC, animated: true,completion: nil)
                        
                        self.DatabaseUpdate()
                        self.emailTextfield.text = ""
                        self.passwordTextfield.text = ""
                        self.nameTextfield.text = ""
                    }
                    else{
                        //회원가입 실패한 경우
                        let alertVC = UIAlertController(title: "Error", message: "회원가입에 실패하였습니다.", preferredStyle: .alert)
                        alertVC.addAction(UIAlertAction(title: "계속", style: .cancel, handler: nil))
                        self.present(alertVC, animated: true,completion: nil)
                        
                        self.emailTextfield.text = ""
                        self.passwordTextfield.text = ""
                        self.nameTextfield.text = ""
                    }
                }
    }
    
    //회원가입한 후 DB에 없데이트
    func DatabaseUpdate(){
        let user = Auth.auth().currentUser
        if let user = user {
        //데이터베이스 연결
        ref = Database.database().reference()
        
        //키값을 받음
        let key = user.uid
        if let name = self.nameTextfield.text, let email = self.emailTextfield.text, let pw = self.passwordTextfield.text{
            let post = ["username":"\(name)", "email":"\(email)","pw":"\(pw)","howmany":"0"]
                let childUpdates = ["/users/\(key)/": post]
        ref.updateChildValues(childUpdates)
        }
    }
 }
    
    //회원가입한 후 DB에 없데이트_google버전
    func DatabaseUpdate_google(){
        let user = Auth.auth().currentUser
        
        if let user = user {
          // The user's ID, unique to the Firebase project.
            
        //데이터베이스 연결
        ref = Database.database().reference()
        //키값
        let key = user.uid
        if let email = user.email{
            let post = ["username":"\(email)","email":"\(email)"]
            let childUpdates = ["/users/\(key)/": post]
            ref.updateChildValues(childUpdates)
        }
    }
    }
    
    
    @IBAction func googleSignup(_ sender: Any) {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                let signInConfig = GIDConfiguration.init(clientID: clientID)
                
              GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
                guard error == nil else { return }

                guard let authentication = user?.authentication else { return }
                let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!, accessToken: authentication.accessToken)
                // access token 부여 받음
                
                  //self.ref2 = self.ref.child("users/2019111096")
                  
                // 파베 인증정보 등록
                Auth.auth().signIn(with: credential) {_,_ in
                    // token을 넘겨주면, 성공했는지 안했는지에 대한 result값과 error값을 넘겨줌
                    self.DatabaseUpdate_google()
                    let alertVC = UIAlertController(title: "Complete", message: "회원가입이 완료되었습니다.", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "완료", style: .cancel, handler: self.MoveToSettingHandler))
                    self.present(alertVC, animated: true,completion: nil)
                   
                }
              }
        
    }
    
    //로그인 페이지로 이동
    func MoveToSettingHandler(alert: UIAlertAction!) {
        
        
        if let user = Auth.auth().currentUser{
//            var storyboard: UIStoryboard = UIStoryboard(
//                name: "Main",
//                bundle: nil
//            )
//            var vc = storyboard.instantiateViewController(withIdentifier: "viewcontroller")
//            vc.modalTransitionStyle = .coverVertical
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true, completion: nil)
            self.signUpView.dismissView(mode: 1)
            self.presentingViewController?.dismiss(animated: true)
        }


    }
    
    
   
    @IBAction func closeBtn(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    
}


