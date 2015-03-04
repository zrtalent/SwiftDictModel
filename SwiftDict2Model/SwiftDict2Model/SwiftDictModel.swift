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
    
    func fullModelInfo(cls: AnyClass) {
        var currentCls: AnyClass = cls
        while let parent: AnyClass = currentCls.superclass() {
            println(modelInfo(currentCls))
            
            currentCls = parent
        }
        
        
    }
    
    // 判断类是否遵守了协议，一旦遵守协议，就说明有自定义对象
    func modelInfo(cls: AnyClass) -> [String: String] {
        var mapping: [String: String]?
        if cls.respondsToSelector("customClassMapping") {
            mapping = cls.customClassMapping()
        }
        
        var count: UInt32 = 0
        let ivars = class_copyIvarList(cls, &count)
        var dictInfo = [String: String]()
        // 遍历ivars数组，
        for i in 0..<count {
            let ivar = ivars[Int(i)]
            // UInt8 = char,获取变量名
            let cname = ivar_getName(ivar)
            let name = String.fromCString(cname)!
            
            // 关于对象的类型
            // 如果是系统的类型：可以通过 KVC 直接设置数值
            // 只有自定义对象，才需要做后续复杂的操作
            // 只需要记录住自定义对象的类型即可
//            var type = ""
//            if mapping?[name] != nil {
//                type = mapping![name]!
//            }
            let type = mapping?[name] ?? "" // Swift特有写法
            dictInfo[name] = type
            
//            // 获取变量类型
//            let ctype = ivar_getTypeEncoding(ivar)
//            let type = String.fromCString(ctype)
//            println("->\(name)-->\(type)")
        }
        
        free(ivars)
        return dictInfo
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

///  extension 类似于 OC 的分类，给类/对象添加方法
extension Dictionary {
    // 此方法为一个对象方法，所以是使一个字典添加另外一个字典的遍历元素将其拼接到现有的字典后面
    ///  将给定的字典（可变的）合并到当前字典
    ///  mutating 表示函数操作的字典是可变类型的
    ///  泛型(随便一个类型)，封装一些函数或者方法，更加具有弹性
    ///  任何两个 [key: value] 类型匹配的字典，都可以进行合并操作
    mutating func merge<K, V>(dict: [K: V]) {
        for (k, v) in dict {
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}








