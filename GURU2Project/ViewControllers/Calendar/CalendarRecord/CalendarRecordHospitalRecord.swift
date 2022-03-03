//
//  CalendarRecordHospitalRecord.swift
//  GURU2Project
//
//  Created by apple on 20K22/01/31.
//

import UIKit
import FirebaseDatabase
class CalendarRecordHospitalRecord:UIViewController{
    
    var ref: DatabaseReference!
    var dateFormatter = DateFormatter()
    var date:Date!
    var petcode:String!
    var recordKey:String!
    var bAdd = true //false:수정 true: 추가
    
    
    
    var recordView:CalendarRecordViewController!
    var calendarView:CalendarViewController!
    
    @IBOutlet var hospitalOption: [UIButton]!
    var indexOfOption = 0
    var hospitalOptionString:String!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var textMemo: UITextView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var btnSave: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference() //데이터베이스 연결
        popupView.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if bAdd {
            datePicker.date = Date()
            textMemo.text = ""
            btnSave.setTitle("등록", for: .normal)
            hospitalOptionString = "진료"
        } else {
            btnSave.setTitle("수정", for: .normal)
        }
        
        setUI()
    }
    
    func setUI(){
        for Btn in hospitalOption {
            Btn.layer.cornerRadius = 10
            Btn.backgroundColor = UIColor.darkGray
        }
        
        hospitalOption[indexOfOption].backgroundColor = UIColor.lightGray
        
    }
    
    @IBAction func doClose(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    //키보드 숨기기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
   }
    
    @IBAction func doSave(_ sender: UIButton) {
        let path = "pets/\(self.petcode!)/hospital"
        let refUser = self.ref.child(path)
        print(path)
        
        self.dateFormatter.dateFormat = "YYYY-MM-dd" //데이터 포맷 설정
        let day = self.dateFormatter.string(from: self.date)

        self.dateFormatter.dateFormat = "HH:mm" //데이터 포맷 설정
        let recordTime = self.dateFormatter.string(from: self.datePicker.date)
        var memo = self.textMemo.text
        let hospital = self.hospitalOptionString!

        if self.textMemo.text == ""{
            memo = "   "
        }
        
        if bAdd{
            refUser.observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? NSDictionary{
                    let recordNum = value["recordNum"] as! Int

                    print(recordNum)
                    self.ref.child("\(path)").updateChildValues(["recordNum":recordNum + 1]) //기록 추가

                    let recordName = String(format: "record%d", recordNum + 1)

                    let data = "\(day),\(recordTime),\(hospital),\(memo!)"
                    self.ref.child("\(path)").updateChildValues([recordName:data])

                    self.presentingViewController?.dismiss(animated: true)
                    self.recordView.dismissView()
                }
            }
             
        } else {
            refUser.observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? NSDictionary{
                    let data = "\(day),\(recordTime),\(hospital),\(memo!)"
                    self.ref.child("\(path)").updateChildValues([self.recordKey!:data])

                    self.presentingViewController?.dismiss(animated: true)
                    self.calendarView.findPetInfo()
                }
            }
        }
    }
    
    @IBAction func touchOption(_ sender: UIButton) {
        indexOfOption = hospitalOption.firstIndex(of: sender)!

        for Btn in hospitalOption {
                    if Btn == sender {
                        // 만약 현재 버튼이 이 함수를 호출한 버튼이라면
                        Btn.isSelected = true
                        Btn.backgroundColor = UIColor.lightGray
                        hospitalOptionString = Btn.titleLabel?.text
                    } else {
                        // 이 함수를 호출한 버튼이 아니라면
                        Btn.isSelected = false
                        Btn.backgroundColor = UIColor.darkGray
                    }
        }
    }
    
}

extension CalendarRecordHospitalRecord:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let str = textMemo.text else { return true }
        let newLength = str.count + text.count - range.length
        return newLength <= 500
     }
}
