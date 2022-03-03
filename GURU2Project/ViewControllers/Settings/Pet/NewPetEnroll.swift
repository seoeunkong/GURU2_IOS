//
//  NewPetEnroll.swift
//  GURU2Project
//
//  Created by 공서은 on 2022/01/26.
//

import UIKit
import Firebase
import FirebaseDatabase

class NewPetEnroll:UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    let genderPicker = ["수컷", "암컷"]
    
    @IBOutlet weak var completeBtn: UIButton!
    
    @IBOutlet weak var petName: UITextField!
    @IBOutlet weak var petAge: UITextField!
    @IBOutlet weak var petWeight: UITextField!
    @IBOutlet weak var petGender: UITextField!
    @IBOutlet weak var petSpecies: UITextField!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        createPickerView(tagNo: 2)
        dismissPickerView()
        
        completeBtn.layer.cornerRadius = 30
    }
    
    //하나의 PickerView 안에 몇 개의 선택 가능한 리스트를 표시할 것인지
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    //PickerView에 표시될 항목의 개수를 반환하는 메서드
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderPicker.count
    }

    //PickerView 내에서 특정한 위치(row)를 가리키게 될 때, 그 위치에 해당하는 문자열을 반환하는 메서드
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderPicker[row]
    }

    //PickerView 에서 특정 row가 focus되었을 때 어떤 행동을 할지 정의하는 메서드
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //showPicker 텍스트필드의 텍스트를 선택된 문자열로 바꿈
        petGender.text = genderPicker[row]

    }
    
    //PickerView의 인스턴스를 생성하여, showPicker 텍스트필드를 눌렀을 때 뜨는 뷰(inputView)에 생성한 인스턴스를 연결시키는 메서드
    func createPickerView(tagNo : Int) {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        petGender.inputView = pickerView
    }
    
    //PickerView의 내부를 정의하는 코드와 및 PickerView가 화면에서 사라질 때 동작하는 코드를 정의하는 메서드
    func dismissPickerView() {
            let toolBar = UIToolbar()
            toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(self.ToNewPetSetting))
            toolBar.setItems([button], animated: true)
            toolBar.isUserInteractionEnabled = true
            petGender.inputAccessoryView = toolBar
    }
    
    func DatabaseUpdate(){
        let user = Auth.auth().currentUser
        if let user = user {
        //데이터베이스 연결
        ref = Database.database().reference()
        
        //petcode
        let str = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let size = 5
        let petcode = str.createRandomStr(length: size)
                    
        let key = user.uid
            
        //firebase에서 해당 유저의 petcode를 찾음
            ref.child("users").child("\(key)").child("pets").observeSingleEvent(of: .value) { snapshot in
        let value = snapshot.value as? NSDictionary
        let DBpetcode = value?["pet"] as? String ?? ""
        let DBhowmany = value?["petNum"] as? String ?? "0"
        let howmany = Int(DBhowmany)
            
          
            if let name = self.petName.text, let age = self.petAge.text, let weight = self.petWeight.text, let gender = self.petGender.text, let species = self.petSpecies.text{
                
                
                
                let post = ["PetName":"\(name)", "PetAge":"\(age)","PetWeight":"\(weight)", "PetGender":"\(gender)","PetSpecies":"\(species)","PetCode":"\(petcode)"]
                let childUpdates = ["/pets/\(petcode)/": post]
                
                self.ref.updateChildValues(childUpdates)
                
               
                self.ref.child("pets/\(petcode)/brush teeth/").updateChildValues(["recordNum":0])
                self.ref.child("pets/\(petcode)/feces/").updateChildValues(["recordNum":0])
                self.ref.child("pets/\(petcode)/hospital/").updateChildValues(["recordNum":0])
                self.ref.child("pets/\(petcode)/meals/").updateChildValues(["recordNum":0])
                self.ref.child("pets/\(petcode)/memos/").updateChildValues(["recordNum":0])
               
                self.ref.child("pets/\(petcode)/shower/").updateChildValues(["recordNum":0])
                
                self.ref.child("pets/\(petcode)/walking/").updateChildValues(["recordNum":0])
                self.ref.child("pets/\(petcode)/weight/").updateChildValues(["recordNum":0])
                
                
                    self.ref.child("users/\(key)/pets/").updateChildValues(["pet"+"\(howmany!+1)":"\(petcode)"])
                    //등록된 펫 갯수 증가
                    self.ref.child("users/\(key)/pets/").updateChildValues(["petNum":"\(howmany!+1)"])
              
                
                
                
                let alertVC = UIAlertController(title: "Complete", message: "새로운 반려동물 등록이 완료되었습니다.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "완료", style: .cancel, handler: self.ToMainUserSetting))
                self.present(alertVC, animated: true,completion: nil)
                
            
            }else{
                let alertVC = UIAlertController(title: "Error", message: "정보를 다시 확인해주세요.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "계속", style: .cancel, handler: nil))
                self.present(alertVC, animated: true,completion: nil)
            }
        }
           
    }
 }
    
    //전 페이지인 새로운 반려동물 등록 화면으로 이동
    @objc func ToNewPetSetting(sender:Any){
        self.view.endEditing(true)
    }
    
    //메인 설정화면으로 이동
    func ToMainUserSetting(alert: UIAlertAction!){
        self.presentingViewController?.dismiss(animated: true)
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func newEnroll(_ sender: Any) {
        if self.petName.text != "", self.petAge.text != "", self.petWeight.text != "", self.petGender.text != "", self.petSpecies.text != ""{
        DatabaseUpdate()
        }
        else{
            let alertVC = UIAlertController(title: "Error", message: "정보를 다시 확인해주세요.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "계속", style: .cancel, handler: nil))
            self.present(alertVC, animated: true,completion: nil)
        }
    }
    
}


extension String {
    func createRandomStr(length: Int) -> String { let str = (0 ..< length).map{ _ in self.randomElement()! }
        return String(str)
        
    }
    
}




