//
//  SwiftDictModel.swift
//  练习字典转模型
//
//  Created by Zr on 15/3/4.
//  Copyright (c) 2015年 Tarol. All rights reserved.
//

import Foundation

/**
在 swift 中类的完整名称是 命名空间＋类名的，因此，Swift中不需要类前缀的

运行时：
1. 是用来开发 OC 的
2. 如果在程序开发中，有一些动态的需求，通常可以使用运行时来处理

关于运行时，总共有三种常见的使用技术
1> 交换方法
2> 动态获取类的信息
3> 在"分类"中，动态关联属性

一定记住：模型中的基本数据类型，不能使用可选项
应该写成 var num: Int
*/

///  字典转模型自定义对象的协议
// 在 Swift 中，如果希望让类动态调用协议方法，需要使用 @objc 的关键字
@objc protocol DictModelProtocol {
    
    ///  自定义类映射表
    ///
    ///  :returns: 返回可选映射关系字典 [属性名: 自定义对象名称]
    /// class 替换成 static 是 swift 1.2 修改的
    static func customeClassMapping() -> [String: String]?
}

///  字典转模型工具
class SwiftDictModel {
    
    /// 单例，全局访问入口
    static let sharedManager = SwiftDictModel()
    
    ///  将字典转换成模型对象
    ///
    ///  :param: dict 数据字典
    ///  :param: cls  模型类
    ///
    ///  :returns: 实例化的类对象
    func objectWithDictionary(dict: NSDictionary, cls: AnyClass) -> AnyObject? {
        
        // 1. 取出模型类的字典
        let dictInfo = fullModleInfo(cls)
        
        // 实例化对象
        var obj: AnyObject = cls.alloc()
        
        // 2. 遍历模型字典，有什么属性就设置什么属性
        // k 应该和 dict 中的 key 是一致的
        for (k, v) in dictInfo {
            // 取出字典中的内容
            if let value: AnyObject? = dict[k] {
                //                println("要设置数值的 \(value) + key \(k)")
                
                // 判断是否是自定义类
                // json 反序列化的时候，如果是 null 值，保存在字典中的是 NSNull()
                if v.isEmpty && !(value === NSNull()) {
                    obj.setValue(value, forKey: k)
                } else {
                    let type = "\(value!.classForCoder)"
                    
                    println("\t自定义对象 \(value) \(k) \(v) ---- type \(type)")
                    // 两种可能，字典/数组
                    
                    if type == "NSDictionary" {
                        // value 是字典－> 将 value 的字典转换成 Info 的对象
                        if let subObj: AnyObject? = objectWithDictionary(value as! NSDictionary, cls: NSClassFromString(v)) {
                            // 使用 KVC 设置数值
                            obj.setValue(subObj, forKey: k)
                        }
                    } else if type == "NSArray" {
                        // value 是数组
                        // 如果是数组如何处理？ 遍历数组，继续处理数组中的字典
                        if let subObj: AnyObject? = objectWithArray(value as! NSArray, cls: NSClassFromString(v)) {
                            obj.setValue(subObj, forKey: k)
                        }
                    }
                }
            }
        }
        
        println(dictInfo)
        
        return obj
    }
    
    ///  将数组转换成模型字典
    ///
    ///  :param: array 数组的描述
    ///  :param: cls 模型类
    ///
    ///  :returns: 模型数组
    func objectWithArray(array: NSArray, cls: AnyClass) -> [AnyObject]? {
        
        // 创建一个数组
        var result = [AnyObject]()
        
        // 1. 遍历数组
        // 可能存在什么类型？字典/数组
        for value in array {
            let type = "\(value.classForCoder)"
            
            if type == "NSDictionary" {
                if let subObj: AnyObject = objectWithDictionary(value as! NSDictionary, cls: cls) {
                    result.append(subObj)
                }
            } else if type == "NSArray" {
                if let subObj: AnyObject = objectWithArray(value as! NSArray, cls: cls) {
                    result.append(subObj)
                }
            }
        }
        
        return result
    }
    
    /// 缓存字典 格式[类名: 模型字典, 类名2: 模型字典]
    var modleCache = [String: [String: String]]()
    
    ///  获取模型类的完整信息
    ///
    ///  :param: cls 模型类
    func fullModleInfo(cls: AnyClass) -> [String: String] {
        
        // 判断类信息是否已经被缓存
        if let cache = modleCache["\(cls)"] {
            println("\(cls)已经被缓存")
            return cache
        }
        
        // 循环查找父类
        // 1. 记录参数
        // 2. 循环中不会处理 NSObject
        var currentCls: AnyClass = cls
        
        // 模型字典
        var dictInfo = [String: String]()
        
        while let parent: AnyClass = currentCls.superclass() {
            // 取出并且拼接 currentCls 的模型字典
            dictInfo.merge(modleInfo(currentCls))
            
            currentCls = parent
        }
        
        // 将模型信息写入缓存
        modleCache["\(cls)"] = dictInfo
        
        return dictInfo
    }
    
    // 获取给定类的信息
    func modleInfo(cls: AnyClass) -> [String: String] {
        
        // 判断类信息是否已经被缓存
        if let cache = modleCache["\(cls)"] {
            println("\(cls)已经被缓存")
            return cache
        }
        
        // 判断类是否遵守了协议，一旦遵守协议，就说明有自定义对象
        var mapping: [String: String]?
        if cls.respondsToSelector("customeClassMapping") {
            println("实现了协议")
            // 调用协议方法，获取自定义对象映射关系字典
            
            mapping = cls.customeClassMapping()
            println(mapping)
        }
        
        // 获取类的属性
        var count: UInt32 = 0
        let ivars = class_copyIvarList(cls, &count)
        
        println("有 \(count) 个属性")
        
        // 定义一个类属性的字典 [属性名称：自定对象的名称/""]
        var dictInfo = [String: String]()
        
        // 获取每个属性的信息：属性的名字，类型
        for i in 0..<count {
            // 检索数组下标只能，用 Int
            let ivar = ivars[Int(i)]
            
            // UInt8 = char，C语言的字符串
            let cname = ivar_getName(ivar)
            // 将 C 语言的字符串转换成 swift 的 String
            let name = String.fromCString(cname)!
            
            // 关于对象的类型
            // 如果是系统的类型：可以通过 KVC 直接设置数值
            // 只有自定义对象，才需要做后续复杂的操作
            // 只需要记录住自定义对象的类型即可
            
            // 判断字典中，是否存在 name 来决定是否是自定义对象
            //            var type = ""
            //            if mapping?[name] != nil {
            //                println("\(name) 属性的自定义对象类型是 \(mapping?[name])")
            //                type = mapping![name]!
            //            }
            
            // ?? —> let 常量 = 可选变量 ?? 另外一个变量
            // 如果可选变量存在，就直接设置
            // 如果可选变量不存在，使用另外一个变量设置
            let type = mapping?[name] ?? ""
            
            // 设置字典
            dictInfo[name] = type
            
            
            // 需要知道每一个属性对应的类型
            // getTypeEncoding 在 OC 中是能够工作正常的！
            //            let ctype = ivar_getTypeEncoding(ivar)
            //            let type = String.fromCString(ctype)!
            //
            //            //
            //            println(name + "---" + type)
        }
        
        free(ivars)
        
        // 将模型信息写入缓存
        modleCache["\(cls)"] = dictInfo
        
        return dictInfo
    }
    
    // 加载属性列表
    func loadProperties(cls: AnyClass) {
        // 获取类的属性
        var count: UInt32 = 0
        // 在 C 语言中，数组变量的名称，就是指向数组第一个元素的地址
        // class_copyPropertyList 提示提取基本数据类型有问题！
        // 如果基本变量使用 ?，就提取不出来
        // 要求用户必须使用设置初始值的 基本变量
        let properties = class_copyPropertyList(cls, &count)
        
        println("有 \(count) 个属性")
        
        // 获取每个属性的信息：属性的名字，类型
        for i in 0..<count {
            // 检索数组下标只能，用 Int
            let property = properties[Int(i)]
            
            // UInt8 = char，C语言的字符串
            let cname = property_getName(property)
            // 将 C 语言的字符串转换成 swift 的 String
            let name = String.fromCString(cname)!
            
            // 需要知道每一个属性对应的类型
            // getTypeEncoding 在 OC 中是能够工作正常的！
            let ctype = property_getAttributes(property)
            let type = String.fromCString(ctype)!
            
            //
            println(name + "---" + type)
        }
        
        free(properties)
    }
    
    // 加载成员变量
    func loadIVars(cls: AnyClass) {
        // 获取类的属性
        var count: UInt32 = 0
        // 在 C 语言中，数组变量的名称，就是指向数组第一个元素的地址
        // class_copyIvarList，在 swift 中，如果调用的 C 语言的函数中
        // 包含 copy/retain/create/new 字样的函数，同样需要释放对象(release/free)
        // 在 swift 中，内存管理同样是 ARC 的，同样只管理 swift 部分的代码
        let ivars = class_copyIvarList(cls, &count)
        
        println("有 \(count) 个属性")
        
        // 获取每个属性的信息：属性的名字，类型
        for i in 0..<count {
            // 检索数组下标只能，用 Int
            let ivar = ivars[Int(i)]
            
            // UInt8 = char，C语言的字符串
            let cname = ivar_getName(ivar)
            // 将 C 语言的字符串转换成 swift 的 String
            let name = String.fromCString(cname)!
            
            // 需要知道每一个属性对应的类型
            // getTypeEncoding 在 OC 中是能够工作正常的！
            let ctype = ivar_getTypeEncoding(ivar)
            let type = String.fromCString(ctype)!
            
            //
            println(name + "---" + type)
        }
        
        free(ivars)
    }
}

///  extension 类似于 OC 的分类，给类/对象添加方法
extension Dictionary {
    
    ///  将给定的字典（可变的）合并到当前字典
    ///  mutating 表示函数操作的字典是可变类型的
    ///  泛型(随便一个类型)，封装一些函数或者方法，更加具有弹性
    ///  任何两个 [key: value] 类型匹配的字典，都可以进行合并操作
    mutating func merge<K, V>(dict: [K: V]) {
        for (k, v) in dict {
            // 字典的分类方法中，如果要使用 updateValue，需要明确的指定类型
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}








