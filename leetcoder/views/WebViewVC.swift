//
//  WebViewVC.swift
//  leetcoder
//
//  Created by EricJia on 2019/7/28.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation

import UIKit
import WebKit
import Alamofire
extension WKWebView {
    func refreshCookies() {
        self.configuration.processPool = WKProcessPool()
        // TO DO: Save your cookies,...
    }
}

class WebViewController: BaseViewController, WKNavigationDelegate {
    
    var linkUrl:String!
    var isGlobalLogin: Bool = false
    var loginSuccCallBack: ((Any) -> Void)?
//    var scrollView: UIScrollView!
//    var contentView: UIView!
    var contentWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
//        scrollView = UIScrollView()
//        view.addSubview (scrollView)
        
//        contentView = UIView()
//        scrollView.addSubview (contentView)
        print(view.bounds)
        
        contentWebView = WKWebView(frame: view.bounds)
        contentWebView.backgroundColor = .white
        view.addSubview(contentWebView)
        contentWebView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        contentWebView.navigationDelegate = self
        if isGlobalLogin {
            if #available(iOS 11.0, *) {
                contentWebView.configuration.websiteDataStore.httpCookieStore.setCookie(HTTPCookie()) {
                    
                }
            } else {
                // Fallback on earlier versions
            }
        }
        let request = URLRequest(url: URL(string: linkUrl)!, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 6000)
        contentWebView.load(request)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("fail")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("Start loading")
        beginLoading()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("End loading")
        endLoading()
        if isGlobalLogin {
            if #available(iOS 11.0, *) {
                webView.configuration.websiteDataStore.httpCookieStore.getAllCookies() { cookies in
                    // do what you need with cookies
                    for cookie in cookies {
                        print(cookie.name, cookie.value)
                        HTTPCookieStorage.shared.setCookie(cookie)
                    }
                    MySession.session.configuration.httpCookieStorage?.setCookies(cookies, for: webView.url, mainDocumentURL: nil)
                    let ok = saveLoginCookie(cookies: cookies)
                    if ok {
                        if (self.loginSuccCallBack != nil) {
                            self.loginSuccCallBack!(true)
                        }
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if isGlobalLogin {
            
            let urlStr = navigationAction.request.url?.relativeString ?? ""
            print("jump", urlStr)
            if urlStr.contains("about:blank") || urlStr.contains("leetcode-cn") {
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
        
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
