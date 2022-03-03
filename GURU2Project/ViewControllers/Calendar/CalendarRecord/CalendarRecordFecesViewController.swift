//
//  CalendarRecordFecesViewController.swift
//  GURU2Project
//
//  Created by 김진원 on 2022/01/24.
//

import UIKit
import FirebaseDatabase
class CalendarRecordFecesViewController:UIViewController{
    
    var ref: DatabaseReference!
    var dateFormatter = DateFormatter()
    var date:Date!
    var petcode:String!
    var bAdd = true //false:수정 true: 추가
    var recordKey:String!
    
    var recordView:CalendarRecordViewController!
    var calendarView:CalendarViewController!
    
    
    @IBOutlet var btnOptions: [UIButton]!
    var indexOfFecesOption = 0
    var fecesOption:String!
    
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
        if bAdd {
            textMemo.text = ""
            recordTime.date = Date()
            btnSave.setTitle("등록", for: .normal)
            fecesOption = "소변"
           
        } else {
            btnSave.setTitle("수정", for: .normal)
        }
        
        setUI()
    }
    
    func setUI(){
        for Btn in btnOptions {
            Btn.layer.cornerRadius = 10
            Btn.backgroundColor = UIColor.darkGray
        }
        
        btnOptions[indexOfFecesOption].backgroundColor = UIColor.lightGray
    }
    
    @IBAction func doClose(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func doSave(_ sender: UIButton) {
        
        let path = "pets/\(self.petcode!)/feces"
        let refUser = self.ref.child(path)
        
        self.dateFormatter.dateFormat = "YYYY-MM-dd" //데이터 포맷 설정

        let day = self.dateFormatter.string(from: self.date)

        self.dateFormatter.dateFormat = "HH:mm" //데이터 포맷 설정
        let recordTime = self.dateFormatter.string(from: self.recordTime.date)
        var memo = self.textMemo.text
        let feces = self.fecesOption!

        if self.textMemo.text == ""{
            memo = "   "
        }
        
        if bAdd {
            refUser.observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? NSDictionary{
                    let recordNum = value["recordNum"] as! Int
                    self.ref.child("\(path)").updateChildValues(["recordNum":recordNum + 1]) //기록 추가
                    let recordName = String(format: "record%d", recordNum + 1)

                    let data = "\(day),\(recordTime),\(feces),\(memo!)"
                    self.ref.child("\(path)").updateChildValues([recordName:data])

                    self.presentingViewController?.dismiss(animated: true)
                    self.recordView.dismissView()
                }
            }
        } else {
            refUser.observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? NSDictionary{
                    
                    let data = "\(day),\(recordTime),\(feces),\(memo!)"
                    self.ref.child("\(path)").updateChildValues([self.recordKey!:data])

                    self.presentingViewController?.dismiss(animated: true)
                    self.calendarView.findPetInfo()
                }
            }
        }
        

    }
    
    @IBAction func touchOption(_ sender: UIButton) {
        indexOfFecesOption = btnOptions.firstIndex(of: sender)!

        for Btn in btnOptions {
                    if Btn == sender {
                        // 만약 현재 버튼이 이 함수를 호출한 버튼이라면
                        Btn.isSelected = true
                        Btn.backgroundColor = UIColor.lightGray
                        fecesOption = Btn.titleLabel?.text
                    } else {
                        // 이 함수를 호출한 버튼이 아니라면
                        Btn.isSelected = false
                        Btn.backgroundColor = UIColor.darkGray
                    }
        }
    }
}

extension CalendarRecordFecesViewController:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let str = textMemo.text else { return true }
        let newLength = str.count + text.count - range.length
        return newLength <= 500
     }
}
