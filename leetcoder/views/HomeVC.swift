//
//  HomeVC.swift
//  leetcoder
//
//  Created by EricJia on 2019/7/22.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation
import UIKit

import Alamofire
import SnapKit
import SwiftyJSON
import SwiftEntryKit
import Spring
import StoreKit

class HomeViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate {
    
    
    var table:UITableView!
    var items:[JSON] = []
    var displayItems:[JSON] = []
    var filterQuesitions:[JSON] = []
    var rateAscItems:[JSON] = []
    var rateDescItems: [JSON] = []
    var diffAscItems: [JSON] = []
    var diffDescItems: [JSON] = []
    
    var bgView = SpringView()
    var contentView = SpringView()
    var cornerRadiusView = SpringView()
    var diffcultyIndex:Int = -1
    var statusIndex:Int = -1
    var sortIndex:Int = -1
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        enableLargeTitle()
        navigationItem.title = t(str: "Problems")
        let filterBtn = UIBarButtonItem(image: UIImage(named: "home_filter"), style: .plain, target: self, action: #selector(handleRightBtnClick))
        filterBtn.tintColor = Colors.boldColor
        
        let searchBtn = UIBarButtonItem(image: UIImage(named: "home_search"), style: .plain, target: self, action: #selector(handleSearch))
        searchBtn.tintColor = Colors.boldColor
        
        self.navigationItem.rightBarButtonItems = [filterBtn, searchBtn]
        
        //设置UITableView的位置
        table = UITableView()
        table.estimatedRowHeight = 300
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = UITableViewCell.SeparatorStyle.none
        table.backgroundColor = Colors.bgColor
        table.dataSource = self
        table.delegate = self
        view.addSubview(table)
        //注册UITableView，cellID为重复使用cell的Identifier
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ProblemCell")
        self.loadData()
        self.fetchData()
        
        table.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.size.equalToSuperview()
        }
        self.bgView.isHidden = true
        let notificationName = Notification.Name(rawValue: "LoginChange")
        NotificationCenter.default.addObserver(self,
                                    selector:#selector(fetchData),
                                    name: notificationName, object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 60 * 1) {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func updateSortItems() {
        self.rateAscItems = self.items.sorted(by: { (a:JSON, b:JSON) -> Bool in
            let aRate = FileCache.getRateDict(titleSlug: a["stat"]["question__title_slug"].stringValue).arrayValue.last?.doubleValue ?? 0
            let bRate = FileCache.getRateDict(titleSlug: b["stat"]["question__title_slug"].stringValue).arrayValue.last?.doubleValue ?? 0
            return  aRate > bRate
        })
        self.diffAscItems = self.items.sorted(by: { (a:JSON, b:JSON) -> Bool in
            return a["difficulty"]["level"] < b["difficulty"]["level"]
        })
    }
    
    func loadData() {
        let data = FileCache.getProblemList()
        self.items = data
        self.displayItems = data
        self.table.reloadData()
        updateSortItems()
    }
    
    func loadFilterData() {
        if filterQuesitions.count > 0 {
            self.displayItems = filterQuesitions
            self.table.reloadData()
        }
    }
    
    @objc func fetchData() {
        beginLoading()
        MySession.request(Urls.algorithms.withCN(), encoding: JSONEncoding.default).responseJSON { response in
            self.endLoading()
            switch response.result {
                case let .success(value):
                    let result = JSON(value)
                    let temp_items = result["stat_status_pairs"].arrayValue
                    self.items = temp_items.reversed()
                    self.displayItems = self.items
                    if self.items.count > 1000 {
                        FileCache.setProblemList(data: self.items)
                    }
                    self.table.reloadData()
                    self.updateSortItems()
                    let username = result["user_name"].stringValue
                    if username == "" {
                        print("未登录")
                        signOut()
                    }
                    print("当前用户", username)
                case let .failure(error):
                    print(error)
            }
        }
    }
    
    @objc func handleSearch() {
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.placeholder = t(str: "ID / Title")
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    func searchBarCancelButtonClicked() {
        navigationItem.title = t(str: "Problems")
        navigationItem.titleView = nil
        self.displayItems = FileCache.getProblemList()
        self.items = FileCache.getProblemList()
        self.table.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searchBarCancelButtonClicked()
            return 
        }
        let searchTextLower = searchText.lowercased()
        let searchTexts = searchTextLower.components(separatedBy: " ")
        
        let results = self.items.filter { (item: JSON) -> Bool in
            let title = item["stat"]["question__title"].stringValue.lowercased()
            let id = item["stat"]["question_id"].stringValue
            let cnTitle = FileCache.getTransTitle(questionId: id)
            let result = intersectSorted([id, title, cnTitle], searchTexts)
            return result.count > 0 || title.contains(searchTextLower) || cnTitle.contains(searchTextLower)
        }
        
        self.displayItems = results
        self.table.reloadData()
    }
    
    func intersectSorted(_ nums1: [String], _ nums2: [String]) -> [String] {
        var intersects = [String]()
        var i = 0
        var j = 0
        var k = 0
        while i < nums1.count {
            while j < nums2.count && i < nums1.count {
                if nums1[i] == nums2[j] {
                    intersects.append(nums1[i])
                    i += 1
                    j += 1
                    k = j
                }
                j += 1
            }
            i += 1
            j = k
        }
        return intersects
    }
    
    @objc func handleRightBtnClick(){
        if bgView.isHidden == false {
            removeSortBgView()
            return
        }
        bgView.isHidden = false
        view.addSubview(bgView)
        view.addSubview(cornerRadiusView)
        view.addSubview(contentView)
        self.contentView.backgroundColor = Colors.mainColor

        
        self.contentView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(88)
        }
        
        self.bgView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(contentView.snp.bottom).offset(-20)
        }

        let idBtn = UIButton()
        contentView.addSubview(idBtn)
        idBtn.snp.makeConstraints { (make) in
            make.left.equalTo(contentView)
            make.size.equalTo(contentView.snp.width).dividedBy(3)
            make.top.bottom.equalTo(contentView).inset(5)
        }
        
        let acceptBtn = UIButton()
        contentView.addSubview(acceptBtn)
        acceptBtn.snp.makeConstraints { (make) in
            make.left.equalTo(idBtn.snp.right)
            make.size.equalTo(contentView.snp.width).dividedBy(3)
            make.centerY.equalTo(idBtn)
        }
       
        
        let diffBtn = UIButton()
        
        contentView.addSubview(diffBtn)
        diffBtn.snp.makeConstraints { (make) in
            make.left.equalTo(acceptBtn.snp.right)
            make.size.equalTo(contentView.snp.width).dividedBy(3)
            make.centerY.equalTo(idBtn)
        }
        
        let btnImages = ["home_sort_id", "home_sort_accept", "home_sort_diff"]
        for i in  0...btnImages.count-1 {
            let btn = [idBtn, acceptBtn, diffBtn][i]
//            btn.backgroundColor = UIColor.random()
            btn.setImage(UIImage(named: btnImages[i]), for: .normal)
            btn.setImage(UIImage(named: btnImages[i]), for: .highlighted)
            btn.imageView?.snp.makeConstraints({ (make) in
                make.width.equalTo(50)
                make.height.equalTo(50)
                make.centerY.centerX.equalToSuperview()
            })
            btn.titleLabel?.snp.makeConstraints({ (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(btn.imageView?.snp.bottom ?? 0).offset(-20)
                make.bottom.equalToSuperview().offset(0)
            })
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            btn.setTitleColor(Colors.titleColor, for: .normal)
            btn.setTitle(["ID", "Rate", "Diffculty"][i], for: .normal)
            btn.addTarget(self, action: [#selector(sortById), #selector(sortByRate), #selector(sortByDiff)][i], for: .touchUpInside)
        }
        
        
        cornerRadiusView.backgroundColor = Colors.mainColor
        cornerRadiusView.layer.cornerRadius = 15
        cornerRadiusView.layer.masksToBounds = true
        cornerRadiusView.snp.makeConstraints { (make) in
            make.left.right.equalTo(contentView)
            make.top.equalTo(contentView.snp.bottom).offset(-15)
            make.height.equalTo(30)
        }

        contentView.animation = "slideDown"
        contentView.curve = "easeIn"
        contentView.duration = 0.3
        
        cornerRadiusView.animation = "slideDown"
        cornerRadiusView.curve = "easeIn"
        cornerRadiusView.duration = 0.3
       
        self.bgView.animation = "fadeIn"
        self.bgView.curve = "easeIn"
        self.bgView.duration = 0.01
        self.bgView.backgroundColor = Colors.shadowBgColor
        self.contentView.animate()
        self.cornerRadiusView.animate()
        self.bgView.animate()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeSortBgView))
        tap.delegate = self
        bgView.addGestureRecognizer(tap)
        
    }
    
    @objc func sortById() {
        removeSortBgView()
        self.displayItems = self.items.sorted(by: { (a:JSON, b:JSON) -> Bool in
            return a["stat"]["question_id"] < b["stat"]["question_id"]
        })
    }
    
    @objc func sortByRate() {
        removeSortBgView()
        self.displayItems = Array(self.rateAscItems)
    }
    
    @objc func sortByDiff() {
        removeSortBgView()
        self.displayItems = Array(self.diffAscItems)
    }
    
    @objc func removeSortBgView() {
//        if self.bgView.superview != nil {
//            self.bgView.snp.makeConstraints { (make) in
//                make.top.equalTo(contentView.snp.bottom).offset(contentView.frame.size.height * -1)
//            }
//        }
        self.bgView.isHidden = true
        self.bgView.backgroundColor = .clear
        DispatchQueue.main.async{
            self.cornerRadiusView.animation = "slideDown"
            self.cornerRadiusView.curve = "easeInOutBack"
            self.cornerRadiusView.duration = 0.3
            self.cornerRadiusView.animateTo()
        }
        DispatchQueue.main.async{
            self.contentView.animation = "slideDown"
            self.contentView.curve = "easeInOutBack"
            self.contentView.duration = 0.3
            self.contentView.animateTo()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
//            self.bgView.animation = "fadeIn"
//            self.bgView.curve = "easeInOutBack"
//            self.bgView.duration = 0.01
//            self.bgView.animateToNext {
//
//            }
            self.contentView.removeFromSuperview()
            self.bgView.removeFromSuperview()
        }
        self.table.reloadData()
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayItems.count
    }
    
    //设置section的数量
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //设置tableview的cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.displayItems[indexPath.row]
        let question__title = "ProblemCell"
        var cell:MineTableViewCell? = tableView.dequeueReusableCell(withIdentifier: question__title) as? MineTableViewCell
        if cell == nil {
            cell = MineTableViewCell(style: .default, reuseIdentifier: question__title)
        }
        cell!.setData(data: item)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath[1]
        print(index)
        let stat = displayItems[index]["stat"]
        let question__title = stat["question__title_slug"].stringValue
        let problemVC = ProblemViewController(needBack: true)
        problemVC.titleSlug = question__title
        problemVC.questionId = stat["question_id"].stringValue
        self.navigationController?.pushViewController(problemVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if animationKeys.contains(cell.reuseIdentifier!) || animationKeys.count > 10 {
//            return
//        }
//        animationKeys.append(cell.reuseIdentifier!)
//        cellAnimation(tableView: tableView, cell: cell, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
