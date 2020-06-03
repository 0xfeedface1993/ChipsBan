//
//  InputView.swift
//  ChipsBan
//
//  Created by JohnConner on 2020/1/29.
//  Copyright © 2020 JohnConner. All rights reserved.
//

import SwiftUI

struct InputView: View {
    @State var title: String
    @Binding var content: String
    var body: some View {
        HStack {
            Text(title).foregroundColor(.white)
            TextField("", text: $content).multilineTextAlignment(.trailing)
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView(title: "测试", content: .constant("阿佩尔哦哦"))
    }
}
