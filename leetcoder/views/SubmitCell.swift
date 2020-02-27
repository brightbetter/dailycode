//
//  SubmitCell.swift
//  leetcoder
//
//  Created by EricJia on 2019/8/1.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

/*

{
    "id":247785019,
    "lang":"python3",
    "time":"1 day, 2 hours",
    "timestamp":1564572320,
    "status_display":"Accepted",
    "runtime":"56 ms",
    "url":"/submissions/detail/247785019/",
    "is_pending":"Not Pending",
    "title":"Two Sum",
    "memory":"15.2 MB",
    "code":"class Solution:\n    def twoSum(self, nums: List[int], target: int) -> List[int]:\n        indice = {}\n        for i, v in enumerate(nums):\n            if v in indice:\n                return [indice[v], i]\n            else:\n                indice[target - v] = i",
    "compare_result":"11111111111111111111111111111"
}
 */

class SubmitTableViewCell: UITableViewCell {
    var runtimeLabel: UILabel!
    var runtimeContentLabel: UILabel!
    var memoryLabel: UILabel!
    var memoryContentLabel: UILabel!
    var statusLabel: UILabel!
    var timeLabel: UILabel!
    var langLabel: UILabel!
    var bgView: UIView!
    
    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init (style: style, reuseIdentifier: reuseIdentifier)
        timeLabel = UILabel()
        contentView.addSubview (timeLabel)
        bgView = UIView()
        contentView.addSubview(bgView)
        
        runtimeLabel = UILabel()
        bgView.addSubview (runtimeLabel)
        runtimeContentLabel = UILabel()
        bgView.addSubview (runtimeContentLabel)
        memoryLabel = UILabel()
        bgView.addSubview (memoryLabel)
        memoryContentLabel = UILabel()
        bgView.addSubview (memoryContentLabel)
        //
        statusLabel = UILabel()
        bgView.addSubview (statusLabel)
        langLabel = UILabel()
        bgView.addSubview (langLabel)
        setupViews ()
    }
    
    required init? (coder aDecoder: NSCoder) {
        fatalError ("init(coder:) has not been implemented")
    }
    
    func setupViews () {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        
        
        
        let labelColor = Colors.titleColor
        
        timeLabel.textColor = labelColor
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        
        
        
        
        runtimeLabel.textColor = labelColor
        runtimeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        runtimeContentLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        memoryLabel.textColor = labelColor
        memoryLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        memoryContentLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        langLabel.textColor = labelColor
        langLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        statusLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(20)
            make.top.equalTo(contentView).offset(20)
            
        }
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(20)
            make.top.equalTo(timeLabel.snp.bottom).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        runtimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(bgView).offset(20)
            make.left.equalTo(bgView).offset(20)
        }
        
        runtimeContentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(runtimeLabel)
            make.left.equalTo(runtimeLabel.snp.right).offset(10)
            make.bottom.equalTo(runtimeLabel)
        }

        memoryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(runtimeLabel.snp.bottom).offset(10)
            make.left.equalTo(runtimeLabel)
            make.bottom.equalToSuperview().offset(-20)
        }

        memoryContentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(memoryLabel)
            make.left.equalTo(memoryLabel.snp.right).offset(10)
            make.bottom.equalTo(memoryLabel)
        }

        langLabel.snp.makeConstraints { (make) in
            make.top.equalTo(memoryLabel)
            make.right.equalToSuperview().offset(-20)
        }

        statusLabel.snp.makeConstraints { (make) in
            make.top.equalTo(runtimeLabel)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(runtimeLabel)
        }

    }
    
    func setData(data: JSON) {
        bgView.backgroundColor = Colors.bgColor
        bgView.layer.cornerRadius = 5
        bgView.layer.masksToBounds = true
        let dateStr  = data["time"].stringValue
            .replace(target: "days", withString: t(str: "days"))
            .replace(target: "weeks", withString: t(str: "weeks"))
            .replace(target: "hours", withString: t(str: "hours"))
            .replace(target: "month", withString: t(str: "month"))
            .replace(target: "months", withString: t(str: "months"))
            .replace(target: "minutes", withString: t(str: "minutes"))
            .replace(target: "years", withString: t(str: "years"))
        runtimeLabel.text = t(str: "Runtime") + ":"
        memoryLabel.text = t(str: "Memory") + ":"
        timeLabel.text = dateStr + " " + t(str: "ago")
        runtimeContentLabel.text = data["runtime"].stringValue
        memoryContentLabel.text = data["memory"].stringValue
        langLabel.text = data["lang"].stringValue
        let status = data["status_display"].stringValue
        if status == "Accepted" {
            statusLabel.textColor = Colors.easy
        } else {
            statusLabel.textColor = Colors.hard
        }
        statusLabel.text = t(str: status)
        layoutSubviews()
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
        // Configure the view for the selected state
    }
}
