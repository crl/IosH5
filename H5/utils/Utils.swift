//
//  Utils.swift
//  H5
//
//  Created by crl on 2017/10/16.
//  Copyright © 2017年 lingyu. All rights reserved.
//

import UIKit
import StoreKit;

class Utils: NSObject,SKStoreProductViewControllerDelegate {

    class func GetRoot()->UIViewController{
        let w = UIApplication.shared.delegate?.window;
        return (w!!.rootViewController)!;
    }
    
    static var _instance:Utils?=nil;
    static var loadingBar:UIActivityIndicatorView?=nil;
    static var _hasLoading=false;
    
    class func Shared()->Utils{
        if(_instance==nil){
            _instance=Utils();
        }
        return _instance!;
    }
    
    class func HasLoading()->Bool{
        return _hasLoading;
    }
    
    class func Send(_ key:String,_ value:String){
        
    }
    
    class func Loading(_ b:Bool){
        _hasLoading=b;
        
        if(loadingBar==nil){
            loadingBar=UIActivityIndicatorView(frame: CGRect(x:0,y:0,width:50,height:50));
            loadingBar?.activityIndicatorViewStyle = .gray;
            loadingBar?.color=UIColor.yellow;
            
            let clr=UIColor.black.withAlphaComponent(0.5);
            loadingBar?.backgroundColor=clr;
        }
        
        if let view=Utils.GetRoot().view{
            view.addSubview(loadingBar!);
        }
        
        if(b){
            let rect=UIScreen.main.bounds;
            loadingBar!.center=CGPoint(x: rect.size.width/2, y: rect.size.height/2);
            loadingBar!.startAnimating();
        }else{
            loadingBar?.stopAnimating();
            
            if(loadingBar?.subviews != nil){
                loadingBar?.removeFromSuperview();
            }
        }
    }
    
    class func Present(_ vc:UIViewController,animated:Bool,completion: (() -> Swift.Void)? = nil){
        let rootViewC=UIApplication.shared.delegate?.window!?.rootViewController;
        rootViewC?.present(vc, animated: true, completion: completion);
    }
    
    class func OpenUserReviews(appID:String){
        let format=String(format: "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=%@", arguments: [appID]);
        let url=URL(string: format);
        UIApplication.shared.open(url!);
    }
    
    class func OpenHome(appID:String){
        let storeView=SKStoreProductViewController();
        storeView.delegate=Utils.Shared();
        storeView.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier:appID]) { (result, error) in
            if(result){
                Utils.Present(storeView, animated: true, completion: nil);
            }else if(error != nil){
                print("error: %@",error!);
            }
        }
    }
    
    class func ParserURLKeys(value:String)->[String:String]{
        let temp = value.components(separatedBy: "&")
        var dict=[String:String]();
        
        for item:String in temp{
           let keyValue = item.components(separatedBy:"=");
            if(keyValue.count != 2){
                continue;
            }
            let key=keyValue[0];
            let value=keyValue[1];
            dict[key] = value;
        }
        return dict;
    }
    
    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController){
        viewController.dismiss(animated: true, completion: nil);
    }
}
