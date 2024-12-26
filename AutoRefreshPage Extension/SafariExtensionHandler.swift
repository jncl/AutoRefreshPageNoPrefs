//
//  SafariExtensionHandler.swift
//  AutoRefreshPage Extension
//
//  Created by Jon Hogg on 18/11/2019.
//  Copyright © 2019-2024 Jon Hogg. All rights reserved.
//

import SafariServices

let myDebug      = false
var initialSetup = false

let reloadBlackList  = [ "developer.apple.com", "google.co.uk", "bbc.co.uk/sport/live" ]
let reloadWhiteList1 = [ "bbc.co.uk/news", "bbc.co.uk/sport" ]
let reloadWhiteList2 = [ "trakt.tv" ]
let refreshInterval1 = 600  // 10 mins
let refreshInterval2 = 7200 // 2 hours

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    fileprivate func checkList(_ urlString: String, _ list: [String]) -> Bool{

        for partURL in list {
            if urlString.contains(partURL) {
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
                if !self.checkList(urlString!, reloadBlackList) {
                    if self.checkList(urlString!, reloadWhiteList1) {
                        if myDebug { NSLog("reload (\(refreshInterval1))") }
                        currentPage.dispatchMessageToScript(withName: "reload", userInfo: ["rInt" : refreshInterval1])
                    }
                    if self.checkList(urlString!, reloadWhiteList2) {
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
