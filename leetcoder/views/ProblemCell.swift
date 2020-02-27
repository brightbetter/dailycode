//
//  ProblemCell.swift
//  leetcoder
//
//  Created by EricJia on 2019/7/23.
//  Copyright © 2019 EricJia. All rights reserved.
//
import Foundation
import UIKit
import SwiftyJSON
import Cosmos


class MineTableViewCell: UITableViewCell {
    var idLabel: UILabel!
    var difficultyLabel: UILabel!
    var titleLabel: UILabel!
    var leftBorderLabel: UILabel!
    var statusImage: UIImageView!
    var starView: CosmosView!
    var wrapView: UIView!
    
    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init (style: style, reuseIdentifier: reuseIdentifier)
        wrapView = UIView()
        contentView.addSubview(wrapView)
        idLabel = UILabel.with(size: 13, weight: .medium, colorStr: "#A3A3A3")
        wrapView.addSubview (idLabel)
        difficultyLabel = UILabel.with(size: 15, weight: .medium, colorStr: "#A3A3A3")
        wrapView.addSubview (difficultyLabel)
        titleLabel = UILabel.with(size: 18, weight: .medium, colorStr: "#333333")
        wrapView.addSubview (titleLabel)
        starView = CosmosView()
        wrapView.addSubview(starView)
    
        statusImage = UIImageView()
        wrapView.addSubview(statusImage)
        setupViews ()
    }
    
    required init? (coder aDecoder: NSCoder) {
        fatalError ("init(coder:) has not been implemented")
    }
    
    func setupViews () {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        wrapView.backgroundColor  = Colors.mainColor
        wrapView.layer.cornerRadius = 5
        wrapView.layer.masksToBounds = true
        contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        wrapView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(7.5)
            make.bottom.equalToSuperview().offset(-7.5)
        }
        
        idLabel.textAlignment = .center
        idLabel.snp.makeConstraints ({(make) in
            make.top.equalTo(wrapView).offset(20)
            make.left.equalTo(wrapView).offset(0)
            make.width.equalTo(35)
            make.height.equalTo(20)
        })
        
        statusImage.snp.makeConstraints ({(make) in
            make.top.equalToSuperview().offset(22)
            make.right.equalTo(wrapView).offset(-20)
            make.width.equalTo(17)
            make.height.equalTo(17)
        })
        
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textColor = Colors.titleColor
        titleLabel.snp.makeConstraints ({(make) in
            make.left.equalTo(idLabel.snp.right)
            make.right.equalTo(statusImage.snp.left).offset(-15)
            make.top.equalTo(wrapView).offset(20)
        })
                
        starView.settings.starSize = 13
        starView.settings.starMargin = 4
        starView.settings.updateOnTouch = false
        starView.settings.filledImage = UIImage(named: "problem_star")
        starView.settings.emptyImage = UIImage(named: "problem_unstar")
        starView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel).offset(3)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        difficultyLabel.snp.makeConstraints ({(make) in
            make.left.equalTo(idLabel.snp.right)
            make.top.equalTo(starView.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-17)
        })
        
    }
    
    func setData(data: JSON) {
        do {
            let stat = data["stat"]
            let question_id = stat["question_id"].stringValue
            let difficulty = data["difficulty"]
            let level_int = difficulty["level"].intValue
            let level_str = ["", "Easy", "Medium", "Hard"][level_int]

            let level_color = [.white, Colors.easy, Colors.medium, Colors.hard][level_int]
            let statusStr = data["status"].stringValue
            if statusStr == "ac" {
                statusImage.image = UIImage(named: "problem_cell_ac")
            }
            else if statusStr == "notac" {
                statusImage.image = UIImage(named: "problem_cell_notac")
            }
            else {
                statusImage.image = UIImage()
            }
            idLabel.text = question_id
            if LanguageHelper.isCN() {
                let trans_title = FileCache.getTransTitle(questionId: question_id)
                titleLabel.text = trans_title != "" ? trans_title : stat["question__title"].stringValue
            } else {
                titleLabel.text = stat["question__title"].stringValue
            }
            
            difficultyLabel.text = " " + t(str: level_str) + " "
            difficultyLabel.textColor = level_color
            
            let rateData = FileCache.getRateDict(titleSlug: stat["question__title_slug"].stringValue).arrayValue
            let rate = rateData.last?.doubleValue
            starView.rating = Double(rate ?? 0)
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
        // Configure the view for the selected state
    }
}
