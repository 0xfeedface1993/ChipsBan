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
        VStack {
            Text("").font(.title).foregroundColor(.orange)
            ZStack {
                Rectangle().cornerRadius(100).frame(width: 200, height: 200).foregroundColor(ban.todayCheckIn ? .red:.blue).onTapGesture {
                    withAnimation {
                        self.ban.chekin()
                    }
                }.blur(radius: ban.todayCheckIn ? 0:2).animation(Animation.easeOut)
                Text(ban.todayCheckIn ? "今日已签到":"签到").font(.title).foregroundColor(.white).lineLimit(nil)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Ban())
    }
}
