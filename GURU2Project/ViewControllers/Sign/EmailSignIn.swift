//
//  EmailSignIn.swift
//  GURU2Project
//
//  Created by 공서은 on 2022/01/22.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FirebaseDatabase

class EmailSignIn:UIViewController{
   
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    
    @IBOutlet weak var signinBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    
    var signUpView:SignUpViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.clearButtonMode = .whileEditing
        pwTextField.clearButtonMode = .whileEditing
        
        signinBtn.layer.cornerRadius = 30
        googleBtn.layer.cornerRadius = 30
        googleBtn.layer.borderColor = UIColor.black.cgColor
        googleBtn.layer.borderWidth = 0.5
        signinBtn.setTitleColor(.gray, for: .highlighted)
        googleBtn.setTitleColor(.white, for: .highlighted)
    
    }
    
    
    //로그인 버튼
    @IBAction func SignInBtn(_ sender: Any) {
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: pwTextField.text!) { (user, error) in
                    if user != nil{
                        //로그인 성공한 경우
                        self.emailTextField.text = ""
                        self.pwTextField.text = ""
                        let alertVC = UIAlertController(title: "Complete", message: "로그인이 완료되었습니다.", preferredStyle: .alert)
                        alertVC.addAction(UIAlertAction(title: "완료", style: .cancel, handler: self.MoveToSettingHandler))
                        self.present(alertVC, animated: true,completion: nil)
                    }
                    else{
                        //로그인 실패한 경우
                        self.emailTextField.text = ""
                        self.pwTextField.text = ""
                        let alertVC = UIAlertController(title: "Error", message: "로그인에 실패하였습니다.", preferredStyle: .alert)
                        alertVC.addAction(UIAlertAction(title: "계속", style: .cancel, handler: nil))
                        self.present(alertVC, animated: true,completion: nil)
                    }
              }
    }
    
    
    @IBAction func googleSignin(_ sender: Any) {
        
                guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                let signInConfig = GIDConfiguration(clientID: clientID)
       
              GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
                guard error == nil else { return }
                guard let authentication = user?.authentication else { return }
                let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!, accessToken: authentication.accessToken)
                // access token 부여 받음
                  
                  // 파베 인증정보 등록
                  Auth.auth().signIn(with: credential) {_,_ in
                      // token을 넘겨주면, 성공했는지 안했는지에 대한 result값과 error값을 넘겨줌
                     
                  }
                  self.withSignUp()
                  }
              }
    
    //설정 페이지로 이동
    func MoveToSettingHandler(alert: UIAlertAction!) {

        self.signUpView.dismissView(mode: 0)
        self.presentingViewController?.dismiss(animated: true)

    }
    
    // 구글로 로그인하는 경우
    // 회원가입을 하고 로그인하는 경우와 그 이외의 경우를 구별하기 위해
    func withSignUp(){
        
        let user = Auth.auth().currentUser
        if let user = user {
        //데이터베이스 연결
        var headDB : DatabaseReference  = Database.database().reference()
        
        //키값을 받음
        let key = user.uid
        //firebase에서 해당 유저의 이메일과 이름을 찾음
        headDB.child("users").child("\(key)").observeSingleEvent(of: .value) {snapshot in
                let value = snapshot.value as? NSDictionary //2번째 줄
                let username = value?["username"] as? String ?? ""
                let useremail = value?["email"] as? String ?? ""
            //회원가입을 하고 로그인 한 경우
            if username != "" {
                let alertVC = UIAlertController(title: "Complete", message: "로그인이 완료되었습니다.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "완료", style: .cancel, handler: self.MoveToSettingHandler))
                self.present(alertVC, animated: true,completion: nil)
            }else{
                //회원가입을 안하고 로그인 하는 경우
                let alertVC = UIAlertController(title: "Error", message: "계정이 존재하지 않습니다.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "계속", style: .cancel, handler: nil))
                self.present(alertVC, animated: true,completion: nil)
            }
            
                }
          }
     }
    
    
    //해당 페이지 닫기
    @IBAction func closeBtn(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
}

