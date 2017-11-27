//
//  ViewController.swift
//  H5
//
//  Created by crl on 2017/10/1.
//  Copyright © 2017年 lingyu. All rights reserved.
//

import UIKit
import WebKit;
import SystemConfiguration;

class ViewController: UIViewController,WKNavigationDelegate {
    
    var webView:WKWebView!;
    let reachability = Reachability()!;
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        // 创建配置
        let config = WKWebViewConfiguration()
        // 创建UserContentController（提供JavaScript向webView发送消息的方法）
        let userContent = WKUserContentController()
        // 添加消息处理，注意：self指代的对象需要遵守WKScriptMessageHandler协议，结束时需要移除
        //userContent.addScriptMessageHandler(self, name: "NativeMethod")
        // 将UserConttentController设置到配置文件
        config.userContentController = userContent
        
        // 高端的自定义配置创建WKWebView
        webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        
        // 设置代理
        webView.navigationDelegate = self;
        
        // 将WebView添加到当前view
        view.addSubview(webView)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability);
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
        super.viewDidDisappear(animated);
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            login();
            print("Reachable via WiFi");
        case .cellular:
            login();
            print("Reachable via Cellular");
        case .none:
            altertStatus();
            print("Network not reachable")
        }
        
        
        
        
        

    }
    
    // 无网络状态添加提示框
    func altertStatus() {
        let alerContl = UIAlertController.init(title: "斗笔提示您：", message: "无网络链接", preferredStyle: .alert)
        let action1 = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        let action2 = UIAlertAction.init(title: "设置", style: .default) { (action) in
            // 打开系统wifi 设置界面
            let s=UIApplicationOpenSettingsURLString;
            //s="prefs:root=WIFI";
            let url = URL(string: s)!;
            if(UIApplication.shared.canOpenURL(url)){
                UIApplication.shared.open(url);
            }
        }
        alerContl.addAction(action1)
        alerContl.addAction(action2)
        
        Utils.Present(alerContl, animated: true, completion: nil);
    }
    
    
    func login(){
        GCLogin.Instance.login(){
            (id) in
            self.enterGame(userID: id);
        };
    }
    
    
    func enterGame(userID:String) {
        // 设置访问的URL
        let url = URL(string: "http://gate.shushanh5.lingyunetwork.com/gate/micro/login.aspx?userId=\(userID)");
        // 根据URL创建请求
        let requst = URLRequest(url: url!);
        
        // WKWebView加载请求
        webView.load(requst);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

