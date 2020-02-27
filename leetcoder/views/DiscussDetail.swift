//
//  DiscussDetail.swift
//  leetcoder
//
//  Created by EricJia on 2019/8/9.
//  Copyright © 2019 EricJia. All rights reserved.
//
import Foundation
import UIKit
import WebKit

import Alamofire
import SnapKit
import SwiftyJSON
import Highlightr

class DiscussDetailViewController: BaseViewController, WKNavigationDelegate  {
    var topicId:String = "1"
    var scrollView: UIScrollView!
    var contentView: UIView!
    var contentWebView: WKWebView!
    var data: JSON!
    var textStorage = CodeAttributedString()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = t(str: "Detail")
        setupViews()
        self.fetchData()
    }

    func setupViews(){
        scrollView = UIScrollView()
        contentView = UIView()
        view.addSubview (scrollView)
        scrollView.addSubview (contentView)
        contentWebView = WKWebView()
        view.addSubview(contentWebView)
        
        contentWebView.scrollView.isScrollEnabled = false
        contentWebView.navigationDelegate = self
        scrollView.snp.makeConstraints ({(make) in
            make.edges.equalTo(view)

        })

        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.width.equalTo(view)
        }
        contentWebView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        textStorage.highlightr.setTheme(to: EditorHelper.currentTheme())
        contentWebView.backgroundColor = textStorage.highlightr.theme.themeBackgroundColor
        contentWebView.backgroundColor = Colors.bgColor
        contentWebView.scrollView.backgroundColor = Colors.bgColor
        scrollView.backgroundColor = Colors.bgColor
        contentWebView.alpha = 0
        
    }


    func fetchData() {
        beginLoading()
        let parameters = ["query": GraphqlSchema.DiscussTopic.replace(target: "$topicId", withString: topicId)]
        MySession.request(Urls.graphql, method:.post, parameters: parameters, encoding: JSONEncoding.default, headers: getHeaders()).responseJSON { response in
            self.endLoading()
            switch response.result {
            case let .success(value):
                self.data = JSON(value)
                FileCache.loadLocalEditor(webview: self.contentWebView)
            case let .failure(error):
                print(error)
            }
        }
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let code = data["data"]["topic"]["post"]["content"].stringValue.replace(target: "\\n", withString: "\n").replace(target: "\\t", withString: "    ")
        let title = self.data["data"]["topic"]["title"].stringValue.lowercased()
        var lang = "JavaScript"
        
        if title.contains("c++") {
            lang = "C++"
        } else if title.contains(" c ") {
            lang = "C"
        } else if title.contains("python") || title.contains("python3") {
            lang = "Python"
        } else if title.contains("golang") || title.contains(" go ") {
            lang = "Go"
        }
        var theme = ""
        if #available(iOS 13.0, *) {
           let bgColor = UIColor.init(dynamicProvider: { (trainCollection) -> UIColor in
               if trainCollection.userInterfaceStyle == .dark {
                   theme = "monokai"
               }
            return .white
            })
            self.view.backgroundColor = bgColor
        }
        let encodedCode:String = code.toBase64()
        let contentScript:String = "window.setEditorContent(\"" + encodedCode +  "\")"
        
        webView.evaluateJavaScript("window.setOption(\"readOnly\", \"nocursor\")") { (res, error) in
        }
        webView.evaluateJavaScript("document.querySelector('.CodeMirror').style.fontSize = '\(EditorHelper.currentFontsize())px'; document.querySelector('.CodeMirror').style.border='none';") { (res, error) in
        }
        webView.evaluateJavaScript("window.setOption(\"theme\", \"\(EditorHelper.currentTheme())\")") { (res, error) in
        }
        webView.evaluateJavaScript("window.setOption(\"set_mode\", \"\(lang)\")") { (res, error) in
        }
        
        webView.evaluateJavaScript(contentScript) { (res, error) in
        }
        
        webView.evaluateJavaScript("var a = function(){return window.getComputedStyle( document.querySelector('.CodeMirror') ,null).getPropertyValue('background-color')}; a();") { (res, error) in
            let colorStr = (res as! String).replace(target: "rgb(", withString: "").replace(target: ")", withString: "")
            let arr = colorStr.components(separatedBy: ", ")
            if arr.count == 3 {
                let color = UIColor(red: Int(arr[0]) ?? 0, green: Int(arr[1]) ?? 0, blue: Int(arr[2]) ?? 0, alpha: 1)
                self.contentWebView.scrollView.backgroundColor = color
            }
            print(colorStr, arr)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.contentWebView.alpha = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
