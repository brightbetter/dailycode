//
//  language.swift
//  leetcoder
//
//  Created by EricJia on 2019/8/8.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation
import UIKit

class LanguageHelper: NSObject {
    static func current() -> String {
        
        let lang = (UserDefaults.standard.value(forKey: "lang") as? String) ?? "system"
        if ["cn", "en"].contains(lang) {
            return lang
        }
        let preferredLang = Bundle.main.preferredLocalizations.first! as NSString
        switch String(describing: preferredLang) {
        case "en-US", "en-CN":
            return "en"//英文
        case "zh-Hans-US","zh-Hans-CN","zh-Hant-CN","zh-TW","zh-HK","zh-Hans":
            return "cn"//中文
        default:
            return "en"
        }
    }
    
    static func isCN() -> Bool {
        return LanguageHelper.current() == "cn"
    }
    
    static func change(lang: String) {
        UserDefaults.standard.set(lang, forKey: "lang")
        resetBootViewController()
    }
}

func resetBootViewController() {
    if #available(iOS 11.0, *) {
        UIApplication.shared.keyWindow?.rootViewController = TabBartViewController()
    } else {
        // Fallback on earlier versions
    }
}


func t(str: String, comment:String? = "") -> String {
    let souce = LanguageHelper.isCN() ? "zh-Hans" : "en"
    let localizedBundle: Bundle = {
        return Bundle(path: Bundle.main.path(forResource: souce, ofType: "lproj")!)!
    }()
    let localText = NSLocalizedString(str, tableName: "Localizable", bundle: localizedBundle, comment: "")
    return localText
}
