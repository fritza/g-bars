//
//  WalkInfoForm.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/9/22.
//

import SwiftUI

enum WhereWalked: String, Hashable {
    case atHome, awayFromHome
}

struct WalkInfoForm: View {
    var summary: String {
        var content = "Info: "
//        print(walkedAtHome ? "Home" : "Away",
        print((whereWalked == .atHome) ? "Home" : "Away",
                  terminator: " ", to: &content)
        return content
    }

    @State private var walkedAtHome = true
    @State private var whereWalked: WhereWalked = .atHome

    var body: some View {
            Form {
                Text(self.summary).font(.callout)
            Text("Where did you perform your walks?")
            Picker("Where did you walk?",
                   selection: $whereWalked) {
                Text("At Home")
                    .tag(WhereWalked.atHome)
                Text("Away from home")
                    .tag(WhereWalked.awayFromHome)
            }
            .pickerStyle(.segmented)
}
    }
}

struct WalkInfoForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalkInfoForm()
                .navigationTitle("Walking Info")
        }
    }
}
