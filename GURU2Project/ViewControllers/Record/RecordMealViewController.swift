//
//  RecordMealViewController.swift
//  GURU2Project
//
//  Created by 김진원 on 2022/01/24.
//

struct DBMealData {
    var recordDate:String //날짜
    var mealCnt:Int //식사 횟수
    var snackCnt:Int //간식 횟수
}

import UIKit
import FirebaseDatabase
import Charts
import FirebaseAuth
class RecordMealViewController:UIViewController{
    
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
    var indexOfMonth:Int!
    
    @IBOutlet weak var ChartView: LineChartView!
    @IBOutlet weak var LabelMonth: UILabel!
    @IBOutlet weak var LabelMeal: UILabel!
    @IBOutlet weak var LabelSnack: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ChartView.noDataText = "데이터가 없습니다."
        ChartView.noDataFont = .systemFont(ofSize: 20)
        ChartView.noDataTextColor = .lightGray
        
        currentDate = Date()
        self.dateFormatter.dateFormat = "MM" //데이터 포맷 설정
        indexOfMonth = Int(self.dateFormatter.string(from: currentDate))
        
        self.LabelMonth.text = String(format: "%d월", indexOfMonth)
        
        //user 키가 있는 지 확인
        if let user = Auth.auth().currentUser?.uid {
            self.userKey = user
        }
        
        
        //데이터베이스 연결
        ref = Database.database().reference()
        guard let key = ref.child("users").childByAutoId().key else { return }
        
        //pet 정보 가져오기
        InitPet()
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
        
        mealData = [DBMealData]() //데이터 초기화
        
        let path = "pets/\(self.petCode[0])/meals"
        let refUser = self.ref.child(path)
        
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
                            
                            //현재 원하는 월의 데이터라면
                            print(self.dateFormatter.string(from: self.currentDate))
                            
                            
                            if self.dateFormatter.string(from: date) == self.dateFormatter.string(from: self.currentDate){
                                
                                //데이터를 string array로 변경
                                let record = data.split(separator: ",")
                                var dataInfoArray = Array<String>()
                                for count in record {
                                    dataInfoArray.append(String(count))
                                }
                                
                                let dayDetailInfo = dataInfoArray
                                
                                //데이터 분석해서 정리하기
                                
                                //식사인지 산책인지 저장하기
                                let mealKind = dayDetailInfo[DataIndex.DATA1.rawValue]
                                
                                
                                //데이터가 기록되어 있는지 확인하기
                                var findSameData = false
                                let format = DateFormatter()
                                self.dateFormatter.dateFormat = "dd" //데이터 포맷 설정
                                let recordDay = self.dateFormatter.string(from: date) //DB 에 저장되어 있는 년도 날짜
                                
                                if self.mealData != nil {
                                    
                                    print(self.mealData.count)
                                    
                                    for cnt in 0..<self.mealData.count {
                                        
                                        format.dateFormat = "yyyy-MM-dd"
                                        let db = self.mealData[cnt]
                                        let arrayDate = format.date(from: db.recordDate)
                                        let arrayDay = self.dateFormatter.string(from: arrayDate!)

                                        if arrayDay == recordDay {
                                            findSameData = true
                                            
                                            if mealKind == "간식" {
                                                self.mealData[cnt].snackCnt += 1
                                            } else {
                                                self.mealData[cnt].mealCnt += 1
                                            }
                                            
                                            
                                            
                                        }

                                    }
                                    
                                }
                                
                                if !findSameData {
                                    var data = DBMealData(recordDate: dateString, mealCnt: 0, snackCnt: 0)
                                    
                                    if mealKind == "간식" {
                                       data.snackCnt += 1
                                    } else {
                                        data.mealCnt += 1
                                    }
                                    self.mealData.append(data)


                                }
                 
                                //

                                

                            } else {
                                print("pass")
                            }

                        }

                        
                    } // record 가져오기
                }

                self.setChart()
            }
            
            }

        }
    
    func setChart(){
        
        ChartView.clear()
        
        if ChartView.leftAxis.limitLines.endIndex > 0 {
            ChartView.leftAxis.removeLimitLine(ChartView.leftAxis.limitLines[0])
        }
        
        if ChartView.rightAxis.limitLines.endIndex > 0 {
            ChartView.rightAxis.removeLimitLine(ChartView.rightAxis.limitLines[0])
        }

        
        
        var mealCntEntry = [ChartDataEntry]() // graph 에 보여줄 data array
        var snackCntEntry = [ChartDataEntry]() // graph 에 보여줄 data array
        
        //chart 작성용 - XAxis
        var days = [String]()
        var meals = [String]()
        var snacks = [String]()
        
        //평균
        var sumMeal = 0.0
        var sumSnack = 0.0
        
        //총 갯수
        let total = Double(self.mealData.count)
        
        //날짜 순으로 정렬하기
        let sortData = self.mealData.sorted(by: {$0.recordDate < $1.recordDate}) //날짜 순서대로
        
        // chart data array 에 데이터 추가
        for i in 0..<sortData.count {
            let mealCnt = ChartDataEntry(x: Double(i), y: Double(sortData[i].mealCnt))
            mealCntEntry.append(mealCnt)
            
            sumMeal += Double(sortData[i].mealCnt)
            
            let snackCnt = ChartDataEntry(x: Double(i), y: Double(sortData[i].snackCnt))
            snackCntEntry.append(snackCnt)
            
            sumSnack += Double(sortData[i].snackCnt)
            
            meals.append(String(sortData[i].mealCnt))
            snacks.append(String(sortData[i].snackCnt))
            
            self.dateFormatter.dateFormat = "yyyy-MM-dd" //데이터 포맷 설정
            let arrayDate = self.dateFormatter.date(from: sortData[i].recordDate)
            self.dateFormatter.dateFormat = "dd" //데이터 포맷 설정
            let arrayDay = self.dateFormatter.string(from: arrayDate!)
            days.append(arrayDay)

            
        }
        
        
        
        let lineMeal = LineChartDataSet(entries: mealCntEntry, label: "식사 횟수")
        lineMeal.colors = [NSUIColor.blue]
        lineMeal.circleRadius = 0.0
        
        let lineSnack = LineChartDataSet(entries: snackCntEntry, label: "간식 횟수")
        lineSnack.colors = [NSUIColor.red]
        lineSnack.circleRadius = 0.0
        
        // 리미트라인
        if total > 0 {
            let limitMeal = ChartLimitLine(limit: Double(sumMeal/total), label: "평균 식사 횟수")
            limitMeal.lineColor = .blue
            ChartView.leftAxis.addLimitLine(limitMeal)
            
            self.LabelMeal.text = String(format: "%0.1f회", Double(sumMeal/total))
            
            let limitSnack = ChartLimitLine(limit: Double(sumSnack/total), label: "평균 간식 횟수")
            limitSnack.lineColor = .red
            ChartView.rightAxis.addLimitLine(limitSnack)
            
            self.LabelSnack.text = String(format: "%0.1f회", Double(sumSnack/total))
            
        }
        
        
        
        // X축 레이블 위치 조정
        ChartView.xAxis.labelPosition = .bottom
        // X축 레이블 포맷 지정
        ChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        ChartView.leftAxis.valueFormatter = IndexAxisValueFormatter(values: meals)
        ChartView.rightAxis.valueFormatter = IndexAxisValueFormatter(values: snacks)
        
        // X축 레이블 갯수 최대로 설정 (이 코드 안쓸 시 Jan Mar May 이런식으로 띄엄띄엄 조금만 나옴)
        ChartView.xAxis.setLabelCount(days.count, force: false)
        
        //X축 레이블 색
        ChartView.xAxis.axisLineColor = .lightGray
        
        // 레이블 제거
        //ChartView.rightAxis.enabled = false
        //ChartView.leftAxis.enabled = false
        
        // 미니멈
        ChartView.leftAxis.axisMinimum = 0
        
        //data 추가
        let data = LineChartData()
        data.addDataSet(lineMeal)
        data.addDataSet(lineSnack)
        
        
        
        
        ChartView.data = data
        
        //animation
        ChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
    }
    @IBAction func goBack(_ sender: UIButton) {
        
        //UI 지우기
        self.LabelMeal.text = "0회"
        self.LabelSnack.text = "0회"
        
        indexOfMonth -= 1
        var date = ""
        //년도를 바꿔야하는 경우
        if indexOfMonth < 1 {
            indexOfMonth = 12
            
            //년도 구하기
            self.dateFormatter.dateFormat = "yyyy" //데이터 포맷 설정
            let year = Int(self.dateFormatter.string(from: currentDate))! - 1
            date = String(format: "%04d", year) + "-12"

        } else {
            
            //년도 구하기
            self.dateFormatter.dateFormat = "yyyy" //데이터 포맷 설정
            date = self.dateFormatter.string(from: currentDate) + String(format: "-%02d", indexOfMonth)

        }
        
        self.dateFormatter.dateFormat = "yyyy-MM" //데이터 포맷 설정
        self.currentDate = self.dateFormatter.date(from: date)
        
        self.LabelMonth.text = String(format: "%d월", indexOfMonth)
        
        self.findData()
    }
    
    @IBAction func goNext(_ sender: Any) {
        indexOfMonth += 1
        
        //UI 지우기
        self.LabelMeal.text = "0회"
        self.LabelSnack.text = "0회"
        
        var date = ""
        //년도를 바꿔야하는 경우
        if indexOfMonth > 12 {
            indexOfMonth = 1
            
            //년도 구하기
            self.dateFormatter.dateFormat = "yyyy" //데이터 포맷 설정
            let year = Int(self.dateFormatter.string(from: currentDate))! + 1
            date = String(format: "%04d", year) + "-01"

        } else {
            
            //년도 구하기
            self.dateFormatter.dateFormat = "yyyy" //데이터 포맷 설정
            date = self.dateFormatter.string(from: currentDate) + String(format: "-%02d", indexOfMonth)

        }
        
        self.dateFormatter.dateFormat = "yyyy-MM" //데이터 포맷 설정
        self.currentDate = self.dateFormatter.date(from: date)
        
        self.LabelMonth.text = String(format: "%d월", indexOfMonth)
        
        findData()
    }
}
