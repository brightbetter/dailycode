//
//  TabbarVC.swift
//  leetcoder
//
//  Created by EricJia on 2019/7/22.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation

import UIKit

class TabBartViewController: UITabBarController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        self.viewControllers = [
//            createNavVC(vc: ProfileViewController(needBack: false), title: t(str: "Profile"), image: "profile"),
//            createNavVC(vc: AboutViewController(needBack: false), title: t(str: "Problems"), image: "problems"),
//            createNavVC(vc: DiscussViewController(needBack: false), title: t(str: "Problems"), image: "problems"),
//            createNavVC(vc: EditerSettingViewController(needBack: false), title: t(str: "Problems"), image: "problems"),
//            createNavVC(vc: ProblemViewController(), title: "Problem", image: "problems"),
//            createNavVC(vc: TagViewController(needBack: false), title: t(str: "Tags"), image: "tags"),
//            createNavVC(vc: LoginViewController(needBack: false), title: "Login", image: "profile"),
//            createNavVC(vc: DiscussDetailViewController(needBack: false), title: t(str: "Problems"), image: "problems"),
//            createNavVC(vc: EditorViewwController(needBack: false), title: t(str: "Problems"), image: "problems"),
//            createNavVC(vc: SolutionDetailViewController(needBack: false), title: t(str: "Problems"), image: "problems"),
            createNavVC(vc: HomeViewController(needBack: false), title: t(str: "Problems"), image: "problems"),
            createNavVC(vc: TagViewController(needBack: false), title: t(str: "Tags"), image: "tags"),

            createNavVC(vc: ProfileViewController(needBack: false), title: t(str: "Profile"), image: "profile"),

        ]
        
        // 文字图片颜色一块修改
        self.tabBar.tintColor = Colors.base
    }
    
    func createNavVC(vc: UIViewController, title: String, image: String) -> UINavigationController {
        let navVC = BaseNavController(rootViewController: vc)
//        navVC.title = title
        navVC.tabBarItem.image = UIImage(named: "tab_\(image)")
        navVC.tabBarItem.selectedImage = UIImage(named: "tab_\(image)_high")
//        navVC.tabBarItem.imageInsets 
        return navVC
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.title = item.title
    }
    
}
