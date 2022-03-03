//
//  TipsDetailViewController.swift
//  GURU2Project
//
//  Created by apple on 2022/01/30.
//

import UIKit
import FirebaseStorage
class TipsDetailViewController:UIViewController,UIScrollViewDelegate{
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var LabelTitle: UILabel!
    
    //storage
    let storage = Storage.storage()
    var storageRef : StorageReference!
    
    //image 표시
    var images = [UIImage]()
    var imageViews = [UIImageView]()
    
    //image 위치 정보
    var tipNum:Int!
    var pageNum:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storageRef = storage.reference() //연결
        scrollView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.images = [UIImage]()
        //비동기 처리로 순서가 엉키지 않게 미리 배열 사이즈를 잡아 넣음
        for num in 1...self.pageNum {
            let image = UIImage()
            self.images.append(image)
        }
        self.InitImage()
    }

    func InitImage() {
        let path = String(format: "Tips/#%d",self.tipNum)
        
        // Create a reference to the file you want to download
        for num in 0..<self.pageNum {
            let path = String(format: "Tips/#%d/%d.png",self.tipNum ,num + 1)
            let islandRef = storageRef.child(path)
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
              if let error = error {
                // Uh-oh, an error occurred!
              } else {
                // Data for "images/island.jpg" is returned
                  if let image = UIImage(data: data!){
                      self.images[num] = image
                      self.addContentScrollView()
                      self.setPageControl()
                  }
                
              }
            }
        }
    }
    
     func addContentScrollView() {
        
         //기존 subview 삭제
         let subViews = self.scrollView.subviews
         for subview in subViews{
             subview.removeFromSuperview()
         }
         
        for i in 0..<images.count {
            let imageView = UIImageView()
            let xPos = self.view.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPos, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
            imageView.image = images[i]
            scrollView.addSubview(imageView)
            scrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1)
        }
        
    }
    
     func setPageControl() {
        pageControl.numberOfPages = images.count
        
    }
    
     func setPageControlSelectedPage(currentPage:Int) {
        pageControl.currentPage = currentPage
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        setPageControlSelectedPage(currentPage: Int(round(value)))
    }
}
