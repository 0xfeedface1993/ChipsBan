//
//  SettingView.swift
//  ChipsBan
//
//  Created by JohnConner on 2020/1/28.
//  Copyright © 2020 JohnConner. All rights reserved.
//

import SwiftUI

enum ConfigType {
    case host
    case account
    case fingerprint
    case none
}

struct SettingView: View {
    @Environment(\.presentationMode) var presentation
    @State var mainHost: String = UserDefaults.standard.host
    @State var account: String = UserDefaults.standard.account
    @State var activeType: ConfigType = .none
    
    var back: some View {
        return Button(action: {
            self.dismiss()
        }) {
            Image(systemName: "chevron.left")
        }.frame(width: 44, height: 44)
    }
    
    
    var body: some View {
        VStack {
            LeftRightView(title: "主域名", content: $mainHost).onTapGesture {
                self.active(type: .host)
            }.frame(height: 44)
            if self.activeType == .host {
                TextField("http(s)://www.example.com", text: $mainHost, onEditingChanged: { state in
                    
                }, onCommit: {
                    withAnimation {
                        self.activeType = .none
                    }
                    UserDefaults.standard.host = self.mainHost
                }).frame(height: 44).keyboardType(.URL).transition(AnyTransition.move(edge: .leading)).animation(Animation.spring())
            }
            Divider()
            LeftRightView(title: "账号", content: $account).onTapGesture {
                self.active(type: .account)
            }.frame(height: 44)
            if self.activeType == .account {
                TextField("318715498", text: $account, onEditingChanged: { state in
                    
                }, onCommit: {
                    withAnimation {
                        self.activeType = .none
                    }
                    UserDefaults.standard.account = self.account
                }).frame(height: 44).transition(AnyTransition.move(edge: .leading)).animation(Animation.spring())
            }
            Divider()
            Spacer()
            }.padding().navigationBarBackButtonHidden(true).navigationBarItems(leading: back).navigationBarTitle("设置")
    }
    
    func dismiss() {
        self.presentation.wrappedValue.dismiss()
    }
    
    func active(type: ConfigType) {
        if type == self.activeType {
            self.activeType = .none
            return
        }
        
        self.activeType = type
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(mainHost: "", account: "")
    }
}
