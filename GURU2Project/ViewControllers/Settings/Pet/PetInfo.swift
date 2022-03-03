//
//  PetInfo.swift
//  GURU2Project
//
//  Created by 공서은 on 2022/01/27.
//

import UIKit
import Firebase
import FirebaseDatabase
import Photos


class PetInfo:UIViewController,UITableViewDataSource,UITableViewDelegate {
 
    var howmany:Int = 0
    
    var ref: DatabaseReference!
    
    var petData:[PetData] = []
    
    var name:String = ""
    var code:String = ""
    var gender:String = ""
    var species:String = ""
    var age:String = ""
    var weight:String = ""
    var image:String = ""
    
    var sameData:Int = 0
    
    var trow:Int = 0
   
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //데이터베이스 연결
        ref = Database.database().reference()
        
        petData.removeAll()
        DatabaseInfo()
        
        tableView.flashScrollIndicators()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    //사용자가 등록한 반려동물
    func DatabaseInfo(){
        
        let user = Auth.auth().currentUser
        
        if let user = user {
       
                    
        let key = user.uid
            
        
            ref.child("users").child("\(key)").child("pets").observe(DataEventType.value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let DBhowmany = value?["petNum"] as? String ?? ""
                self.howmany = Int(DBhowmany) ?? 0
                
                for i in 0...self.howmany {
                   
                    let DBpetcode = value?["pet"+"\(i)"] as? String ?? "x"
                    if DBpetcode != "x"{
                    self.ref.child("pets").child("\(DBpetcode)").observe(DataEventType.value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    let DBpetname = value?["PetName"] as? String ?? ""
                    let DBpetgender = value?["PetGender"] as? String ?? ""
                    let DBpetage = value?["PetAge"] as? String ?? ""
                    let DBpetspecies = value?["PetSpecies"] as? String ?? ""
                    let DBpetweight = value?["PetWeight"] as? String ?? ""
                    let DBpetc = value?["PetCode"] as? String ?? ""
                    let DBimage = value?["Image"] as? String ?? ""
                    self.petData.append(PetData(DBpetname, DBpetgender, DBpetage, DBpetspecies, DBpetc,DBpetweight,DBimage))
                        self.tableView.reloadData()
                        
                        
                        })
                    }
             
            }
        })
        
        }
        
       
 }
    
    //사용자가 등록한 반려동물 삭제
    func DatabaseDelete(_ row:Int){
        
        let pcode = self.petData[row].pet_code
        let user = Auth.auth().currentUser
        
        if let user = user {
            let key = user.uid
            
            //pets DB에서 삭제
            self.ref.child("pets").child("\(pcode)").removeValue()
       
            //pets DB에서 삭제
            
            self.ref.child("users").child("\(key)").child("pets").observeSingleEvent(of: .value) { snapshot in
                let value = snapshot.value as? NSDictionary
                let DBhowmany = value?["petNum"] as? String ?? ""
                self.howmany = Int(DBhowmany) ?? 0
                let bhowmany = self.howmany
                
                self.ref.child("users/\(key)/pets/").updateChildValues(["petNum":"\(self.howmany-1)"])
                
                self.petData.remove(at: row)
                self.tableView.reloadData()
                
                for i in 0...bhowmany {
                    if self.trow < bhowmany{
                        let bcode = value?["pet"+"\(bhowmany)"] as? String ?? ""
                        self.ref.child("users").child("\(key)").child("pets").child("pet"+"\(bhowmany)").removeValue()
                        self.ref.child("users").child("\(key)").child("pets").updateChildValues(["pet"+"\(bhowmany-1)":bcode])
                        
                    }
                     else{
                         self.ref.child("users").child("\(key)").child("pets").child("pet"+"\(row+1)").removeValue()
                            
                    }
                }
            }
        }
 }

        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return self.petData.count
    }
    
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CustomCell else {
             return UITableViewCell()
         }
        
        
        cell.contentView.backgroundColor = .clear
        /*
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 8, width: self.view.frame.size.width - 20, height: 120))
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.9])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 15
        whiteRoundedView.layer.borderWidth = 2.0
        whiteRoundedView.layer.borderColor = CGColor.init(gray: 0.8, alpha: 0.6)
        
        
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubviewToBack(whiteRoundedView)
        */
        
        tableView.backgroundColor? = UIColor.init(white: 0.8, alpha: 0.3)
        cell.layer.borderWidth = CGFloat(10)
        cell.layer.cornerRadius = 15
        cell.layer.borderColor = tableView.backgroundColor?.cgColor
        
       
       // let background = UIView()
       // background.backgroundColor = .clear
       // cell.selectedBackgroundView = background
        
        var p:Int = 0
        var data = self.petData[indexPath.row]
        if data.pet_name != ""{
            cell.petName.text = data.pet_name
            cell.petGender.text = data.pet_gender
            cell.petSpecies.text = data.pet_species
            cell.petAge.text = data.pet_age
            cell.petCode.text = "등록코드: "+data.pet_code
            
            
            if data.pet_image != ""{
               
            //이미지 넣기
            let imageurl = URL(string: "\(data.pet_image)")!
           
            let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [imageurl], options: nil)

            if let photo = fetchResult.firstObject {
                
                PHImageManager.default().requestImage(for: photo, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) {
                    image, info in

                    cell.petImage.image = image
                }
            }
            }else{
                cell.petImage.image = UIImage(named: "no-image-icon.png")
            }
            
            
            for i in 0...indexPath.row {
                if self.petData[i].pet_code == data.pet_code {
                p += 1
                    if p >= 2 {
                        self.petData.remove(at: i)
                            self.tableView.reloadData()
                    }
                }
            }
            
        } else{
            self.petData.remove(at: indexPath.row)
                self.tableView.reloadData()
        }
           
        
        
        
        return cell
    }
    
    
    
    //UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.height / 6
        
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       /*
        let cell = tableView.cellForRow(at: indexPath)
        //cell.contentView.backgroundColor = .clear
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 8, width: self.view.frame.size.width - 20, height: 120))
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.5, 0, 0, 0.5])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 15
        whiteRoundedView.layer.borderWidth = 2.0
        whiteRoundedView.layer.borderColor = CGColor.init(gray: 0.8, alpha: 0.6)
        
        cell?.contentView.addSubview(whiteRoundedView)
        cell?.contentView.sendSubviewToBack(whiteRoundedView)
        */
        
       // cell?.contentView.subviews(whiteRoundedView)
        
       
        
         tableView.deselectRow(at: indexPath, animated: false)
             
            
        
      //  cell?.contentView.subviews
        let clickdata = petData[indexPath.row]
        self.name = clickdata.pet_name
        self.age = clickdata.pet_age
        self.gender = clickdata.pet_gender
        self.species = clickdata.pet_species
        self.weight = clickdata.pet_weight
        self.image = clickdata.pet_image
        
        code = clickdata.pet_code
        
        
        guard let vc = self.storyboard?.instantiateViewController(identifier: "PetEditView") as? PetEdit else {
                    return
                }
        vc.name = name
        vc.age = age
        vc.code = code
        vc.gender = gender
        vc.species = species
        vc.weight = weight
       
            vc.images = image
        
        
       
        
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    //swipe를 했을때 셀 오른쪽 끝에 나타날 버튼들을 지정
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //오른쪽으로 swipe하면 나타날 delete 버튼
        let btnDelete = UIContextualAction(style: .destructive, title: "Del") { (action, view, completion) in
            
            //데이터상으로 지움
            let row = indexPath.row
            self.trow = row + 1
            self.DatabaseDelete(row)
            
            
            //self.tableView.reloadData()
            completion(true)
            
        }
        btnDelete.backgroundColor = .red
        
        //오른쪽으로 swipe하면 나타날 share 버튼
        let btnEdit = UIContextualAction(style: .normal, title: "Share") { (action, view, completion) in
            let row = indexPath.row
            var objectsToShare = [String]()
            let petcode = self.petData[row].pet_code
          
            
            objectsToShare.append(petcode)
            
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
            
           
            }
            
            
            
        btnEdit.backgroundColor = .gray
        return UISwipeActionsConfiguration(actions: [btnDelete,btnEdit])
    }
    
    
    
    //셀 왼쪽 시작부분에 나타날 버튼들을 지정
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let btnShare = UIContextualAction(style: .normal, title: "Share") { (action, view, completion) in
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [btnShare])
    }
    
    
         
    @IBAction func closeBtn(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
   
}


    
class CustomCell: UITableViewCell {
    
    @IBOutlet weak var petName: UILabel!
    @IBOutlet weak var petGender: UILabel!
    @IBOutlet weak var petSpecies: UILabel!
    @IBOutlet weak var petAge: UILabel!
    @IBOutlet weak var petCode: UILabel!
    @IBOutlet weak var petImage: UIImageView!
    

}



