//
//  PetData.swift
//  GURU2Project
//
//  Created by 공서은 on 2022/01/27.
//

struct PetData {
    
    var pet_name:String
    var pet_gender:String
    var pet_age:String
    var pet_species:String
    var pet_code:String
    var pet_weight:String
    var pet_image:String
    
    init(_ name:String, _ gender:String, _ age:String, _ species:String,_ code:String, _ weight:String, _ image:String){
        
       
        self.pet_name = name
        self.pet_age = age
        self.pet_code = code
        self.pet_gender = gender
        self.pet_species = species
        self.pet_weight = weight
        self.pet_image = image
        
    }
}
