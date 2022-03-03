//
//  CalendarRecordWalkingViewController.swift
//  GURU2Project
//
//  Created by 김진원 on 2022/01/22.
//

import UIKit
import FirebaseDatabase
class CalendarRecordWalkingViewController:UIViewController{
   
    
    @IBOutlet weak var startTime: UIDatePicker!
    @IBOutlet weak var stopTime: UIDatePicker!
    @IBOutlet weak var textMemo: UITextView!
    @IBOutlet weak var textDistance: UITextField!
    @IBOutlet weak var textCal: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var popupView: UIView!
    
    var ref: DatabaseReference!
    var dateFormatter = DateFormatter()
    var date:Date!
    var petcode:String!
    var recordKey:String!
    var bAdd = true //false:수정 true: 추가
    
    var recordView:CalendarRecordViewController!
    var calendarView:CalendarViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference() //데이터베이스 연결
        
        popupView.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if bAdd{
            startTime.date = Date()
            stopTime.date = Date()
            textMemo.text = ""
            textDistance.text = ""
            textCal.text = ""
            btnSave.setTitle("등록", for: .normal)
        } else {
            btnSave.setTitle("수정", for: .normal)
        }

    }
    
    @IBAction func doSave(_ sender: UIButton) {
        
        //시작 시간이 더 늦은 경우
        if startTime.date > stopTime.date {
            let actionSheet = UIAlertController(title: nil, message: "시작 시간이 종료 시간보다 이릅니다.", preferredStyle: .alert)
            //확인 버튼
            let action_ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            actionSheet.addAction(action_ok)
            present(actionSheet, animated: true, completion: nil)
            return
        }
        
        let path = "pets/\(petcode!)/walking"
        let refUser = ref.child(path)
        
        self.dateFormatter.dateFormat = "YYYY-MM-dd" //데이터 포맷 설정

        let day = self.dateFormatter.string(from: self.date)

        self.dateFormatter.dateFormat = "HH:mm" //데이터 포맷 설정
        let start = self.dateFormatter.string(from: self.startTime.date)
        let stop = self.dateFormatter.string(from: self.stopTime.date)
        var memo = self.textMemo.text
        var distance = self.textDistance.text
        var cal = self.textCal.text
        
        if self.textMemo.text == ""{
            memo = "   "
        }
        
        if self.textDistance.text == ""{
            distance = "   "
        }
        
        if self.textCal.text == ""{
            cal = "   "
        }
        
        if bAdd {
            refUser.observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? NSDictionary{
                    let recordNum = value["recordNum"] as! Int

                    let recordName = String(format: "record%d", recordNum + 1)
                    self.ref.child("\(path)").updateChildValues(["recordNum":recordNum + 1]) //기록 추가

                    let data = "\(day),\(start),\(stop),\(distance!),\(cal!),\(memo!)"
                    self.ref.child("\(path)").updateChildValues([recordName:data])
                    
                    self.presentingViewController?.dismiss(animated: true)
                    self.recordView.dismissView()
                    
                }
            }
        } else {
            
            refUser.observeSingleEvent(of: .value) { (snapshot) in
                
                //DB 수정
                let data = "\(day),\(start),\(stop),\(distance!),\(cal!),\(memo!)"
                self.ref.child("\(path)").updateChildValues([self.recordKey!:data])
                
                self.presentingViewController?.dismiss(animated: true)
                //self.calendarView.findPetInfo()
            }
        }

    }
    
    //키보드 숨기기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
   }

    @IBAction func doClose(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)

    }
    
}

extension CalendarRecordWalkingViewController:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let str = textMemo.text else { return true }
        let newLength = str.count + text.count - range.length
        return newLength <= 500
     }
}
