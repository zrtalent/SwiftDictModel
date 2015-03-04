//
//  ViewController.swift
//  02-字典转模型
//
//  Created by apple on 15/3/3.
//  Copyright (c) 2015年 heima. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftDictModel().modelInfo(Model.self)
    }
    
    func loadJSON() -> NSDictionary {
        let path = NSBundle.mainBundle().pathForResource("Model01.json", ofType: nil)
        return NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: path!)!, options: NSJSONReadingOptions.allZeros, error: nil) as! NSDictionary
    }
    
}

