//
//  ContentView.swift
//  ChipsBan
//
//  Created by JohnConner on 2020/1/28.
//  Copyright © 2020 JohnConner. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var ban : Ban
    var body: some View {
        NavigationView {
            VStack {
                Text(needShow() ? "正在签到":"").font(.title).foregroundColor(.orange)
                Spacer()
                ZStack {
                    Rectangle().cornerRadius(100).frame(width: 200, height: 200).foregroundColor(ban.todayCheckIn ? .red:.blue).onTapGesture {
                        withAnimation {
                            self.ban.chekin()
                        }
                    }.blur(radius: ban.todayCheckIn ? 0:2).animation(Animation.easeOut)
                    Text(ban.todayCheckIn ? "今日已签到":"签到").font(.title).foregroundColor(.white).lineLimit(nil)
                }
                Spacer()
            }.navigationBarItems(trailing: NavigationLink(destination: SettingView()) {
                Text("设置")
            }).onAppear {
                self.ban.reload()
            }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                self.ban.reload()
            }
        }.environment(\.horizontalSizeClass, .compact).foregroundColor(.orange)
    }
    
    func needShow() -> Bool {
        if ban.goLogin != nil, ban.goChioce != nil, ban.goCheckIn != nil {
            return false
        }
        
        if let _ = ban.goLogin {
            return true
        }
        
        if let _ = ban.goChioce {
            return true
        }
        
        if let _ = ban.goCheckIn {
            return true
        }
        
        return false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Ban())
    }
}
