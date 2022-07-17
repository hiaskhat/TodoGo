//
//  Category.swift
//  TodoGo
//
//  Created by Асхат Баймуканов on 15.07.2022.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    
    let items = List<Item>()
}
