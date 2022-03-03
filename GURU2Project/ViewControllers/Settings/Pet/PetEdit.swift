//
//  PetEdit.swift
//  GURU2Project
//
//  Created by 공서은 on 2022/01/28.
//

import UIKit
import Firebase
import FirebaseDatabase
import Photos

class PetEdit:UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var completeBtn: UIButton!
    
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var petName: UITextField!
    @IBOutlet weak var petAge: UITextField!
    @IBOutlet weak var petWeight: UITextField!
    @IBOutlet weak var petGender: UITextField!
    @IBOutlet weak var petSpecies: UITextField!
    
    let genderPicker = ["수컷", "암컷"]
    
    var imageurl:URL = URL(fileURLWithPath: "")
    
    let alertController = UIAlertController(title: "올릴 방식을 선택하세요", message: "사진 찍기 또는 앨범에서 선택", preferredStyle: .actionSheet)
    
    let imagePickerController = UIImagePickerController()
    
    var name:String = ""
    var code:String = ""
    var gender:String = ""
    var species:String = ""
    var age:String = ""
    var weight:String = ""
    var images:String = ""
    
    var ref: DatabaseReference!
    
    var petData:[PetData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        petName.text = name
        petAge.text = age
        petGender.text = gender
        petSpecies.text = species
        petWeight.text = weight
        
        createPickerView(tagNo: 2)
        dismissPickerView()
        
        petName.clearButtonMode = .whileEditing
        petAge.clearButtonMode = .whileEditing
        petGender.clearButtonMode = .whileEditing
        petWeight.clearButtonMode = .whileEditing
        petSpecies.clearButtonMode = .whileEditing
        
        addGestureRecognizer()
        enrollAlertEvent()
        imageUpload()
        
        completeBtn.layer.cornerRadius = 30
        completeBtn.setTitleColor(.gray, for: .highlighted)
        
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
        let button = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(self.ToPetSetting))
            toolBar.setItems([button], animated: true)
            toolBar.isUserInteractionEnabled = true
            petGender.inputAccessoryView = toolBar
    }
    
    //반려동물 정보 수정
    func petInfo_edit(){
        
        let user = Auth.auth().currentUser
        if let user = user {
            ref = Database.database().reference()
            if petName.text != "", petAge.text != "", petWeight.text != "", petGender.text != "", petSpecies.text != "" {
                if let pname = petName.text, let page = petAge.text, let pweight = petWeight.text, let pgender = petGender.text, let pspecies = petSpecies.text{
        //키값을 받음
        let key = user.uid
        
       
            ref.child("pets").child("\(self.code)").observeSingleEvent(of: .value) {snapshot in
            let value = snapshot.value as? NSDictionary
            
            
            self.ref.child("pets/\(self.code)/").updateChildValues(["PetName":"\(pname)"])
            self.ref.child("pets/\(self.code)/").updateChildValues(["PetGender":"\(pgender)"])
            self.ref.child("pets/\(self.code)/").updateChildValues(["PetWeight":"\(pweight)"])
            self.ref.child("pets/\(self.code)/").updateChildValues(["PetAge":"\(page)"])
                self.ref.child("pets/\(self.code)/").updateChildValues(["Image":"\(self.imageurl)"])
            self.ref.child("pets/\(self.code)/").updateChildValues(["PetSpecies":"\(pspecies)"])
                }
            let alertVC = UIAlertController(title: "Complete", message: "정보 수정이 완료되었습니다.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "완료", style: .cancel, handler: self.MoveToPetSettingHandler))
            self.present(alertVC, animated: true,completion: nil)
                    
          }
            } else{
                let alertVC = UIAlertController(title: "Error", message: "정보가 다릅니다.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "계속", style: .cancel, handler: nil))
                self.present(alertVC, animated: true,completion: nil)
            }
        }
     }
    
    func imageUpload(){
        
        if images == ""{
            //default 사진
            images = "assets-library://asset/asset.JPG?id=0B034B76-5995-438A-81DD-102D26C83AB0&ext=JPG"
                
        }
                let imageurl = URL(string: "\(images)")!
        
                let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [imageurl], options: nil)

                if let photo = fetchResult.firstObject {
                    
                    PHImageManager.default().requestImage(for: photo, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) {
                        image, info in

                        self.petImage.image = image
                    }
                }
    }
    
    
    func openLibrary(){

        self.imagePickerController.delegate = self
        self.imagePickerController.sourceType = .photoLibrary
        present(self.imagePickerController, animated: true, completion: nil)
    }

    func openCamera(){
    
        self.imagePickerController.delegate = self
        self.imagePickerController.sourceType = .camera 
        present(self.imagePickerController, animated: true, completion: nil)

    }
    
    //이미지뷰를 클릭했을때 나타나는 창
    func enrollAlertEvent() {
            let photoLibraryAlertAction = UIAlertAction(title: "사진앨범에서 가져오기", style: .default) {
                (action) in
                self.openLibrary()
            }
            let cameraAlertAction = UIAlertAction(title: "카메라 열기", style: .default) {(action) in
                self.openCamera()
            }
            let cancelAlertAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            self.alertController.addAction(photoLibraryAlertAction)
            self.alertController.addAction(cameraAlertAction)
            self.alertController.addAction(cancelAlertAction)
            guard let alertControllerPopoverPresentationController
                    = alertController.popoverPresentationController
            else {return}
            
    }
    
    
    //이미지 뷰 클릭
    func addGestureRecognizer() {
            let tapGestureRecognizer
      = UITapGestureRecognizer(target: self,
                               action: #selector(self.tappedUIImageView(_:)))
            self.petImage.addGestureRecognizer(tapGestureRecognizer)
            self.petImage.isUserInteractionEnabled = true
    }
    
    @objc func tappedUIImageView(_ gesture: UITapGestureRecognizer) {
            self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func ToPetSetting(sender:Any){
        self.view.endEditing(true)
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    @IBAction func editBtn(_ sender: Any) {
        petInfo_edit()
    }
    
    func MoveToPetSettingHandler(alert: UIAlertAction!) {
        petData.removeAll()
        
        let preVC = self.presentingViewController
        
        guard let vc = preVC as? PetInfo else {
            return
        }
        vc.petData = self.petData
        vc.DatabaseInfo()
        vc.tableView.reloadData()
        self.presentingViewController?.dismiss(animated: true)
        
        
    }
}


extension PetEdit : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        if let imageurl01 = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
            imageurl = imageurl01
            print(imageurl01)
        
        }
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            petImage.image = image
        
        }
       //imageDBUpdate(imageurl)
        picker.dismiss(animated: true, completion: nil)
        
    }

   

}
