//
//  ResultVC.swift
//  leetcoder
//
//  Created by EricJia on 2019/7/30.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation

import Foundation

import UIKit
import SwiftyJSON
import SwiftEntryKit

enum LCResultType {
    case run
    case submit
}

class ResultViewController: UIViewController {
    
    var topView: UIView!
    var bottomView: UIView!
    var exitBtn: UIButton!
    
    var headLabel: UILabel!
    var runtimeLabel: UILabel!
    var runtimeContentLabel: UILabel!
    var inputLabel: UILabel!
    var outputLabel: UILabel!
    var expectedLabel: UILabel!
    var inputContentLabel: UILabel!
    var outputContentLabel: UILabel!
    var expectedContentLabel: UILabel!
   
    
    var type: LCResultType!
    var data: JSON!
    var runAnswer: String!
    var runInput: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupDatas()
    }
    
    func setErrView (msg: String) {
        headLabel.textColor = Colors.hard
        inputLabel = UILabel()
        bottomView.addSubview(inputLabel)
        inputLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        inputLabel.snp.makeConstraints { (make) in
            make.top.equalTo(runtimeLabel.snp.bottom).offset(20)
            make.left.equalTo(runtimeLabel)
            make.width.equalTo(runtimeLabel)
        }
        
        inputContentLabel = UILabel()
        bottomView.addSubview(inputContentLabel)
        inputContentLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        inputContentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(inputLabel)
            make.left.equalTo(runtimeContentLabel)
            make.right.equalTo(runtimeContentLabel)
        }
        
        inputLabel.text = t(str: "Error") + ":  "
        inputContentLabel.numberOfLines = 0
        inputContentLabel.text = msg
        inputContentLabel.textColor = Colors.hard
        
        
    }
    
    func setContentView() {
        headLabel.textColor = Colors.base
        
        inputLabel.snp.makeConstraints { (make) in
            make.top.equalTo(runtimeLabel.snp.bottom).offset(20)
            make.left.equalTo(runtimeLabel)
            make.width.equalTo(runtimeLabel)
        }
        
        inputContentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(inputLabel)
            make.left.equalTo(runtimeContentLabel)
            make.right.equalTo(runtimeContentLabel)
        }
        
        outputLabel.snp.makeConstraints { (make) in
            make.top.equalTo(inputContentLabel.snp.bottom).offset(20)
            make.left.equalTo(runtimeLabel)
            make.width.equalTo(runtimeLabel)
        }
        
        outputContentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(outputLabel)
            make.left.equalTo(runtimeContentLabel)
            make.right.equalTo(runtimeContentLabel)
        }
        
        expectedLabel.snp.makeConstraints { (make) in
            make.top.equalTo(outputContentLabel.snp.bottom).offset(20)
            make.left.equalTo(runtimeLabel)
            make.width.equalTo(runtimeLabel)
        }
        
        expectedContentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(expectedLabel)
            make.left.equalTo(runtimeContentLabel)
            make.right.equalTo(runtimeContentLabel)
        }
        
        inputLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        inputContentLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        outputLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        outputContentLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        expectedLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        expectedContentLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        runtimeLabel.textColor = Colors.boldColor
        inputLabel.textColor = Colors.boldColor
        outputLabel.textColor = Colors.boldColor
        expectedLabel.textColor = Colors.boldColor
        

        let color = Colors.titleColor
        runtimeContentLabel.textColor = color
        inputContentLabel.textColor = color
        outputContentLabel.textColor = color
        expectedContentLabel.textColor = color
        inputContentLabel.numberOfLines = 0
        outputContentLabel.numberOfLines = 0
        expectedContentLabel.numberOfLines = 0
        runtimeContentLabel.numberOfLines = 0
    }
    
    func setRunSuccData() {
        let bgColor = Colors.mainColor
        inputContentLabel.backgroundColor = bgColor
        outputContentLabel.backgroundColor = bgColor
        expectedContentLabel.backgroundColor = bgColor
        inputLabel.text =    t(str: "Input") + ":"
        outputLabel.text =   t(str: "Output") + ":"
        expectedLabel.text = t(str: "Expected") + ":"
        let output = data["code_answer"].arrayValue.map({ (ans) -> String in
            return ans.stringValue
        }).joined(separator: "\n")
        inputContentLabel.text = runInput
        outputContentLabel.text = output
        expectedContentLabel.text = runAnswer
    }
    
    func setSubmitSuccData(isWrong: Bool) {
        let total_correct = data["total_correct"].stringValue
        let total_testcases = data["total_testcases"].stringValue
        let status_memory = data["status_memory"].stringValue
        inputLabel.text = t(str: "Memory") + ":"
        outputLabel.text = t(str: "TestCase") + ":"
        
        inputContentLabel.text = status_memory
        outputContentLabel.text = "\(total_correct) / \(total_testcases) " + t(str: "passed")
        if isWrong == true {
            headLabel.textColor = Colors.hard
        } else {
            let memory_percentile = data["memory_percentile"].doubleValue.format(f: ".2")
            let runtime_percentile = data["runtime_percentile"].doubleValue.format(f: ".2")
            // let lang = data["pretty_lang"].stringValue
            runtimeContentLabel.text = "\(runtimeContentLabel.text!), \(t(str: "faster than")) \(runtime_percentile)%"
            inputContentLabel.text = "\(inputContentLabel.text!), \(t(str: "less than")) \(memory_percentile)%"
        }
    }
    
    func setupDatas() {
        let status_msg = data["status_msg"].stringValue
        let status_runtime = data["status_runtime"].stringValue
//        let status_memory = data["status_memory"].stringValue
        
        var msg = ""
        switch status_msg {
        case "Accepted":
            msg = status_msg
        case "Compile Error":
            msg = data["compile_error"].stringValue
        case "Time Limit Exceeded":
            msg = "Time Limit Exceeded"
        case "Runtime Error":
            msg = data["runtime_error"].stringValue
        default:
            msg = status_msg
        }
        headLabel = UILabel()
        bottomView.addSubview(headLabel)
        headLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(exitBtn)
            make.left.equalToSuperview().offset(20)
            
        }
        headLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        headLabel.text = t(str: status_msg)
        
        runtimeLabel = UILabel()
        bottomView.addSubview(runtimeLabel)
        runtimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(70)
        }
        runtimeContentLabel = UILabel()
        bottomView.addSubview(runtimeContentLabel)
        runtimeContentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(runtimeLabel)
            make.left.equalTo(runtimeLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
        }
        runtimeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        runtimeContentLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        runtimeLabel.text = "\(t(str: "Runtime")): "
        runtimeContentLabel.text = status_runtime

        if status_msg == "Accepted" && type == .run {
            setContentView()
            setRunSuccData()
        } else if status_msg == "Accepted" && type == .submit {
            setContentView()
            setSubmitSuccData(isWrong: false)
        } else if status_msg == "Wrong Answer" && type == .submit {
            setContentView()
            setSubmitSuccData(isWrong: true)
        } else {
            setErrView(msg: msg)
        }
        
    }
    
    func setupViews() {
        topView = UIView()
        view.addSubview(topView)
        bottomView = UIView()
        view.addSubview(bottomView)
        exitBtn = UIButton()
        bottomView.addSubview(exitBtn)
        inputLabel = UILabel()
        bottomView.addSubview(inputLabel)
        inputContentLabel = UILabel()
        bottomView.addSubview(inputContentLabel)
        outputLabel = UILabel()
        bottomView.addSubview(outputLabel)
        outputContentLabel = UILabel()
        bottomView.addSubview(outputContentLabel)
        expectedLabel = UILabel()
        bottomView.addSubview(expectedLabel)
        expectedContentLabel = UILabel()
        bottomView.addSubview(expectedContentLabel)
        
        bottomView.backgroundColor = Colors.mainColor
        bottomView.layer.cornerRadius = 8
        bottomView.layer.masksToBounds = true
        
        bottomView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            
        }
        
        
        exitBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(20)
            make.size.equalTo(25)
            
        }
        
        exitBtn.setImage(UIImage(named: "exit_btn"), for: .normal)
        
        exitBtn.addTarget(self, action: #selector(handleExit), for: .touchUpInside)
    }
    
    @objc func handleExit () {
        SwiftEntryKit.dismiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
