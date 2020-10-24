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
import CryptoKit

class Ban: ObservableObject {
    enum State {
        case normal
        case getCookie
        case login
        case fetchQuestion
        case uploadAnswser
        case failed
        
        var text: String {
            let sets: [State:String] = [.normal: "",
                                        .getCookie: "首页加载",
                                        .login: "登录中",
                                        .fetchQuestion: "获取题目",
                                        .uploadAnswser: "上传答案",
                                        .failed: "失败"]
            return sets[self] ?? ""
        }
        
        enum Reward {
            case normal
            case waiting
            case sigin
            case success
            case failed
            
            var text: String {
                let sets: [Reward:String] = [.normal: "",
                                            .waiting: "等待奖励",
                                            .sigin: "处理中",
                                            .success: "奖励成功",
                                            .failed: "获取奖励失败"]
                return sets[self] ?? ""
            }
        }
    }
    
    @Published var todayCheckIn = false
    @Published var username : String?
    @Published var password : String?
    @Published var state : State = .normal
    @Published var reward : State.Reward = .normal
    var cancels = Set<AnyCancellable>()
    
    private var latestCookie = ""
    
    init() {
        reload()
    }
    
    func reload() {
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
        
//        login()
        cookies()
    }
    
    func failedCompletion() {
        self.todayCheckIn = false
        state = .failed
        reward = .normal
    }
    
    func debugClear() {
        todayCheckIn = false
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentor.viewContext
        let fetch = NSFetchRequest<Check>(entityName: "Check")
        let fetch2 = NSFetchRequest<Reward>(entityName: "Reward")
        fetch.predicate = NSPredicate(value: true)
        fetch2.predicate = NSPredicate(value: true)
        
        do {
            let results = try context.fetch(fetch).map({ $0.objectID })
            let results2 = try context.fetch(fetch2).map({ $0.objectID })
            for i in results {
                let obj = context.object(with: i)
                context.delete(obj)
            }
            for i in results2 {
                let obj = context.object(with: i)
                context.delete(obj)
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func cookies() {
        let host = UserDefaults.standard.host
        guard let url = URL(string: host) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.addValue("zh-cn", forHTTPHeaderField: "Accept-Language")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "accept-encoding")
        state = .getCookie
        reward = .waiting
        URLSession.shared.dataTaskPublisher(for: request)
            .map({ $1 as? HTTPURLResponse })
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink(receiveValue: { [weak self] response in
                guard let res = response else { return }
                print(">>> response: \(res)")
                guard let cookie = res.allHeaderFields["Set-Cookie"] as? String else {
                    self?.state = .failed
                    return
                }
                print(">>> Set-Cookie: \(cookie)")
                self?.latestCookie = cookie
                self?.login()
            }).store(in: &cancels)
    }
    
    func login() {
        state = .login
        username = UserDefaults.standard.account
        password = "\(Insecure.MD5.hash(data: UserDefaults.standard.pasword.data(using: .utf8)!).description.components(separatedBy: ": ").last ?? "")"
        let fingerprint = "3583691549"
        
        let host = UserDefaults.standard.host
        
        var request = URLRequest(url: URL(string: "\(host)/member.php?mod=logging&action=login&loginsubmit=yes&infloat=yes&lssubmit=yes&inajax=1")!)
        request.httpMethod = "POST"
        request.addValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("\(host)", forHTTPHeaderField: "Origin")
        request.addValue("zh-cn", forHTTPHeaderField: "Accept-Language")
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.addValue(HTTPCookieStorage.shared.currentCookie, forHTTPHeaderField: "Cookie")
        request.addValue("\(host)/", forHTTPHeaderField: "Referer")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.httpBody = "fingerprint=\(fingerprint)&referer=portal.html&username=\(username ?? "")&password=\(password ?? "")&quickforward=yes&handlekey=ls&sectouchpoint=0".data(using: .utf8, allowLossyConversion: false)!
        URLSession.shared.dataTaskPublisher(for: request)
            .map({ data, response -> String? in
                if let res = response as? HTTPURLResponse {
                    self.cookieCache(response: res)
                    res.logCookie()
                }
                return String(data: data, encoding: .utf8)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .replaceError(with: nil)
            .sink(receiveValue: { [weak self] result in
                print(result ?? "oops")
                self?.choice()
            }).store(in: &cancels)
    }
    
    func choice() {
        state = .fetchQuestion
        let host = UserDefaults.standard.host
        var request = URLRequest(url: URL(string: "\(host)/plugin.php?id=lotteryquiz:lotteryquiz")!)
        request.httpMethod = "GET"
        request.addValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.addValue("zh-cn", forHTTPHeaderField: "Accept-Language")
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.addValue(latestCookie, forHTTPHeaderField: "Cookie")
        request.addValue("\(host)/home.php?mod=spacecp&ac=credit&showcredit=1", forHTTPHeaderField: "referer")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        URLSession.shared.dataTaskPublisher(for: request).delay(for: 2, scheduler: DispatchQueue.main).map({ data, response -> String? in
            if let res = response as? HTTPURLResponse {
                self.cookieCache(response: res)
                res.logCookie()
            }
            return String(data: data, encoding: .utf8)
        })
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        .replaceError(with: nil)
        .sink(receiveValue: { [weak self] result in
            print(result ?? "oops")
            guard let raw = result else { return }
            do {
                let doc = try SwiftSoup.parse(raw)
                if let formhash = try doc.getElementsByAttributeValue("name", "formhash").first()?.attr("value") {
                    self?.realCheckIn(hash: formhash)
                }   else    {
                    DispatchQueue.main.async {
                        self?.failedCompletion()
                    }
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self?.failedCompletion()
                }
            }
        }).store(in: &cancels)
    }
    
    func realCheckIn(hash: String) {
        state = .uploadAnswser
        let host = UserDefaults.standard.host
        var request = URLRequest(url: URL(string: "\(host)/plugin.php?id=lotteryquiz")!)
        request.httpMethod = "POST"
        request.addValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("\(host)", forHTTPHeaderField: "Origin")
        request.addValue("zh-cn", forHTTPHeaderField: "Accept-Language")
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.addValue(HTTPCookieStorage.shared.currentCookie, forHTTPHeaderField: "Cookie")
        request.addValue("\(host)/plugin.php?id=lotteryquiz:lotteryquiz", forHTTPHeaderField: "Referer")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("Keep-Alive", forHTTPHeaderField: "Connection")
        let data = "formhash=\(hash)&action=checkanswer&answer=B".data(using: .utf8, allowLossyConversion: false)!
        request.httpBody = data
        
        URLSession.shared.dataTaskPublisher(for: request).map({ data, response -> String? in
            if let res = response as? HTTPURLResponse {
                self.cookieCache(response: res)
                res.logCookie()
            }
            return String(data: data, encoding: .utf8)
        })
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        .replaceError(with: nil)
        .sink(receiveValue: { [weak self] result in
            print(result ?? "oops")
            guard let raw = result else { return }
            do {
                let doc = try SwiftSoup.parse(raw)
                
                let completion : () -> () = {
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentor.viewContext
                    let item = Check(context: context)
                    item.time = Date()
                    item.account = self?.username ?? "oops"
                    item.password = self?.password
                    context.insert(item)
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    self?.todayCheckIn = true
                    self?.state = .normal
                    self?.reward(check: item)
                }
                
                var found = false
                
                if let msg = try doc.getElementById("answer_msg")?.text(), msg.isCheckInText {
                    print(msg)
                    completion()
                    found = true
                }
                
                if try doc.text().isCheckInText {
                    completion()
                    found = true
                }
                
                if !found {
                    self?.failedCompletion()
                }
            } catch {
                print(error.localizedDescription)
                self?.failedCompletion()
            }
        }).store(in: &cancels)
    }
    
    func reward(check: Check) {
        self.reward = .sigin
        let host = UserDefaults.standard.host
        var request = URLRequest(url: URL(string: "\(host)/plugin.php?id=signin:signin_reg")!)
        request.httpMethod = "POST"
        request.addValue("application/json, text/javascript, */*; q=0.01", forHTTPHeaderField: "Accept")
        request.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.addValue("zh-cn", forHTTPHeaderField: "Accept-Language")
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("\(host)", forHTTPHeaderField: "Origin")
        request.addValue("\(host)//portal.html", forHTTPHeaderField: "Referer")
        request.addValue(HTTPCookieStorage.shared.currentCookie, forHTTPHeaderField: "Cookie")
        request.addValue("Keep-Alive", forHTTPHeaderField: "Connection")
        let data = "ac=regsign".data(using: .utf8, allowLossyConversion: false)!
        request.httpBody = data
        
        URLSession.shared.dataTaskPublisher(for: request).map({ data, response -> Data? in
            if let res = response as? HTTPURLResponse {
                self.cookieCache(response: res)
                res.logCookie()
            }
            return data
        })
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        .replaceError(with: nil)
        .sink(receiveValue: { [weak self] result in
            print(result ?? "oops")
            guard let data = result else {
                self?.reward = .failed
                return
            }
            
            let completion: ((SnapReward) -> Void) = { info in
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentor.viewContext
                let reward = Reward(context: context)
                reward.time = Date()
                reward.status = Int32(info.status)
                reward.msg = info.msg
                reward.reward_info = info.rewardInfo
                reward.reward_type = info.rewardType
                reward.check = check
                context.insert(reward)
                print(">>> 插入: \(info)")
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                self?.reward = .normal
            }
            
            guard let raw = SnapReward(data: data) else {
                guard let json = SnapReward.Onic(data: data) else {
                    self?.reward = .failed
                    return
                }
                completion(SnapReward(status: 1, msg: json.msg, rewardInfo: "", rewardType: ""))
                return
            }
            completion(raw)
        }).store(in: &cancels)
    }
    
    func cookieCache(response: HTTPURLResponse) {
        self.latestCookie = HTTPCookieStorage.shared.currentCookie
    }
}

extension String {
    var isCheckInText: Bool {
        self.contains("恭喜哦") || self.contains("请明天再来")
    }
}

extension HTTPURLResponse {
    func logCookie() {
        print(">>> cookies: \(HTTPCookieStorage.shared.currentCookie)")
        print(">>> response: \(self.url?.absoluteString ?? "bad"), cookie: \(self.allHeaderFields["Set-Cookie"] as? String ?? "bad")")
    }
}

extension HTTPCookieStorage {
    var currentCookie: String {
        cookies?.compactMap({ ($0.name, $0.value) }).map({ "\($0.0)=\($0.1)" }).joined(separator: "; ") ?? ""
    }
}
