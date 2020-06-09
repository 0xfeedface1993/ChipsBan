//
//  Host.swift
//  ChipsBan
//
//  Created by JohnConner on 2020/2/22.
//  Copyright © 2020 JohnConner. All rights reserved.
//

import Foundation

extension UserDefaults {
    var host: String {
        get {
            return self.object(forKey: "host") as? String ?? "https://www.chezzen.space"
        }
        
        set {
            self.set(newValue, forKey: "host")
        }
    }
    
    var account: String {
        get {
            return self.object(forKey: "account") as? String ?? "318715498"
        }
        
        set {
            self.set(newValue, forKey: "account")
        }
    }
    
    var pasword: String {
        get {
            return self.object(forKey: "password") as? String ?? ""
        }
        
        set {
            set(newValue, forKey: "password")
        }
    }
}
