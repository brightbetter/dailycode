//
//  ProblemVC.swift
//  leetcoder
//
//  Created by EricJia on 2019/7/22.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation

import UIKit

import Alamofire
import SwiftyJSON

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = Colors.borderColor.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = Colors.borderColor.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.8)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

class LoginViewController: BaseViewController {
    var imageView:UIImageView!
    var usernameTF:UITextField!
    var passwordTF:UITextField!
    var loginBtn:UIButton!
    var golbalLabel: UILabel!
    var cnLabel: UILabel!
    var isGlobal = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.barTintColor = .cl
        self.navigationController?.navigationBar.isTranslucent = true
        
        imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.size.equalTo(94)
            make.centerX.equalTo(view)
            make.top.equalToSuperview().offset(120)
        }
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds =  true
        
        usernameTF = UITextField()
        usernameTF.borderStyle = .none
        usernameTF.textColor = Colors.titleColor
        usernameTF.attributedPlaceholder = NSAttributedString.init(string:t(str: "Username or E-mail"), attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize:15), NSAttributedString.Key.foregroundColor:Colors.subTitleColor])
        usernameTF.setBottomBorder()
        view.addSubview(usernameTF)
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        usernameTF.leftView = paddingView
        usernameTF.leftViewMode = .always
        usernameTF.autocapitalizationType = .none
        usernameTF.backgroundColor = Colors.mainColor
        usernameTF.keyboardType = .emailAddress
        usernameTF.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
            make.top.equalTo(imageView.snp.bottom).offset(40)
        }
        
        passwordTF = UITextField()
        passwordTF.attributedPlaceholder = NSAttributedString.init(string:t(str: "Password"), attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize:15), NSAttributedString.Key.foregroundColor:Colors.subTitleColor])
        passwordTF.leftView = paddingView
        passwordTF.leftViewMode = .always
        passwordTF.borderStyle = .none
        passwordTF.setBottomBorder()
        passwordTF.textColor = Colors.titleColor
        passwordTF.backgroundColor = Colors.mainColor
        passwordTF.clearButtonMode = .always
        passwordTF.isSecureTextEntry = true
        view.addSubview(passwordTF)
        passwordTF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        passwordTF.leftViewMode = .always
        passwordTF.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
            make.top.equalTo(usernameTF.snp.bottom).offset(20)
        }
        
        golbalLabel = UILabel.with(size: 13, weight: .medium, color: Colors.base)
        golbalLabel.text = "Global"
        golbalLabel.textAlignment = .right
        golbalLabel.isUserInteractionEnabled = true
        view.addSubview(golbalLabel)
        let globalTap = UITapGestureRecognizer(target: self, action: #selector(globalClick))
        golbalLabel.addGestureRecognizer(globalTap)
        golbalLabel.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTF.snp.bottom).offset(20)
            make.centerX.equalToSuperview().offset(-35)
            make.height.equalTo(30)
        }
        
        cnLabel = UILabel.with(size: 13, weight: .medium, color: Colors.titleColor)
//        cnLabel.text = "China"
        cnLabel.text = "China"
        cnLabel.textAlignment = .left
        cnLabel.isUserInteractionEnabled = true
        view.addSubview(cnLabel)
        let cnTap = UITapGestureRecognizer(target: self, action: #selector(cnClick))
        cnLabel.addGestureRecognizer(cnTap)
        cnLabel.snp.makeConstraints { (make) in
            make.top.equalTo(golbalLabel)
            make.centerX.equalToSuperview().offset(35)
            make.height.equalTo(golbalLabel)
        }
        
        loginBtn = UIButton()
        loginBtn.setTitle(t(str: "Sign in"), for: .normal)
        loginBtn.backgroundColor = Colors.easy
        loginBtn.setTitleColor(UIColor(hexStr: "#FFFFFF"), for: .normal)
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds =  true
        loginBtn.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        view.addSubview(loginBtn)
        loginBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(usernameTF)
            make.height.equalTo(40)
            make.top.equalTo(golbalLabel.snp.bottom).offset(20)
        }
        
//        handleLogin()
        if self.usernameTF.canBecomeFirstResponder {
            self.usernameTF.becomeFirstResponder()
        }
        globalClick()
        
    }
    
    func loadwebView() {
        let webviewVC = WebViewController()
        webviewVC.linkUrl = "https://leetcode.com/accounts/login/"
        webviewVC.isGlobalLogin = true
        webviewVC.loginSuccCallBack = { (_) in
            self.loginSucc(username: "ok")
        }
        self.navigationController?.pushViewController(webviewVC, animated: true)
//        self.navigationController?.pushViewController(webviewVC, animated: true)
    }
    
    @objc func globalClick() {
        golbalLabel.textColor = Colors.base
        cnLabel.textColor = Colors.titleColor
        isGlobal = true
        FileCache.setVal(isGlobal, forKey: "isGlobal")
    }
    
    @objc func cnClick() {
        golbalLabel.textColor = Colors.titleColor
        cnLabel.textColor = Colors.base
        isGlobal = false
        FileCache.setVal(isGlobal, forKey: "isGlobal")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func handleLogin(){
        let loginUrl = Urls.login.withCN()
        let headers = [
            "Origin": Urls.base.withCN(),
            "Referer": loginUrl,
        ]
        
        signOut()
        delCookie(str: loginUrl)
        if isGlobal {
            loadwebView()
            return
        }
        self.beginLoading(text: "Sign in...")
        MySession.request(loginUrl, headers: headers).response { response in
            let csrftoken = getTokenFromResp(response: response)
            print("Login: get token:", csrftoken)
            
            let params = [
                "csrfmiddlewaretoken": csrftoken,
                "login": self.usernameTF.text!,
                "password": self.passwordTF.text!,
            ]
            MySession.request(loginUrl, method: .post, parameters:params, headers: headers).response { response in
                let token = getCookie(key: "csrftoken")
                let sessionId = getCookie(key: "LEETCODE_SESSION")
                print("Session:", sessionId)
                print("Token:", token)
                let headers = getHeaders()
                if self.isGlobal == false {
                    let parameters = ["query": GraphqlSchema.cnUser]
                    MySession.request(Urls.graphql.withCN(), method:.post, parameters:parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                        switch response.result {
                        case let .success(value):
                            let username = JSON(value)["data"]["userStatus"]["username"].stringValue
                            self.loginSucc(username: username)
                        case let .failure(error):
                            print(error)
                        }
                    }
                    return
                }
                
                let parameters = [
                    "query": "{\n  user {\n    username\n  }\n}\n",
                    "operationName": "",
                    "variables": ""
                ]
                
                MySession.request(Urls.graphql, method:.post, parameters:parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                    switch response.result {
                    case let .success(value):
                        let username = JSON(value)["data"]["user"]["username"].stringValue
                        self.loginSucc(username: username)
                    case let .failure(error):
                        print(error)
                    }
                }
            }
        }
    }
    
    func loginSucc(username: String) {
        if username == "" {
            self.beginLoading(text: "Sign in failed", bgColor: Colors.hard)
        } else {
            self.beginLoading(text: t(str: "Welcome") + " " + username)
            saveUsername(username: username)
        }
        print(username)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.endLoading()
            if username != "" {
                FileCache.setVal(self.isGlobal, forKey: "isGlobal")
                let vc = self.navigationController?.viewControllers.first as? ProfileViewController
                vc?.setSigninStatus()
                vc?.fetchData()
                self.navigationController?.popViewController(animated: true)
                let notificationName = Notification.Name(rawValue: "LoginChange")
                NotificationCenter.default.post(name: notificationName, object: self,
                                                        userInfo: nil)
            }
           
        })
    }
    
    @objc func handleBack(sender: Selector){
        dismiss(animated: true) {
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
