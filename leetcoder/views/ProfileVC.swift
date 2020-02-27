//
//  ProfileVC.swift
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
import Alamofire
import Kingfisher
import StoreKit


class ProfileViewController: BaseViewController, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate {
    
    
    
    var data:JSON! = nil
    var scrollView: UIScrollView!
    var contentView: UIView!
    var avatarImageView: UIImageView!
    var usernameLael:UILabel!
    var emailLabel:UILabel!
    var colltionView: UICollectionView!
    var tableView:UITableView!
    
    var tableViewItems:Array<Array<ProblemItem>> = []
    var commits:JSON! = []
    var commitCount:Int=7*52
    
    var acLeftLabel: UILabel = UILabel.with(size: 13, weight: .medium, color: Colors.titleColor)
    var acMidLabel: UILabel = UILabel.with(size: 13, weight: .medium, color: Colors.titleColor)
    var acRightLabel: UILabel = UILabel.with(size: 13, weight: .medium, color: Colors.titleColor)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableLargeTitle()
        navigationItem.title = t(str: "Profile")
        setViews()
        
        let cacheUser = FileCache.getVal("user")
        let cacheCommits = FileCache.getVal("commits")
        self.data = JSON(cacheUser ?? "")
        self.commits = JSON(cacheCommits ?? "")
        fetchData()

        if isSignIn() == false {
            let loginvc = LoginViewController(needBack: true)
            self.navigationController?.pushViewController(loginvc, animated: true)
        }
        
    }
    
    func setViews() {
        tableView = UITableView()
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
//        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Colors.bgColor
//        let footerView = UIView(frame: CGRect.zero)
//        tableView.tableFooterView = footerView
        view.addSubview(tableView)
        //注册UITableView，cellID为重复使用cell的Identifier
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProblemItemCell")
        var editorSettingVc = UIViewController()
        DispatchQueue.main.async {
            editorSettingVc = EditerSettingViewController()
        }
        tableViewItems = [
            [],
            [],
            [],
            [
                ProblemItem(imgBgColor: .clear, textColor: .black, title: "Settings", img: "profile_editor_setting", rightTitle: "", onTap: { (_) in
                    self.navigationController?.pushViewController(editorSettingVc, animated: true)
                }),
                ProblemItem(imgBgColor: .clear, textColor: .black, title: "Languages", img: "profile_language", rightTitle: "", onTap: { (_) in
                    let vc = SettingsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }),
                ProblemItem(imgBgColor: .clear, textColor: .black, title: "About", img: "profile_about", rightTitle: "", onTap: { (_) in
                    let vc = AboutViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }),
            ],
            [
                ProblemItem(imgBgColor: .clear, textColor: .black, title: "", img: "profile_signout", rightTitle: "", onTap: { (_) in
            })
            ]
        ]
        
        if isSignIn() {
            self.setSigninStatus()
        } else {
            self.setSignoutStatus()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
//        if #available(iOS 10.3, *) {
//            SKStoreReviewController.requestReview()
//        } else {
//            // Fallback on earlier versions
//        }
        
    }
    
    func setSigninStatus() {
        tableViewItems[tableViewItems.count - 1][0].title = "Sign out"
        tableViewItems[tableViewItems.count - 1][0].onTap = { _ in
            signOut()
            self.setSignoutStatus()
            self.fetchData()
        }
        self.tableView.reloadData()
    }
    
    func setSignoutStatus() {
        
        tableViewItems[tableViewItems.count - 1][0].title = "Sign in"
        tableViewItems[tableViewItems.count - 1][0].onTap = { _ in
            let loginVC = LoginViewController()
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
        FileCache.setVal([], forKey: "user")
        FileCache.setVal([], forKey: "commits")
        signOut()
        endLoading()
        self.tableView.reloadData()
    }
    
    func setData() {
        let profile = data["profile"]
        let url = URL(string: profile["userAvatar"].stringValue)
        if profile["userAvatar"].stringValue != "" {
            avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "logo"))
        }
        usernameLael.text = data["username"].stringValue
        
        if FileCache.isGlobal() {
            emailLabel.text = data["email"].stringValue
            let acStats = profile["acStats"]
            acLeftLabel.text = "\(acStats["acQuestionCount"].intValue)/\(FileCache.getProblemList().count)"
            acMidLabel.text = "\(acStats["acSubmissionCount"].intValue)/\(acStats["totalSubmissionCount"].intValue)"
            acRightLabel.text = "\(acStats["acRate"].intValue)%"
        } else {
            if isSignIn() {
                emailLabel.text = ""
            }
            let acStats = data["submissionProgress"]
            acLeftLabel.text = "\(acStats["acTotal"].intValue)/\(FileCache.getProblemList().count)"
            acMidLabel.text = "\(acStats["acSubmissions"].intValue)/\(acStats["totalSubmissions"].intValue)"
            var rate = 0.0
            if acStats["totalSubmissions"].intValue > 0 {
                rate = Double(acStats["acSubmissions"].doubleValue / acStats["totalSubmissions"].doubleValue * 100.0).rounded(places: 2)
            }
            acRightLabel.text = "\(rate)%"
        }
        tableView.reloadData()
    }
    
    
    
    func fetchData() {
        beginLoading()
        let headers = getHeaders()
        if FileCache.isGlobal() {
            let parameters = [
                "query": "{\n  user {\n    username\n    firstName\n    lastName\n    isActive\n    isCurrentUserPremium\n    isCurrentUserVerified\n    profile {\n      userSlug\n      realName\n      birthday\n      aboutMe\n      reputation\n      occupation\n      country\n      school\n      company\n      lastModified\n      countryName\n      countryCode\n      userAvatar\n      location\n      gender\n      privacyContact\n      websites\n      rewardStats\n      skillTags\n      age\n      education\n      yearsOfExperience\n      globalRanking\n      contestCount\n      acStats {\n        acQuestionCount\n        acSubmissionCount\n        totalSubmissionCount\n        acRate\n      }\n      ranking {\n        rating\n        ranking\n        currentGlobalRanking\n        currentRating\n        ratingProgress\n      }\n      skillSet {\n        topics {\n          name\n        }\n      }\n    }\n    socialAccounts\n    email\n    emails {\n      email\n      verified\n      primary\n    }\n    phone\n    isDiscussAdmin\n    isDiscussStaff\n    id\n  }\n}\n",
                "operationName": "",
                "variables": ""
            ]
            MySession.request(Urls.graphql, method:.post, parameters:parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                self.endLoading()
                switch response.result {
                case let .success(value):
                    self.data = JSON(value)["data"]["user"]
                    FileCache.setVal(self.data.rawString(), forKey: "user")
                    let username = self.data["username"].stringValue
                    if username != "" && username != "." {
                        self.fetchCommits()
                        self.setSigninStatus()
                    } else {
                        self.setSignoutStatus()
                    }
                    self.setData()
                    print(value)
                case let .failure(error):
                    print(error)
                }
            }
        } else {
            let parameters = [
                "query": GraphqlSchema.cnPublicUser,
                "operationName": "userPublicProfile",
                "variables": ["userSlug": getUsername()],
                ] as [String : Any]
            MySession.request(Urls.graphql.withCN(), method:.post, parameters:parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                self.endLoading()
                switch response.result {
                case let .success(value):
                    self.data = JSON(value)["data"]["userProfilePublicProfile"]
                    let username = self.data["username"].stringValue
                    FileCache.setVal(self.data.rawString(), forKey: "user")
                    if username != "" && username != "." {
                        self.fetchCommits()
                        self.setSigninStatus()
                    } else {
                        self.setSignoutStatus()
                    }
                    self.setData()
                    print(value)
                case let .failure(error):
                    print(error)
                }
            }
        }
        
    }
    
    
    
    func fetchCommits() {
        let headers = getHeaders()
        MySession.request(Urls.submissions_cal.replace(target: "$username", withString: data["username"].stringValue).withCN(), method:.get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            self.endLoading()
            switch response.result {
            case let .success(value):
                let jsonStr = stringValueDic(value as! String) as Any
                self.commits = JSON(jsonStr)
                FileCache.setVal(self.commits.rawString(), forKey: "commits")
                self.colltionView.reloadData()
                self.colltionView?.layoutIfNeeded()
                self.colltionView?.scrollToItem(at: NSIndexPath(item: self.commitCount-1, section: 0) as IndexPath, at: .right, animated: false)
                
            case let .failure(error):
                print(error)
            }
        }
    }
    
    //返回多少个组
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    //返回多少个cell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commitCount
    }
    
    func getCellTs(index: Int) -> Int {
        let now = Date(timeIntervalSinceNow: 0)
        let timeInterval:TimeInterval = getMorningDate(date: now).timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        let curTs = timeStamp - (commitCount - index) * 60*60*24 + 8*60*60
        return curTs
    }
    
    //返回自定义的cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(index)_cell", for: indexPath as IndexPath) as! CalendarCell
        
        if commits != nil {
            let curTs = getCellTs(index: index)
            let commit = commits[String(curTs)].intValue
            cell.setData(cmt: commit)
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        do {
            let index = indexPath.row
            let cell:CalendarCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(index)_cell", for: indexPath as IndexPath) as! CalendarCell
            let curTs = getCellTs(index: index)
            let date = Date(timeIntervalSince1970: TimeInterval(curTs))
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "YYYY-MM-dd"
            let dateString = dateformatter.string(from: date)
            let commit = commits[String(curTs)].intValue
            self.becomeFirstResponder() // 这句很重要
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let menuController = UIMenuController.shared
                let item1 = UIMenuItem(title: "\(commit) submissions on \(dateString)", action: #selector(self.test1))
                let btn = (NSClassFromString("UICalloutBarButton")! as! UIButton.Type).appearance()
//                btn.backgroundColor = Colors.base
                btn.setTitleColor(.white, for: .normal)
                menuController.menuItems = [item1]
                menuController.setTargetRect(cell.frame, in: collectionView)
                menuController.setMenuVisible(true, animated: false)
            }
        }
       
    }
    
    @objc func test1(sender: Selector) {
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if [#selector(test1)].contains(action) {
            return true
        }
        return false
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(tableViewItems[section].count, 1)
    }
    
    //设置section的数量
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewItems.count
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return UIView()
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return 0
//        }
//        return 10
//    }
    
    //设置tableview的cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = "\(indexPath.section)_\(indexPath.row)_cell"
        var cell:ProblemItemCell!
        if indexPath.section == 0 {
            cell = ProblemItemCell(style: .default, reuseIdentifier: indentifier)
            avatarImageView = UIImageView()
            cell.contentView.addSubview(avatarImageView)
            avatarImageView.image = UIImage(named: "logo")
            
            usernameLael = UILabel.with(size: 19, weight: .bold, color: Colors.boldColor)
            cell.contentView.addSubview(usernameLael)
            emailLabel = UILabel.with(size: 14, weight: .regular, color: Colors.titleColor)
            cell.contentView.addSubview(emailLabel)
            
            avatarImageView.layer.cornerRadius = 6
            avatarImageView.layer.masksToBounds = false
            avatarImageView.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
                make.size.equalTo(60)
                make.bottom.equalToSuperview().offset(-20)
            }
            
            usernameLael.snp.makeConstraints { (make) in
                make.centerY.equalTo(avatarImageView).offset(-14)
                make.right.equalTo(avatarImageView.snp.left).offset(-20)
                make.left.equalToSuperview().offset(20)
            }
            
            emailLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(avatarImageView).offset(14)
                make.left.right.equalTo(usernameLael)
                
            }
            
            return cell
        }
        if indexPath.section == 1 {
            cell = ProblemItemCell(style: .default, reuseIdentifier: indentifier)
            let leftView = UIView()
            cell.contentView.addSubview(leftView)
            let midView = UIView()
            cell.contentView.addSubview(midView)
            let rightView = UIView()
            cell.contentView.addSubview(rightView)

            leftView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(20)
                make.top.bottom.equalToSuperview().inset(20)
                make.width.equalTo(cell.contentView.snp.width).offset(-20).dividedBy(3)
            }
            
            midView.snp.makeConstraints { (make) in
                make.left.equalTo(leftView.snp.right).offset(10)
                make.top.bottom.equalTo(leftView)
                make.width.equalTo(leftView)
            }
            
            rightView.snp.makeConstraints { (make) in
                make.left.equalTo(midView.snp.right).offset(10)
                make.right.equalToSuperview().offset(-20)
                make.top.bottom.equalTo(leftView)
                make.width.equalTo(leftView)
            }
            
            let leftLabel = UILabel.with(size: 13, color: Colors.titleColor)
            leftView.addSubview(leftLabel)
            leftView.addSubview(acLeftLabel)
            
            let midLabel = UILabel.with(size: 13, color: Colors.titleColor)
            midView.addSubview(midLabel)
            midView.addSubview(acMidLabel)
            
            let rightLabel = UILabel.with(size: 13, color: Colors.titleColor)
            rightView.addSubview(rightLabel)
            rightView.addSubview(acRightLabel)
            
            let leftLabels = [leftLabel, midLabel, rightLabel]
            let acLeftLabels = [acLeftLabel, acMidLabel, acRightLabel]
            
            for (_, subLabel) in acLeftLabels.enumerated() {
                subLabel.textAlignment = .left
                subLabel.textColor = Colors.titleColor
                subLabel.snp.makeConstraints({ (make) in
                    make.top.left.right.equalToSuperview().inset(10)
                })
            }
            
            for (index, subLabel) in leftLabels.enumerated() {
                subLabel.numberOfLines = 2
                subLabel.textAlignment = .left
                subLabel.textColor = Colors.titleColor
                subLabel.text = t(str: ["Solved Question", "Accepted Submission", "Acceptance Rate"][index])
                subLabel.snp.makeConstraints({ (make) in
                    make.bottom.left.right.equalToSuperview().inset(10)
                    make.top.equalTo(acLeftLabels[index].snp.bottom).offset(10)
                })
                
            }
            
            [midView, leftView, rightView].forEach { (subView) in
                subView.layer.cornerRadius = 6
                subView.layer.masksToBounds = false
                subView.layer.borderColor = Colors.borderColor.cgColor
                subView.layer.borderWidth = 0.5
                subView.backgroundColor = Colors.mainColor
            }
            return cell
        }
        
        if indexPath.section == 2 {
            cell = ProblemItemCell(style: .default, reuseIdentifier: indentifier)
            
            let layout = UICollectionViewFlowLayout()
            colltionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
            cell.contentView.addSubview(colltionView!)
            
            //注册一个cell
            for i in 0...commitCount {
                colltionView!.register(CalendarCell.self, forCellWithReuseIdentifier:"\(i)_cell")
            }
            colltionView?.delegate = self;
            colltionView?.dataSource = self;
            colltionView?.backgroundColor = Colors.mainColor
            colltionView.bounces = false
            //设置每一个cell的宽高
            layout.itemSize = CGSize(width: 12, height: 12)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 2
            layout.scrollDirection = .horizontal
            colltionView.showsHorizontalScrollIndicator = false
            layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            let offset = 19
            colltionView.snp.makeConstraints { (make) in
                
                make.top.equalToSuperview().offset(18)
                make.left.equalToSuperview().offset(offset)
                make.right.equalToSuperview().offset(0-offset)
                //            make.leading.equalToSuperview()
                make.height.equalTo((12 + 3) * 7)
                make.bottom.equalToSuperview().offset(-18)
            }
            
            if (data != nil) {
                usernameLael.text = data["username"].stringValue
                if FileCache.isGlobal() {
                    emailLabel.text = data["email"].stringValue
                } else {
                    emailLabel.text = ""
                }
                avatarImageView.kf.setImage(with: URL(string: data["profile"]["userAvatar"].stringValue), placeholder: UIImage(named: "logo"))
            }
            return cell
        }
        cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as? ProblemItemCell
        if cell == nil {
            cell = ProblemItemCell(style: .default, reuseIdentifier: indentifier)
        }

        cell.setData(data: tableViewItems[indexPath.section][indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section <= 2 {
            return
        }
        tableViewItems[indexPath.section][indexPath.row].onTap?(1)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

