//
//  EditSettingVC.swift
//  leetcoder
//
//  Created by EricJia on 2019/8/4.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation

import UIKit
import SwiftyJSON
import TagListView
import WebKit
import Alamofire
import Spring
import Highlightr
//import AMPopTip

class EditerSettingViewController: BaseViewController, WKNavigationDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    var colltionView: UICollectionView!
    let langs = EditorHelper.getLanguages()
    var data:JSON! = nil
    var langBtn: UIButton!
    var themesTableView: UITableView!
    var programLangLabel: UILabel!
    var fontsizeLabel: UILabel!
    var themeLabel: UILabel!
    var themeRightLabel: UILabel!
    var fontsizeRightLabel: UILabel!
    var programLangRightLabel: UILabel!
    var webviews: [WKWebView]! = []
    var editors: [UITextView] = []
    
//    let themes = Highlightr()?.availableThemes() ?? []
//    let themes = ["default", "routeros",   "monokai-sublime", "vs",  "school-book", "xcode", "solarized-light", "solarized-dark", "github-gist", "atelier-seaside-light", "atom-one-light", "atom-one-dark"]
    let themes = ["default","eclipse", "lucario", "ambiance", "base16-dark", "base16-light", "dracula",   "material", "midnight", "monokai"]
    
    var editorSetings: [CodeAttributedString] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = t(str: "Settings")
        setViews()
        fetchData()
    }
    
    func setViews() {
        editorSetings = themes.map({ (theme) -> CodeAttributedString in
            return CodeAttributedString()
        })
        
        let labelColor = UIColor(hexStr: "#424656")
        programLangLabel = UILabel.with(weight: .medium, color: labelColor)
        view.addSubview(programLangLabel)
        fontsizeLabel = UILabel.with(weight: .medium, color: labelColor)
        view.addSubview(fontsizeLabel)
        fontsizeRightLabel = UILabel.with(weight: .bold, color: Colors.boldColor)
        view.addSubview(fontsizeRightLabel)
        programLangRightLabel = UILabel.with(weight: .bold, color: Colors.boldColor)
        view.addSubview(programLangRightLabel)
        themeLabel = UILabel.with(weight: .medium, color: labelColor)
        view.addSubview(themeLabel)
        themeRightLabel =  UILabel.with(weight: .bold)
        view.addSubview(themeRightLabel)
        let slider = UISlider()
        view.addSubview(slider)
        
        themesTableView = UITableView()
        view.addSubview(themesTableView)
        themesTableView.delegate = self
        themesTableView.dataSource = self
        themesTableView.rowHeight = 140
        themesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "editorSettings")
        themesTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        themesTableView.backgroundColor = Colors.mainColor
        
        langBtn = UIButton()
        view.addSubview(langBtn)
        langBtn.setImage(UIImage(named: "editor_triangle"), for: .normal)
        langBtn.setImage(UIImage(named: "editor_triangle"), for: .highlighted)
        langBtn.addTarget(self, action: #selector(handleLangBtnClick), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLangBtnClick))
        tap.numberOfTapsRequired = 1
        programLangRightLabel.isUserInteractionEnabled = true
        tap.delegate = self
        programLangRightLabel.addGestureRecognizer(tap)
        programLangRightLabel.textAlignment = .right
        
        slider.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-30 + -44)
            make.left.right.equalToSuperview().inset(50)
        }
        
        fontsizeLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(slider.snp.top).offset(-20)
            make.left.equalToSuperview().offset(20)
        }
        
        
        fontsizeRightLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(fontsizeLabel)
            make.right.equalToSuperview().offset(-20)
        }
        
        
        programLangLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(fontsizeLabel.snp.top).offset(-20)
            make.left.equalToSuperview().offset(20)
//            make.right.equalToSuperview().offset(-20)
        }
        
        langBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(programLangLabel)
        }
        
        langBtn.imageView?.snp.makeConstraints({ (make) in
            make.centerY.centerX.equalToSuperview()
            make.width.height.equalTo(10)
            
        })
        
        programLangRightLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(programLangLabel)
            make.left.equalTo(programLangLabel.snp.right)
            make.right.equalToSuperview().offset(-40)
        }
        
        
        
        themeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(88+20)
            make.left.equalTo(view).offset(20)
        }
        
        themeRightLabel.snp.makeConstraints { (make) in
            make.top.equalTo(themeLabel)
            make.right.equalToSuperview().offset(-20)
        }
        
        themesTableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(themeLabel.snp.bottom).offset(20)
            make.bottom.equalTo(programLangLabel.snp.top).offset(-20)
        }
        
        
        slider.center = self.view.center
        slider.minimumValue = 12  //最小值
        slider.maximumValue = 30  //最大值
        slider.isContinuous = true
        slider.maximumTrackTintColor = UIColor(hexStr: "#ECEDF2")
        slider.minimumTrackTintColor = UIColor(hexStr: "#ECEDF2")
        slider.thumbTintColor = UIColor.clear
        slider.addTarget(self, action: #selector(sliderDidChange), for: .valueChanged)
        slider.setThumbImage(UIImage(named: "editor_slider"), for: .normal)
        slider.setThumbImage(UIImage(named: "editor_slider"), for: .highlighted)
        
        
        themeLabel.text = t(str: "Theme")
        fontsizeLabel.text = "\(t(str: "Font Size"))"
        fontsizeRightLabel.text = "\(EditorHelper.currentFontsize())"
        programLangLabel.text = t(str: "Programing Language")
        programLangRightLabel.text = EditorHelper.currentLang()
//        themeRightLabel.text = EditorHelper.currentTheme()
        slider.setValue(Float(EditorHelper.currentFontsize()), animated: true)
        
        themesTableView.reloadData()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return langs.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(index)_cell", for: indexPath as IndexPath)
        let label = UILabel.with(size: 13, color: Colors.titleColor)
        label.text = langs[index]
        cell.addSubview(label)
        cell.backgroundColor = collectionView.backgroundColor
        label.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        if langs[index] == EditorHelper.currentLang() {
            label.textColor = Colors.base
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(langs[indexPath.row])
        EditorHelper.setLang(lang: langs[indexPath.row])
        programLangRightLabel.text = langs[indexPath.row]
        for webView in webviews {
            webView.evaluateJavaScript("window.setOption(\"set_mode\", \"\(EditorHelper.currentLang())\");") { (res, error) in
            }
        }
        removeSpringView()
    }
    
    func removeSpringView() {
        langBtn.isEnabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let superView = self.colltionView.superview as! SpringView
            superView.animation = "slideUp"
            superView.curve = "easeInOutBack"
            superView.duration = 1.0
            superView.animateTo()
        }
    }
    
    @objc func handleLangBtnClick() {
        if langBtn.isEnabled == false {
            removeSpringView()
            return
        }
        langBtn.isEnabled = false
        let contentView = SpringView()
        contentView.animation = "slideUp"
        contentView.curve = "easeIn"
        contentView.duration = 0.5
        contentView.backgroundColor = Colors.mainColor
        view.addSubview(contentView)
        
        let layout = UICollectionViewFlowLayout()
        colltionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        contentView.addSubview(colltionView)
        colltionView.layer.shadowOffset = CGSize(width: 0, height: 8)
        var shadowColor = UIColor(red: 0.85, green: 0.89, blue: 0.92, alpha: 1).cgColor
        if #available(iOS 13.0, *) {
           shadowColor = UIColor.init(dynamicProvider: { (trainCollection) -> UIColor in
               if trainCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.85, green: 0.89, blue: 0.92, alpha: 0.2)
               }
               return UIColor(red: 0.85, green: 0.89, blue: 0.92, alpha: 1)
           }).cgColor
       }

        colltionView.layer.shadowColor = shadowColor
        
        colltionView.layer.shadowOpacity = 0
        colltionView.layer.shadowRadius = 4
        colltionView.layer.cornerRadius = 5
        colltionView.layer.masksToBounds = false
        //注册一个cell
        for i in 0...langs.count-1 {
            colltionView!.register(CalendarCell.self, forCellWithReuseIdentifier:"\(i)_cell")
        }
        colltionView?.delegate = self
        colltionView?.dataSource = self
        colltionView?.backgroundColor = Colors.mainColor
        colltionView.isScrollEnabled = false
        
        //设置每一个cell的宽高
        layout.itemSize = CGSize(width: (view.frame.size.width - 50 - 20) / 4, height: 30)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(programLangLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(19)
            make.right.equalToSuperview().offset(-19)
            make.height.greaterThanOrEqualTo((langs.count / 4 + 1) * (20 + 10))
            make.bottom.equalToSuperview().offset(-20)
        }
        
        colltionView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(10)
        }
        
        contentView.layer.shadowColor = shadowColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 7
        contentView.animate()
    }
    
    @objc func sliderDidChange(slider:UISlider){
        let fontsize = Int(slider.value)
        fontsizeRightLabel.text = "\(fontsize)"
        EditorHelper.setFontsize(fontsize: fontsize)
        webviews.forEach { (webView) in
            webView.evaluateJavaScript("document.querySelector('.CodeMirror').style.fontSize = '\(fontsize)px'") { (res, error) in
                print(error ?? "")
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let theme = themes[webView.tag]
        if EditorHelper.currentTheme() == theme {
            webView.layer.borderWidth = 3
        }
        webView.evaluateJavaScript("window.setOption(\"readOnly\", \"nocursor\"); window.setOption(\"lineNumbers\", false); window.setOption(\"gutters\", []); window.setOption(\"theme\", \"\(theme)\"); ") { (res, error) in
        }
        webView.evaluateJavaScript("window.setOption(\"set_mode\", \"\(EditorHelper.currentLang())\");") { (res, error) in
        }
    }

    func fetchData() {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }
    
    //设置section的数量
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //设置tableview的cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "\(indexPath.section)_\(indexPath.row)"
        var cell = tableView.dequeueReusableCell(withIdentifier: id)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: id)
            let webview = WKWebView()
            cell?.contentView.addSubview(webview)
            webview.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(0)
            }
            cell?.contentView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(20)
                make.top.bottom.equalToSuperview().inset(10)
            }
            if indexPath.row == 0 {
                cell?.contentView.snp.updateConstraints { (make) in
                    make.top.equalToSuperview().inset(0)
                }
            }
            let view = UIView()
            webview.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.left.top.bottom.right.equalToSuperview()
            }
            webview.layer.cornerRadius = 8
            webview.layer.masksToBounds = true
            webview.navigationDelegate = self
            webview.scrollView.isScrollEnabled = false
            webview.tag = indexPath.row
            FileCache.loadLocalEditor(webview: webview)
            webviews.append(webview)
            
            cell?.contentView.backgroundColor = .white
            webview.layer.shadowColor = UIColor(red: 0.85, green: 0.89, blue: 0.92, alpha: 0.3).cgColor
            webview.layer.shadowOffset = CGSize(width: 0, height: 4)
            webview.layer.shadowOpacity = 1
            webview.layer.shadowRadius = 5
            webview.layer.borderColor = Colors.base.cgColor
            webview.layer.borderWidth = 0
        }
        
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let theme = themes[index]

        EditorHelper.setTheme(theme: theme)

        for webview in webviews {
           if webview.tag == index {
               webview.layer.borderWidth = 3
           } else {
               webview.layer.borderWidth = 0
           }
        }
//        themeRightLabel.text = theme
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
