//
//  About.swift
//  leetcoder
//
//  Created by EricJia on 2019/8/9.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import UIDeviceComplete

class AboutViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate,MFMailComposeViewControllerDelegate {
    
    var scrollView: UIScrollView!
    var contentView: UIView!
    var tableView: UITableView!
    var tableViewItems: [[[String]]] = []
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = t(str: "About")
        tableViewItems = [
            [
                ["", ""],
            ],
            [
                [t(str: "Author"), "", "https://github.com/ericjjj"],
                [t(str: "Website"), "", "https://github.com/ericjjj"],
                [t(str: "Rate"), "", "https://apps.apple.com/us/app/leetcode-dailycode/id1475606624?l=zh&ls=1"],
                [t(str: "Telegram"), "", "https://t.me/joinchat/ESfcURIYiFudiDBSnBNQEQ"],
                
                [t(str: "QQ Group"), "786921729", "mqqapi://card/show_pslcard?src_type=internal&version=1&card_type=group&uin=786921729"],
                [t(str: "Feedback"), "dailycode@ericjj.com", "dailycode@ericjj.com"],
                
            ]
        ]
        setViews()
        
    }
    
    func setViews() {
        //设置UITableView的位置
        tableView = UITableView()
        tableView.estimatedRowHeight = 100
//        tableView.isScrollEnabled = true
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.separatorColor = Colors.borderColor
        let footerView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = footerView
        //设置数据源
        tableView.dataSource = self
        //设置代理
        tableView.delegate = self
        view.addSubview(tableView)
        //注册UITableView，cellID为重复使用cell的Identifier
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProblemItemCell")

        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(20)
            make.left.equalTo(view).offset(0)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-20)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewItems[section].count
    }
    
    //设置section的数量
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewItems.count
    }
    
    //设置tableview的cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = "\(indexPath.section)_\(indexPath.row)_cell"
        var cell:UITableViewCell!
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: indentifier)
            cell.selectionStyle = .none
            let imageView = UIImageView()
            imageView.image = UIImage(named: "logo")
            cell.contentView.addSubview(imageView)
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds  = true
            imageView.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(50)
//                make.bottom.equalToSuperview().offset(-50)
                make.centerX.equalToSuperview()
                make.size.equalTo(94)
                
            }
            let titleLabel = UILabel.with(size: 17, weight: .medium, color: Colors.titleColor)
            cell.contentView.addSubview(titleLabel)
            titleLabel.text = "Daily Code"
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(imageView.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
            }
            
            let versionLabel = UILabel.with(size: 14, weight: .medium, color: Colors.titleColor)
            cell.contentView.addSubview(versionLabel)
            
            versionLabel.text = "Version \(appVersion)"
            versionLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(1)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-50)
            }
            return cell
        }
        
        cell = tableView.dequeueReusableCell(withIdentifier: indentifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: indentifier)
        }
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        let data = tableViewItems[indexPath.section][indexPath.row]
        cell.textLabel?.text = data[0]
        cell.detailTextLabel?.text = data[1]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = tableViewItems[indexPath.section][indexPath.row]
        if data.count >= 3 {
            if data.last?.contains("@") ?? false {
                
                let body = "\nDevice: \(UIDevice.current.dc.commonDeviceName)\nSystem: iOS\(UIDevice.current.systemVersion) \nVersion: \(appVersion)\nBuild: \(buildVersion)"
                print(body)
                let mailComposerVC = MFMailComposeViewController()
                mailComposerVC.mailComposeDelegate = self
                mailComposerVC.setToRecipients([data.last!])
                mailComposerVC.setSubject("【DailyCode】\(t(str: "Feedback"))")
                mailComposerVC.setMessageBody(body, isHTML: false)
                if mailComposerVC != nil {
                    self.present(mailComposerVC, animated: true, completion: nil)
                }
            } else {
                openUrlScheme(str: data.last ?? "")
            }
            
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
