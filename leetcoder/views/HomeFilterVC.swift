//
//  HomeFilterVC.swift
//  leetcoder
//
//  Created by EricJia on 2019/8/4.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation

import UIKit

import Alamofire

class HomeFilterViewController: UIViewController {
    var imageView:UIImageView!
    var scrollView: UIScrollView!
    var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.isTranslucent = true
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        contentView = UIView()
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints { (make) in
            make.right.equalTo(view)
            make.top.equalTo(view)
            make.bottom.equalTo(view)
            make.width.equalTo(200)
        }
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
            make.leading.trailing.equalTo(scrollView)
        }

        view.backgroundColor = UIColor(white: 0, alpha: 0)
        scrollView.backgroundColor = UIColor.random()
        imageView = UIImageView()
        imageView.image = UIImage(named: "AppIcon")
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.size.equalTo(94)
            make.centerX.equalTo(contentView)
            make.top.equalToSuperview().offset(0)
        }
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds =  true


    }
    
    @objc func handleLogin(sender: Selector){
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
