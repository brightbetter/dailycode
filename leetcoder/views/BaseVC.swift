//
//  BaseVC.swift
//  leetcoder
//
//  Created by EricJia on 2019/7/30.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation

import UIKit
import SwiftEntryKit

class BaseViewController: UIViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    var needBack:Bool=true
    var isLoading:Bool=false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.bgColor
        
        if needBack {
            hidesBottomBarWhenPushed = true
            if #available(iOS 11.0, *) {
                navigationController?.navigationBar.prefersLargeTitles = false
            } else {
                // Fallback on earlier versions
            }
            let leftBarBtn = UIBarButtonItem(title: "", style: .plain, target: self,
                                             action: #selector(backToPrevious))
            leftBarBtn.tintColor = Colors.boldColor
            leftBarBtn.image = UIImage(named: "navbar_back copy")
            
            //用于消除左边空隙，要不然按钮顶不到最前面
            let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil,
                                         action: nil)
            spacer.width = -10
            self.navigationItem.leftBarButtonItems = [spacer, leftBarBtn]
            //        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.barTintColor = Colors.bgColor
            self.navigationController?.navigationBar.isTranslucent = true
        }
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let enable = self.navigationController?.viewControllers.count ?? 0 > 1
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = enable
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func enableLargeTitle() {
        if #available(iOS 11.0, *) {
//            navigationController?.navigationBar.prefersLargeTitles = true
//            navigationController?.navigationBar.largeTitleTextAttributes = [
//                NSAttributedString.Key.foregroundColor: UIColor(hex: 0x222222),
//                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 27, weight: .bold)]
//            navigationItem.largeTitleDisplayMode = .automatic
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    convenience init(needBack:Bool=true) {
        self.init(nibName:nil, bundle:nil)
        self.needBack=needBack
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func beginLoading(type:EKAttributes.NotificationHapticFeedback=EKAttributes.NotificationHapticFeedback.success,
                      text:String="Loading. Please wait...",
                      bgColor:UIColor=Colors.base
                      ) {
        endLoading()
        isLoading = true
        var attributes = EKAttributes.topNote
        attributes.hapticFeedbackType = type
        attributes.displayDuration = .infinity
        attributes.popBehavior = .animated(animation: .translation)
        attributes.entryBackground = .color(color: bgColor)
        attributes.statusBar = .light

        let style = EKProperty.LabelStyle(
            font: UIFont.systemFont(ofSize: 14),
            color: .white,
            alignment: .center
        )
        let labelContent = EKProperty.LabelContent(
            text: t(str: text),
            style: style
        )
        let contentView = EKProcessingNoteMessageView(
            with: labelContent,
            activityIndicator: .white
        )
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        endLoading()
    }
    
    func endLoading() {
        isLoading = false
        SwiftEntryKit.dismiss()
    }
    
    //返回按钮点击响应
    @objc func backToPrevious(){
        self.navigationController!.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


class BaseNavController: UINavigationController {
    
    //MARK: - 初始化
    override func viewDidLoad() {
        
        super.viewDidLoad()
//        self.isNavigationBarHidden = true //上部的导航栏
//        self.isToolbarHidden = true //底部的状态栏
    }
    
    
    //MARK: 重写跳转
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count>0 {
            viewController.hidesBottomBarWhenPushed = true //跳转之后隐藏
        }
        super.pushViewController(viewController, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/*
 
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
 import SDWebImage
 
 
 class SettingsViewController: BaseViewController {
 
 var scrollView: UIScrollView!
 var contentView: UIView!
 
 override func viewDidLoad() {
 super.viewDidLoad()
 setViews()
 }
 
 func setViews() {
 scrollView = UIScrollView()
 view.addSubview(scrollView)
 contentView = UIView()
 scrollView.addSubview(contentView)
 
 scrollView.snp.makeConstraints { (make) in
 make.edges.equalTo(view)
 }
 contentView.snp.makeConstraints { (make) in
 make.edges.equalTo(scrollView)
 make.width.equalTo(scrollView)
 make.leading.trailing.equalTo(scrollView)
 }
 }
 
 override func didReceiveMemoryWarning() {
 super.didReceiveMemoryWarning()
 // Dispose of any resources that can be recreated.
 }
 
 }

 */
