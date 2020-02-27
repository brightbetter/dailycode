//
//  config.swift
//  leetcoder
//
//  Created by EricJia on 2019/7/30.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation
import UIKit

let a = """
"""
class UrlsConfig: Any {
    let base =            "https://leetcode.com"
    let graphqlCN =       "https://leetcode-cn.com/graphql"
    let graphql =         "https://leetcode.com/graphql"
    let login =           "https://leetcode.com/accounts/login/"
    let articles =        "https://leetcode.com/articles/$slug/"
    let algorithms =      "https://leetcode.com/api/problems/algorithms/"
    let problems =        "https://leetcode.com/api/problems/$category/"
    let problem =         "https://leetcode.com/problems/$slug/description/"
    let test =            "https://leetcode.com/problems/$slug/interpret_solution/"
    let session =         "https://leetcode.com/session/"
    let submit =          "https://leetcode.com/problems/$slug/submit/"
    let submissions =     "https://leetcode.com/api/submissions/$slug"
    let submission =      "https://leetcode.com/submissions/detail/$id/"
    let verify =          "https://leetcode.com/submissions/detail/$id/check/"
    let favorites =       "https://leetcode.com/list/api/questions"
    let favorite_delete = "https://leetcode.com/list/api/questions/$hash/$id"
    let submissions_cal = "https://leetcode.com/api/user_submission_calendar/$username/"
    let plugin =          "https://github.com/skygragon/leetcode-cli-plugins/raw/master/plugins/$name.js"
    let logout =          "NSString(data: fooData, encoding: String.Encoding.utf8.rawValue)"
    
    init() {
        
    }
}




class ColorsConfig: Any {
    let easy = UIColor(hexStr: "#5ACAD6")
    let medium = UIColor(hexStr: "#FDBE33")
    let hard = UIColor(hexStr: "#FF9F8F")
    let base = UIColor(hexStr: "#5ACAD6")
    
//    let bgColor = UIColor(named: "bgColor")
//    let titleColor = UIColor(named: "titleColor")
//    let subTitleColor = UIColor(named: "subTitleColor")
    
    var boldColor: UIColor {
        get {
            let normalColor = UIColor.black
            if #available(iOS 13.0, *) {
                return UIColor { (trainCollection) -> UIColor in
                    if trainCollection.userInterfaceStyle == .dark {
                        return .white
                    } else {
                        return normalColor
                    }
                }
            } else {
                return normalColor
            }
        }
    }
    
    // 主标题
    var titleColor: UIColor {
        get {
            let normalColor = UIColor.black
            if #available(iOS 13.0, *) {
                return UIColor { (trainCollection) -> UIColor in
                    if trainCollection.userInterfaceStyle == .dark {
                        return UIColor(red: 153, green: 156, blue: 160, alpha: 1)
                    } else {
                        return normalColor
                    }
                }
            } else {
                return normalColor
            }
        }
    }
    
    // 主色调
    var bgColor: UIColor {
        get {
            if #available(iOS 13.0, *) {
                return UIColor { (trainCollection) -> UIColor in
                    if trainCollection.userInterfaceStyle == .dark {
                        return UIColor.black
                    } else {
                        return .white
                    }
                }
            } else {
                return .white
            }
        }
    }
    
    // 主要控制器背景色
    var mainColor: UIColor {
        get {
            let normalColor = UIColor(hexStr: "#F9FAF9")
            if #available(iOS 13.0, *) {
                return UIColor { (trainCollection) -> UIColor in
                    if trainCollection.userInterfaceStyle == .dark {
                        return UIColor(red: 21, green: 25, blue: 33, alpha: 1)
                    } else {
                        return normalColor
                    }
                }
            } else {
                return normalColor
            }
        }
    }
    
    // 副标题
    var subTitleColor: UIColor {
        get {
            if #available(iOS 13.0, *) {
                return UIColor { (trainCollection) -> UIColor in
                    if trainCollection.userInterfaceStyle == .dark {
                        return UIColor.black
                    } else {
                        return UIColor(hexStr: "#A7A7A7")
                    }
                }
            } else {
                return .black
            }
        }
    }
    
    var borderColor: UIColor {
        get {
            let normal = UIColor(hexStr: "E7EEF2")
            if #available(iOS 13.0, *) {
                return UIColor { (trainCollection) -> UIColor in
                    if trainCollection.userInterfaceStyle == .dark {
                        return UIColor(hexStr: "#A7A7A7")
                    } else {
                        return normal
                    }
                }
            } else {
                return normal
            }
        }
    }
    
    
    var shadowBgColor: UIColor {
        get {
            let normalColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            if #available(iOS 13.0, *) {
                return UIColor { (trainCollection) -> UIColor in
                    if trainCollection.userInterfaceStyle == .dark {
                        return UIColor(red: 255, green: 255, blue: 255, alpha: 0.3)
                    } else {
                        return normalColor
                    }
                }
            } else {
                return normalColor
            }
        }
    }
    
//    let bgColor = UIColor { (trainCollection) -> UIColor in
//        if trainCollection.userInterfaceStyle == .dark {
//            return UIColor.black
//        } else {
//            return UIColor(hexStr: "#FBFCFB")
//        }
//    }
//
//    let titleColor = UIColor { (trainCollection) -> UIColor in
//        if trainCollection.userInterfaceStyle == .dark {
//            return UIColor.white
//        } else {
//            return .black
//        }
//    }
//    
//    let subTitleColor = UIColor { (trainCollection) -> UIColor in
//        if trainCollection.userInterfaceStyle == .dark {
//            return UIColor.white
//        } else {
//            return UIColor(hexStr: "#A7A7A7")
//        }
//    }
    init() {
        
    }
}

let Urls = UrlsConfig()
let Colors = ColorsConfig()
