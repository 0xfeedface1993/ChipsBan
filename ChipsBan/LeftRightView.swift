//
//  LeftRightView.swift
//  ChipsBan
//
//  Created by JohnConner on 2020/1/28.
//  Copyright © 2020 JohnConner. All rights reserved.
//

import SwiftUI

struct LeftRightView: View {
    var title: String
    @Binding var content: String
    var body: some View {
        HStack {
            Text(title)
            Spacer(minLength: 8)
            Text(content).foregroundColor(.gray)
            Image(systemName: "chevron.right").padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
        }
    }
}

struct LeftRightView_Previews: PreviewProvider {
    static var previews: some View {
        LeftRightView(title: "gogogo", content: .constant("yes"))
    }
}
