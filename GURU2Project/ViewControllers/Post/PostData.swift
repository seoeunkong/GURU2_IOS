//
//  PostData.swift
//  GURU2Project
//
//  Created by 공서은 on 2022/01/29.
//

struct PostData {
    
    var title:String
    var contents:String
    var filter:String
    var writer:String
    var time:String
    var code:String
    var image:String
    var postimage:String
    
    init(_ title:String, _ filter:String, _ contents:String, _ writer:String, _ time:String, _ code:String, _ image:String, _ postimage:String){
        
       
        self.title = title
        self.filter = filter
        self.contents = contents
        self.writer = writer
        self.time = time
        self.code = code
        self.image = image
        self.postimage = postimage
    }
}
