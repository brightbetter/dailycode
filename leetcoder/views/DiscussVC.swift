//
//  discussVC.swift
//  leetcoder
//
//  Created by EricJia on 2019/8/9.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation
import UIKit

import Alamofire
import SnapKit
import SwiftyJSON
import Kingfisher

class DiscussItemCell: UITableViewCell {
    var iconImage: UIImageView!
    var nameLabel: UILabel!
    var timeLabel: UILabel!
    var titleLabel: UILabel!
    var wrapView: UIView!
    
    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init (style: style, reuseIdentifier: reuseIdentifier)
        
        wrapView = UIView()
        contentView.addSubview(wrapView)
        iconImage = UIImageView()
        wrapView.addSubview(iconImage)
        nameLabel = UILabel.with(size: 14, weight: .regular, color: Colors.base)
        wrapView.addSubview(nameLabel)
        timeLabel = UILabel.with(size: 13, weight: .regular, color: Colors.titleColor)
        wrapView.addSubview(timeLabel)
        titleLabel = UILabel.with(size: 16, weight: .medium, color: Colors.titleColor)
        wrapView.addSubview(titleLabel)
     
        setupViews ()
        
    }
    
    required init? (coder aDecoder: NSCoder) {
        fatalError ("init(coder:) has not been implemented")
    }
    
    func setupViews () {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        iconImage.layer.cornerRadius = 20
        iconImage.layer.masksToBounds = true
        titleLabel.numberOfLines = 0
        wrapView.backgroundColor = Colors.mainColor
        wrapView.layer.cornerRadius = 5
        wrapView.layer.masksToBounds = true
        
        wrapView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
        
        iconImage.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(20)
            make.size.equalTo(40)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconImage).offset(-10)
            make.left.equalTo(iconImage.snp.right).offset(10)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconImage).offset(10)
            make.left.equalTo(nameLabel)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconImage)
            make.top.equalTo(iconImage.snp.bottom).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    func setData(data: JSON) {
 
        if FileCache.isGlobal() {
           iconImage.kf.setImage(with: URL(string: data["node"]["post"]["author"]["profile"]["userAvatar"].stringValue))
            nameLabel.text = data["node"]["post"]["author"]["username"].stringValue
            timeLabel.text =  "\(data["node"]["post"]["voteCount"].stringValue) \(t(str: "likes"))"
            titleLabel.text = data["node"]["title"].stringValue
        } else {
            iconImage.kf.setImage(with: URL(string: data["post"]["author"]["profile"]["userAvatar"].stringValue))
            nameLabel.text = data["post"]["author"]["username"].stringValue
            timeLabel.text =  "\(data["post"]["voteUpCount"].stringValue) \(t(str: "likes"))"
            titleLabel.text = data["post"]["content"].stringValue
            titleLabel.numberOfLines = 3
        }
        
    }
    
    override func awakeFromNib () {
        super.awakeFromNib ()
        // Initialization code
    }
    override func layoutSubviews () {
        super.layoutSubviews ()
        setupViews ()
    }
    override func setSelected (_ selected: Bool, animated: Bool) {
        super.setSelected (selected, animated: animated)
    }
}


class DiscussViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    var questionId:String = "1"
    var topicId: String = "2"
    
    var table:UITableView!
    var items:[JSON] = []
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.title = t(str: "Discuss")
        
        //设置UITableView的位置
        table = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        view.addSubview(table)
        
        table.estimatedRowHeight = 100
        table.sectionHeaderHeight = 10
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = UITableViewCell.SeparatorStyle.none
        table.backgroundColor = Colors.bgColor
        table.showsVerticalScrollIndicator = false
        //设置数据源
        table.dataSource = self
        //设置代理
        table.delegate = self
        
        //注册UITableView，cellID为重复使用cell的Identifier
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ProblemCell")
        
        table.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        self.fetchData()
    }
    
    
    func fetchData() {
        beginLoading()
        
        if FileCache.isGlobal() {
            let parameters = [
                "query": GraphqlSchema.TopicsList,
                "operationName": "questionTopicsList",
                "variables": [
                    "orderBy": "most_votes", "query": "", "skip": 0, "first": 15, "tags": [], "questionId": questionId
                ]
                ] as [String : Any]
            MySession.request(Urls.graphql, method:.post, parameters: parameters, encoding: JSONEncoding.default, headers:getHeaders()).responseJSON { response in
                
                switch response.result {
                case let .success(value):
                    self.items = JSON(value)["data"]["questionTopicsList"]["edges"].arrayValue
                    self.table.reloadData()
                case let .failure(error):
                    print(error)
                }
                self.endLoading()
            }
        } else {
            let parameters = [
                "query": GraphqlSchema.cnComments,
                "operationName": "commentsSelection",
                "variables": [
                     "topicId": topicId
                ]
                ] as [String : Any]
            MySession.request(Urls.graphql.withCN(), method:.post, parameters: parameters, encoding: JSONEncoding.default, headers:getHeaders()).responseJSON { response in
                
                switch response.result {
                case let .success(value):
                    self.items = JSON(value)["data"]["commentsSelection"].arrayValue
                    self.table.reloadData()
                case let .failure(error):
                    print(error)
                }
                self.endLoading()
            }
        }
        
    }
    
    
    //设置cell的数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //设置section的数量
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 20
    }
    
    //设置tableview的cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.section]
        let id = item["id"].stringValue
        var cell:DiscussItemCell! = tableView.dequeueReusableCell(withIdentifier: id)as?DiscussItemCell
        if cell == nil {
            cell = DiscussItemCell(style: .default, reuseIdentifier: id)
        }
//        cell.backgroundColor = Colors.mainColor
        cell.setData(data: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if FileCache.isGlobal() {
            let item = self.items[indexPath.section]["node"]
            let vc = DiscussDetailViewController()
            vc.topicId = item["id"].stringValue
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let item = self.items[indexPath.section]
            let vc = SolutionDetailViewController()
            vc.markdown = item["post"]["content"].stringValue
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
