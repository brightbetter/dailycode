//
//  account.swift
//  leetcoder
//
//  Created by EricJia on 2019/8/8.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

func getCookie(key: String) ->  String {
    let cookies = HTTPCookieStorage.shared.cookies!
    var value = ""
    for cookie in cookies {
        if cookie.name == key {
            value = cookie.value
        }
    }
    if value == "csrftoken" {
        UserDefaults.standard.set(value, forKey: "leetcode_token")
    }
    if value == "LEETCODE_SESSION" {
        UserDefaults.standard.set(value, forKey: "leetcode_sessionId")
    }
    return value
}

func isSignIn () -> Bool {
    return getUsername() != ""
}

func signOut () {
    HTTPCookieStorage.shared.removeCookies(since: Date.init(timeIntervalSince1970: 0))
    UserDefaults.standard.set(nil, forKey: "leetcode_token")
    UserDefaults.standard.set(nil, forKey: "leetcode_sessionId")
    UserDefaults.standard.set(nil, forKey: "leetcode_username")
//    UserDefaults.standard.set(nil, forKey: "csrftoken")
//    UserDefaults.standard.set(nil, forKey: "LEETCODE_SESSION")
}

func needSignIn() {
    if isSignIn() == false {
        let vc = LoginViewController()
        UIApplication.shared.keyWindow?.rootViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

func saveUsername(username: String) {
    FileCache.setVal(username, forKey: "leetcode_username")
}

func getUsername() -> String {
    return FileCache.getVal("leetcode_username") as? String ?? ""
}

func getHeaders() -> [String:String] {
    let token = getCookie(key: "csrftoken")
    let sessionId = getCookie(key: "LEETCODE_SESSION")
    let headers = [
        "Cookie": "LEETCODE_SESSION=" + sessionId + ";csrftoken=" + token + ";",
        "X-CSRFToken": token,
    ]
    return headers
}


func getTokenFromResp(response: Alamofire.DefaultDataResponse) ->  String {
    let headerFields = response.response?.allHeaderFields as! [String: String]
    let url = response.request?.url
    let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url!)
    var cookieArray = [ [HTTPCookiePropertyKey : Any ] ]()
    var csrftoken = ""
    var sessionId = ""
    for cookie in cookies {
        if cookie.name == "csrftoken" {
            csrftoken = cookie.value
        }
        if cookie.name == "LEETCODE_SESSION" {
            sessionId = cookie.value
        }
        cookieArray.append(cookie.properties!)
    }
    UserDefaults.standard.set(cookieArray, forKey: "leetcode_cookie")
    UserDefaults.standard.set(csrftoken, forKey: "leetcode_token")
    UserDefaults.standard.set(sessionId, forKey: "leetcode_sessionId")
    return csrftoken
}

func saveLoginCookie(cookies: [HTTPCookie]) -> Bool {
    var cookieArray = [ [HTTPCookiePropertyKey : Any ] ]()
    var csrftoken = ""
    var sessionId = ""
    var isLogin = false
    for cookie in cookies {
        if cookie.name == "csrftoken" {
            csrftoken = cookie.value
        }
        if cookie.name == "LEETCODE_SESSION" {
            sessionId = cookie.value
            isLogin = true
        }
        cookieArray.append(cookie.properties!)
    }
    UserDefaults.standard.set(cookieArray, forKey: "leetcode_cookie")
    UserDefaults.standard.set(csrftoken, forKey: "leetcode_token")
    UserDefaults.standard.set(sessionId, forKey: "leetcode_sessionId")
    return isLogin
}
func delCookie(str: String) {
    let cstorage = HTTPCookieStorage.shared
    if let cookies = cstorage.cookies(for: URL(string: str)!) {
        for cookie in cookies {
            cstorage.deleteCookie(cookie)
        }
    }
}
