//
//  http.swift
//  leetcoder
//
//  Created by EricJia on 2019/8/12.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation
import Alamofire

var MySession: SessionManager = {
    let configuration = URLSessionConfiguration.default
    configuration.connectionProxyDictionary = [:]
    configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
    return Alamofire.SessionManager(configuration: configuration);
}();
