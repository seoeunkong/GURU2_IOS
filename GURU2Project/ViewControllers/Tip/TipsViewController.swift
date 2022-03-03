//
//  TipsViewController.swift
//  GURU2Project
//
//  Created by 김진원 on 2022/01/20.
//

struct imageData {
    var indexFolder:Int! //폴더 번호
    var pageNum:Int! //page rottn
    var thumbNail:UIImage! //이미지
    var tipTitle:String! //제목
    var filter = [String]() //필터
}

import UIKit
import FirebaseStorage
import FirebaseDatabase
import DropDown
class TipsViewController:UIViewController{
    
    var showData = [imageData]() //보여주는 데이터
    var backData = [imageData]() //모든 데이터
    
    //collection View
    @IBOutlet weak var collectionView: UICollectionView!
    let sectionInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    
    //storage
    let storage = Storage.storage()
    var storageRef : StorageReference!
    
    //Firebase
    var baseRef : DatabaseReference!
    var tipCnt = 0 //tip 갯수
    
    //필터
    let dropDown = DropDown()
    @IBOutlet weak var btnFilter: UIButton!
    var filter = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storageRef = storage.reference() //연결
        baseRef = Database.database().reference() //데이터베이스 연결
        InitDB()
        
        dropDown.dataSource = ["교육", "병원", "코로나", "입양", "봉사","음식"]
        dropDown.anchorView = self.btnFilter
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        for data in dropDown.dataSource {
            filter.append(data)
        }
    }
    
    //DB 연결
    func InitDB() {
        baseRef = Database.database().reference() //데이터베이스 연결
        
        guard let key = baseRef.child("tips").childByAutoId().key else { return }
        
        InitData()
    }
    
    //RealTime Database 에서 이미지 정보 찾기
    func InitData(){
        let refTip = baseRef.child("tips")
        refTip.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let tipNum = value["tipNum"] as! Int
                
                self.tipCnt = tipNum
                self.backData = [imageData]()
                self.showData = [imageData]()
                //비동기 처리로 순서가 엉키지 않게 미리 배열 사이즈를 잡아 넣음
                for num in 1...self.tipCnt {
                    self.backData.append(imageData(indexFolder:num,pageNum: 0, thumbNail: UIImage(), tipTitle: "", filter: [String]()))
                    self.showData.append(imageData(indexFolder:num,pageNum: 0, thumbNail: UIImage(), tipTitle: "", filter: [String]()))
                }
                
                //image가 존재한다면 -> 페이지 정보 기록하기
                if self.tipCnt > 0 {
                    for number in 0..<self.tipCnt {
                        
                        let tipKey = String(format: "tip%d", number + 1)
                        let path = "tips/\(tipKey)"
                        let refCount = self.baseRef.child(path)
                        
                        refCount.observeSingleEvent(of: .value) { [self] (snapshot) in
                            if let value = snapshot.value as? NSDictionary{
                                let pageNum = value["count"] as! Int
                                self.backData[number].pageNum = pageNum
                                
                                let title = value["title"] as! String
                                self.backData[number].tipTitle = title
                                
                                let filter = value["filter"] as! String
                                //데이터를 string array로 변경
                                let record = filter.split(separator: ",")
                                var dataArray = Array<String>()
                                for count in record {
                                    dataArray.append(String(count))
                                }
                                self.backData[number].filter = dataArray
                                self.showData[number] = self.backData[number]
                            }
                            
                           
                        }


                    }
                }
                self.updateImage()
            }
            
        }
    }
        
    func updateImage() {
        // Create a reference to the file you want to download
        for num in 0..<self.showData.count {
            let path = String(format: "Tips/#%d/1.png", self.showData[num].indexFolder)
            let islandRef = storageRef.child(path)
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
              if let error = error {
                // Uh-oh, an error occurred!
              } else {
                // Data for "images/island.jpg" is returned
                  if let image = UIImage(data: data!){
                      self.showData[num].thumbNail = image
                      self.collectionView.reloadData()
                  }
                
              }
            }

        
        }
        
        self.collectionView.reloadData()
    }
    
    //필터에 맞게 이미지 재정렬
    func ReloadData(){
        

        self.tipCnt = self.backData.count
        self.showData = [imageData]()
        

            var ok = true //필터 조건에 만족하는지 확인
            for num in 0..<self.backData.count {
                ok = true
                
                let data = self.backData[num]
                
                for key in self.filter { //검색 필터가 tip 필터 안에 존재하는지 확인
                    if data.filter.contains(key) == false { //필터가 하나라도 없으면 표시 X
                        ok = false
                    }
                }
                
                if ok {
                    showData.append(data)
                }
            }
            
            
        
        self.tipCnt = self.showData.count
        //self.collectionView.reloadData()
        updateImage()
    }
    
    @IBAction func doFilter(_ sender: UIButton) {
        dropDown.show()
        dropDown.multiSelectionAction = { [unowned self] (index: Array<Int> , item: Array<String>) in
            
            filter = [String]()
            filter = item
            
            print(filter)
            ReloadData()
        }
    }
    
}

extension TipsViewController:UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tipCnt
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectCell", for: indexPath) as?
                TipsCell else {
            return UICollectionViewCell()
        }
        
        //index 에서 벗어나지 않도록
        if self.showData.count > indexPath.row {
            cell.imageView.image = self.showData[indexPath.row].thumbNail
        }
        
        return cell
    }
    
    //collection view 선택
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let currentVC = UIStoryboard(name: "Tips", bundle: nil).instantiateViewController(withIdentifier: "TipsDetail") as? TipsDetailViewController{
            currentVC.view.frame = UIApplication.shared.windows[0].frame
            currentVC.didMove(toParent: self)
            currentVC.modalPresentationStyle = .popover
            
            currentVC.tipNum = self.showData[indexPath.row].indexFolder
            currentVC.pageNum = self.showData[indexPath.row].pageNum
            currentVC.LabelTitle.text = self.showData[indexPath.row].tipTitle
            present(currentVC, animated: true, completion: nil) //창 띄우기

        }
    }
    
    
    //UI 구성
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = collectionView.frame.width
            let height = collectionView.frame.height
            let itemsPerRow: CGFloat = 2
            let widthPadding = sectionInsets.left * (itemsPerRow + 1)
            let itemsPerColumn: CGFloat = 3
            let heightPadding = sectionInsets.top * (itemsPerColumn + 1)
            let cellWidth = (width - widthPadding) / itemsPerRow
            let cellHeight = (height - heightPadding) / itemsPerColumn
            
            return CGSize(width: cellWidth, height: cellHeight)
            
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return sectionInsets
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return sectionInsets.left
        }
    
}
