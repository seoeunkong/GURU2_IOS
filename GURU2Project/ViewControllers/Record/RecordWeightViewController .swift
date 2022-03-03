//
//  RecordWeightViewController.swift
//  GURU2Project
//
//  Created by 김진원 on 2022/01/24.
//

struct DBWeightData {
    var recordDate:String //날짜
    var weight:String //식사 횟수
}

import UIKit
import FirebaseDatabase
import Charts
import FirebaseAuth
class RecordWeightViewController:UIViewController{
    
    //User 정보
    var petCode = [String]()
    var petName:String!
    var havePet = false
    var userKey:String!
    
    //DB 데이터
    var weightData = [DBWeightData]()
    var ref:DatabaseReference!
    let dateFormatter = DateFormatter()
    
    //날짜 정보
    var currentDate:Date!
    var indexOfMonth:Int!
    
    //평균 체중
    var currentAvg:Double!
    var beforeAvg = 0.0
    
    
    @IBOutlet weak var LabelMonth: UILabel!
    @IBOutlet weak var ChartView: LineChartView!
    @IBOutlet weak var LabelWeight: UILabel!
    @IBOutlet weak var LabelDif: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChartView.noDataText = "데이터가 없습니다."
        ChartView.noDataFont = .systemFont(ofSize: 20)
        ChartView.noDataTextColor = .lightGray
        
        currentDate = Date()
        self.dateFormatter.dateFormat = "MM" //데이터 포맷 설정
        indexOfMonth = Int(self.dateFormatter.string(from: currentDate))
        
        self.LabelMonth.text = String(format: "%d월", indexOfMonth)
        
        //데이터베이스 연결
        ref = Database.database().reference()
        guard let key = ref.child("users").childByAutoId().key else { return }
        
        //user 키가 있는 지 확인
        if let user = Auth.auth().currentUser?.uid {
            self.userKey = user
            
            //pet 정보 가져오기
            InitPet()
        }

    }
    
    func InitPet(){
        //pet code 찾기
        let refUser = ref.child("users/\(self.userKey!)/pets")
        refUser.observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let petNum = Int(value?["petNum"] as! String)!
            
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
        
        self.beforeAvg = 0.0
        self.currentAvg = 0.0
        
        self.findBeforeData() // 이전 데이터 찾기
        
        weightData = [DBWeightData]() //데이터 초기화
        
        let path = "pets/\(self.petCode[0])/weight"
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
                                //데이터가 기록되어 있는지 확인하기
                                var findSameData = false
                                let format = DateFormatter()
                                self.dateFormatter.dateFormat = "dd" //데이터 포맷 설정
                                let recordDay = self.dateFormatter.string(from: date) //DB 에 저장되어 있는 년도 날짜
                                
                                let weight = String(record[DataIndex.DATA1.rawValue])
                                
                                if self.weightData != nil {
                                    
                                    print(self.weightData.count)
                                    
                                    for cnt in 0..<self.weightData.count {
                                        
                                        format.dateFormat = "yyyy-MM-dd"
                                        let db = self.weightData[cnt]
                                        let arrayDate = format.date(from: db.recordDate)
                                        let arrayDay = self.dateFormatter.string(from: arrayDate!)

                                        if arrayDay == recordDay {
                                            findSameData = true
                                            self.weightData[cnt].weight = weight
                                            
                                        }

                                    }
                                    
                                }
                                
                                if !findSameData {
                                    var data = DBWeightData(recordDate: dateString,weight: weight)
                                    self.weightData.append(data)
                                }

                            }

                        }

                        
                    } // record 가져오기
                }

                self.setChart()
            }
            
            }

        }
    
    
    func findBeforeData(){
        var dataWeight = [DBWeightData]() //데이터 초기화
        
        //검색해야하는 월 찾기
        var beforeDate = Date()
        var beforeDateString  = ""
        let dataForm = DateFormatter()

        //년도를 바꿔야하는 경우
        if self.indexOfMonth == 1 {
            let indexMonth = 12
            
            //년도 구하기
            dataForm.dateFormat = "yyyy" //데이터 포맷 설정
            let year = Int(dataForm.string(from: currentDate))! - 1
            beforeDateString = String(format: "%04d", year) + "-12"

        } else {
            let indexMonth = Int(self.indexOfMonth)
            //년도 구하기
            dataForm.dateFormat = "yyyy" //데이터 포맷 설정
            beforeDateString = dataForm.string(from: currentDate) + String(format: "-%02d",  indexMonth - 1)

        }
        
        dataForm.dateFormat = "yyyy-MM" //데이터 포맷 설정
        beforeDate = dataForm.date(from: beforeDateString)!
        
        let path = "pets/\(self.petCode[0])/weight"
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
                            
                            
                            dataForm.dateFormat = "YYYY-MM-dd" //데이터 포맷 설정
                            let record = data.split(separator: ",") //데이터 나누기
                            
                            let dateString = String(record[DataIndex.DATADAY.rawValue])
                            let date:Date = dataForm.date(from: dateString)! //db에 기록된 날짜
                            
                            dataForm.dateFormat = "yyyy-MM" //데이터 포맷 설정
                            
                            //현재 원하는 월의 데이터라면
                            if dataForm.string(from: date) == dataForm.string(from: beforeDate){
                                
                                //데이터를 string array로 변경
                                let record = data.split(separator: ",")
                                var dataInfoArray = Array<String>()
                                for count in record {
                                    dataInfoArray.append(String(count))
                                }
                                
                                let dayDetailInfo = dataInfoArray
                                //데이터가 기록되어 있는지 확인하기
                                var findSameData = false
                                let format = DateFormatter()
                                dataForm.dateFormat = "dd" //데이터 포맷 설정
                                let recordDay = dataForm.string(from: date) //DB 에 저장되어 있는 년도 날짜
                                
                                let weight = String(record[DataIndex.DATA1.rawValue])
                                
                                if dataWeight != nil {

                                    for cnt in 0..<dataWeight.count {
                                        
                                        format.dateFormat = "yyyy-MM-dd"
                                        let db = dataWeight[cnt]
                                        let arrayDate = format.date(from: db.recordDate)
                                        let arrayDay = dataForm.string(from: arrayDate!)

                                        if arrayDay == recordDay {
                                            findSameData = true
                                            dataWeight[cnt].weight = weight
                                            
                                        }

                                    }
                                    
                                }
                                
                                if !findSameData {
                                    var data = DBWeightData(recordDate: dateString,weight: weight)
                                    dataWeight.append(data)
                                }

                            }

                        }

                        
                    } // record 가져오기
                    
                    //평균 구하기
                    let total = Double(dataWeight.count)
                    var sum = 0.0
                    
                    if total > 0 {
                        for db in dataWeight {
                            sum += Double(db.weight)!
                        }
                        
                        self.beforeAvg = Double(sum/total)
                        
                        if self.beforeAvg > self.currentAvg {
                            self.LabelDif.text = String(format: "지난 달 보다 %0.2f kg 감소하였습니다.", self.beforeAvg - self.currentAvg)
                        } else {
                            self.LabelDif.text = String(format: "지난 달 보다 %0.2f kg 증가하였습니다.", self.currentAvg - self.beforeAvg)
                        }
                    }
                    
                    
  
                }
            }
            
            }
    }
    
    func setChart(){
        
        ChartView.clear()
        
        if ChartView.leftAxis.limitLines.endIndex > 0 {
            ChartView.leftAxis.removeLimitLine(ChartView.leftAxis.limitLines[0])
        }

        var weightEntry = [ChartDataEntry]() // graph 에 보여줄 data array

        
        //chart 작성용 - XAxis
        var days = [String]()
        var weights = [String]()
        
        //평균
        var sumWeight = 0.0
        
        //총 갯수
        let total = Double(self.weightData.count)
        
        //날짜 순으로 정렬하기
        let sortData = self.weightData.sorted(by: {$0.recordDate < $1.recordDate}) //날짜 순서대로
        
        // chart data array 에 데이터 추가
        for i in 0..<sortData.count {
            let weight = ChartDataEntry(x: Double(i), y: Double(sortData[i].weight)!)
            weightEntry.append(weight)
            
            sumWeight += Double(sortData[i].weight)!
            weights.append(String(sortData[i].weight))

            
            self.dateFormatter.dateFormat = "yyyy-MM-dd" //데이터 포맷 설정
            let arrayDate = self.dateFormatter.date(from: sortData[i].recordDate)
            self.dateFormatter.dateFormat = "dd" //데이터 포맷 설정
            let arrayDay = self.dateFormatter.string(from: arrayDate!)
            days.append(arrayDay)

            
        }
        
        
        
        let lineWeight = LineChartDataSet(entries: weightEntry, label: "체중")
        lineWeight.colors = [NSUIColor.blue]
        lineWeight.circleRadius = 0.0

        
        // 리미트라인
        if total > 0 {
            let limitLine = ChartLimitLine(limit: Double(sumWeight/total), label: "평균 체중")
            limitLine.lineColor = .blue
            ChartView.leftAxis.addLimitLine(limitLine)
            
            self.LabelWeight.text = String(format: "%0.2f kg", Double(sumWeight/total))
            self.currentAvg = Double(sumWeight/total) //현재 체중 저장
            
            if self.beforeAvg > self.currentAvg {
                self.LabelDif.text = String(format: "지난 달 보다 %0.2f kg 감소하였습니다.", self.beforeAvg - self.currentAvg)
            } else {
                self.LabelDif.text = String(format: "지난 달 보다 %0.2f kg 증가하였습니다.", self.currentAvg - self.beforeAvg)
            }
            
            
        }
        
        
        
        // X축 레이블 위치 조정
        ChartView.xAxis.labelPosition = .bottom
        // X축 레이블 포맷 지정
        ChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        ChartView.leftAxis.valueFormatter = IndexAxisValueFormatter(values: weights)

        
        // X축 레이블 갯수 최대로 설정 (이 코드 안쓸 시 Jan Mar May 이런식으로 띄엄띄엄 조금만 나옴)
        ChartView.xAxis.setLabelCount(days.count, force: false)
        
        //X축 레이블 색
        ChartView.xAxis.axisLineColor = .lightGray
        
        // 레이블 제거
        ChartView.rightAxis.enabled = false
        //ChartView.leftAxis.enabled = false
        
        // 미니멈
        ChartView.leftAxis.axisMinimum = 0
        
        //data 추가
        let data = LineChartData()
        data.addDataSet(lineWeight)
     
        ChartView.data = data
        
        //animation
        ChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        indexOfMonth -= 1
        var date = ""
        //UI 지우기
        self.LabelWeight.text = ""
        self.LabelDif.text = ""
        
        //년도를 바꿔야하는 경우
        if indexOfMonth < 1 {
            indexOfMonth = 12
            
            //년도 구하기
            self.dateFormatter.dateFormat = "yyyy" //데이터 포맷 설정
            let year = Int(self.dateFormatter.string(from: currentDate))! - 1
            date = String(format: "%04d", year) + "-12-04"

        } else {
            
            //년도 구하기
            self.dateFormatter.dateFormat = "yyyy" //데이터 포맷 설정
            date = self.dateFormatter.string(from: currentDate) + String(format: "-%02d-04", indexOfMonth)

        }
        
        self.dateFormatter.dateFormat = "yyyy-MM-dd" //데이터 포맷 설정
        self.currentDate = self.dateFormatter.date(from: date)
        
        self.LabelMonth.text = String(format: "%d월", indexOfMonth)
        
        print(currentDate)
        
        self.findData()
    }
    @IBAction func goNext(_ sender: UIButton) {
        
        indexOfMonth += 1

        //UI 지우기
        self.LabelWeight.text = "0.0 kg"
        self.LabelDif.text = ""
        
        var date = ""
        //년도를 바꿔야하는 경우
        if indexOfMonth > 12 {
            indexOfMonth = 1
            
            //년도 구하기
            self.dateFormatter.dateFormat = "yyyy" //데이터 포맷 설정
            let year = Int(self.dateFormatter.string(from: currentDate))! + 1
            date = String(format: "%04d", year) + "-01-04"

        } else {
            
            //년도 구하기
            self.dateFormatter.dateFormat = "yyyy" //데이터 포맷 설정
            date = self.dateFormatter.string(from: currentDate) + String(format: "-%02d-04", indexOfMonth)

        }
        
        self.dateFormatter.dateFormat = "yyyy-MM-dd" //데이터 포맷 설정
        self.currentDate = self.dateFormatter.date(from: date)
        
        self.LabelMonth.text = String(format: "%d월", indexOfMonth)
        
        findData()
    }
}
