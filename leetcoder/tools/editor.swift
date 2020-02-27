//
//  editor.swift
//  leetcoder
//
//  Created by EricJia on 2019/8/8.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import Highlightr

class EditorHelper: NSObject {
    
    static func getCodeSnippets (lang: String) -> String {
        var res = ""
        let codeSnippets = FileCache.getDescDict(titleSlug: "two-sum")["codeSnippets"].arrayValue
        codeSnippets.forEach { (item) in
            if item["lang"].stringValue == lang {
                res = item["code"].stringValue
            }
        }
        return res
    }
    
    static func getLangSlug(lang: String) -> String{
        if lang.lowercased() == "python3" {
            return "python"
        }
        var res = lang.lowercased()
        let codeSnippets = FileCache.getDescDict(titleSlug: "two-sum")["codeSnippets"].arrayValue
        codeSnippets.forEach { (item) in
            if item["lang"].stringValue == lang {
                res = item["langSlug"].stringValue
            }
        }
        return res
    }
    
    static func getLanguages() -> [String] {
        return ["C++","C", "C#", "Java", "JavaScript", "Python", "Python3", "Swift",  "Scala", "Rust", "Ruby", "PHP", "Kotlin"]
    }
    
    static func currentLang() -> String {
        return UserDefaults.standard.value(forKey: "editor_lang")  as? String ?? "Python3"
    }
    
    static func setLang(lang: String) {
        UserDefaults.standard.set(lang, forKey: "editor_lang")
        UserDefaults.standard.synchronize()
    }
    
    static func currentFontsize() -> Int {
        return UserDefaults.standard.value(forKey: "editor_fontsize")  as? Int ?? 13
    }
    
    static func setFontsize(fontsize: Int) {
        UserDefaults.standard.set(fontsize, forKey: "editor_fontsize")
        UserDefaults.standard.synchronize()
    }
    
    static func currentTheme() -> String {
        return UserDefaults.standard.value(forKey: "editor_theme")  as? String ?? "default"
    }
    
    static func setTheme(theme: String) {
       UserDefaults.standard.set(theme, forKey: "editor_theme")
        UserDefaults.standard.synchronize()
    }
    
    static func createEditorView(textStorage: CodeAttributedString, code: String, lang: String, theme: String) -> UITextView {
        textStorage.language = lang
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: UIApplication.shared.keyWindow?.frame.size ?? CGSize.zero)
        layoutManager.addTextContainer(textContainer)
        
        let textView = UITextView(frame: CGRect.zero, textContainer: textContainer)
        
        textView.text = code
        textView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.autocapitalizationType = UITextAutocapitalizationType.none
        textView.textColor = UIColor(white: 0.8, alpha: 1.0)
        textStorage.highlightr.setTheme(to: theme)
        textView.backgroundColor = textStorage.highlightr.theme.themeBackgroundColor
        return textView
    }
}
