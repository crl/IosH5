//
//  IAPManager.swift
//  H5
//
//  Created by crl on 2017/10/6.
//  Copyright © 2017年 lingyu. All rights reserved.
//

import UIKit
import StoreKit;
import Security;

class IAPManager: NSObject,SKPaymentTransactionObserver {
    
    var gameData:NSDictionary?=nil;
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for trans in transactions {
        
            let msg:String=String(format: "Transcation state %ld", [trans.transactionState]);
            
            NSLog(msg);
            
            
            switch(trans.transactionState){
            case .purchased:
                self.completeTransaction(trans);
            case .failed:
                self.failedTransaction(trans);
            case .restored:
                self.restoreTransaction(trans);
            case .purchasing:
                self.purchasingTransaction(trans);
            case .deferred:
                self.deferredTransaction(trans);
            }
            
        }
    }
    
   static let Instance=IAPManager();
    
    func start() {
        SKPaymentQueue.default().add(self);
    }
    
    
    func purchasingTransaction(_ trans:SKPaymentTransaction) -> Void {
    
    }
    
    func deferredTransaction(_ trans:SKPaymentTransaction) -> Void {
        
    }
    
    func completeTransaction(_ trans:SKPaymentTransaction) -> Void {
        self.finish(trans, true);
        //let productIdentifier=trans.payment.productIdentifier;
        
        let receiptURL = Bundle.main.appStoreReceiptURL;
        // 从沙盒中获取到购买凭据
        do{
            let receiptData = try Data(contentsOf: receiptURL!);
            let receipt=receiptData.base64EncodedString(options: .endLineWithCarriageReturn);
            //向自己的服务器验证购买凭证
            
            let postURL="_";
            
            if(postURL.count<5){
                return;
            }
            
            //test;
            //postURL=@"http://192.168.2.163:9001/charge/apple/pay.aspx";
            print("postURL:%@",postURL);
            
            let userInfo=gameData?.object(forKey: "userInfo");
            let productID=gameData?.object(forKey: "productID");
            let appID=gameData?.object(forKey: "appID");
            let productName=gameData?.object(forKey: "productName");
            
            let now=Int(Date.timeIntervalSinceReferenceDate);
            let orderID=String(format:"%d",now);
            
            let post=String(format:"receipt=%@&userInfo=%@&orderID=%@&productID=%@&appID=%@&productName=%@",[receipt,userInfo,orderID,productID,appID,productName]);
            
            self.requestGameServer(postURL: postURL, post: post, failSave: true, deletePath: nil, retryCount: 2);
            
        }catch{
            
        }
    }
    
    func requestGameServer(postURL:String,post:String,failSave:Bool,deletePath:String?,retryCount:Int) {
        
        let postData=post.data(using: .ascii, allowLossyConversion: true);
        let serverURL=URL(string: postURL);
        let postLength=String(format:"%lu",(postData?.count)!);
        
        var request=URLRequest(url:serverURL!);
        request.httpMethod="POST";
        request.setValue(postLength, forHTTPHeaderField: "Content-Length");
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type");
        
        request.httpBody=postData;
        
        let session=URLSession.shared;
        let task=session.dataTask(with: request) { (data, response, error) in
            
            if(error != nil){
                let v=retryCount-1;
                self.requestGameServer(postURL: postURL, post: post, failSave: true, deletePath: nil, retryCount: v);
                return;
            }
            
            if(failSave){
                let msg=String(format:"验证服务器错误返回:%@",[error!]);
                self.showAlert(msg);
                self.saveIapReceipt(postURL,post);
            }
            
            let jsonString=String.init(data: data!, encoding: String.Encoding.utf8);
            if((jsonString?.count)!<3){
                if(failSave){
                    self.saveIapReceipt(postURL,post);
                }
                return;
            }
            
            print("remote:%@",jsonString!);
            
            var json:NSDictionary?=nil;
            do{
                json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? NSDictionary;
            }catch{
                let msg=String(format:"0|支付失败:%@",jsonString!);
                Utils.Send("pay_back",msg);
                
                if(failSave){
                    self.saveIapReceipt(postURL,post);
                }
                
                return;
            }
            
            
            if(failSave==false){
                self.deleteIapReceipt(deletePath);
            
            }
            var msg=String();
            let code=json!.object(forKey: "code") as! Int;
            let remoteData=json!.object(forKey: "data");
            
            if(code==1){
                
            }else{
                msg="0|支付失败!";
                if(remoteData == nil){
                    
                }else{
                    
                }
            }
            
            Utils.Send("pay_back", msg);
        }
        
        task.resume();
    }
    
    class func AppStoreInfoLocalFilePath()->String{
        let prefix=NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
        return String(format:"%@/%@/",prefix,"iap")
    }
    class func GetUUIDString() -> String {
        let uuidRef = CFUUIDCreate(kCFAllocatorDefault)
        let strRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef)
        let uuidString = (strRef! as String).replacingOccurrences(of: "-", with: "");
        return uuidString;
    }
    
    func saveIapReceipt(_ postURL:String,_ post:String){
        let fileName=IAPManager.GetUUIDString();
        let prefix=IAPManager.AppStoreInfoLocalFilePath();
        let savePath=String(format:"%@%@.plist",prefix,fileName);
        
        let dic=NSMutableDictionary();
        dic.setValue(postURL, forKey: "postURL");
        dic.setValue(post, forKey: "post");
        
        dic.write(toFile: savePath, atomically: true);
    }
    
    func sendIapReceipt(_ path:String) {
        let dic=NSDictionary(contentsOfFile: path);
        if(dic==nil){
            self.deleteIapReceipt(path);
            return;
        }
        let postURL=dic?.object(forKey: "postURL") as! String;
        let post=dic?.object(forKey: "post") as! String;
        
        self.requestGameServer(postURL: postURL, post: post, failSave: false, deletePath: path, retryCount: 0);
    }
    
    func deleteIapReceipt(_ path:String?) {
        if(path==nil || path!.isEmpty){
            return;
        }
        let fileManager=FileManager.default;
        if(fileManager.fileExists(atPath: path!)){
            do{
                try fileManager.removeItem(atPath: path!);
            }catch{
            }
        }
    }
    
    //验证receipt失败,App启动后再次验证
    func sendFailedIapFiles(){
        let fileManager=FileManager.default;
        let rootPath=IAPManager.AppStoreInfoLocalFilePath();
        if(fileManager.fileExists(atPath: rootPath)==false){
            do{
                try fileManager.createDirectory(atPath: rootPath, withIntermediateDirectories: true, attributes: nil);
            }catch{
            }
            return;
        }
        
        do{
            let cacheFileNames=try fileManager.contentsOfDirectory(atPath: rootPath);
            for item in cacheFileNames{
                //如果有plist后缀的文件，说明就是存储的购买凭证
                if(item.hasSuffix(".plist")){
                    let filePath=String(format:"%@/%@",rootPath,item);
                    self.sendIapReceipt(filePath);
                }
            }
        }catch{
            return;
        }
        
    }
    
    
    func failedTransaction(_ trans:SKPaymentTransaction) -> Void {
        
    }
    
    func restoreTransaction(_ trans:SKPaymentTransaction) -> Void {
    }

    
    func finish(_ trans:SKPaymentTransaction,_ success:Bool) -> Void {
        Utils.Loading(false);
        SKPaymentQueue.default().finishTransaction(trans);
    }
    
    
    func showAlert(_ msg:String) -> Void {
        let alertControl=UIAlertController(title: "提示", message: msg, preferredStyle: .alert);
        
        let okAction=UIAlertAction(title: "确定", style: .default, handler: nil)
        alertControl.addAction(okAction);
        
    
        Utils.GetRoot().present(alertControl, animated: true, completion: nil);
    }
}
