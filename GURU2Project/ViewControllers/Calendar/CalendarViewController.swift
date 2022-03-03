//
//  CalendarViewController.swift
//  GURU2Project
//
//  Created by 김진원 on 2022/01/20.
//

enum TableDataIndex:Int {
   case RECORDKIND = 0
    case FINDKEY
    case DATADAY
    case DATATIME
    case DATA1
    case DATA2
    case DATA3
    case DATA4
    case DATA5
}

enum DataIndex:Int {
    case DATADAY = 0
    case DATATIME
    case DATA1
    case DATA2
    case DATA3
    case DATA4
    case DATA5
}



import UIKit
import FSCalendar
import FirebaseDatabase
import FirebaseAuth
class CalendarViewController:UIViewController{
    var ref: DatabaseReference! //DB 전체 연결용
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var LabelDate: UILabel! //캘린더에서 날짜 클릭시 계속 변경
    
    @IBOutlet weak var calendar: FSCalendar!
    let dateFormatter = DateFormatter()
    var currentDate:Date!
    var indexOfMonth = 0
    var images = [UIImage(imageLiteralResourceName: "ICON_WALKING.png"),
                  UIImage(imageLiteralResourceName: "ICON_MEAL.png"),
                  UIImage(imageLiteralResourceName: "ICON_SHOWER.png"),
                  UIImage(imageLiteralResourceName: "ICON_BRUSH.png"),
                  UIImage(imageLiteralResourceName: "ICON_FECES.png"),
                  UIImage(imageLiteralResourceName: "ICON_WEIGHT.png"),
                  UIImage(imageLiteralResourceName: "ICON_USER.png"),
                  UIImage(imageLiteralResourceName: "ICON_HOSPITAL.png"),] //Icon image 배열
    
    //User 정보
    var userKey:String!
    var petCode = [String]()
    var petName:String!
    var havePet = false
    let petInfo = ["walking","meals","shower","brush teeth","feces","weight","memos","hospital"]
    
    var haveInfo = [Bool](repeating: false, count: 50)
    var arr : [[String]] = Array(repeating: [String](), count: 50)
    var dayInfo = Array<Array<String>>()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //user 키가 있는 지 확인
        if let user = Auth.auth().currentUser?.uid {
            self.userKey = user
        }

        
        //DB
        InitDB()

        
        //캘린더
        calendar.delegate = self
        calendar.dataSource = self
        currentDate = Date()
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        // 스와이프 스크롤 작동 여부 ( 활성화하면 좌측 우측 상단에 다음달 살짝 보임, 비활성화하면 사라짐 )
        calendar.scrollEnabled = false
        
        dateFormatter.dateFormat = "MM"
        indexOfMonth = Int(dateFormatter.string(from: currentDate))!
        
        //calendar.scrollEnabled = false
        
        //기록 내역
        dateFormatter.dateFormat = "MM월 dd일" //데이터 포맷 설정
        LabelDate.text = dateFormatter.string(from: Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //print("calendar appear")
        
        
        //user 키가 있는 지 확인
        if let user = Auth.auth().currentUser?.uid {
            self.userKey = user
            InitPet()
        }
        
        
        //self.tableView.reloadData()
        //self.calendar.reloadData()
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //DB 접속해서 user 정보 가져오기
    func InitDB(){
        ref = Database.database().reference() //데이터베이스 연결
        
        guard let key = ref.child("users").childByAutoId().key else { return }
        //InitPet()
    }
    

    
    func InitPet(){
        //pet code 찾기
        //let refUser = ref.child("users/\(Auth.auth().currentUser)/pets")
        petCode = [String]()
        let refUser = ref.child("users/\(self.userKey!)/pets")
        refUser.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let petNum = Int(value["petNum"] as! String)!
                
                //pet이 있다면
                if petNum > 0 {
                    
                    self.havePet = true
                    //등록한 pet의 갯수 만큼
                    for number in 0..<petNum {
                        
                        //pet code 가져오기
                        let findkey = String(format: "pet%d", number+1)
                        if let petcode = value[findkey] as? String{
                            self.petCode.append(petcode)
                        }

                        
                    } // petcode 다 찾음
                    //펫 정보 가져오기
                    self.findPetInfo()
                    
                }
            }


        }
    }
    
    func findPetInfo(){

        arr = Array(repeating: [String](), count: 50)
        self.haveInfo = [Bool](repeating: false, count: 50)
        dayInfo = Array<Array<String>>()
        for code in petCode {
            print(code)
            
            //pet 이름 확인
            let path = "pets/\(code)"
            let refUser = ref.child(path)
            refUser.observeSingleEvent(of: .value) { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let petName = value?["PetName"] as! String
                self.petName = petName
            }
            
            //pet 정보 불러오기
            for info in petInfo {
                let path = "pets/\(code)/\(info)"
                let refUser = ref.child(path)
                refUser.observeSingleEvent(of: .value) { [self] (snapshot) in
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
                                    
                                    let dateString = String(record[0])
                                    let date:Date = self.dateFormatter.date(from: dateString)!
                                    
                                    self.dateFormatter.dateFormat = "YYYY-MM" //데이터 포맷 설정
                                    
                                    if self.dateFormatter.string(from: date) == self.dateFormatter.string(from: self.currentDate){

                                        self.dateFormatter.dateFormat = "dd" //데이터 포맷 설정
                                        let index = Int(self.dateFormatter.string(from: date))
                                        self.haveInfo[index!] = true
                                        self.arr[index!].append(info + "," + findkey + "," + data) //데이터 추가

                                    }

                                }

                                
                            } // record 가져오기
                        }
                        
                        //
                        self.calendar(self.calendar, didSelect: self.currentDate, at: .current)
                        self.calendar.reloadData()
                    }
                }
            }
            
        }
    }
    
    func removeDB(index:Int){
        let dayDetailInfo = self.dayInfo[index]
        let info = dayDetailInfo[TableDataIndex.RECORDKIND.rawValue]
        
        let path = "pets/\(self.petCode[0])/\(info)"
        let refUser = ref.child(path)
        
        var recordKey = dayDetailInfo[TableDataIndex.FINDKEY.rawValue]
        if let recordIndex = Int(String(recordKey[recordKey.index(recordKey.endIndex, offsetBy: -1)])){
            
            
            refUser.observeSingleEvent(of: .value) { [self] (snapshot) in

                if let value = snapshot.value as? NSDictionary{

                    let recordNum = value["recordNum"] as! Int
                    print(recordNum)
                    for number in recordIndex..<recordNum {

                            //pet code 가져오기
                            let findkey = String(format: "record%d", number+1)
                            let recordName = String(format: "record%d", number)
                            if let data = value[findkey] as? String {

                                self.ref.child("\(path)").updateChildValues([recordName:data])

                            }


                        } // record 데이터 수정하기
                    
                    //마지막 데이터 삭제
                    let recordName = String(format: "record%d", recordNum)
                    self.ref.child("\(path)").updateChildValues([recordName:nil])
                    
                    //record 갯수 수정
                    self.ref.child("\(path)").updateChildValues(["recordNum":recordNum - 1])


                    self.findPetInfo()
                    
                }
            }
        }
    }
    
    @IBAction func btnAdd(_ sender: Any) {
        print("Add")
        performSegue(withIdentifier: "presentToRecord", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let secondVC = segue.destination as? CalendarRecordViewController else {return}
        
        //second 뷰가 존재하면 데이터를 전달한다
        secondVC.currentDate = self.currentDate
        secondVC.petCode = self.petCode
    }
    
    //산책 수정
    func showWalking(index:Int){
        let dayDetailInfo = dayInfo[index]
        
        if let WalkingVC = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarRecordWalking") as? CalendarRecordWalkingViewController {
            
            WalkingVC.view.frame = UIApplication.shared.windows[0].frame
            WalkingVC.didMove(toParent: self)
            WalkingVC.modalPresentationStyle = .overCurrentContext
            
            WalkingVC.bAdd = false
            
            self.present(WalkingVC, animated: true, completion: nil) //등록창 띄우기
            
            WalkingVC.date = self.currentDate
            WalkingVC.petcode = self.petCode[0]
            
            WalkingVC.textMemo.text = dayDetailInfo[TableDataIndex.DATA4.rawValue]
            WalkingVC.textDistance.text = dayDetailInfo[TableDataIndex.DATA2.rawValue]
            WalkingVC.textCal.text = dayDetailInfo[TableDataIndex.DATA3.rawValue]
            WalkingVC.recordKey = dayDetailInfo[TableDataIndex.FINDKEY.rawValue]
            
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd "
            let startTime = format.string(from: currentDate) + dayDetailInfo[TableDataIndex.DATATIME.rawValue]
            let stopTime = format.string(from: currentDate) + dayDetailInfo[TableDataIndex.DATA1.rawValue]

            format.dateFormat = "yyyy-MM-dd HH:mm"
            WalkingVC.startTime.date = format.date(from: startTime)!
            WalkingVC.stopTime.date = format.date(from: stopTime)!
            
            WalkingVC.calendarView = self
        }
    }
    
    //식사 수정
    func showMeal(index:Int){
        let dayDetailInfo = dayInfo[index]
        
        if let MealVC = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarRecordMeal") as? CalendarRecordMealViewController {
            
            MealVC.view.frame = UIApplication.shared.windows[0].frame
            MealVC.didMove(toParent: self)
            MealVC.modalPresentationStyle = .overCurrentContext
            
            MealVC.bAdd = false
            
            MealVC.date = self.currentDate
            MealVC.petcode = self.petCode[0]
            
            MealVC.mealOption = dayDetailInfo[TableDataIndex.DATA1.rawValue]
            MealVC.textMeal.text = dayDetailInfo[TableDataIndex.DATA2.rawValue]
            MealVC.textMemo.text = dayDetailInfo[TableDataIndex.DATA3.rawValue]
            MealVC.recordKey = dayDetailInfo[TableDataIndex.FINDKEY.rawValue]
            
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd "
            let recordTime = format.string(from: currentDate) + dayDetailInfo[TableDataIndex.DATATIME.rawValue]

            format.dateFormat = "yyyy-MM-dd HH:mm"
            MealVC.recordTime.date = format.date(from: recordTime)!
            
            MealVC.calendarView = self
            
            switch MealVC.mealOption {
            case "아침" :
                MealVC.indexOfMealOption = 0
                break
            case "점심" :
                MealVC.indexOfMealOption = 1
                break
            case "저녁" :
                MealVC.indexOfMealOption = 2
                break
            case "간식" :
                MealVC.indexOfMealOption = 3
                break
            default:
                print(MealVC.mealOption)
                break
                
            }
            
            self.present(MealVC, animated: true, completion: nil) //등록창 띄우기
        }
        
    }
    
    //샤워 수정
    func showShower(index:Int){
        let dayDetailInfo = dayInfo[index]
        
        if let ShowerVC = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarRecordShower") as? CalendarRecordShowerViewController {
            
            ShowerVC.view.frame = UIApplication.shared.windows[0].frame
            ShowerVC.didMove(toParent: self)
            ShowerVC.modalPresentationStyle = .overCurrentContext
            
            ShowerVC.bAdd = false
            
            self.present(ShowerVC, animated: true, completion: nil) //등록창 띄우기
            
            ShowerVC.date = self.currentDate
            ShowerVC.petcode = self.petCode[0]
            
            ShowerVC.textMemo.text = dayDetailInfo[TableDataIndex.DATA1.rawValue]
            ShowerVC.recordKey = dayDetailInfo[TableDataIndex.FINDKEY.rawValue]
            
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd "
            let recordTime = format.string(from: currentDate) + dayDetailInfo[TableDataIndex.DATATIME.rawValue]

            format.dateFormat = "yyyy-MM-dd HH:mm"
            ShowerVC.recordTime.date = format.date(from: recordTime)!
            
            ShowerVC.calendarView = self
        }
    }
    
    //양치 수정
    func showBrushTeeth(index:Int){
        let dayDetailInfo = dayInfo[index]
        
        if let BrushTeethVC = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarRecordBrushTeeth") as? CalendarRecordBrushTeethViewController {
            
            BrushTeethVC.view.frame = UIApplication.shared.windows[0].frame
            BrushTeethVC.didMove(toParent: self)
            BrushTeethVC.modalPresentationStyle = .overCurrentContext
            
            BrushTeethVC.bAdd = false
            
            self.present(BrushTeethVC, animated: true, completion: nil) //등록창 띄우기
            
            BrushTeethVC.date = self.currentDate
            BrushTeethVC.petcode = self.petCode[0]
            
            BrushTeethVC.textMemo.text = dayDetailInfo[TableDataIndex.DATA1.rawValue]
            BrushTeethVC.recordKey = dayDetailInfo[TableDataIndex.FINDKEY.rawValue]
            
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd "
            let recordTime = format.string(from: currentDate) + dayDetailInfo[TableDataIndex.DATATIME.rawValue]

            format.dateFormat = "yyyy-MM-dd HH:mm"
            BrushTeethVC.recordTime.date = format.date(from: recordTime)!
            
            BrushTeethVC.calendarView = self
        }
    }
    
    //대소변 수정
    func showFeces(index:Int){
        let dayDetailInfo = dayInfo[index]
        
        if let FecesVC = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarRecordFeces") as? CalendarRecordFecesViewController {
            
            FecesVC.view.frame = UIApplication.shared.windows[0].frame
            FecesVC.didMove(toParent: self)
            FecesVC.modalPresentationStyle = .overCurrentContext
            
            FecesVC.bAdd = false
            
            
            
            FecesVC.date = self.currentDate
            FecesVC.petcode = self.petCode[0]
            
            FecesVC.fecesOption = dayDetailInfo[TableDataIndex.DATA1.rawValue]
            FecesVC.textMemo.text = dayDetailInfo[TableDataIndex.DATA2.rawValue]
            FecesVC.recordKey = dayDetailInfo[TableDataIndex.FINDKEY.rawValue]
            
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd "
            let recordTime = format.string(from: currentDate) + dayDetailInfo[TableDataIndex.DATATIME.rawValue]

            format.dateFormat = "yyyy-MM-dd HH:mm"
            FecesVC.recordTime.date = format.date(from: recordTime)!
            
            FecesVC.calendarView = self
            
            switch FecesVC.fecesOption {
            case "소변" :
                FecesVC.indexOfFecesOption = 0
                break
            case "대변" :
                FecesVC.indexOfFecesOption = 1
                break
            default:
                print(FecesVC.fecesOption)
                break
            }
            
            self.present(FecesVC, animated: true, completion: nil) //등록창 띄우기
        }
    }
    
    //체중 수정
    func showWeight(index:Int){
        let dayDetailInfo = dayInfo[index]
        
        if let WeightVC = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarRecordWeight") as? CalendarRecordWeightViewController {
            
            WeightVC.view.frame = UIApplication.shared.windows[0].frame
            WeightVC.didMove(toParent: self)
            WeightVC.modalPresentationStyle = .overCurrentContext
            
            WeightVC.bAdd = false
            
            self.present(WeightVC, animated: true, completion: nil) //등록창 띄우기
            
            WeightVC.date = self.currentDate
            WeightVC.petcode = self.petCode[0]
            
            WeightVC.textMemo.text = dayDetailInfo[TableDataIndex.DATA2.rawValue]
            WeightVC.textWeight.text = dayDetailInfo[TableDataIndex.DATA1.rawValue]
            WeightVC.recordKey = dayDetailInfo[TableDataIndex.FINDKEY.rawValue]
            
            WeightVC.calendarView = self
        }
    }
    
    //직접 입력 수정
    func showMemo(index:Int){
        let dayDetailInfo = dayInfo[index]
        
        if let MemoVC = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarRecordMemo") as? CalendarRecordMemoViewController {
            
            MemoVC.view.frame = UIApplication.shared.windows[0].frame
            MemoVC.didMove(toParent: self)
            MemoVC.modalPresentationStyle = .overCurrentContext
            
            MemoVC.bAdd = false
            
            self.present(MemoVC, animated: true, completion: nil) //등록창 띄우기
            
            MemoVC.date = self.currentDate
            MemoVC.petcode = self.petCode[0]
            
            MemoVC.textMemo.text = dayDetailInfo[TableDataIndex.DATA1.rawValue]
            MemoVC.recordKey = dayDetailInfo[TableDataIndex.FINDKEY.rawValue]
            
            MemoVC.calendarView = self
        }
    }
    
    //병원 수정
    func showHospital(index:Int){
        let dayDetailInfo = dayInfo[index]
        
        if let HospitalVC = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarRecordHospital") as? CalendarRecordHospitalRecord {
            
            HospitalVC.view.frame = UIApplication.shared.windows[0].frame
            HospitalVC.didMove(toParent: self)
            HospitalVC.modalPresentationStyle = .overCurrentContext
            
            HospitalVC.bAdd = false
            
            
            
            HospitalVC.date = self.currentDate
            HospitalVC.petcode = self.petCode[0]
            
            HospitalVC.hospitalOptionString = dayDetailInfo[TableDataIndex.DATA1.rawValue]
            HospitalVC.textMemo.text = dayDetailInfo[TableDataIndex.DATA2.rawValue]
            HospitalVC.recordKey = dayDetailInfo[TableDataIndex.FINDKEY.rawValue]
            
            HospitalVC.calendarView = self
            
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd "
            let recordTime = format.string(from: currentDate) + dayDetailInfo[TableDataIndex.DATATIME.rawValue]

            format.dateFormat = "yyyy-MM-dd HH:mm"
            HospitalVC.datePicker.date = format.date(from: recordTime)!
            
            switch HospitalVC.hospitalOptionString {
            case "진료" :
                HospitalVC.indexOfOption = 0
                break
            case "검진" :
                HospitalVC.indexOfOption = 1
                break
            case "기타" :
                HospitalVC.indexOfOption = 2
                break
            default:
                print(HospitalVC.hospitalOptionString)
                break
            }
            
            self.present(HospitalVC, animated: true, completion: nil) //등록창 띄우기
        }
            
        
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
        self.findPetInfo()
        self.calendar.select(currentDate, scrollToDate: true)
    }
    
    @IBAction func goBefore(_ sender: UIButton) {
        
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
         self.findPetInfo()
         self.calendar.select(currentDate, scrollToDate: true)
    }
    
    

}

extension CalendarViewController:FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance{
    
    // 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        self.currentDate = date
        dateFormatter.dateFormat = "MM월 dd일" //데이터 포맷 설정
        LabelDate.text = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "dd" //데이터 포맷 설정
        let index = Int(dateFormatter.string(from: date))
        
        self.dayInfo = Array<Array<String>>()
        
        if self.haveInfo[index!]{
            //print(self.arr[index!])

            for data in self.arr[index!] {

                //데이터를 string array로 변경
                let record = data.split(separator: ",")
                var dataInfoArray = Array<String>()
                for count in record {
                    dataInfoArray.append(String(count))
                }
                self.dayInfo.append(dataInfoArray)
            }

        }
        
        self.tableView.reloadData()
        
    }
    
    // 날짜 선택 해제 시 콜백 메소드
    public func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
    }
    
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

extension CalendarViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dayInfo.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell()
        //print("\(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarcell", for: indexPath) as! CalendarCell //lottocell의 타입으로
        
        let dayDetailInfo = dayInfo[indexPath.row]
        
        
        var textKind = "오류" //정보 종류
        var textContent = " " //내용
        let textTime = dayDetailInfo[TableDataIndex.DATATIME.rawValue]
        
        switch dayDetailInfo[TableDataIndex.RECORDKIND.rawValue] {
        case "weight" :
            textKind = "무게"
            if let fWeight = Float(dayDetailInfo[TableDataIndex.DATA1.rawValue]){
                textContent = String(format: "%0.2f kg", fWeight)
            }
            cell.imageView?.image = self.images[5]
            break
        case "memos" :
            textKind = "메모"
            textContent = dayDetailInfo[TableDataIndex.DATA1.rawValue]
            cell.imageView?.image = self.images[6]
            break
        case "brush teeth" :
            textKind = "양치"
            textContent = dayDetailInfo[TableDataIndex.DATA1.rawValue]
            cell.imageView?.image = self.images[3]
            break
        case "feces" :
            textKind = "대소변"
            textContent = dayDetailInfo[TableDataIndex.DATA1.rawValue]
            cell.imageView?.image = self.images[4]
            break
        case "shower" :
            textKind = "샤워"
            textContent = dayDetailInfo[TableDataIndex.DATA1.rawValue]
            cell.imageView?.image = self.images[2]
            break
        case "walking" :
            textKind = "산책"
            
            //산책 시간 계산
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd "
            let startTime = format.string(from: currentDate) + dayDetailInfo[TableDataIndex.DATATIME.rawValue]
            let stopTime = format.string(from: currentDate) + dayDetailInfo[TableDataIndex.DATA1.rawValue]

            
            format.dateFormat = "yyyy-MM-dd HH:mm"
            let startDate = format.date(from: startTime)!
            let stopDate = format.date(from: stopTime)!

            
            var useTime = Int(stopDate.timeIntervalSince(startDate)) //차이를 초로 반환
            textContent = String(format: "%d 분 ,", useTime/60) + dayDetailInfo[TableDataIndex.DATA2.rawValue] + " km"
            
            cell.imageView?.image = self.images[0]
            break
        case "meals" :
            textKind = dayDetailInfo[TableDataIndex.DATA1.rawValue]
            textContent = dayDetailInfo[TableDataIndex.DATA2.rawValue]
            cell.imageView?.image = self.images[1]
            break
        case "hospital" :
            textKind = dayDetailInfo[TableDataIndex.DATA1.rawValue]
            textContent = dayDetailInfo[TableDataIndex.DATA2.rawValue]
            cell.imageView?.image = self.images[7]
            break
        default:
            break
        }
        
        cell.LabelKind.text = textKind
        cell.LabelContent.text = textContent
        cell.LabelTime.text = textTime
        cell.layer.cornerRadius = 13
        
        return cell
    }
    
    //셀 왼쪽 시작에 나타날 버튼들
   func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       let btnDel =  UIContextualAction(style: .destructive, title: "Del") { (action,view,completation) in
           
           
           let editAlert = UIAlertController(title: "삭제", message: "삭제하면 복구할 수 없습니다.\n삭제하시겠습니까?\n(해당 내용을 공유하는 모든 사용자에게 삭제됩니다.)", preferredStyle: .alert) //pop-up]
           editAlert.addAction(UIAlertAction(title: "예", style: .default, handler: { (action) in
               
               //삭제하기
               self.removeDB(index: indexPath.row)
               
           }))
           editAlert.addAction(UIAlertAction(title: "아니요", style: .cancel, handler: nil))
           
           self.present(editAlert, animated: true, completion: nil)
           
           completation(true)
       }
       
       return UISwipeActionsConfiguration(actions: [btnDel])
    }
    
    //셀 오른쪽 끝에 나타날 버튼
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let btnEdit = UIContextualAction(style: .normal, title: "Edit") { (Action, view, completation) in
            
            let dayDetailInfo = self.dayInfo[indexPath.row]
            
            switch dayDetailInfo[TableDataIndex.RECORDKIND.rawValue] {
            case "weight" :
                self.showWeight(index: indexPath.row)
                break
            case "memos" :
                self.showMemo(index: indexPath.row)
                break
            case "brush teeth" :
                self.showBrushTeeth(index: indexPath.row)
                break
            case "feces" :
                self.showFeces(index: indexPath.row)
                break
            case "shower" :
                self.showShower(index: indexPath.row)
                break
            case "walking" :
                self.showWalking(index: indexPath.row)
                break
            case "meals" :
                self.showMeal(index: indexPath.row)
                break
            case "hospital" :
                self.showHospital(index: indexPath.row)
                break
            default:
                break
            }
            
            completation(true)
        }
        
        btnEdit.backgroundColor = .blue //UIColor.black 이랑 동일함
        return UISwipeActionsConfiguration(actions: [btnEdit])
    }

}
