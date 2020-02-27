//
//  TagVC.swift
//  leetcoder
//
//  Created by EricJia on 2019/7/22.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation

import UIKit
import SwiftyJSON
import TagListView
import WebKit

struct TagsColumn {
    var title: String
    var iamgeName: String
    var onTap: ((Any) -> Void)?
}

class TagViewController: BaseViewController {
    var data:JSON! = nil
    var topics:Array<JSON>!
    var companies:Array<JSON>!
    var tagsListView:TagListView!
    var scrollView: UIScrollView!
    var contentView: UIView!
    var diffcultyView: UIView!
    var statusView: UIView!
    var hitsView: UIView!
    var topicsView: UIView!
    var topicTableView: UITableView!
    var cacheFilters: [String: [JSON]] = [:]
 
    override func viewDidLoad() {
        super.viewDidLoad()
        enableLargeTitle()
        navigationItem.title = t(str: "Tags")
        setupViews()
        self.loadCacheFilters()
    }
    
    func createTitleLabel(superView: UIView, title: String) -> UILabel {
        let titleLabel = UILabel.with(size: 13, weight: .medium, colorStr: "#9DADC2")
        superView.addSubview(titleLabel)
        titleLabel.text = t(str: title)
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(10)
        }
        return titleLabel
    }
    
    func createColumView(superView:UIView, title: String, items: [TagsColumn], method:Selector) {
        let titleLabel = createTitleLabel(superView: superView, title: title)
        
        let leftBtn = UIButton()
        superView.addSubview(leftBtn)
        
        
        let midBtn = UIButton()
        superView.addSubview(midBtn)
        
        
        
        let rightBtn = UIButton()
        superView.addSubview(rightBtn)
        let width = (view.frame.size.width - 40 - 40) * 0.33
        leftBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(-10)
            make.width.equalTo(width)
            make.bottom.equalToSuperview().offset(-30)
        }
        midBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(leftBtn)
            make.width.equalTo(width)
            make.centerX.equalToSuperview()
        }
        rightBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(width)
            make.top.bottom.equalTo(leftBtn)
        }
        
        var index = 0
        [leftBtn, midBtn, rightBtn].forEach { (btn) in
            btn.setImage(UIImage(named: items[index].iamgeName), for: .normal)
            btn.imageView?.snp.makeConstraints({ (make) in
                make.size.equalTo(50)
                make.centerY.centerX.equalToSuperview()
            })
            btn.titleLabel?.snp.makeConstraints({ (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(btn.imageView?.snp.bottom ?? 0).offset(20)
                make.bottom.equalToSuperview().offset(0)
            })
//            btn.backgroundColor = UIColor.random()
            btn.setTitle(t(str: items[index].title), for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            btn.setTitleColor(Colors.titleColor, for: .normal)
            btn.titleLabel?.textAlignment = .center
            btn.tag = index
            index += 1
            
            btn.addTarget(self, action: method, for: .touchUpInside)
        }
        
        
    }
    
    func setupViews() {
        data = JSON(TagsFileCache)
        topics = data["topics"].arrayValue.sorted(by: { (a:JSON, b:JSON) -> Bool in
            return a["questions"].arrayValue.count > b["questions"].arrayValue.count
        })
       
        companies =  data["companies"].arrayValue
        
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
            make.leading.trailing.equalTo(scrollView)
        }
        scrollView.backgroundColor = Colors.bgColor
        
        
        diffcultyView = UIView()
        contentView.addSubview(diffcultyView)
        diffcultyView.backgroundColor = Colors.mainColor
        diffcultyView.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        createColumView(superView: diffcultyView, title: "Diffculty", items: [
            TagsColumn(title: "Easy", iamgeName: "easy", onTap: { (_) in
            
            }),
            TagsColumn(title: "Medium", iamgeName: "medium", onTap: { (_) in
                
            }),
            TagsColumn(title: "Hard", iamgeName: "hard", onTap: { (_) in
                
            }),
        ], method: #selector(handleDiffculty))
        
        statusView = UIView()
        contentView.addSubview(statusView)
        statusView.backgroundColor = diffcultyView.backgroundColor
        statusView.snp.makeConstraints { (make) in
            make.left.right.equalTo(diffcultyView)
            make.top.equalTo(diffcultyView.snp.bottom).offset(20)
        }
        createColumView(superView: statusView, title: "Status", items: [
            TagsColumn(title: "Todo", iamgeName: "not done", onTap: { (_) in
                
            }),
            TagsColumn(title: "Solved", iamgeName: "answered", onTap: { (_) in
                
            }),
            TagsColumn(title: "Attempted", iamgeName: "tried", onTap: { (_) in
                
            }),
        ], method: #selector(handleStatus))
        
        hitsView = UIView()
        contentView.addSubview(hitsView)
        hitsView.backgroundColor = diffcultyView.backgroundColor
        hitsView.snp.makeConstraints { (make) in
            make.left.right.equalTo(diffcultyView)
            make.top.equalTo(statusView.snp.bottom).offset(20)
        }
        let hitsTitleLabel = createTitleLabel(superView: hitsView, title: "Hits")
        let hitsLeftImageView = UIImageView(image: UIImage(named: "双引号"))
        hitsView.addSubview(hitsLeftImageView)
        hitsLeftImageView.snp.makeConstraints { (make) in
            make.top.equalTo(hitsTitleLabel.snp.bottom).offset(20)
            make.left.equalTo(hitsTitleLabel)
            make.size.equalTo(24)
        }
        
        var last:UIView = hitsTitleLabel
        for i in 0...companies.count-1 {
            let company = companies[i]
            let button = UIButton()
            hitsView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.left.equalTo(hitsLeftImageView.snp.right).offset(10)
                make.right.equalToSuperview().offset(-10)
                make.top.equalTo(last.snp.bottom).offset(20)
                make.height.greaterThanOrEqualTo(55)
            }
           
            button.setTitle("   " + t(str: company["name"].stringValue), for: .normal)
            button.setTitleColor(Colors.titleColor, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            button.contentHorizontalAlignment = .left
            button.titleLabel?.textAlignment = .left

            
            button.addTarget(self, action: #selector(handleCompany), for: .touchUpInside)
            button.tag = i
            last = button
    
            let width = view.frame.size.width - 37 - 10 - 40
            let height = 55
            let shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: Int(width), height: height))
            
            button.layer.cornerRadius = 3
            if #available(iOS 13.0, *) {
                button.layer.shadowColor = UIColor.init(dynamicProvider: { (trainCollection) -> UIColor in
                    if trainCollection.userInterfaceStyle == .dark {
                        return UIColor(red: 0.35, green: 0.49, blue: 0.64, alpha: 0.5)
                    }
                    return UIColor(red: 0.35, green: 0.49, blue: 0.64, alpha: 0.1)
                }).cgColor
            } else {
                button.layer.shadowColor = UIColor(red: 0.35, green: 0.49, blue: 0.64, alpha: 0.1).cgColor
                // Fallback on earlier versions
            }
            button.layer.shadowOffset = CGSize(width: 0, height: 3)
            button.layer.shadowOpacity = 1
            button.layer.shadowRadius = 7
            button.layer.masksToBounds =  false
            button.layer.shadowPath = shadowPath.cgPath
            button.backgroundColor = Colors.mainColor
        }
        
        last.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
        }
        
        topicsView = UIView()
        contentView.addSubview(topicsView)
        topicsView.backgroundColor = diffcultyView.backgroundColor!
        topicsView.snp.makeConstraints { (make) in
            make.left.right.equalTo(diffcultyView)
            make.top.equalTo(hitsView.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        let topicsTitleLabel = createTitleLabel(superView: topicsView, title: "Topics")
                
        tagsListView = TagListView()
        topicsView.addSubview(tagsListView)
        topics.insert(JSON(["name": "All", "questions": FileCache.getProblemList()]), at: 0)
        var btnCountColor = UIColor.black
        if #available(iOS 13.0, *) {
            btnCountColor = UIColor.init(dynamicProvider: { (trainCollection) -> UIColor in
                if trainCollection.userInterfaceStyle == .dark {
                    return .white
                }
                return .black
            })
        }
        
        for i in 0...topics.count-1 {
            let topic = topics[i]
            let name = t(str: topic["name"].stringValue)
            let questions = topic["questions"].arrayValue
            if questions.count == 0 {
                continue
            }
            
            let count = String(questions.count)
            let tagView = TagView(title: "\(name)  \(count)")
            tagView.cornerRadius = 6
            tagView.borderColor = Colors.borderColor
            tagView.borderWidth  = 0.5
            let attr = NSMutableAttributedString.init(string: "\(name)  \(count)")
            let nameRange = NSRange(location: 0, length: name.count)
            let countRange = NSRange(location: name.count, length: "  \(count)".count)
            attr.addAttribute(.foregroundColor, value: Colors.titleColor, range: nameRange)
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .regular), range: nameRange)

            attr.addAttribute(.foregroundColor, value: btnCountColor, range: countRange)
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .bold), range: countRange)
//            attr.addAttribute(.backgroundColor, value: Colors.mainColor, range: countRange)
            
            tagView.setAttributedTitle(attr, for: .normal)
            tagsListView.addTagView(tagView)
//            let countView = TagView(title: count)
//            tagView.addSubview(countView)
            
            
            
//            countView.layer.cornerRadius = 6
//            countView.layer.masksToBounds =  false
//            countView.tagBackgroundColor =  UIColor(hexStr: "#ECEFEF")
//            countView.textColor = .black
            
//            countView.textFont = font
//            let size = "\(name)  ".size(withAttributes: [NSAttributedString.Key.font: font])
//            let diff = countView.frame.width - "\(count)".size(withAttributes: [NSAttributedString.Key.font: font]).width
//
//            countView.snp.makeConstraints({ (make) in
//                make.centerY.equalTo(tagView.titleLabel!)
//                make.left.equalTo(size.width + (8-diff) + 8 - 1.1)
//            })
            tagView.tag = i
//            countView.tag = i
//            countView.addTarget(self, action: #selector(handleTopic), for: .touchUpInside)
            tagView.addTarget(self, action: #selector(handleTopic), for: .touchUpInside)
        }
        tagsListView.alignment = .left
        tagsListView.marginX = 10
        tagsListView.marginY = 15
        tagsListView.paddingX = 10
        tagsListView.paddingY = 8
        tagsListView.tagBackgroundColor = diffcultyView.backgroundColor!
        tagsListView.textColor = Colors.titleColor
        tagsListView.textFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        tagsListView.snp.makeConstraints { (make) in
            make.top.equalTo(topicsTitleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-10)
//            make.height.equalTo(20 * 40)
        }
    }
   
    func loadCacheFilters() {
        let problems = FileCache.getProblemList()
        DispatchQueue.global().async {
            for (index, key) in ["Easy", "Medium", "Hard"].enumerated() {
                self.cacheFilters[key] = problems.filter({ (element:JSON) -> Bool in
                    return element["difficulty"]["level"].intValue == index + 1
                })
            }
            for (index, key) in ["Todo", "Solved", "Attempted"].enumerated() {
                self.cacheFilters[key] = problems.filter({ (element:JSON) -> Bool in
                    return element["status"].stringValue ==  ["", "ac", "notac"][index]
                })
            }
            
            let allItmes = self.companies + self.topics
            for (_, item) in allItmes.enumerated() {
                let questions = item["questions"].arrayValue
                self.cacheFilters[item["name"].stringValue] = problems.filter({ (element:JSON) -> Bool in
                    return questions.contains(element["stat"]["question_id"])
                })
            }
        }
        
        
    }
    
    @objc func handleDiffculty(sender: UILabel) {
        let key = ["Easy", "Medium", "Hard"][sender.tag]
        jump(key: key)
    }
    
    @objc func handleStatus(sender: UILabel) {
        let key = ["Todo", "Solved", "Attempted"][sender.tag]
        jump(key: key)
    }
    
    @objc func handleTopic(sender: UIButton){
        let item = topics[sender.tag]
        jump(key: item["name"].stringValue)
    }
    
    @objc func handleCompany(sender: UIButton){
        let item = companies[sender.tag]
        jump(key: item["name"].stringValue)
    }
    
    func jump(key: String) {
        let nav: UINavigationController? = self.tabBarController?.viewControllers?[0] as? UINavigationController
        let vc = nav?.topViewController as! HomeViewController
        var items = cacheFilters[key] ?? []
        if key == "All" {
            items = FileCache.getProblemList()
        }
        vc.filterQuesitions = items
        vc.loadFilterData()
        self.tabBarController?.selectedIndex = 0
        print(key, items.count)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

