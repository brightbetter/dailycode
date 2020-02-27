//
//  ProblemItemCell.swift
//  leetcoder
//
//  Created by EricJia on 2019/7/28.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation
import UIKit

struct ProblemItem {
    var imgBgColor: UIColor = Colors.base
    var textColor: UIColor = UIColor(hexStr: "#000000")
    var title: String
    var img: String
    var rightTitle: String = ""
    var onTap: ((Any) -> Void)?
}

class ProblemItemCell: UITableViewCell {
    var leftBgView: UIView!
    var leftLabel: UILabel!
    var iconImage: UIImageView!
    var rightImage: UIImageView!
    var rightLabel: UILabel!
   
    
    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init (style: style, reuseIdentifier: reuseIdentifier)
        leftBgView = UIView()
        contentView.addSubview(leftBgView)
        iconImage = UIImageView()
        leftBgView.addSubview(iconImage)
        
        leftLabel = UILabel()
        contentView.addSubview (leftLabel)
        
        rightImage = UIImageView()
        contentView.addSubview(rightImage)
        
        
        rightLabel = UILabel()
        contentView.addSubview(rightLabel)
        setupViews ()
    }
    
    required init? (coder aDecoder: NSCoder) {
        fatalError ("init(coder:) has not been implemented")
    }
    
    func setupViews () {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        
        leftBgView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(23)
        }
        
        iconImage.snp.makeConstraints ({(make) in
            make.centerY.centerX.equalToSuperview()
            make.size.equalTo(17)
        })
        
        
        
        leftLabel.numberOfLines = 0
        leftLabel.snp.makeConstraints ({(make) in
            make.left.equalTo(leftBgView.snp.right).offset(13)
            make.right.equalTo(rightImage.snp.left).offset(-10)
            make.centerY.equalToSuperview()
        })
        
        rightImage.snp.makeConstraints ({(make) in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(13)
        })
        
        rightLabel.snp.makeConstraints ({(make) in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        })
        
    }
    
    func setData(data: ProblemItem) {
        
        leftBgView.layer.cornerRadius = 3
        leftBgView.layer.masksToBounds = true
        leftLabel.textColor = Colors.titleColor
        rightLabel.textColor = Colors.subTitleColor
        leftLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        rightLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        leftBgView.backgroundColor = data.imgBgColor
        iconImage?.image = UIImage(named: data.img)
        leftLabel.text = t(str: data.title)
        
        if data.rightTitle == "" {
            rightImage.image = UIImage(named: "problem_right_anchor")
        } else {
            rightLabel.text = data.rightTitle
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
