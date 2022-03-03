//
//  CalendarRecordWeightViewController.swift
//  GURU2Project
//
//  Created by 김진원 on 2022/01/24.
//

import UIKit
import FirebaseDatabase
class CalendarRecordWeightViewController:UIViewController {
    
    var ref: DatabaseReference!
    var dateFormatter = DateFormatter()
    var date:Date!
    var petcode:String!
    var bAdd = true //false:수정 true: 추가
    var recordKey:String!
    
    var recordView:CalendarRecordViewController!
    var calendarView:CalendarViewController!
    
    
    @IBOutlet weak var textWeight: UITextField!
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
            textWeight.text = ""
            textMemo.text = ""
            btnSave.setTitle("등록", for: .normal)
        } else {
            btnSave.setTitle("수정", for: .normal)
        }

    }

    @IBAction func doClose(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func doSave(_ sender: UIButton) {
        
        //체중 미 입력 시
        if self.textWeight.text == "" {
            let actionSheet = UIAlertController(title: nil, message: "체중이 입력되지 않았습니다.", preferredStyle: .alert)
            //확인 버튼
            let action_ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            actionSheet.addAction(action_ok)
            present(actionSheet, animated: true, completion: nil)
            return
        }
        
        
        let path = "pets/\(self.petcode!)/weight"
        let refUser = self.ref.child(path)
        
        self.dateFormatter.dateFormat = "YYYY-MM-dd" //데이터 포맷 설정
        let day = self.dateFormatter.string(from: self.date)

        self.dateFormatter.dateFormat = "HH:mm" //데이터 포맷 설정
        let recordTime = self.dateFormatter.string(from: Date())
        
        var memo = self.textMemo.text
        let weight = self.textWeight.text

        if self.textMemo.text == ""{
            memo = "   "
        }
        
        if bAdd {
            refUser.observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? NSDictionary{
                    let recordNum = value["recordNum"] as! Int
                    self.ref.child("\(path)").updateChildValues(["recordNum":recordNum + 1]) //기록 추가
                    let recordName = String(format: "record%d", recordNum + 1)

                    
                    let data = "\(day),\(recordTime),\(weight!),\(memo!)"
                    self.ref.child("\(path)").updateChildValues([recordName:data])

                    self.presentingViewController?.dismiss(animated: true)
                    self.recordView.dismissView()
                }
            }
            
        } else {
            
            refUser.observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? NSDictionary{
                    
                    let data = "\(day),\(recordTime),\(weight!),\(memo!)"
                    self.ref.child("\(path)").updateChildValues([self.recordKey!:data])

                    self.presentingViewController?.dismiss(animated: true)
                    self.calendarView.findPetInfo()
                }
            }
            
        }

        

    }
}

extension CalendarRecordWeightViewController:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let str = textMemo.text else { return true }
        let newLength = str.count + text.count - range.length
        return newLength <= 500
     }
}
