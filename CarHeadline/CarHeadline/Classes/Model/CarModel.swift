//
//  CarModel.swift
//  CarHeadline
//
//  Created by Liu Chuan on 2018/1/21.
//  Copyright © 2018年 LC. All rights reserved.
//

import UIKit

/*
    - 在swift3中，编译器自动推断@objc，换句话说，它自动添加@objc
    - 在swift4中，编译器不再自动推断，你必须显式添加@objc
 */

class CarModel: NSObject {
    
    /// 图片
    @objc var icon: String!
    
    /// 名字
    @objc var name: String!
    
    // MARK: 定义字典转模型的构造函数
    init(dict: [String: Any]) {
        super.init()
        
        // 使用KVC字典转模型
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
}
