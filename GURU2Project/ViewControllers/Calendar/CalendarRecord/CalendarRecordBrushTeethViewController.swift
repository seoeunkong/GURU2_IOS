
//
//  CalendarRecordBrushTeethViewController.swift
//  GURU2Project
//
//  Created by 김진원 on 2022/01/24.
//

import UIKit
import FirebaseDatabase

class CalendarRecordBrushTeethViewController:UIViewController{
    
    var ref: DatabaseReference!
    var dateFormatter = DateFormatter()
    var date:Date!
    var petcode:String!
    var bAdd = true //false:수정 true: 추가
    
    var recordKey:String!
    
    var recordView:CalendarRecordViewController!
    var calendarView:CalendarViewController!
    
    @IBOutlet weak var recordTime: UIDatePicker!
    @IBOutlet weak var textMemo: UITextView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var popupView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference() //데이터베이스 연결
        popupView.layer.cornerRadius = 20
    }
    
    //키보드 숨기기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
   }
    
    override func viewWillAppear(_ animated: Bool) {
        if bAdd{
            textMemo.text = ""
            recordTime.date = Date()
            btnSave.setTitle("등록", for: .normal)
        } else {
            btnSave.setTitle("수정", for: .normal)
        }
    }
    
    @IBAction func doClose(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    @IBAction func doSave(_ sender: Any) {
        let path = "pets/\(self.petcode!)/brush teeth"
        let refUser = self.ref.child(path)
       
        
        self.dateFormatter.dateFormat = "YYYY-MM-dd" //데이터 포맷 설정

        let day = self.dateFormatter.string(from: self.date)

        self.dateFormatter.dateFormat = "HH:mm" //데이터 포맷 설정
        let recordTime = self.dateFormatter.string(from: self.recordTime.date)
        var memo = self.textMemo.text
        if self.textMemo.text == ""{
            memo = "   "
        }
        
        if bAdd {
            refUser.observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? NSDictionary{
                    
                    let recordNum = value["recordNum"] as! Int
                    let recordName = String(format: "record%d", recordNum + 1)
                    
                    self.ref.child("\(path)").updateChildValues(["recordNum":recordNum + 1]) //기록 추가

                    let data = "\(day),\(recordTime),\(memo!)"
                    self.ref.child("\(path)").updateChildValues([recordName:data])

                    self.presentingViewController?.dismiss(animated: true)
                    self.recordView.dismissView()
                }
            }
        } else {
            refUser.observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? NSDictionary{
                    
                    //DB 수정
                    let data = "\(day),\(recordTime),\(memo!)"
                    self.ref.child("\(path)").updateChildValues([self.recordKey!:data])
                    
                    self.presentingViewController?.dismiss(animated: true)
                    self.calendarView.findPetInfo()
                }
            }
        }
    }
}

extension CalendarRecordBrushTeethViewController:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let str = textMemo.text else { return true }
        let newLength = str.count + text.count - range.length
        return newLength <= 500
     }
}
