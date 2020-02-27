//
//  tool.swift
//  leetcoder
//
//  Created by EricJia on 2019/7/23.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation
import UIKit

import Alamofire
import SwiftyJSON

extension Double {
    /// Rounds the double to decimal places value
    func rounded(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UIViewController {
    func removeInputAccessoryView() {
        // locate accessory view
        let windowCount = UIApplication.shared.windows.count
        if (windowCount < 2) {
            return;
        }

        let tempWindow:UIWindow = UIApplication.shared.windows[1] as UIWindow
        let accessoryView:UIView = traverseSubViews(vw: tempWindow)
        print(accessoryView.description)
        if (accessoryView.description.hasPrefix("<UIWebFormAccessory")) {
            // Found the inputAccessoryView UIView
            accessoryView.removeFromSuperview()
        }
    }

    func traverseSubViews(vw:UIView) -> UIView
    {
        if (vw.description.hasPrefix("<UIWebFormAccessory")) {
            return vw
        }

        for i in (0  ..< vw.subviews.count) {
            let subview = vw.subviews[i] as UIView;
            if (subview.subviews.count > 0) {
                let subvw = self.traverseSubViews(vw: subview)
                if (subvw.description.hasPrefix("<UIWebFormAccessory")) {
                    return subvw
                }
            }
        }
        return UIView()
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UILabel {
    static func with(size:CGFloat=15, weight:UIFont.Weight = .regular, colorStr:String = "#000000", color: UIColor=UIColor.black) -> UILabel {
        let label = self.init()
        label.font = UIFont.systemFont(ofSize: size, weight: weight)
        if color === UIColor.black {
            label.textColor = UIColor(hexStr: colorStr)
        } else {
            label.textColor = color
        }
        return label
    }
}

extension UIColor {
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
    
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 0.5)
    }
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha))
    }
    
    convenience init(hex:Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff, alpha: 1)
    }
    
    convenience init(hexStr:String) {
        let hex = "0x" + hexStr.replace(target: "#", withString: "").lowercased()
        let hexInt = Int(strtoul(hex, nil, 16))
        self.init(hex: hexInt)
    }
}

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func withCN() -> String {
        
        if FileCache.isGlobal() {
            return self
        }
        return self.replace(target: "leetcode.com", withString: "leetcode-cn.com")
    }
}


func readFile(filename:String, filetype: String) -> Any {
    do {
        if let file = Bundle.main.url(forResource: filename, withExtension: filetype) {
            let data = try Data(contentsOf: file)
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if ((json as? [String: Any]) != nil) {
                    // json is a dictionary
                    return json
                } else if ((json as? [Any]) != nil) {
                    // json is an array
                    return json
                }
            } catch {
                print("readFile: error", error.localizedDescription)
            }
            do {
                return String(data: data, encoding: String.Encoding.utf8) as Any
            }
        } else {
            print("readFile: no file")
        }
    } catch {
        print("readFile: error", error.localizedDescription)
    }
    return "readFile: none"
}

func readSandBoxFile(filepath: String) -> JSON {
    var data:JSON = []
    do {
        data = try JSON(data: Data(contentsOf: URL(fileURLWithPath: CacheDir + "/file/" + filepath)))
    } catch {
        print("fileCache: unzip error", error.localizedDescription)
    }
    return data
}

func wapperContentHTML(content:String) -> String {
    
    
    var html = """
    <!DOCTYPE html>
    <html>
    <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0, minimum-scale=1.0">
    </head>
    <body>
    <style type="text/css">
    
    /**
     * No mixins for output here.
     * If you want to expose some mixins,
     * define them to `legacy/common/styles/atomic`
     */
    /* stylelint-disable */
    html {
        color: htmlTextColor;
        width: 100%;
        background: htmlBgColor;
    }
    
    #main {
        width: 100%;
    }
    
    p {
        font-size: 15px !important;
        font-weight: 400;
        font-family: -apple-system, BlinkMacSystemFont, sans-serif;
    }
    
    strong {
        font-weight: 600;
    }
    
    hr {
        border: 1px solid #eceff1;
        background-color: #eceff1;
    }
    a {
        pointer-events: auto;
        color: #607d8b;
        text-decoration: none;
        padding-bottom: 1px;
        border-bottom: 1px solid transparent;
        -webkit-transition: border-bottom-color 0.3s;
        -o-transition: border-bottom-color 0.3s;
        transition: border-bottom-color 0.3s;
    }
    a:hover {
        border-bottom-color: #607d8b;
    }
    pre {
        background: preBgColor;
        padding: 10px 15px;
        color: preTextColor;
        line-height: 1.6;
        font-size: 13px;
        border-radius: 3px;
    }
    pre code {
        padding: 0;
        color: inherit;
        background-color: transparent;
        -moz-tab-size: 4;
        -o-tab-size: 4;
        tab-size: 4;
    }
    code {
        color: preTextColor;
        background-color: preBgColor;
        padding: 2px 4px;
        font-size: 13px;
        border-radius: 3px;
        font-family: monospace;
    }
    table {
        margin-bottom: 15px;
    }
    table th,
    table td {
        padding: 6px 12px;
        border: 1px solid #dddddd;
    }
    table tr {
        border-top: 1px solid #dddddd;
    }
    table tr:nth-child(2n) {
        background-color: #f7f9fa;
    }
    blockquote {
        padding-left: 15px;
        border-left: 5px solid #eceff1;
        color: #616161;
    }
    
    pre {
        white-space: pre-wrap;
    }
    img {
        max-width: 100%;
        height: auto !important;
    }
    
    div, p {
        margin-left: 0;
        margin-right: 0;
        padding-left: 0;
        padding-right: 0;
    }
    
    
    </style>
    <div id="main">nishizhu</div>
    </body>
    </html>
"""

    html = html.replace(target: "nishizhu", withString: content)
        .replace(target: "htmlBgColor", withString: Colors.mainColor.toHexString())
        .replace(target: "htmlTextColor", withString: Colors.titleColor.toHexString())
        .replace(target: "preBgColor", withString: Colors.bgColor.toHexString())
        .replace(target: "preTextColor", withString: Colors.boldColor.toHexString())
    
    return html
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

extension UIView {
    func addBottomBorder(color: UIColor = UIColor.red, margins: CGFloat = 0, padding: CGFloat=0, borderLineSize: CGFloat = 1) {
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(border)
        border.addConstraint(NSLayoutConstraint(item: border,
                                                attribute: .height,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .height,
                                                multiplier: 1, constant: borderLineSize))
        self.addConstraint(NSLayoutConstraint(item: border,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .bottom,
                                              multiplier: 1, constant: padding))
        self.addConstraint(NSLayoutConstraint(item: border,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1, constant: margins))
        self.addConstraint(NSLayoutConstraint(item: border,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1, constant: margins))
    }
}

// MARK: 字典转字符串
func dicValueString(_ dic:[String : Any]) -> String?{
    let data = try? JSONSerialization.data(withJSONObject: dic, options: [])
    let str = String(data: data!, encoding: String.Encoding.utf8)
    return str
}

// MARK: 字符串转字典
func stringValueDic(_ str: String) -> [String : Any]?{
    let data = str.data(using: String.Encoding.utf8)
    if let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] {
        return dict
    }
    return nil
}


func getMorningDate(date:Date) -> Date{
    let calendar = NSCalendar.init(identifier: .chinese)
    let components = calendar?.components([.year,.month,.day], from: date)
    return (calendar?.date(from: components!))!
}



func openUrlScheme(str: String) {
    if let url = URL(string: str) {
        //根据iOS系统版本，分别处理
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:],
                                      completionHandler: {
                                        (success) in
            })
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}


func cellAnimation(tableView:UITableView, cell:UITableViewCell, indexPath: IndexPath) {
    cell.transform = CGAffineTransform(translationX: tableView.frame.size.width, y: 0)
    UIView.animate(withDuration: 0.4, delay: Double(indexPath.row) * 0.07, usingSpringWithDamping: 0.75, initialSpringVelocity: 1/0.75, options: [], animations: {
        cell.transform = CGAffineTransform.identity
    }) { (finished) in
        
    }
}
