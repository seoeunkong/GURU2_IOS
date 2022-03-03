//
//  CommentsData.swift
//  GURU2Project
//
//  Created by 공서은 on 2022/01/30.
//

struct CommentsData {
    
    var postcode:String
    var comments:String
    var writer:String
    var time:String
    var commentcode:String
    var image:String
    
    init(_ postcode:String, _ comments:String, _ writer:String, _ time:String, _ commentcode:String, _ image:String){
        
       
        self.postcode = postcode
        self.comments = comments
        self.writer = writer
        self.time = time
        self.commentcode = commentcode
        self.image = image
        
    }
}
