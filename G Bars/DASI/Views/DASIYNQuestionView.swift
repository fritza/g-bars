//
//  DASIYNQuestionView.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/8/22.
//

import SwiftUI

struct DASIYNQuestionView: View {
    @State var yesNoState: Int = 1
    @EnvironmentObject var pages: DASIPages
    @EnvironmentObject var responseStatue: DASIResponseStatus

    var body: some View {
        VStack {
            DASIQuestionView()
            Spacer()
            YesNoStack(boundState: $yesNoState)
//            Text("Integer state = \(yesNoState)")
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("← Back") {
                    _ = pages.decrement()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Next →") {
                    _ = pages.increment()
                }
            }
        }
        .onChange(of: yesNoState) { newValue in
            rootResponseStatus.currentValue =
            (newValue == 1) ? .yes : .no
        }
    }
}

struct DASIYNQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DASIYNQuestionView()
                .environmentObject(DASIPages())
                .environmentObject(DASIResponseStatus())
        }
    }
}
