
//
//  Settings.swift
//  leetcoder
//
//  Created by EricJia on 2019/8/7.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation

import UIKit
import SwiftyJSON
import TagListView
import WebKit
import Alamofire
import SDCAlertView


class SettingsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate {
    
    var scrollView: UIScrollView!
    var contentView: UIView!
    var tableView: UITableView!
    var tableViewItems: [[[String]]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = t(str: "Languages")
        setViews()
    }
    
    func setViews() {
        //设置UITableView的位置
        tableView = UITableView()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.separatorColor = Colors.borderColor
        tableView.estimatedRowHeight = 100
//        tableView.rowHeight = 60
        tableView.isScrollEnabled = false
        let footerView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = footerView
        //设置数据源
        tableView.dataSource = self
        //设置代理
        tableView.delegate = self
        view.addSubview(tableView)
        //注册UITableView，cellID为重复使用cell的Identifier
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProblemItemCell")
        var lang = ""
        let langCode = LanguageHelper.current()
        if langCode == "cn" {
            lang = "简体中文"
        } else if langCode == "en" {
            lang = "English"
        }
        tableViewItems = [
            [
                [t(str: "Language"), lang]
            ]
        ]
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(20)
            make.left.equalTo(view).offset(20)
            make.right.equalToSuperview().offset(-20)
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
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: indentifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: indentifier)
        }
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        let data = tableViewItems[indexPath.section][indexPath.row]
        cell.textLabel?.text = data[0]
        cell.detailTextLabel?.text = data[1]
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let alert = AlertController(title: "", message: "", preferredStyle: .actionSheet)
                
                alert.addAction(AlertAction(title: "System", style: .normal, handler: { action in
                    self.tableViewItems[indexPath.section][indexPath.row][1] = action.title ?? ""
                    LanguageHelper.change(lang: "system")
                    self.tableView.reloadData()
                }))
                alert.addAction(AlertAction(title: "简体中文", style: .normal, handler: { action in
                    self.tableViewItems[indexPath.section][indexPath.row][1] = action.title ?? ""
                    LanguageHelper.change(lang: "cn")
                    self.tableView.reloadData()
                }))
                alert.addAction(AlertAction(title: "English", style: .normal, handler: { action in
                    self.tableViewItems[indexPath.section][indexPath.row][1] = action.title ?? ""
                    LanguageHelper.change(lang: "en")
                    self.tableView.reloadData()
                }))
                alert.addAction(AlertAction(title: t(str: "Cancel"), style: .preferred, handler: { action in
                    alert.dismiss()
                }))
                alert.present()

            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
