//
//  CalendarRecordViewController.swift
//  GURU2Project
//
//  Created by 김진원 on 2022/01/22.
//

import UIKit

class CalendarRecordViewController:UIViewController{
    
    @IBOutlet var tabBtns: [UIImageView]!
    
    
    var viewContollers = [UIViewController]()
    var previousIndex:Int = 0
    var selectedIndex:Int = 0

    
    //데이터 정보
    var currentDate:Date!
    var petCode = [String]()
    
    static let WalkingViewController = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarRecordWalking")
    static let MealViewController = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarRecordMeal")
    static let ShowerViewController = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarRecordShower")
    static let BrushTeethViewController = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarRecordBrushTeeth")
    static let FecesViewController = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarRecordFeces")
    static let WeightViewController = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarRecordWeight")
    static let MemoViewController = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarRecordMemo")
    static let HospitalViewController = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarRecordHospital")
    override func viewDidLoad() {
        super.viewDidLoad()
        for btn in tabBtns {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tabTapped(_:)))
            btn.isUserInteractionEnabled = true
            btn.addGestureRecognizer(tap)
        }
        
        
        viewContollers.append(CalendarRecordViewController.WalkingViewController)
        viewContollers.append(CalendarRecordViewController.MealViewController)
        viewContollers.append(CalendarRecordViewController.ShowerViewController)
        viewContollers.append(CalendarRecordViewController.BrushTeethViewController)
        viewContollers.append(CalendarRecordViewController.FecesViewController)
        viewContollers.append(CalendarRecordViewController.WeightViewController)
        viewContollers.append(CalendarRecordViewController.MemoViewController)
        viewContollers.append(CalendarRecordViewController.HospitalViewController)
    }
    
    //키보드 숨기기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
   }
    
    override func viewWillAppear(_ animated: Bool) {
        //let CalendarVC = ViewController.calendarViewController as? CalendarViewController
        print("record view appear")
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let startTime = format.string(from: currentDate)
        print(startTime)
    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }
    
    @IBAction func goBack(_ sender: UIButton) {
        
        dismissView()
    }
    
    //뒤로가기 함수
    func dismissView(){
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func tabTapped(_ sender:UITapGestureRecognizer){
        //탭버튼을 터치하면 화면 전환
        NSLog("Tab")
        if let tag = sender.view?.tag{
            print(tag)
            
            
            previousIndex = selectedIndex
            selectedIndex = tag
            let previousVC = viewContollers[previousIndex]
            previousVC.willMove(toParent: self)
            previousVC.view.removeFromSuperview()
            previousVC.removeFromParent()
            switch tag {
            case 0: //산책
                if let currentVC = viewContollers[selectedIndex] as? CalendarRecordWalkingViewController{
                    currentVC.view.frame = UIApplication.shared.windows[0].frame
                    currentVC.didMove(toParent: self)
                    currentVC.modalPresentationStyle = .overCurrentContext
                    currentVC.bAdd = true
                    present(currentVC, animated: true, completion: nil) //등록창 띄우기
                    currentVC.recordView = self // 현재 클래스 할당 됨
                    currentVC.date = self.currentDate
                    currentVC.petcode = self.petCode[0]
                }
                break
            case 1: //식사
                if let currentVC = viewContollers[selectedIndex] as? CalendarRecordMealViewController{
                    currentVC.view.frame = UIApplication.shared.windows[0].frame
                    currentVC.didMove(toParent: self)
                    currentVC.modalPresentationStyle = .overCurrentContext
                    currentVC.bAdd = true
                    present(currentVC, animated: true, completion: nil) //등록창 띄우기
                    currentVC.recordView = self // 현재 클래스 할당 됨
                    currentVC.date = self.currentDate
                    currentVC.petcode = self.petCode[0]
                }
                break
            case 2: //샤워
                if let currentVC = viewContollers[selectedIndex] as? CalendarRecordShowerViewController{
                    currentVC.view.frame = UIApplication.shared.windows[0].frame
                    currentVC.didMove(toParent: self)
                    currentVC.modalPresentationStyle = .overCurrentContext
                    currentVC.bAdd = true
                    present(currentVC, animated: true, completion: nil) //등록창 띄우기
                    currentVC.recordView = self // 현재 클래스 할당 됨
                    currentVC.date = self.currentDate
                    currentVC.petcode = self.petCode[0]
                }
                break
            case 3: //양치
                if let currentVC = viewContollers[selectedIndex] as? CalendarRecordBrushTeethViewController{
                    currentVC.view.frame = UIApplication.shared.windows[0].frame
                    currentVC.didMove(toParent: self)
                    currentVC.modalPresentationStyle = .overCurrentContext
                    currentVC.bAdd = true
                    present(currentVC, animated: true, completion: nil) //등록창 띄우기
                    currentVC.recordView = self // 현재 클래스 할당 됨
                    currentVC.date = self.currentDate
                    currentVC.petcode = self.petCode[0]
                }
                break
            case 4: //대소변
                if let currentVC = viewContollers[selectedIndex] as? CalendarRecordFecesViewController{
                    currentVC.view.frame = UIApplication.shared.windows[0].frame
                    currentVC.didMove(toParent: self)
                    currentVC.modalPresentationStyle = .overCurrentContext
                    currentVC.bAdd = true
                    present(currentVC, animated: true, completion: nil) //등록창 띄우기
                    currentVC.recordView = self // 현재 클래스 할당 됨
                    currentVC.date = self.currentDate
                    currentVC.petcode = self.petCode[0]
                }
                break
            case 5: //체중
                if let currentVC = viewContollers[selectedIndex] as? CalendarRecordWeightViewController{
                    currentVC.view.frame = UIApplication.shared.windows[0].frame
                    currentVC.didMove(toParent: self)
                    currentVC.modalPresentationStyle = .overCurrentContext
                    currentVC.bAdd = true
                    present(currentVC, animated: true, completion: nil) //등록창 띄우기
                    currentVC.recordView = self // 현재 클래스 할당 됨
                    currentVC.date = self.currentDate
                    currentVC.petcode = self.petCode[0]
                }
                break
            case 6: //직접 입력
                if let currentVC = viewContollers[selectedIndex] as? CalendarRecordMemoViewController{
                    currentVC.view.frame = UIApplication.shared.windows[0].frame
                    currentVC.didMove(toParent: self)
                    currentVC.modalPresentationStyle = .overCurrentContext
                    currentVC.bAdd = true
                    present(currentVC, animated: true, completion: nil) //등록창 띄우기
                    currentVC.recordView = self // 현재 클래스 할당 됨
                    currentVC.date = self.currentDate
                    currentVC.petcode = self.petCode[0]     
                }
                break
            case 7: // 진료
                if let currentVC = viewContollers[selectedIndex] as? CalendarRecordHospitalRecord{
                    currentVC.view.frame = UIApplication.shared.windows[0].frame
                    currentVC.didMove(toParent: self)
                    currentVC.modalPresentationStyle = .overCurrentContext
                    currentVC.bAdd = true
                    present(currentVC, animated: true, completion: nil) //등록창 띄우기
                    currentVC.recordView = self // 현재 클래스 할당 됨
                    currentVC.date = self.currentDate
                    currentVC.petcode = self.petCode[0]
                }
            default:
                break
            }
        }
        
        
    }
}
