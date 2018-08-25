//
//  Category.swift
//  Todoey
//
//  Created by Manish Thakur on 8/21/18.
//  Copyright © 2018 Manish Thakur. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object{
    
    @objc dynamic var name : String = ""
    @objc dynamic var cellColor : String = ""
    let items = List<Item>()
    
}
