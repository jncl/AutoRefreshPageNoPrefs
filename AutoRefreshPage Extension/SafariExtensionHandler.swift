//
//  SafariExtensionHandler.swift
//  AutoRefreshPage Extension
//
//  Created by Jon Hogg on 18/11/2019.
//  Copyright © 2019 Jon Hogg. All rights reserved.
//

import SafariServices

let myDebug      = false;
var initialSetup = false

let reloadBlackList  = [ "developer.apple.com", "google.co.uk", "bbc.co.uk/sport/live" ]
let reloadWhiteList1 = [ "bbc.co.uk/news", "bbc.co.uk/sport" ]
let reloadWhiteList2 = [ "trakt.tv", "forum.tinycorelinux.net/index.php" ]
let refreshInterval1 = 300 // 5 mins
let refreshInterval2 = 7200 // 2 hours

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    fileprivate func checkBlackList(_ urlString: String) -> Bool{

        for partBL in reloadBlackList {
            if urlString.contains(partBL) {
               return false
            }
        }
        if myDebug { NSLog("Page not blacklisted") }
        return true

    }

    fileprivate func checkWhiteList1(_ urlString: String) -> Bool {
 
        for partWL1 in reloadWhiteList1 {
            if urlString.contains(partWL1) {
                if myDebug { NSLog("in WhiteList1") }
                return true
            }
        }
        return false

    }
    
    fileprivate func checkWhiteList2(_ urlString: String) -> Bool {
 
        for partWL2 in reloadWhiteList2 {
            if urlString.contains(partWL2) {
                if myDebug { NSLog("in WhiteList2") }
                return true
            }
        }
        return false
 
    }

    fileprivate func checkLists4Site(_ currentPage: SFSafariPage) {
 
        currentPage.getPropertiesWithCompletionHandler { properties in
            if ((properties?.url) != nil) {
                let urlString = properties?.url?.absoluteString
                if myDebug { NSLog("checkLists4Site Page: (\(urlString!))") }
                if self.checkBlackList(urlString!) {
                    if self.checkWhiteList1(urlString!) {
                        if myDebug { NSLog("reload (\(refreshInterval1))") }
                        currentPage.dispatchMessageToScript(withName: "reload", userInfo: ["rInt" : refreshInterval1])
                    }
                    if self.checkWhiteList2(urlString!) {
                        if myDebug { NSLog("reload (\(refreshInterval2))") }
                        currentPage.dispatchMessageToScript(withName: "reload", userInfo: ["rInt" : refreshInterval2])
                    }
                }
            }
        }

    }
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        
        if myDebug { NSLog("messageReceived (\(messageName))") }
        
        if !initialSetup {
            if myDebug { NSLog("UserDefaults: (\(reloadBlackList)) (\(reloadWhiteList1)) (\(reloadWhiteList2)) (\(refreshInterval1)) (\(refreshInterval2))") }
            initialSetup = true
        }
        
        if messageName == "checkReloadRequired" {
            checkLists4Site(page)
        }
        
    }
        
}
