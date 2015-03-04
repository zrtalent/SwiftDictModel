//
//  ViewController.swift
//  02-字典转模型
//
//  Created by apple on 15/3/3.
//  Copyright (c) 2015年 heima. All rights reserved.
//

import UIKit

/**
1. 获取字典
2. 根据字典的内容，"创建"并且"填充"模型类
3. 需要动态的知道模型类都包含哪些属性
class_copyPropertyList(基本类型必须设置初始值，能够获取类型 - 自定义对象，如果包含在数组中，同样无法获取)
class_copyIVarList(能够提取所有属性，但是不能获取类型)
4. 如何能够知道自定义对象的类型？
- MJExtension，定义了一个协议，通过协议告诉"工具"自定义对象的类型
- JSONModel，定义了很多协议，通过遵守协议的方式，告诉"工具"准确的类型
5. 测试子类的模型信息
运行时 class_copyIVarList 只能获取到当前类的属性列表，不会获取到父类的属性列表

解决问题：利用循环，顺序遍历父类，依次生成所有父类的属性列表
SubModel : 1 个属性 + 10 个属性 = 11 属性
Mdole : 10 个属性
...
6. 之所以要求模型类必须继承自 NSObject
1> 可以使用 KVC 设置数值，如果对象不是继承自 NSObject，是无法使用 KVC 的
2> 方便遍历

7. 拼接字典

8. 需要考虑到性能优化的问题 -> 一旦类的模型信息获取到，就不再需要再次获取

解决办法：可以使用一个缓存字典，记录所有解析过的模型类信息
[类名: 模型字典, 类名2: 模型字典]

9. 字典转模型的工具使用范围，在非常多的界面中，都会有对网络数据做字典转模型的需求！
将字典转模型工具，变成单例，统一负责应用程序中所有模型转换的工作！

10. 字典转模型
*/
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let json = loadJSON()
        let obj = SwiftDictModel.sharedManager.objectWithDictionary(json, cls: SubModel.self) as! SubModel
        
        println("object.info.name !!!! " + obj.info!.name!)
        
        println("OTHER")
        for value in obj.other! {
            println(value.name)
        }
        
        println("OTHERS")
        for value in obj.others! {
            let o = value as! Info
            println(o.name)
        }
        
        println("Demo \(obj.demo!)")
    }
    
    ///  测试模型信息
    func testModleInfo() {
        println(loadJSON())
        
        let tools = SwiftDictModel()
        println("模型字典 + \(tools.fullModleInfo(SubModel.self))")
        println("模型字典 + \(tools.fullModleInfo(SubModel.self))")
        println("模型字典 + \(tools.fullModleInfo(Model.self))")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadJSON() -> NSDictionary {
        let path = NSBundle.mainBundle().pathForResource("Model01.json", ofType: nil)
        let data = NSData(contentsOfFile: path!)
        return NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: nil) as! NSDictionary
    }
    
}

