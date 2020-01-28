//
//  Ban.swift
//  ChipsBan
//
//  Created by JohnConner on 2020/1/28.
//  Copyright © 2020 JohnConner. All rights reserved.
//

import UIKit
import CoreData
import SwiftSoup
import Combine

class Ban: ObservableObject {
    @Published var todayCheckIn = false
    @Published var username : String?
    @Published var password : String?
    var goLogin: AnyCancellable?
    var goChioce: AnyCancellable?
    var goCheckIn: AnyCancellable?
    
    init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentor.viewContext
        let fetch = NSFetchRequest<Check>(entityName: "Check")
        fetch.predicate = NSPredicate.init(value: true)
        fetch.fetchLimit = 1
        let sort = NSSortDescriptor.init(key: "time", ascending: false)
        fetch.sortDescriptors = [sort]
        do {
            let result = try context.fetch(fetch)
            if let item = result.first, Calendar.current.isDateInToday(item.time!) {
                todayCheckIn = true
                return
            }
            todayCheckIn = false
        } catch {
            print(error.localizedDescription)
            todayCheckIn = false
        }
    }
    
    func chekin() {
        if self.todayCheckIn {
            return
        }
        
        login()
    }
    
    func debugClear() {
        todayCheckIn = false
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentor.viewContext
        let fetch = NSFetchRequest<Check>(entityName: "Check")
        fetch.predicate = NSPredicate.init(value: true)
        
        do {
            let results = try context.fetch(fetch).map({ $0.objectID })
            for i in results {
                let obj = context.object(with: i)
                context.delete(obj)
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func login() {
        username = "318715498"
        password = "a016b7182c0de2605b1d118f3c1e7366"
        let fingerprint = "3583691549"
        
        var request = URLRequest(url: URL(string: "https://www.chezzen.space/member.php?mod=logging&action=login&loginsubmit=yes&infloat=yes&lssubmit=yes&inajax=1")!)
        request.httpMethod = "POST"
        request.addValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.addValue("https://www.chezzen.space", forHTTPHeaderField: "origin")
        request.addValue("zh-cn", forHTTPHeaderField: "accept-language")
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.4 Safari/605.1.15", forHTTPHeaderField: "user-agent")
        request.addValue("https://www.chezzen.space/", forHTTPHeaderField: "referer")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "accept-encoding")
 
        request.httpBody = "fingerprint=\(fingerprint)&referer=portal.html&username=\(username ?? "")&password=\(password ?? "")&quickforward=yes&handlekey=ls&sectouchpoint=0".data(using: .utf8, allowLossyConversion: false)!
        let goLogin = URLSession.shared.dataTaskPublisher(for: request)
            .map({ String(data: $0.data, encoding: .utf8) })
            .receive(on: DispatchQueue.main)
        self.goLogin = goLogin.sink(receiveCompletion: { error in
            
        }) { [unowned self] result in
            print(result ?? "oops")
            self.choice()
        }
    }
    
    func choice() {
        var request = URLRequest(url: URL(string: "https://www.chezzen.space/plugin.php?id=lotteryquiz:lotteryquiz")!)
        request.httpMethod = "GET"
        request.addValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "accept")
        request.addValue("zh-cn", forHTTPHeaderField: "accept-language")
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.4 Safari/605.1.15", forHTTPHeaderField: "user-agent")
        request.addValue("https://www.chezzen.space/home.php?mod=spacecp&ac=credit&showcredit=1", forHTTPHeaderField: "referer")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "accept-encoding")
        
        let goChioce = URLSession.shared.dataTaskPublisher(for: request).map({ String(data: $0.data, encoding: .utf8) }).receive(on: DispatchQueue.main)
        self.goChioce = goChioce.sink(receiveCompletion: { _ in }) { [unowned self] result in
            guard let raw = result else { return }
            do {
                let doc = try SwiftSoup.parse(raw)
                if let formhash = try doc.getElementsByAttributeValue("name", "formhash").first()?.attr("value") {
                    self.realCheckIn(hash: formhash)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func realCheckIn(hash: String) {
        var request = URLRequest(url: URL(string: "https://www.chezzen.space/plugin.php?id=lotteryquiz")!)
        request.httpMethod = "POST"
        request.addValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.addValue("https://www.chezzen.space", forHTTPHeaderField: "origin")
        request.addValue("zh-cn", forHTTPHeaderField: "accept-language")
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.4 Safari/605.1.15", forHTTPHeaderField: "user-agent")
        request.addValue("https://www.chezzen.space/plugin.php?id=lotteryquiz", forHTTPHeaderField: "referer")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "accept-encoding")
        
        let data = "formhash=\(hash)&action=checkanswer&answer=B".data(using: .utf8, allowLossyConversion: false)!
        request.httpBody = data
        
        let goCheck = URLSession.shared.dataTaskPublisher(for: request).map({ String(data: $0.data, encoding: .utf8) }).receive(on: DispatchQueue.main)
        self.goCheckIn = goCheck.sink(receiveCompletion: { _ in }) { [unowned self] result in
            guard let raw = result else { return }
            do {
                let doc = try SwiftSoup.parse(raw)
                
                let completion : () -> () = {
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentor.viewContext
                    let item = Check(context: context)
                    item.time = Date()
                    item.account = self.username ?? "oops"
                    item.password = self.password
                    context.insert(item)
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    self.todayCheckIn = true
                }
                if let msg = try doc.getElementById("answer_msg")?.text() {
                    print(msg)
                    completion()
                }
                
                if try doc.text().contains("恭喜哦") {
                    completion()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
