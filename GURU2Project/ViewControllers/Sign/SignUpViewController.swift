//
//  SignUpViewController.swift
//  GURU2Project
//
//  Created by 김진원 on 2022/01/20.
//

import UIKit
import Firebase
import FirebaseAuth


class SignUpViewController:UIViewController{
    
    var vc:ViewController!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var signinBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signupBtn.layer.cornerRadius = 20
        signinBtn.setTitleColor(.gray, for: .highlighted)
        signupBtn.setTitleColor(.gray, for: .highlighted)
       
    }
    
    @IBAction func doLogIn(_ sender: Any) {
        performSegue(withIdentifier: "LogIn", sender: nil)
    }
    
    @IBAction func doSignUp(_ sender: Any) {
        performSegue(withIdentifier: "Signup", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "LogIn" {
            guard let secondVC = segue.destination as? EmailSignIn else {return}

            //second 뷰가 존재하면 데이터를 전달한다
            secondVC.signUpView = self

        } else {
            guard let signupVC = segue.destination as? SignUp else {return}
            //second 뷰가 존재하면 데이터를 전달한다
            signupVC.signUpView = self
        }

        

    }
    
    func dismissView(mode:Int){
        
        print("dismiss",mode)
        
        self.vc.showCal()
        let viewWithTag = self.vc.view.viewWithTag(100)

        // 해당 뷰를 제거한다
        viewWithTag?.removeFromSuperview()
        
        //self.vc.view.removeFromSuperview()
        //self.presentingViewController?.dismiss(animated: true)
    }
    
}
