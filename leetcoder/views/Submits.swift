//
//  Submits.swift
//  leetcoder
//
//  Created by EricJia on 2019/7/31.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation
import UIKit

import Alamofire
import SnapKit
import SwiftyJSON

class SubmitsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    var questionSlug:String = "two-sum"
    var questionTitle:String = "Two Sum"
    var questionId:String = "1"
    
    var table:UITableView!
    var items:[JSON] = []
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationItem.title = t(str: "Submissions")
        
        
        //设置UITableView的位置
        table = UITableView()
        view.addSubview(table)
        table.estimatedRowHeight = 100
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = UITableViewCell.SeparatorStyle.none
        //设置数据源
        table.dataSource = self
        //设置代理
        table.delegate = self
        
        //注册UITableView，cellID为重复使用cell的Identifier
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ProblemCell")
        
        table.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.size.equalToSuperview()
        }
        
        self.fetchData()
    }
    
    
    func fetchData() {
        beginLoading()
        MySession.request(Urls.submissions.replace(target: "$slug", withString: questionSlug).withCN(), encoding: JSONEncoding.default).responseJSON { response in
            
            switch response.result {
            case let .success(value):
                self.items = JSON(value)["submissions_dump"].arrayValue
                self.table.reloadData()
                self.endLoading()
            case let .failure(error):
                print(error)
                self.endLoading()
            }
        }
    }
    

    //设置cell的数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    //设置section的数量
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //设置tableview的cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.row]
        let question_id = String("submit_cell")
        var cell:SubmitTableViewCell! = tableView.dequeueReusableCell(withIdentifier: question_id)as?SubmitTableViewCell
        if cell == nil {
            cell = SubmitTableViewCell(style: .default, reuseIdentifier: question_id)
        }
        cell.backgroundColor = Colors.mainColor
        cell.setData(data: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        let code = item["code"].stringValue
        let lang = item["lang"].stringValue
        let editorVC = EditorViewwController()
        editorVC.lang = lang
        editorVC.code = code
        editorVC.langSlug = EditorHelper.getLangSlug(lang: lang)
        editorVC.sampleTestCase = ""
        editorVC.questionId = ""
        editorVC.titleSulg = ""
        editorVC.enableEdit = false
        self.navigationController?.pushViewController(editorVC, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

