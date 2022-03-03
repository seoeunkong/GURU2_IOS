//
//  ViewController.swift
//  GURU2Project
//
//  Created by 김진원 on 2022/01/20.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class ViewController: UIViewController {
    @IBOutlet weak var containView: UIView! //다른 view 보여주기 위한 용도
    
    var ref: DatabaseReference!
    var previousMainIndex:Int = 0
    var selectedMainIndex:Int = 0
    var previousSubIndex:Int = 0
    var selectedSubIndex:Int = 0

    @IBOutlet var tabMain: [UIImageView]! //캘린더, 기록, 팁, 게시글
    @IBOutlet var tabSub: [UIImageView]! //산책기록, 설정
    
    var mainViews = [UIViewController]()
    var subViews = [UIViewController]()
    
    static let calendarViewController = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarView")
    static let recordViewController = UIStoryboard(name: "Record", bundle: nil).instantiateViewController(withIdentifier: "recordTabControl")
    static let tipsViewController = UIStoryboard(name: "Tips", bundle: nil).instantiateViewController(withIdentifier: "TipsView")
    static let walkingMapViewController = UIStoryboard(name: "WalkingRecord", bundle: nil).instantiateViewController(withIdentifier: "WalkingMapView")
    static let signUpViewController = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUpView")
    static let postViewController = UIStoryboard(name: "Post", bundle: nil).instantiateViewController(withIdentifier: "PostView")
    static let settingViewController = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "SettingView")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ref = Database.database().reference() //데이터베이스 연결
        
        for btn in tabMain {
            let tap = UITapGestureRecognizer(target: self, action: #selector(mainTapped(_:)))
            btn.isUserInteractionEnabled = true
            btn.addGestureRecognizer(tap)
        }
        
        for btn in tabSub {
            let tap = UITapGestureRecognizer(target: self, action: #selector(subTapped(_:)))
            btn.isUserInteractionEnabled = true
            btn.addGestureRecognizer(tap)
        }
            
        mainViews.append(ViewController.calendarViewController)
        mainViews.append(ViewController.recordViewController)
        mainViews.append(ViewController.tipsViewController)
        mainViews.append(ViewController.postViewController)
        
        subViews.append(ViewController.walkingMapViewController)
        subViews.append(ViewController.settingViewController)
        
        //controller
        if let walkVC = ViewController.walkingMapViewController as? WalkingMapViewController {
            walkVC.viewController = self
        }
        
        if let signVC = ViewController.signUpViewController as? SignUpViewController {
            signVC.vc = self
        }
        
        if let setVC = ViewController.settingViewController as? SettingViewController {
            setVC.viewController = self
        }
        
        
        if let user = Auth.auth().currentUser{
            let currentVC = mainViews[0]
            currentVC.view.frame = UIApplication.shared.windows[0].frame
            currentVC.view.frame.size.height = containView.frame.height
            currentVC.didMove(toParent: self)
            self.addChild(currentVC)
            containView.addSubview(currentVC.view)

        } else {
            print("Plz Sign up")
            let currentVC = ViewController.signUpViewController
            currentVC.view.frame = UIApplication.shared.windows[0].frame
            currentVC.didMove(toParent: self)
            self.addChild(currentVC)
            currentVC.view.tag = 100
            self.view.addSubview(currentVC.view)
//            currentVC.view.frame = UIApplication.shared.windows[0].frame
//            currentVC.didMove(toParent: self)
//            currentVC.modalPresentationStyle = .fullScreen
//            present(currentVC, animated: true, completion: nil) //등록창 띄우기
        }
        

        
    }
    
    
    @objc func mainTapped(_ sender:UITapGestureRecognizer){
        //탭버튼을 터치하면 화면 전환
        NSLog("Tab")
        if let tag = sender.view?.tag{
            previousMainIndex = selectedMainIndex
            selectedMainIndex = tag
            let previousVC = mainViews[previousMainIndex]
            previousVC.willMove(toParent: self)
            previousVC.view.removeFromSuperview()
            previousVC.removeFromParent()
            
            let currentVC = mainViews[selectedMainIndex]
            currentVC.view.frame = UIApplication.shared.windows[0].frame
            currentVC.view.frame.size.height = containView.frame.height
            currentVC.didMove(toParent: self)
            self.addChild(currentVC)
            containView.addSubview(currentVC.view)
        }
    }
    
    func showCal(){
        if let currentVC = mainViews[0] as? CalendarViewController {
            currentVC.view.frame = UIApplication.shared.windows[0].frame
            currentVC.view.frame.size.height = containView.frame.height
            currentVC.didMove(toParent: self)
            currentVC.findPetInfo()
            self.addChild(currentVC)
            containView.addSubview(currentVC.view)
        }
    }
    
    func showSignIn(){
        let currentVC = ViewController.signUpViewController
        currentVC.view.frame = UIApplication.shared.windows[0].frame
        currentVC.didMove(toParent: self)
        self.addChild(currentVC)
        currentVC.view.tag = 100
        self.view.addSubview(currentVC.view)
    }
    
    func showSetting(){
        let currentVC = ViewController.settingViewController
        currentVC.view.frame = UIApplication.shared.windows[0].frame
        currentVC.didMove(toParent: self)
        currentVC.modalPresentationStyle = .overCurrentContext
        present(currentVC, animated: true, completion: nil) //등록창 띄우기
    }
    
    @objc func subTapped(_ sender:UITapGestureRecognizer){
        //탭버튼을 터치하면 화면 전환
        NSLog("Tab")
        if let tag = sender.view?.tag{
            
            selectedSubIndex = tag
            let currentVC = subViews[selectedSubIndex]
            currentVC.view.frame = UIApplication.shared.windows[0].frame
            currentVC.didMove(toParent: self)
            currentVC.modalPresentationStyle = .overCurrentContext
            present(currentVC, animated: true, completion: nil) //등록창 띄우기
            
        }

    }


}

