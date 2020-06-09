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
    @State var password: String = UserDefaults.standard.pasword
    @State var activeType: ConfigType = .none
    var accountSetState: Bool {
        account.count > 0 && password.count > 0 && (UserDefaults.standard.account != account || UserDefaults.standard.pasword != password)
    }
    
    var back: some View {
        return Button(action: {
            self.dismiss()
        }) {
            Image(systemName: "chevron.left")
        }.frame(width: 44, height: 44)
    }
    
    
    var body: some View {
        VStack {
            LeftRightView(title: "主域名", content: $mainHost)
                .onTapGesture {
                    self.active(type: .host)
            }
            .frame(height: 44)
            if self.activeType == .host {
                TextField("http(s)://www.example.com", text: $mainHost, onEditingChanged: { state in
                    
                }, onCommit: {
                    withAnimation {
                        self.activeType = .none
                    }
                    UserDefaults.standard.host = self.mainHost
                })
                    .frame(height: 44)
                    .keyboardType(.URL)
                    .transition(AnyTransition.move(edge: .leading))
                    .animation(Animation.spring())
            }
            Divider()
            LeftRightView(title: "账号", content: $account)
                .onTapGesture {
                    self.active(type: .account)
            }
            .frame(height: 44)
            if self.activeType == .account {
                TextField("account", text: $account)
                    .frame(height: 44)
                    .transition(AnyTransition.move(edge: .leading))
                    .animation(Animation.spring())
                
                SecureField("password", text: $password)
                    .frame(height: 44)
                    .transition(AnyTransition.move(edge: .leading))
                    .animation(Animation.spring())
                
                Button(action: {
                    if !self.accountSetState {
                        return
                    }
                    UserDefaults.standard.account = self.account
                    UserDefaults.standard.pasword = self.password
                    self.active(type: .none)
                }) {
                    Text("确定")
                        .foregroundColor(.white)
                        .frame(width: 240, height: 44)
                        .background(RoundedRectangle(cornerRadius: 8).foregroundColor(accountSetState ? .green:.gray))
                        .opacity(accountSetState ? 1.0:0.7)
                }
            }
            Divider()
            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: back)
        .navigationBarTitle("设置")
    }
    
    func dismiss() {
        self.presentation.wrappedValue.dismiss()
    }
    
    func active(type: ConfigType) {
        self.reloadAll()
        
        if type == self.activeType {
            self.activeType = .none
            return
        }
        
        self.activeType = type
    }
    
    func reloadAll() {
        self.account = UserDefaults.standard.account
        self.password = UserDefaults.standard.pasword
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(mainHost: "", account: "")
    }
}
