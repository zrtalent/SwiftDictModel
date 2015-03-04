//
//  SwiftDictModel.swift
//  练习字典转模型
//
//  Created by Zr on 15/3/4.
//  Copyright (c) 2015年 Tarol. All rights reserved.
//

import Foundation

@objc protocol DictModelProtocol {
    ///  自定义类映射表
    ///
    ///  :returns: 返回可选映射关系字典 [属性名: 自定义对象名称]
    /// class 替换成 static 是 swift 1.2 修改的
    static func customClassMapping() -> [String: String]?
}

class SwiftDictModel {
    // 判断类是否遵守了协议，一旦遵守协议，就说明有自定义对象
    func modelInfo(cls: AnyClass) {
        var mapping: [String: String]?
        if cls.respondsToSelector("customClassMapping") {
            mapping = cls.customClassMapping()
            
        }
        
        
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
            println("->\(name)-->\(type)")
        }
        
        free(ivars)
        
    }
    
    func loadProperties(cls: AnyClass) {
        
        // 运行时知识
        var count: UInt32 = 0
        // 在 C 语言中，数组变量的名称，就是指向数组第一个元素的地址
        // class_copyPropertyList 提示提取基本数据类型有问题！
        // 如果基本变量使用 ?，就提取不出来
        // 要求用户必须使用设置初始值的 基本变量
        let properties = class_copyPropertyList(cls, &count)
        // 遍历ivars数组，
        for i in 0..<count {
            let property = properties[Int(i)]
            // UInt8 = char,获取变量名
            let cname = property_getName(property)
            let name = String.fromCString(cname)
            // 获取变量类型
            let ctype = property_getAttributes(property)
            let type = String.fromCString(ctype)
            println("->\(name)-->\(type)") // 应为Swift的bug所以type取不出来, 在OC中可以
        }
        free(properties)
        
    }
    
    // 在 C 语言中，数组变量的名称，就是指向数组第一个元素的地址
    // class_copyIvarList，在 swift 中，如果调用的 C 语言的函数中
    // 包含 copy/retain/create/new 字样的函数，同样需要释放对象(release/free)
    // 在 swift 中，内存管理同样是 ARC 的，同样只管理 swift 部分的代码
    func loadIVars(cls: AnyClass) {
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
            println("->\(name)-->\(type)")
        }
        
        free(ivars)
    }
    
    
}





