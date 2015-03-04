//
//  Model.swift
//  练习字典转模型
//
//  Created by Zr on 15/3/4.
//  Copyright (c) 2015年 Tarol. All rights reserved.
//

import UIKit

class Model: NSObject, DictModelProtocol {
    var str1: String?
    var str2: NSString?
    var b: Bool = true
    var i: Int = 0
    var f: Float = 0
    var d: Double = 0
    var num: NSNumber?
    var info: Info?
    var other: [Info]?
    var others: NSArray?
    var demo: NSArray?
    
    static func customeClassMapping() -> [String : String]? {
        return ["info": "\(Info.self)", "other": "\(Info.self)", "others": "\(Info.self)", "demo": "\(Info.self)"];
    }
}
class SubModel: Model {
    var boy: String?
}

class Info: NSObject {
    var name: String?
}
