//
//  ViewController.swift
//  CarHeadline
//
//  Created by Liu Chuan on 2018/1/21.
//  Copyright © 2018年 LC. All rights reserved.
//

import UIKit

/// 标识符
private let identify = "cellID"

/* --- 汽车头条 --- */
class ViewController: UIViewController {
    
    // MARK: - 属性
    /// 字母数组
    fileprivate var letters = [String]()
    
    /// 记录TableView的Y坐标滚动的位置
    fileprivate var lastOffsetY: CGFloat = 0
    
    /// 记录TableView是否向下滚动
    fileprivate var  isScrollDown: Bool = true

    // MARK: - 懒加载属性
    /// 索引视图
    fileprivate lazy var indexView: IndexView = IndexView(frame: nil, delegate: self)

    /// 数据分组模型
    fileprivate lazy var groupModels = [CarGroupModel]()
    
    /// 表格视图
    private lazy var table: UITableView = { [unowned self] in
        let tab = UITableView(frame: view.bounds, style: .grouped)
        tab.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        tab.register(UITableViewCell.self, forCellReuseIdentifier: identify)
        tab.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tab.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        tab.dataSource = self
        tab.delegate = self
        return tab
    }()
    
    /// 提示字母标签
    private lazy var reminderLabel: UILabel = {
        let reminderLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        reminderLabel.center = self.view.center
        reminderLabel.textColor = UIColor.white
        reminderLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        reminderLabel.font = UIFont.systemFont(ofSize: 28)
        reminderLabel.textAlignment = .center
        reminderLabel.isHidden = true
        return reminderLabel
    }()
    
    // MARK: - 视图生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
    
        loadData()
        configUI()
    }
    
    // MARK: - 方法(method)
    /// 加载数据
    fileprivate func loadData() {
        
        // 1.获得plist的全路径
        guard let path = Bundle.main.path(forResource: "cars_total.plist", ofType: nil)  else { return }
        
        // 2.加载数组
        guard let dictArray = NSArray(contentsOfFile: path) as? [[String : Any]] else { return }
        
        // 3.遍历字典,将dictArray里面的所有字典转换成模型对象,放到新的数组中
        for dict in dictArray {
            groupModels.append(CarGroupModel(dict: dict))
        }
        // 4.将dataArrM里面的所有属性,放到新的数组中
        for group in groupModels {
            letters.append(group.title)
        }
        // 5.刷新表格
        table.reloadData()
    }
    
    /// 显示提示字母标题
    ///
    /// - Parameter title: 标题
    fileprivate func showLetter(title: String) {
        reminderLabel.isHidden = false
        reminderLabel.text = title
    }
    
}

// MARK: - 配置UI界面
extension ViewController {
    
    /// 配置UI
    fileprivate func configUI() {
        addSub()
        configNavigationBar()
        configIndexView()
    }
    /// 添加视图
    private func addSub() {
        view.addSubview(table)
        view.addSubview(indexView)
        view.addSubview(reminderLabel)
        view.bringSubviewToFront(indexView)
    }
    /// 配置导航栏
    private func configNavigationBar() {
        navigationItem.title = "汽车头条"
        navigationController?.navigationBar.barTintColor = .red
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    /// 配置索引视图
    private func configIndexView() {
        indexView.selectedScaleAnimation = true
        indexView.backgroundColor = UIColor(white: 1, alpha: 0.5)
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return groupModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let group = groupModels[section]
        return group.carModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 创建cell, 并设置其相关属性
        let cell = tableView.dequeueReusableCell(withIdentifier: identify, for: indexPath)
        let group = groupModels[indexPath.section]
        let model = group.carModels[indexPath.row]
        cell.textLabel?.text = model.name
        cell.imageView?.image = UIImage(named: model.icon)
        cell.accessoryType = .none
        return cell
    }
    
    // 头部标题
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let group = groupModels[section]
        return group.title
    }
}


// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    // 每组头部的高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    // 每组尾部的高度
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    // 点击cell闪烁动画
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // 头部视图将要显示时调用
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        // 如果TableView处于开始滚动状态, 且向上滚动
        if tableView.isDragging && !isScrollDown {
        /*
             参数:
             aName: aName是名称，定义一个类型为NSNotification.Name的全局常量，或者扩展NSNotification.Name即可
                    所有观察LCDidEndDisplayingHeaderViewNotification的对象都会收到这条post了。
             object: 一般是在哪个类中调用post方法，就传哪个类。有的人喜欢用这个参数来传递参数，不是说不行，只是我感觉不太舒服。
             userInfo: 才是用来传参数的字段，[AnyHashable : Any]的范围足够你爱传什么传什么了。
        */
            LCNotificationCenter.post(name: Notification.Name.init(LCDidEndDisplayingHeaderViewNotification), object: nil, userInfo: ["section": section + 1])
        }
    }
    // 头部视图完全消失时调用
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        // 如果TableView处于开始滚动状态, 且向下滚动
        if tableView.isDragging && isScrollDown {
            LCNotificationCenter.post(name: Notification.Name.init(LCDidEndDisplayingHeaderViewNotification), object: nil, userInfo: ["section": section + 1])
        }
    }
}


// MARK: - IndexViewDelegate
extension ViewController: IndexViewDelegate {
    
    // 点击右侧索引表项时调用
    func indexView(_ indexView: IndexView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {

        // 点击字母 向上滚动到 该分组的第0行
        table.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)

        showLetter(title: title)

        return index
    }

    func indexView(_ indexView: IndexView, cancelTouch: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.8) {
            self.reminderLabel.isHidden = true
        }
    }
    
    func indexViewSectionIndexTitles(for indexView: IndexView) -> [String]? {
        return letters
    }
}
