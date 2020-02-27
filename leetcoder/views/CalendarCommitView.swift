//
//  CalendarView.swift
//  leetcoder
//
//  Created by EricJia on 2019/8/2.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class CalendarCell: UICollectionViewCell {
    var label:UILabel!
    var commit:Int=0
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView(){
//        label = UILabel.with(size: 14, weight: .regular, colorStr: "#333333")
//        contentView.addSubview(label)
//
//        label.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
        self.contentView.layer.cornerRadius = 2
        self.contentView.layer.masksToBounds = true
        self.backgroundColor = Colors.bgColor
    }
    func setData(cmt:Int) {
//        label.text = String(commit)
        commit=cmt
        if commit > 0 {
            let rate = min(CGFloat(commit) / 20.0, 1)
            self.contentView.backgroundColor = UIColor(red: 90, green: 202, blue: 214, alpha: rate)
        }
    }
}
