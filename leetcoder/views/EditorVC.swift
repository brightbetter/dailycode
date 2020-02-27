//
//  TagVC.swift
//  leetcoder
//
//  Created by EricJia on 2019/7/22.
//  Copyright © 2019 EricJia. All rights reserved.
//

/* two sum solution
 indice = {}
 for i, v in enumerate(nums):
 if v in indice:
 return [indice[v], i]
 else:
 indice[target - v] = i
 */
import Foundation

import UIKit
import WebKit
import JavaScriptCore
import Alamofire
import SwiftyJSON
import SwiftEntryKit
import Highlightr
import SDCAlertView
import Lottie
import Spring
import UIDeviceComplete

protocol CodeEditorDelegate {
    func handleToolBar(item: UIBarButtonItem)
}

class CodeEditorWebView: WKWebView {

    var accessoryView: UIView?
    var topBarStrs:[String] = []
    var bottomBarStrs:[String] = []
    var toolBarDelegate: CodeEditorDelegate?
    
    override var inputAccessoryView: UIView? {
        let view = UIView()
        if UIDevice.current.dc.isIpad {
            view.frame = CGRect(x: 0, y: 0, width: UIApplication.shared.keyWindow!.frame.size.width, height: 40)
            let topBar = addToolbar(topBarStrs + bottomBarStrs)
            view.addSubview(topBar)
            topBar.snp.makeConstraints { (make) in
                make.top.left.right.bottom.equalToSuperview()
            }
        } else {
            view.frame = CGRect(x: 0, y: 0, width: UIApplication.shared.keyWindow!.frame.size.width, height: 80)
            let topBar = addToolbar(topBarStrs)
            let bottomBar = addToolbar(bottomBarStrs)
            view.addSubview(topBar)
            view.addSubview(bottomBar)
            topBar.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(40)
            }
            bottomBar.snp.makeConstraints { (make) in
                make.bottom.left.right.equalToSuperview()
                make.height.equalTo(40)
            }
        }
        return view
    }
    
    @objc func click(item: UIBarButtonItem) {
        toolBarDelegate?.handleToolBar(item: item)
    }
    
    func addToolbar(_ toolBarStrs :[String]) -> UIView {
        let toolbar: UIToolbar = UIToolbar()
        toolbar.tintColor = Colors.boldColor;
        toolbar.backgroundColor = UIColor.gray;
        var items:[UIBarButtonItem] = []
//        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        for (index, title) in toolBarStrs.enumerated() {
            let item = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(click))
            items.append(item)
            item.tag = index
        }
//        toolbar.autoresizingMask = .flexibleWidth
//        toolbar.bounds = toolbar.frame
        toolbar.items = items
        toolbar.sizeToFit()
        return toolbar;
    }
}

class EditorViewwController: BaseViewController, WKNavigationDelegate, UITextViewDelegate, CodeEditorDelegate {
    
    var webview: CodeEditorWebView!
    var questionId:String = ""
    var titleSulg = ""
    var code: String=""
    var lang: String=""
    var langSlug: String=""
    var sampleTestCase: String=""
    var enableEdit:Bool = true
    var runBtn: UIButton!
    var submitBtn: UIButton!
    var enableClick:Bool = true
    var textStorage = CodeAttributedString()
    var textView = UITextView()
    var bgView: SpringView?
    var tabStr = "    "
    let topBarStrs =  [" \"\" "," \'\' ",  " [] ", " {} "," () "," ; ", " : ", " , ", " . ", " + ", " = "]
    let bottomBarStrs = [ " ↺ ", " ↻ ", " ← ", " → ", " F ", " ↓ "]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = t(str: "Editor")
        
        setupViews()
        let rightBarBtn1 = UIBarButtonItem(image: UIImage(named: "reset"), style: .plain, target: self, action: #selector(handleReset))
        rightBarBtn1.tintColor = Colors.boldColor
        let rightBarBtn2 = UIBarButtonItem(image: UIImage(named: "set"), style: .plain, target: self, action: #selector(handleToSetting))
        rightBarBtn2.tintColor = Colors.boldColor
        self.navigationItem.rightBarButtonItems = [rightBarBtn1]
//        beginLoading()
    }

    override func viewWillDisappear(_ animated: Bool) {
        webview.evaluateJavaScript("window.getEditorContent()") { (res, error) in
            let codeContent = (res as! String).fromBase64()
            FileCache.setVal(codeContent, forKey: "\(self.titleSulg)-\(self.lang)-2")
        }
        
    }
    
    @objc func handleReset() {
        let alert = AlertController(title: t(str: "Reset"), message: t(str: "reset editor content"), preferredStyle: .alert)
        alert.addAction(AlertAction(title: "Cancel", style: .normal))
        alert.addAction(AlertAction(title: "OK", style: .preferred, handler: { (h) in
            self.webview.evaluateJavaScript("window.setEditorContent(\"" + self.code.toBase64() +  "\")", completionHandler: nil)
        }))
        alert.present()

    }

    
    @objc func handleToSetting() {
        let editor = EditerSettingViewController()
        self.navigationController?.pushViewController(editor, animated: true)
    }
    
    override func beginLoading(type:EKAttributes.NotificationHapticFeedback=EKAttributes.NotificationHapticFeedback.success,
    text:String="Loading. Please wait...",
    bgColor:UIColor=Colors.base
    ) {
        if isLoading == true {
            return
        }
        isLoading = true
        bgView = SpringView()
        view.addSubview(bgView!)
        bgView!.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
        bgView!.animation = "fadeIn"
        bgView!.curve = "easeIn"
        bgView!.duration = 0.01
        bgView!.backgroundColor = Colors.shadowBgColor
        bgView!.animate()
        
        let starAnimationView = AnimationView()
        bgView!.addSubview(starAnimationView)
        starAnimationView.backgroundColor = Colors.mainColor
        starAnimationView.layer.cornerRadius = 25
        starAnimationView.snp.makeConstraints { (make) in
            make.size.equalTo(160)
            make.center.equalToSuperview()
        }
        let imageView = UIImageView(image: UIImage(named: "monkey_pc"))
        starAnimationView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.size.equalTo(100)
            make.center.equalToSuperview()
        }
        /// Some time later
        
        let file = Bundle.main.path(forResource: "loading", ofType: "json") ?? ""
        let starAnimation = Animation.filepath(file)
        starAnimationView.animation = starAnimation
        starAnimationView.loopMode = .repeat(100)
        starAnimationView.play()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeBgView))
        tap.delegate = self
        bgView!.addGestureRecognizer(tap)
    }
    
    @objc func removeBgView() {
        self.endLoading()
    }
    
    override func endLoading() {
        super.endLoading()
        self.bgView?.removeFromSuperview()
    }
    
    func setupViews() {
        
        view.backgroundColor = .white
        webview = CodeEditorWebView()
        view.addSubview(webview)
        webview.topBarStrs = topBarStrs
        webview.bottomBarStrs = bottomBarStrs
        webview.toolBarDelegate = self
        webview.navigationDelegate = self
        webview.scrollView.isScrollEnabled = false
        webview.snp.makeConstraints ({(make) in
            make.left.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            } else {
                make.top.equalToSuperview().offset(88)
            }
        })

        runBtn = UIButton()
        view.addSubview(runBtn)
        
        submitBtn = UIButton()
        view.addSubview(submitBtn)
        
        runBtn.setTitle("\(t(str: "Run"))   ", for: .normal)
        runBtn.setTitleColor(.black, for: .normal)
        runBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        runBtn.layer.shadowColor = UIColor(red: 0.46, green: 0.58, blue: 0.63, alpha: 0.1).cgColor
        runBtn.layer.shadowOffset = CGSize(width: 0, height: 3)
        runBtn.layer.shadowOpacity = 1
        runBtn.layer.shadowRadius = 10
        runBtn.backgroundColor = Colors.medium
        runBtn.setTitleColor(.white, for: .normal)
        runBtn.layer.cornerRadius = 5
        
        if enableEdit == false {
            runBtn.removeFromSuperview()
            submitBtn.removeFromSuperview()
            webview.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
            }
        } else {
            runBtn.snp.makeConstraints ({(make) in
                make.left.equalToSuperview().offset(40)
                make.bottom.equalToSuperview().offset(-44)
                make.width.equalToSuperview().dividedBy(2).offset(-50)
                make.height.equalTo(45)
                
            })
            submitBtn.setTitle(t(str: "Submit"), for: .normal)
            submitBtn.setTitleColor(.white, for: .normal)
            submitBtn.backgroundColor = Colors.base
            submitBtn.layer.cornerRadius = 5
            submitBtn.layer.masksToBounds = true
            submitBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            submitBtn.snp.makeConstraints ({(make) in
                make.centerY.equalTo(runBtn)
                make.right.equalToSuperview().offset(-40)
                make.size.equalTo(runBtn)
                
            })
            
            webview.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-65 - 44)
            }
            
            runBtn.addTarget(self, action: #selector(handleRun), for: .touchUpInside)
            submitBtn.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        }
        FileCache.loadLocalEditor(webview: webview)
//        webview.becomeFirstResponder()
        
//        if UIDevice.current.dc.commonDeviceName {
//            var barButtonItems:[UIBarButtonItem] = []
//            for (index, title) in topBarStrs.enumerated() {
//                let item = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
//                barButtonItems.append(item)
//                item.tag = index
//            }
//            webview.inputAssistantItem.leadingBarButtonGroups = [UIBarButtonItemGroup(barButtonItems: barButtonItems, representativeItem: nil)]
//            webview.inputAssistantItem.trailingBarButtonGroups = []
//        }
        
    }
    
     
    func handleToolBar(item: UIBarButtonItem) {
        var appendStr = ""
        switch item.title! {
        case "Tab":
            appendStr = tabStr
        case " \"\" ":
            appendStr = "\"\""
        case " \'\' ":
            appendStr = "\'\'"
        case " [] ":
            appendStr = "[]"
        case " {} ":
            appendStr = "{}"
        case " () ":
            appendStr = "()"
        case " ↓ ":
            self.view.endEditing(true)
            return
        case " : ":
            appendStr = ":"
        case " , ":
            appendStr = ","
        case " ; ":
            appendStr = ";"
        case " . ":
            appendStr = "."
        case " + ":
            appendStr = "+"
        case " = ":
            appendStr = "="
//         [ " ↺ ", " ↻ ", " ← ", " → ", " F ", " ↓ "]
        case " ↻ ":
            webview.evaluateJavaScript("window.editor.redoSelection();", completionHandler: nil)
        case " ↺ ":
            webview.evaluateJavaScript("window.editor.undoSelection();") { (err, res) in
                print("Undo", err ?? "", res ?? "")
            }
        case " → ":
            webview.evaluateJavaScript("window.editor.indentSelection(\"add\");") { (err, res) in
                 print("Indent", err ?? "", res ?? "")
            }
        case " ← ":
            webview.evaluateJavaScript("window.editor.indentSelection(\"subtract\");") { (err, res) in
                print("Unindent", err ?? "", res ?? "")
            }
        case " F ":
            webview.evaluateJavaScript("var totalLines = editor.lineCount(); window.editor.autoFormatRange({line:0, ch:0}, {line:totalLines});setTimeout(function(){window.getSelection().empty();}, 200);") { (err, res) in
                print("Format", err ?? "", res ?? "")
            }
        default:
            print(item.title!)
        }
        if appendStr != "" {
            var str = "\"\(appendStr)\""
            if appendStr == "\"\"" {
                str = "'\(appendStr)'"
            }
            webview.evaluateJavaScript("editor.replaceRange(\(str), {line: editor.getCursor().line, ch: editor.getCursor().ch})") { (err, res) in
                print("append", err ?? "", res ?? "")
                if appendStr.count == 2 {
                    self.webview.evaluateJavaScript("editor.setCursor({line: editor.getCursor().line, ch: editor.getCursor().ch-1})") { (err, res) in
                        print("move", err ?? "", res ?? "")
                    }
                }
            }
        }
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if enableEdit == false {
                webview.evaluateJavaScript("window.setOption(\"readOnly\", \"nocursor\")") { (res, error) in
                }
            }
            webView.evaluateJavaScript("document.querySelector('.CodeMirror').style.fontSize = '\(EditorHelper.currentFontsize())px'") { (res, error) in
                
            }
            webview.evaluateJavaScript("window.setOption(\"theme\", \"\(EditorHelper.currentTheme())\")") { (res, error) in
            }
            webview.evaluateJavaScript("window.setOption(\"set_mode\", \"\(EditorHelper.currentLang())\")") { (res, error) in
            }
            let cacheText =  FileCache.getVal("\(titleSulg)-\(lang)-2") as? String ?? ""
            if cacheText != "" && enableEdit == true {
                self.webview.evaluateJavaScript("window.setEditorContent(\"" + cacheText.toBase64() +  "\")", completionHandler: nil)
            } else {
                self.webview.evaluateJavaScript("window.setEditorContent(\"" + code.toBase64() +  "\")", completionHandler: nil)
            }
            webview.evaluateJavaScript("var a = function(){return window.getComputedStyle( document.querySelector('.CodeMirror') ,null).getPropertyValue('background-color')}; a();") { (res, error) in
                let colorStr = (res as! String).replace(target: "rgb(", withString: "").replace(target: ")", withString: "")
                let arr = colorStr.components(separatedBy: ", ")
                if arr.count == 3 {
                    let color = UIColor(red: Int(arr[0]) ?? 0, green: Int(arr[1]) ?? 0, blue: Int(arr[2]) ?? 0, alpha: 1)
                    self.webview.scrollView.backgroundColor = color
                    self.view.backgroundColor = color
                }
                print(colorStr, arr)
            }
        }
     
    // 跳转
    
    func pushToResultVC(vc: ResultViewController) {
        endLoading()
        var attributes = EKAttributes.bottomFloat
        attributes.displayDuration = .infinity
        attributes.screenBackground = .color(color: UIColor(white: 100.0/255.0, alpha: 0.3))
        attributes.entryBackground = .color(color: UIColor.init(white: 0, alpha: 0))
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.entranceAnimation = .init(
            translate: .init(
                duration: 0.3,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
        attributes.exitAnimation = .init(
            translate: .init(duration: 0.35)
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.3)
            )
        )
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 6
            )
        )
        attributes.positionConstraints.size = .init(
            width: .fill,
            height: .ratio(value: 0.5)
            
        )
        attributes.positionConstraints.verticalOffset = 0
        attributes.positionConstraints.safeArea = .overridden
        attributes.statusBar = .currentStatusBar
        SwiftEntryKit.display(entry: vc, using: attributes)
    }
    
    func checkResult(okUrl:String, ErrUrl:String, headers:HTTPHeaders) {
        
        MySession.request(okUrl, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case let .success(value):
                let result = JSON(value)
                let state = result["state"].stringValue
                
                if state == "SUCCESS" {
                    let statusMsg = result["status_msg"].stringValue
                    if statusMsg == "Accepted" {
                        print("检查运行成功")
                    }
                    
                    MySession.request(ErrUrl.contains("/detail//check/") ? okUrl : ErrUrl, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                        switch response.result {
                        case let .success(value):
                            let answer = JSON(value)["code_answer"].arrayValue.map({ (ans) -> String in
                                return ans.stringValue
                            }).joined(separator: "\n")
                            let vc = ResultViewController()
                            vc.data = result
                            vc.type = LCResultType.run
                            vc.runInput = self.sampleTestCase
                            vc.runAnswer = answer
                            self.pushToResultVC(vc: vc)
                        case let .failure(error):
                            print(ErrUrl, error)
                        }
                    }
                    print("检查运行结果", state, statusMsg)
                    return
                } else {
                    print("检查运行结果中,", state)
                    self.checkResult(okUrl: okUrl, ErrUrl: ErrUrl, headers: headers)
                }
                sleep(1)
            case let .failure(error):
                print(error)
            }
        }
        
    }
    
    func checkSubmitResult(url:String, headers:HTTPHeaders) {
        MySession.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case let .success(value):
                let result = JSON(value)
                let state = result["state"].stringValue
                
                if state == "SUCCESS" {
                    let statusMsg = result["status_msg"].stringValue
                    
                    print("检查提交结果", state, statusMsg, statusMsg)
                    let vc = ResultViewController()
                    vc.data = result
                    vc.type = LCResultType.submit
                    vc.runInput = self.sampleTestCase
                    vc.runAnswer = ""
                    self.pushToResultVC(vc: vc)
                    return
                } else {
                    print("检查提交结果中,", state)
                    self.checkSubmitResult(url: url, headers: headers)
                }
                sleep(1)
            case let .failure(error):
                print(error)
            }
        }
        
    }
    
    
    @objc func handleRun(sender: Selector){
        if isSignIn() == false {
            navigationController?.pushViewController(LoginViewController(), animated: true)
            return
        }
        
        webview.evaluateJavaScript("window.getEditorContent()") { (res, error) in
            if res == nil {
                return
            }
            self.beginLoading(text: "Judging...")
            let codeContent = (res as! String).fromBase64()
            let parameters = [
                "data_input":  self.sampleTestCase,
                "lang": self.langSlug,
                "question_id": Int(self.questionId) ?? 1,
                "test_mode": true,
                "typed_code": codeContent ?? "",
                ] as [String : Any]
            
            let token = getCookie(key: "csrftoken")
            let sessionId = getCookie(key: "LEETCODE_SESSION")
            var headers = [
                "Origin": Urls.base,
                "Referer": Urls.problem.replace(target: "$slug", withString: self.titleSulg).withCN(),
                "Cookie": "LEETCODE_SESSION=" + sessionId + ";csrftoken=" + token + ";",
                "X-CSRFToken": token,
                "X-Requested-With": "XMLHttpRequest",
            ]
            let url = Urls.test.replace(target: "$slug", withString: self.titleSulg).withCN()
            MySession.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                print(response)
                switch response.result {
                case let .success(value):
                    let result = JSON(value)
                    print(result)
                    let interpretId = result["interpret_id"].stringValue
                    let interpretExpectedId = result["interpret_expected_id"].stringValue
                    print("interpretId:", interpretId)
                    print("interpretExpectedId:", interpretExpectedId)
                    let interpretUrl = Urls.verify.replace(target: "$id", withString: interpretId).withCN()
                    let expectedUrl = Urls.verify.replace(target: "$id", withString: interpretExpectedId).withCN()
                    headers["Referer"] = Urls.problem.replace(target: "$slug", withString: self.titleSulg).withCN()
                    self.checkResult(okUrl: interpretUrl, ErrUrl: expectedUrl, headers: headers)
                    
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
    
    @objc func handleSubmit(sender: Selector){
        if isSignIn() == false {
            navigationController?.pushViewController(LoginViewController(), animated: true)
            return
        }
        
        webview.evaluateJavaScript("window.getEditorContent()") { (res, error) in
            if res == nil {
                return
            }
            self.beginLoading(text: "Judging...")
            let codeContent = (res as! String).fromBase64()
            let parameters = [
                "judge_type":  "large",
                "lang": self.langSlug,
                "question_id": Int(self.questionId) ?? 1,
                "test_mode": false,
                "typed_code": codeContent ?? "",
                ] as [String : Any]
            
            let token = getCookie(key: "csrftoken")
            let sessionId = getCookie(key: "LEETCODE_SESSION")
            var headers = [
                "Origin": Urls.base,
                "Referer": Urls.problem.replace(target: "$slug", withString: self.titleSulg).withCN(),
                "Cookie": "LEETCODE_SESSION=" + sessionId + ";csrftoken=" + token + ";",
                "X-CSRFToken": token,
                "X-Requested-With": "XMLHttpRequest",
            ]
            let url = Urls.submit.replace(target: "$slug", withString: self.titleSulg).withCN()
            MySession.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                switch response.result {
                case let .success(value):
                    let JSON = value as! Dictionary<String, Any>
                    print(JSON)
                    let submissionId = String(JSON["submission_id"] as! Int)
                    print("submissionId:", submissionId)
                    let submissionUrl = Urls.verify.replace(target: "$id", withString: submissionId).withCN()
                    headers["Referer"] = Urls.problem.replace(target: "$slug", withString: self.titleSulg).withCN()
                    self.checkSubmitResult(url: submissionUrl, headers: headers)
                    
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
