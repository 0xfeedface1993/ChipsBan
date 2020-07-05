//
//  SnapReward.swift
//  ChipsBan
//
//  Created by JohnConner on 2020/7/5.
//  Copyright © 2020 JohnConner. All rights reserved.
//

import Foundation

struct SnapReward: Codable {
    let status: Int
    let msg: String
    let rewardInfo, rewardType: String

    enum CodingKeys: String, CodingKey {
        case status, msg
        case rewardInfo = "reward_info"
        case rewardType = "reward_type"
    }
    
    struct Onic: Codable {
        let status: Int
        let msg: String
        let isLogin: Int
        
        enum CodingKeys: String, CodingKey {
            case status, msg
            case isLogin = "is_login"
        }
    }
}

// MARK: Convenience initializers

extension SnapReward {
    init?(data: Data) {
        guard let me = try? JSONDecoder().decode(SnapReward.self, from: data) else { return nil }
        self = me
    }

    init?(_ json: String, using encoding: String.Encoding = .utf8) {
        guard let data = json.data(using: encoding) else { return nil }
        self.init(data: data)
    }

    init?(fromURL url: String) {
        guard let url = URL(string: url) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        self.init(data: data)
    }

    var jsonData: Data? {
        return try? JSONEncoder().encode(self)
    }

    var json: String? {
        guard let data = self.jsonData else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension SnapReward.Onic {
    init?(data: Data) {
        guard let me = try? JSONDecoder().decode(SnapReward.Onic.self, from: data) else { return nil }
        self = me
    }

    init?(_ json: String, using encoding: String.Encoding = .utf8) {
        guard let data = json.data(using: encoding) else { return nil }
        self.init(data: data)
    }

    init?(fromURL url: String) {
        guard let url = URL(string: url) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        self.init(data: data)
    }

    var jsonData: Data? {
        return try? JSONEncoder().encode(self)
    }

    var json: String? {
        guard let data = self.jsonData else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
