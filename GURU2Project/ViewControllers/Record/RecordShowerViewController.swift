//
//  RecordShowerViewController.swift
//  GURU2Project
//
//  Created by 김진원 on 2022/01/24.
//

import UIKit
import FSCalendar
import FirebaseDatabase
import FirebaseAuth
class RecordShowerViewController:UIViewController{
    
    @IBOutlet weak var calendar: FSCalendar!
    
    //User 정보
    var petCode = [String]()
    var petName:String!
    var havePet = false
    var userKey:String!
    
    //DB 데이터
    var mealData = [DBMealData]()
    var ref:DatabaseReference!
    let dateFormatter = DateFormatter()
    
    //날짜 정보
    var currentDate:Date!
    var indexOfMonth = 0
    
    var haveInfo = [Bool](repeating: false, count: 50)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentDate = Date()
        dateFormatter.dateFormat = "MM"
        indexOfMonth = Int(dateFormatter.string(from: currentDate))!
        
        //데이터베이스 연결
        ref = Database.database().reference()
        guard let key = ref.child("users").childByAutoId().key else { return }
        
        //user 키가 있는 지 확인
        if let user = Auth.auth().currentUser?.uid {
            self.userKey = user
            
            //pet 정보 가져오기
            InitPet()
        }
        
        
        
        
        
        
        //event 표시할 때 색상
        calendar.appearance.eventDefaultColor = UIColor.red
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        // 스와이프 스크롤 작동 여부 ( 활성화하면 좌측 우측 상단에 다음달 살짝 보임, 비활성화하면 사라짐 )
        calendar.scrollEnabled = false
    }
    
    func InitPet(){
        //pet code 찾기
        let refUser = ref.child("users/\(self.userKey!)/pets")
        refUser.observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let petNum = Int(value!["petNum"] as! String)!
            
            //pet이 있다면
            if petNum > 0 {
                
                self.havePet = true
                //등록한 pet의 갯수 만큼
                for number in 0..<petNum {
                    
                    //pet code 가져오기
                    let findkey = String(format: "pet%d", number+1)
                    if let petcode = value?[findkey] as? String{
                        self.petCode.append(petcode)
                    }

                    
                } // petcode 다 찾음
                
                //데이터 검색 및 분석
                self.findData()
            }

        }
    }
    
    func findData(){
        let path = "pets/\(self.petCode[0])/shower"
        let refUser = self.ref.child(path)
        
        haveInfo = [Bool](repeating: false, count: 50) //초기화
        
        refUser.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary{
                
                let recordNum = value["recordNum"] as! Int

                //  정보가 있다면
                if recordNum > 0 {
                    
                    for number in 0..<recordNum {
                        
                        //pet code 가져오기
                        let findkey = String(format: "record%d", number+1)
                        if let data = value[findkey] as? String{
                            
                            self.dateFormatter.dateFormat = "YYYY-MM-dd" //데이터 포맷 설정
                            let record = data.split(separator: ",") //데이터 나누기
                            
                            let dateString = String(record[DataIndex.DATADAY.rawValue])
                            let date:Date = self.dateFormatter.date(from: dateString)! //db에 기록된 날짜
                            
                            self.dateFormatter.dateFormat = "yyyy-MM" //데이터 포맷 설정
                            
                            //원하는 달의 데이터라면
                            if self.dateFormatter.string(from: date) == self.dateFormatter.string(from: self.currentDate){
                                self.dateFormatter.dateFormat = "dd" //데이터 포맷 설정
                                let index = Int(self.dateFormatter.string(from: date))
                                self.haveInfo[index!] = true
                                
                            }

                        }

                        
                    } // record 가져오기
                }
                print("finish")
                self.calendar.reloadData()
            }
            
            }
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        let form = DateFormatter()
         form.dateFormat = "YYYY"
         let year = Int(form.string(from: self.currentDate))!
         var day = ""
         indexOfMonth -= 1
         
         print(year)
         
         if indexOfMonth < 1 {
             day = String(format: "%04d-12-04", year - 1) //1일로 하면 제대로 표기안되는 경우가 있음
             indexOfMonth = 12
             
         } else {
             day = String(format: "%04d-%02d-04", year,indexOfMonth) //1일로 하면 제대로 표기안되는 경우가 있음
         }
         print(day)
         form.dateFormat = "yyyy-MM-dd"
         self.currentDate = form.date(from:day)
         self.findData()
         self.calendar.select(currentDate, scrollToDate: true)
    }
    @IBAction func goNext(_ sender: UIButton) {
        let form = DateFormatter()
         form.dateFormat = "YYYY"
         let year = Int(form.string(from: self.currentDate))!
         var day = ""
         indexOfMonth += 1
         
         print(year)
         
         if indexOfMonth > 12 {
             day = String(format: "%04d-01-04", year + 1) //1일로 하면 제대로 표기안되는 경우가 있음
             indexOfMonth = 1
             
         } else {
             day = String(format: "%04d-%02d-04", year,indexOfMonth) //1일로 하면 제대로 표기안되는 경우가 있음
         }
         print(day)
         form.dateFormat = "yyyy-MM-dd"
         self.currentDate = form.date(from:day)
         self.findData()
         self.calendar.select(currentDate, scrollToDate: true)

    }
}

extension RecordShowerViewController:FSCalendarDelegate,FSCalendarDataSource {
   
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        dateFormatter.dateFormat = "MM" //데이터 포맷 설정
        let month = Int(dateFormatter.string(from: date))!
        let curMonth = Int(dateFormatter.string(from: self.currentDate))!
        
        if month == curMonth {
            dateFormatter.dateFormat = "dd" //데이터 포맷 설정
            let index = Int(dateFormatter.string(from: date))
            if self.haveInfo[index!] {
                return 1
            }
        }
        
        return 0
    }

}

