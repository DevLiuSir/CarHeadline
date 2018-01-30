//
//  CarGroupModel.swift
//  CarHeadline
//
//  Created by Liu Chuan on 2018/1/26.
//  Copyright © 2018年 LC. All rights reserved.
//

import UIKit
/*
    - 在swift3中，编译器自动推断@objc，换句话说，它自动添加@objc
    - 在swift4中，编译器不再自动推断，你必须显式添加@objc
 */

class CarGroupModel: NSObject {
    
    /// 这组的标题
    @objc var title: String!
    
    /// 汽车模型数组
    @objc var carModels: [CarModel] = [CarModel]()
    
    /// 存放的所有的汽车品牌(里面装的都是CarModel模型)
    @objc var cars: [[String : NSObject]]? {
        didSet {
            guard let car = cars else { return }
            for dict in car {
                carModels.append(CarModel(dict: dict))
            }
        }
    }
    
    // MARK: 定义字典转模型的构造函数
    init(dict: [String: Any]) {
        super.init()
        // 使用KVC字典转模型
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
}
