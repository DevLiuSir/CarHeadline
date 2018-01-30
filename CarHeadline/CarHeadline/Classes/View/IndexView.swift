//
//  IndexView.swift
//  CarHeadline
//
//  Created by Liu Chuan on 2018/1/28.
//  Copyright © 2018年 LC. All rights reserved.
//

import UIKit


// MARK: - 全局参数
let screenBounds = UIScreen.main.bounds
let screenW      = UIScreen.main.bounds.size.width
let screenH      = UIScreen.main.bounds.size.height

/// 通知中心
let LCNotificationCenter = NotificationCenter.default

/// 头部 即将消失 的通知
let LCWillDisplayHeaderViewNotification = "LCWillDisplayHeaderViewNotification"

/// 头部 完全消失 的通知
let LCDidEndDisplayingHeaderViewNotification = "LCDidEndDisplayingHeaderViewNotification"


/// 索引视图
class IndexView: UIView {
    
    // MARK: - 私有属性
    /// 选中颜色
    fileprivate var selectedColor: UIColor = UIColor.red
    
    /// 默认颜色
    fileprivate var normalColor: UIColor = UIColor.gray
    
    /// 选中的索引
    fileprivate var selectedIndex: Int = 0

    /// 字母按钮数组 (用来记录UIButton)
    fileprivate lazy var letterButtons: [UIButton] = [UIButton]()
    
    /// 选中按钮
    fileprivate lazy var selectedButton: UIButton = UIButton()
    
    // MARK: - 接口属性
    /// 选中的标题是否放大, 默认:false
    public var selectedScaleAnimation: Bool = false
    
    /// 代理
    weak var delegate: IndexViewDelegate?
    
    /// 选中标题颜色
    var selectTitleColor: UIColor = UIColor.red {
        didSet {
            selectedColor = selectTitleColor
        }
    }
    
    /// 默认标题颜色
    var normalTitleColor: UIColor = UIColor.gray {
        didSet {
            normalColor = normalTitleColor
        }
    }
    
    /// 右边显示的字母索引数组
    var letters: [String] = [String]() {
        didSet {
            reloadSectionIndexTitles()
        }
    }
  
    // MARK: - 初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect(x: screenW - 20, y: 0, width: 20, height: screenH)
        
        // 注册滑动通知
        /**
         *参数一：注册观察者对象，参数不能为空
         *参数二：收到通知执行的方法，可以带参
         *参数三：通知的名字
         *参数四：收到指定对象的通知，没有指定具体对象就写nil
         */
        LCNotificationCenter.addObserver(self, selector: #selector(scrollViewSelectButtonTitleColor(noti:)), name: Notification.Name.init(LCWillDisplayHeaderViewNotification), object: nil)
        
        LCNotificationCenter.addObserver(self, selector: #selector(scrollViewSelectButtonTitleColor(noti:)), name: Notification.Name.init(LCDidEndDisplayingHeaderViewNotification), object: nil)
    }
    
    
    /// 滑动选择按钮, 并改变标题按钮的颜色
    ///
    /// - Parameter noti: 通知
    @objc fileprivate func scrollViewSelectButtonTitleColor(noti: NSNotification) {
        
        guard let section: Int = noti.userInfo?["section"] as? Int else { return }
        guard section < letterButtons.count else { return }
        let btn = letterButtons[section]
        //print(section)
        
        UIView.animate(withDuration: 0.25) {
            self.selectedButton.setTitleColor(.gray, for: .normal)
            self.selectedButton = btn
            self.selectedButton.setTitleColor(.red, for: .normal)
        }
        if selectedScaleAnimation {
            scaleSelectedButton(btn: btn)
        }
    }
    
    
    /*
     指定构造器: 必须调用它直接父类的指定构造器方法.
     便利构造器: 必须调用同一个类中定义的其它初始化方法.
     便利构造器: 在最后必须调用一个指定构造器.
     */
    
    /// 便利构造器
    ///
    /// - Parameters:
    ///   - frame: 位置尺寸
    ///   - delegate: 代理协议
    public convenience init(frame: CGRect?, delegate: IndexViewDelegate?) {
        self.init()
        self.delegate = delegate
        
        /*返回一个布尔值，该值指示接收者是否实现或继承能够响应指定消息的方法。
         应用程序负责判断是否应该将错误响应视为错误。*/
        let dele = (delegate?.responds(to: #selector(IndexViewDelegate.indexViewSectionIndexTitles(for:))))!
        
        guard delegate != nil && dele == true else { return }
        
        letters = delegate!.indexViewSectionIndexTitles(for: self)!
        
        reloadSectionIndexTitles()
    }

    // 销毁
    deinit {
        print("IndexView == deinit")
        // 移除通知
        LCNotificationCenter.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // 一根或多根手指 `触摸` 屏幕
    ///
    /// - Parameters:
    ///   - touches: 触摸
    ///   - event: 事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesMoved(touches, with: event)
    }
    
    /// 一根或多根手指 在屏幕上 `移动`
    ///
    /// - Parameters:
    ///   - touches: 触摸
    ///   - event: 事件
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 获取点击的第一下
        guard let touch = touches.first else { return }
        
        // 获取当前的触摸焦点
        let touchFocus = touch.location(in: self)
        
        // 遍历 letterButtons 数组
        for btn in letterButtons {
            
            // 将btn的转化为 坐标
            let btnPoint = self.convert(touchFocus, to: btn)
            
            // 判断当前点是否点在按钮上
            if btn.point(inside: btnPoint, with: event) {
                
                btn.setTitleColor(selectedColor, for: .normal)
                
                guard let i = letterButtons.index(of: btn) else { return }
                
                let letter = btn.currentTitle ?? ""
                
                // 该值指示: 接收者是否实现或继承能够响应指定消息的方法。BOOL值
                let dele = (delegate?.responds(to: #selector(IndexViewDelegate.indexView(_:sectionForSectionIndexTitle:at:))))!
                
                guard delegate != nil && dele == true else { return }
                let _ = delegate?.indexView(self, sectionForSectionIndexTitle: letter, at: i)
        
                if selectedScaleAnimation {
                    scaleSelectedButton(btn: btn)
                }
                
            }else {
                btn.setTitleColor(normalColor, for: .normal)
                btn.layer.transform = CATransform3DIdentity
            }
        }
    }

    
    /// 一根或多根手指 `离开` 屏幕
    ///
    /// - Parameters:
    ///   - touches: 触摸
    ///   - event: 事件
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
        
        // 该值指示: 接收者是否实现或继承能够响应指定消息的方法。BOOL值
        let dele = (delegate?.responds(to: #selector(IndexViewDelegate.indexView(_:cancelTouch:with:))))!
        
        guard delegate != nil && dele == true else { return }
        
        let _ = delegate?.indexView!(self, cancelTouch: touches, with: event)
    }
    
}


// MARK: - 配置UI界面
extension IndexView {
    
    /// 配置UI界面
    fileprivate func configUI() {
        
        // 遍历当前所有子视图
        for view in self.subviews {
            view.removeFromSuperview()
        }
        letterButtons.removeAll()
        
        let btnHeight: CGFloat = 30.0
        let btnWidth: CGFloat = self.frame.size.width
        let btnX: CGFloat = 0.0
        // 创建所有索引字母按钮
        for (i, letter) in letters.enumerated() {
            
            let btnY: CGFloat = CGFloat(i) * btnHeight
            // 创建按钮, 并设置其相关属性
            let btn = UIButton(frame: CGRect(x: btnX, y: btnY, width: btnWidth, height: btnHeight))
            btn.setTitle(letter, for: .normal)
            btn.setTitleColor(normalColor, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            btn.isUserInteractionEnabled = false
            
            // 如果按钮索引为:选中索引, 设置btn颜色为: 选中颜色, 否则为: 默认颜色
            let btn_Color = i == selectedIndex ? selectedColor : normalColor
            selectedButton = btn
            btn.setTitleColor(btn_Color, for: .normal)
           
            addSubview(btn)
            letterButtons.append(btn)
        }
    
        /* 调用此方法后，才可以获取到正确的frame*/
        // 强制更新布局
        layoutIfNeeded()
        
        // 设置当前IndexView的frame
        frame.size.height = CGFloat(letterButtons.count) * btnHeight
        center = CGPoint(x: screenW - 10, y: screenH * 0.5)
        
    }
    
    
    /// 放大选中按钮
    ///
    /// - Parameter btn: 按钮
    fileprivate func scaleSelectedButton(btn: UIButton) {
        btn.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)   // 放大
        UIView.animate(withDuration: 0.25) {
            btn.layer.transform = CATransform3DIdentity             // 还原
        }
    }
    /// 重新加载段索引标题
    fileprivate func reloadSectionIndexTitles() {
        configUI()
    }

}

// MARK: - 代理协议
@objc
protocol IndexViewDelegate: NSObjectProtocol {
    
    // 手指触摸的时候调用
    /// 分给索引视图的索引标题
    ///
    /// - Parameters:
    ///   - indexView: 索引视图
    ///   - title: 标题
    ///   - index: 索引
    /// - Returns: 索引
    func indexView(_ indexView: IndexView, sectionForSectionIndexTitle title: String, at index: Int) -> Int

    /// 返回要显示的section索引标题
    ///
    /// - Parameter indexView: 索引视图
    /// - Returns: 索引标题数组
    func indexViewSectionIndexTitles(for indexView: IndexView) -> [String]?
    
    // 手指离开的时候调用
    ///
    /// - Parameters:
    ///   - indexView: 索引视图
    ///   - cancelTouch: 取消点击
    ///   - event: 点击事件
    @objc optional func indexView(_ indexView: IndexView, cancelTouch: Set<UITouch>, with event: UIEvent?)
}

