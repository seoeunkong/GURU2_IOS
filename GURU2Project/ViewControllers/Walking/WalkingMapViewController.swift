//
//  WalkingMapViewController.swift
//  GURU2Project
//
//  Created by apple on 2022/01/30.
//

import UIKit
import NMapsMap
import FirebaseDatabase
import FirebaseAuth
class WalkingMapViewController:UIViewController,CLLocationManagerDelegate{
    
    var viewController:ViewController!
    var locationManager = CLLocationManager()
    
    var bRun = false // 산책 중
    var startTime:Date! //시작 시간
    var stopTime:Date! //종료 시간
    
    @IBOutlet weak var mapView: NMFMapView!
    @IBOutlet weak var LabelTimer: UILabel!
    @IBOutlet weak var LabelDistance: UILabel!
    @IBOutlet weak var LabelCal: UILabel!
    
    @IBOutlet weak var btnStart: UIButton!
    var ref: DatabaseReference!
    var dateFormatter = DateFormatter()
    var petCode = [String]()
    var recordKey:String!
    var userKey:String!
    
    var pathPoints = [NMGLatLng]() //이동 위치
    let pathOverlay = NMFPath() //이동 그리기
    
    var sportCoef = 0.9 //운동 계수 5km/hr 기준
     
    //타이머
    let timerSelector:Selector = #selector(WalkingMapViewController.updateTime)
    let mapSelelctor:Selector = #selector(WalkingMapViewController.moveCam)
    let interval = 1.0 //타이머 반복 시간
    var count = 0 //시간 측정
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnStart.layer.cornerRadius = 10
        
        ref = Database.database().reference() //데이터베이스 연결
        //user 키가 있는 지 확인
        if let user = Auth.auth().currentUser?.uid {
            self.userKey = user
            
            //pet 정보 가져오기
            InitPet()
        }
         
        Timer.scheduledTimer(timeInterval: interval, target: self, selector: timerSelector, userInfo: nil, repeats: true)
        
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: mapSelelctor, userInfo: nil, repeats: true)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
                
        //UI 설정
        mapView.positionMode = .direction
        
        if CLLocationManager.locationServicesEnabled() {
            print("위치 서비스 On 상태")
            locationManager.startUpdatingLocation()
            
        } else {
            print("위치 서비스 Off 상태")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //현 위치로 카메라 이동
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: locationManager.location?.coordinate.latitude ?? 0, lng: locationManager.location?.coordinate.longitude ?? 0))
                cameraUpdate.animation = .easeIn
           mapView.moveCamera(cameraUpdate)
       
    }
    
    
    //현재 화면 찾기
    func findLocalPos() {
        
        //현 위치 저장
        pathPoints.append(NMGLatLng(lat: locationManager.location?.coordinate.latitude ?? 0, lng: locationManager.location?.coordinate.longitude ?? 0))
    }
    
    func InitPet(){
        //pet code 찾기
        let refUser = ref.child("users/\(self.userKey!)/pets")
        
        refUser.observeSingleEvent(of: .value) { (snapshot) in
            
            //pet 정보가 존재한다먄
            if let value = snapshot.value as? NSDictionary {
                let petNum = Int(value["petNum"] as! String)!
                
                //pet이 있다면
                if petNum > 0 {
                    //등록한 pet의 갯수 만큼
                    for number in 0..<petNum {
                        
                        //pet code 가져오기
                        let findkey = String(format: "pet%d", number+1)
                        if let petcode = value[findkey] as? String{
                            self.petCode.append(petcode)
                        }

                        
                    } // petcode 다 찾음
                    
                }
            }


        }
    }
    
    @objc func updateTime(){
        
        if self.bRun {
            let second = count % 60
            let minute = count / 60
            let text =  String(format: "%02d:%02d", minute ,second)
            
            self.LabelTimer.text = text
            
            count = count + 1
        }
        
    }
    
    //카메라 강제 이동
    @objc func moveCam(){
        
        
        if bRun {
            //현 위치로 카메라 이동
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: locationManager.location?.coordinate.latitude ?? 0, lng: locationManager.location?.coordinate.longitude ?? 0))
            cameraUpdate.animation = .easeIn
            cameraUpdate.reason = 1000
            mapView.moveCamera(cameraUpdate)
            //mapView(self.mapView, cameraIsChangingByReason: 1000)
            let cameraPosition = mapView.cameraPosition
            self.pathPoints.append(NMGLatLng(lat: cameraPosition.target.lat, lng: cameraPosition.target.lng))
        }

    }
    
    //시작 화면으로 이동하기
    @IBAction func goBack(_ sender: UIButton) {
        self.bRun = false
        self.dismissView()
    }
    
    //좌표 그리기
    func DrawMap(){
        
        self.pathOverlay.path = NMGLineString(points:self.pathPoints)
        
        //ui 그리기
        self.pathOverlay.mapView = mapView
        self.pathOverlay.width = 15
        pathOverlay.color = UIColor.green
        //거리 계산하기
        if (self.pathPoints.count) > 2 {
            
            
            for num in 1..<self.pathPoints.count {
                let beforePoint = self.pathPoints[num - 1]
                let firstLat = beforePoint.lat //경도#1
                let firstlng = beforePoint.lng //위도#1
                
                let nowPoint = self.pathPoints[num]
                let nextLat = nowPoint.lat//경도#2
                let nextlng = nowPoint.lng//위도#2
                
                /*
                X = ( cos( 위도#1 ) * 6400 * 2 * 3.14 / 360 ) * | 경도#1 - 경도#2 |
                Y = 111 * | 위도#1 - 위도#2 |
                D = √ ( X² + Y² )
                 */

                var difLat:Double! //경도 차이
                if firstLat > nextLat{
                    difLat = firstLat - nextLat
                } else {
                    difLat = nextLat - firstLat
                }

                var difLng:Double! //위도 차이
                if firstlng > nextlng{
                    difLng = firstlng - nextlng
                } else {
                    difLng = nextlng - firstlng
                }

                let x = cos(firstLat) * 6400 * 2 * 3.14 / 360 * difLat
                let y = 111 * difLng
                let distance = sqrt(x*x + y*y) //km 단위

                self.LabelDistance.text = String(format: "%0.2f", distance)

                //칼로리 계산
                let min = count / 60
                let minCoef = 1 / Double(min) //역수로 치환
                let speed = distance * 60 * minCoef //시속으로 환산
                self.sportCoef = 0.18 * speed //운동 계수 계산

                let cal = self.sportCoef * 60 * Double(min) * 0.0667 //칼로리 계산, 60kg 으로 가정

                self.LabelCal.text = String(format: "%0.0f", cal)

            }

        }
    }
    
    //뒤로가기 함수
    func dismissView(){
        if viewController != nil {
            self.viewController.showCal()
        } else {
            if let calVC = UIStoryboard(name: "Calendar", bundle: nil).instantiateViewController(withIdentifier: "CalendarView") as? CalendarViewController {
                calVC.viewWillAppear(true)
            }
        }
        
        self.presentingViewController?.dismiss(animated: true)
    }
    
    //산책 완료 및 기록
    @IBAction func btnEnd(_ sender: UIButton) {
        
        if self.bRun == false { //시작하는 경우
            self.pathOverlay.mapView = nil //이전 내용 지우기
            pathPoints = [NMGLatLng]()
            findLocalPos()
            self.bRun = true
            self.startTime = Date()
            
            self.btnStart.setTitle("■", for: .normal)
            self.btnStart.layer.cornerRadius = 10

            
        } else { //종료하는 경우
            self.bRun = false
            self.stopTime = Date()
            self.btnStart.setTitle("▶", for: .normal)
            self.btnStart.layer.cornerRadius = 10

            //그리기
            self.DrawMap()
            
            //저장 할 것인지 묻기?
            let editAlert = UIAlertController(title: "저장", message: "산책 기록을 저장하시겠습니까?", preferredStyle: .alert) //pop-up]
            editAlert.addAction(UIAlertAction(title: "예", style: .default, handler: { (action) in
                
                //저장하기
                let path = "pets/\(self.petCode[0])/walking"
                let refUser = self.ref.child(path)
                
                self.dateFormatter.dateFormat = "YYYY-MM-dd" //데이터 포맷 설정

                let day = self.dateFormatter.string(from: Date())

                self.dateFormatter.dateFormat = "HH:mm" //데이터 포맷 설정
                let start = self.dateFormatter.string(from: self.startTime)
                let stop = self.dateFormatter.string(from: self.stopTime)
                var memo = "   "
                var distance = self.LabelDistance.text
                var cal = self.LabelCal.text
                
                
                refUser.observeSingleEvent(of: .value) { (snapshot) in
                    if let value = snapshot.value as? NSDictionary{
                        let recordNum = value["recordNum"] as! Int

                        let recordName = String(format: "record%d", recordNum + 1)
                        self.ref.child("\(path)").updateChildValues(["recordNum":recordNum + 1]) //기록 추가

                        let data = "\(day),\(start),\(stop),\(distance!),\(cal!),\(memo)"
                        self.ref.child("\(path)").updateChildValues([recordName:data])
                        
                    }
                }
                
            }))
            editAlert.addAction(UIAlertAction(title: "아니요", style: .cancel, handler: nil))
            
            self.present(editAlert, animated: true, completion: nil)

        }
        
        
        
        
        
    }
}
