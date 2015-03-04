//
//  SwiftDictModel.swift
//  练习字典转模型
//
//  Created by Zr on 15/3/4.
//  Copyright (c) 2015年 Tarol. All rights reserved.
//

import Foundation

class SwiftDictModel {
    
    func modelInfo(cls: AnyClass) {
        
        // 运行时知识
        var count: UInt32 = 0
        let ivars = class_copyIvarList(cls, &count)
        // 遍历ivars数组，
        for i in 0..<count {
            let ivar = ivars[Int(i)]
            // UInt8 = char,获取变量名
            let cname = ivar_getName(ivar)
            let name = String.fromCString(cname)
            // 获取变量类型
            let ctype = ivar_getTypeEncoding(ivar)
            let type = String.fromCString(ctype)
            println("->\(name)-->\(type)") // 应为Swift的bug所以type取不出来
        }
        
        
    }
    
    
    
    
}





