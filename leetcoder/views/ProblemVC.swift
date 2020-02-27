//
//  ProblemVC.swift
//  leetcoder
//
//  Created by EricJia on 2019/7/22.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation

import UIKit
import WebKit

import TagListView
import Cosmos
import SwiftyJSON
import Alamofire
//import EasyTipView
import UIDeviceComplete


class ProblemViewController: BaseViewController, WKNavigationDelegate, UITableViewDataSource, UITableViewDelegate  {
    var titleSlug:String = "two-sum"
    var questionTitle:String = "Two Sum"
    var questionId:String = "1"
    var descDict:JSON = []
    var tableViewItems:Array<ProblemItem>!
    
    var scrollView: UIScrollView!
    var contentView: UIView!
    
    var titleLabel: UILabel!
    var statusView: UIButton!
    var starView: CosmosView!
    var difficultyLabel: UILabel!
    
    var contentWebView: WKWebView!
    
    var tagsView: TagListView!
    var similarsView: TagListView!
    var tableView:UITableView!
    var solveBtn: UIButton!
    var discussVC: DiscussViewController!
    var submissionsVC: SubmitsViewController!
    var isIpadaTwoView:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        navigationItem.title = t(str: "Problem")
        
        setupViews()
        print("ProblemVC:", titleSlug)
        
        self.discussVC = DiscussViewController()
        self.submissionsVC = SubmitsViewController()
    
//        同屏幕
        isIpadaTwoView = view.frame.size.width > 700
        if isIpadaTwoView {
            scrollView.snp.makeConstraints { (make) in
                make.width.equalToSuperview().dividedBy(2)
            }
            handleSolve()
        }
//        handleSolve()
        
    }
    
    func setupViews(){
        scrollView = UIScrollView()
        contentView = UIView()
        
        view.addSubview (scrollView)
        scrollView.addSubview (contentView)
        
        titleLabel = UILabel()
        contentView.addSubview (titleLabel)
        contentWebView = WKWebView()
        contentView.addSubview(contentWebView)
        tagsView = TagListView()
        contentView.addSubview(tagsView)
        
        statusView = UIButton()
        contentView.addSubview(statusView)
        
        starView = CosmosView()
        statusView.addSubview(starView)
        
        difficultyLabel = UILabel()
        statusView.addSubview(difficultyLabel)
    
        solveBtn = UIButton()
        contentView.addSubview(solveBtn)
        
        
        contentWebView.scrollView.isScrollEnabled = false
        contentWebView.navigationDelegate = self
//        setupDatas()
        
        
        scrollView.snp.makeConstraints ({(make) in
            make.edges.equalTo(view)
            
        })
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        statusView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(10)
            make.right.equalTo(scrollView).offset(-20)
            make.width.equalTo(60)
            make.height.equalTo(50)
        }
        
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        titleLabel.textColor = Colors.titleColor
        titleLabel.numberOfLines = 0
        titleLabel.snp.makeConstraints ({(make) in
            make.top.equalTo(contentView).offset(10)
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(statusView.snp.left).offset(-10)
        })
        
        statusView.layer.borderColor = Colors.borderColor.cgColor
        statusView.layer.borderWidth = 0.5
        statusView.layer.cornerRadius = 2
        statusView.layer.masksToBounds = true
        
//        statusView.layer.cornerRadius = 2
        
        
        
        difficultyLabel.font = UIFont.systemFont(ofSize: 13)
        difficultyLabel.textColor = UIColor(hex: 0xFFFFFF)
        difficultyLabel.layer.cornerRadius = 2
        difficultyLabel.layer.masksToBounds = true
        difficultyLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        
        starView.settings.starSize = 7
        starView.settings.starMargin = 1
        starView.settings.updateOnTouch = false
        starView.settings.filledImage = UIImage(named: "problem_star")
        starView.settings.emptyImage = UIImage(named: "problem_unstar")
        starView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.centerX.equalToSuperview()
        }
        
//        statusView.backgroundColor = .gray
        
        contentWebView.snp.makeConstraints ({(make) in
            make.left.equalTo(contentView).offset(10)
            make.top.equalTo(statusView.snp.bottom).offset(20)
//            make.leading.trailing.equalTo(contentView)
            make.right.equalTo(contentView).offset(-10)
            make.height.equalTo(0)
            
        })
        
        
        statusView.snp.makeConstraints ({(make) in
//            make.top.equalTo(contentView).offset(10)
            make.right.equalTo(contentWebView.snp.right)
        })
        
        tagsView.textFont = UIFont.systemFont(ofSize: 15, weight: .regular)
        tagsView.textColor = Colors.titleColor
        tagsView.tagBackgroundColor = Colors.mainColor
        tagsView.alignment = .left
        tagsView.paddingX = 12
        tagsView.paddingY = 8
        tagsView.snp.makeConstraints { (make) in
            make.top.equalTo(contentWebView.snp.bottom).offset(20)
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
        }
        
        //设置UITableView的位置
        tableView = UITableView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = 45
        tableView.isScrollEnabled = false
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.separatorColor = Colors.borderColor
        //设置数据源
        tableView.dataSource = self
        //设置代理
        tableView.delegate = self
        contentView.addSubview(tableView)
        //注册UITableView，cellID为重复使用cell的Identifier
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProblemItemCell")
        tableViewItems = [
            ProblemItem(imgBgColor: .clear, textColor: .black, title: "Discuss", img: "problem_read", rightTitle: "", onTap: { (_) in
                let vc = DiscussViewController()
                vc.topicId = self.descDict["boundTopicId"].stringValue
                vc.questionId = "\(self.questionId)"
                self.navigationController?.pushViewController(vc, animated: true)
            }),
            ProblemItem(imgBgColor: .clear, textColor: .black, title: "Submissions", img: "problem_history_commit",rightTitle: "", onTap: { (_) in
                let vc = SubmitsViewController()
                vc.questionSlug = self.titleSlug
                self.navigationController?.pushViewController(vc, animated: true)
            })
        ]
        
        if FileCache.isGlobal() == false {
            tableViewItems.insert(ProblemItem(imgBgColor: .clear, textColor: .black, title: "Solutions", img: "problem_history_solution",rightTitle: "", onTap: { (_) in
                let vc = SolutionsViewController()
                vc.questionSlug = self.titleSlug
                self.navigationController?.pushViewController(vc, animated: true)
            }), at: 1)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(tagsView.snp.bottom).offset(10)
            make.left.equalTo(contentView).offset(0)
            make.right.equalTo(contentView).offset(0)
            make.height.equalTo(45 * tableViewItems.count)
        }
        
        solveBtn.backgroundColor = Colors.base
        solveBtn.setTitleColor(.white, for: .normal)
        solveBtn.layer.cornerRadius = 5
        solveBtn.setTitle(t(str: "Solve"), for: .normal)
        solveBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        solveBtn.addTarget(self, action: #selector(handleSolve), for: .touchUpInside)
        solveBtn.snp.makeConstraints { (make) in
            make.top.equalTo(tableView.snp.bottom).offset(20)
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.height.equalTo(45)
            make.bottom.equalTo(contentView).offset(-20)
        }
        fetchData()
        setupDatas()
    }
    
    func fetchData() {
//        beginLoading()
        let parameters = [
            "query": FileCache.isGlobal() ? GraphqlSchema.Problem : GraphqlSchema.cnProblem,
            "operationName": "questionData",
            "variables": ["titleSlug": titleSlug]
            ] as [String : Any]
        MySession.request(Urls.graphql.withCN(), method:.post, parameters: parameters, encoding: JSONEncoding.default, headers: getHeaders()).responseJSON { response in
//            self.endLoading()
            switch response.result {
            case let .success(value):
                self.descDict = JSON(value)["data"]["question"]
//                self.setupDatas()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    func setupDatas() {
        descDict  = FileCache.getDescDict(titleSlug: titleSlug)

        let rateData = FileCache.getRateDict(titleSlug:titleSlug).arrayValue
        
        let topicTags = descDict["topicTags"].arrayValue
        let tags = topicTags.map { (dict:JSON) -> String in
            return t(str: dict["name"].stringValue)
        }
        var isDisplayTag = false
        let displayTag = tagsView.addTag(t(str: "Related Topics"))
        displayTag.onTap = { tagView in
            if isDisplayTag == true {
                for tag in tags {
                    self.tagsView.removeTag(tag)
                }
                tagView.setTitle(t(str: "Related Topics"), for: .normal)
            } else {
                self.tagsView.addTags(tags)
                tagView.setTitle(t(str: "Close Topics"), for: .normal)
            }
            isDisplayTag = !isDisplayTag
        }
        
        let rate = rateData.last?.doubleValue
        starView.rating = Double(rate ?? 0)
        
        let difficulty = descDict["difficulty"].stringValue
        let translatedTitle = descDict["translatedTitle"].stringValue
        
        difficultyLabel.text = t(str: difficulty)
        difficultyLabel.textColor = ["Easy": Colors.easy,
                                          "Medium": Colors.medium,
                                          "Hard": Colors.hard][difficulty] ?? Colors.easy
        
        let translatedContent = descDict["translatedContent"].stringValue
        var content = descDict["content"].stringValue
        if LanguageHelper.isCN() && translatedTitle != "" {
            titleLabel.text =  "\(descDict["questionId"].stringValue). \(translatedTitle)"
        } else {
            titleLabel.text =  "\(descDict["questionId"].stringValue). \(descDict["title"].stringValue)"
        }
        if LanguageHelper.isCN() && translatedContent != "" {
            content = translatedContent
        }
        
        if content == "" {
            content = t(str: "Something is wrong, This may be a premium problem")
        }
        let contentHtml = wapperContentHTML(content: content)
        contentWebView.loadHTMLString(contentHtml, baseURL: nil)
    }
    
    @objc func handleSolve(){
        let codeSnippets = descDict["codeSnippets"].arrayValue
        let sampleTestCase = descDict["sampleTestCase"].stringValue
        for codeSnippet in codeSnippets {
            let lang = codeSnippet["lang"].stringValue
            let code = codeSnippet["code"].stringValue
            let langSlug = codeSnippet["langSlug"].stringValue
            
            let codeLanguage = EditorHelper.currentLang()
            if lang == codeLanguage {
                let editorVC = EditorViewwController()
                editorVC.lang = lang
                editorVC.code = code
                editorVC.langSlug = langSlug
                editorVC.sampleTestCase = sampleTestCase
                editorVC.questionId = self.questionId
                editorVC.titleSulg = self.titleSlug
                if isIpadaTwoView {
                    self.addChild(editorVC)

                    self.view.addSubview(editorVC.view)
                    editorVC.view.snp.makeConstraints { (make) in
                        make.width.equalTo(self.scrollView)
                        make.height.equalTo(self.scrollView)
                        make.left.equalTo(self.scrollView.snp.right)
                    }
                } else {
                    self.navigationController?.pushViewController(editorVC, animated: true)
                }
                return
            }
        }
        print("没找到对应编程模板, 出错")
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        contentWebView.evaluateJavaScript("document.querySelector('#main').offsetHeight") { (result, err) in
            let height = result as! Int
            self.contentWebView.snp.updateConstraints({ (make) in
                make.height.equalTo(height + 40)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewItems.count
    }
    
    //设置section的数量
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //设置tableview的cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = "ProblemItemCell"
        let index = indexPath[1]
        var cell:ProblemItemCell! = tableView.dequeueReusableCell(withIdentifier: indentifier)as?ProblemItemCell
        if cell == nil {
            cell = ProblemItemCell(style: .default, reuseIdentifier: indentifier)
        }
        cell.setData(data: tableViewItems[index])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath[1]
        tableViewItems[index].onTap?(index)
    }
    
}
