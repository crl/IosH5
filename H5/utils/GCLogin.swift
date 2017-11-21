//
//  GCLogin.swift
//  H5
//
//  Created by crl on 2017/10/1.
//  Copyright © 2017年 lingyu. All rights reserved.
//

import UIKit
import GameKit;

class GCLogin:NSObject,GKGameCenterControllerDelegate {
    
    var gameCenterEnabled = Bool()
    var playerID:String?;
    
    var loginCallBackHandle:((String)->Void)?;
    
    static let Instance=GCLogin();
    
    func login(callBack:@escaping (String)->Void) {
        
        self.loginCallBackHandle=callBack;
        
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        if(localPlayer.isAuthenticated){
            playerID=localPlayer.playerID;
            self.loginCallBack();
            return;
        }
        
        if(localPlayer.authenticateHandler != nil){
            return
        }
        
        localPlayer.authenticateHandler = {(vc, error) -> Void in
            if(vc != nil) {
                Utils.Present(vc!, animated: true, completion: nil)
                return;
            }
            var uuid:String?;
            if (localPlayer.isAuthenticated) {
                self.gameCenterEnabled = true;
                uuid=localPlayer.playerID;
            } else {
                self.gameCenterEnabled = false;
                uuid=UserDefaults.standard.string(forKey: "uuid");
                if(uuid==nil){
                    uuid=UIDevice.current.identifierForVendor?.uuidString;
                    if(uuid==nil){
                        uuid=NSUUID().uuidString;
                    }
                    if(uuid != nil){
                        UserDefaults.standard.set(uuid, forKey: "uuid");
                    }
                }
            }
            
            if(self.playerID==uuid){
                return;
            }
            self.playerID=uuid;
            self.loginCallBack();
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gcvc: GKGameCenterViewController) {
        gcvc.dismiss(animated: true, completion: nil)
    }
    
    func loginCallBack(){
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        if(localPlayer.isAuthenticated){
            playerID=localPlayer.playerID!;
        }
        
        if(playerID==nil){
            Utils.Send("login_back", "0|login fail!");
            return;
        }
        
        let id=playerID!.replacingOccurrences(of: ":", with: "");
        
        if(self.loginCallBackHandle != nil){
            self.loginCallBackHandle!(id);
        }
        
        let msg=String(format:"1|%@|%@|%@",id,id,"ios");
        Utils.Send("login_back", msg);
    }
    
}
