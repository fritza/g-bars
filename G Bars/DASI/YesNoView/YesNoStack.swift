//
//  YesNoStack.swift
//  CardSeries
//
//  Created by Fritz Anderson on 3/4/22.
//

import SwiftUI

/*
 RATS RATS RATS

 I think it might be best to bind the button selection so the stack sets/unsets the answer in client code.
 */

struct YesNoStack: View {
    typealias AnswerVoid = ((AnswerState) -> Void)

    @State var currentAnswer = AnswerState.unknown
    @Binding var boundState: AnswerState

    init(boundState: Binding<AnswerState>) {
        self._boundState = boundState
    }

    func selectButton(id button: YesNoButton) {
        switch button.id {
        case 1: currentAnswer  = .yes
        case 2: currentAnswer  = .no
        default: currentAnswer = .unknown
        }
        boundState = currentAnswer
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                YesNoButton(
                    id: 1, title: "Yes", checked: (currentAnswer == .yes),
                    width: proxy.size.width * 0.8,
                    completion: {
                        btn in
//                       boundState = .yes; btn.isChecked = true
                        selectButton(id: btn)
                    }
                )

/*
 NO NO NO.
 We want the stack to have a single state.
 (What do I mean by that?)

 */



                YesNoButton(
                    id: 2, title: "No",
                    checked: (currentAnswer == .no),
                    width: proxy.size.width * 0.8,
                    completion: { _ in boundState = .no  })
                .frame(height: proxy.size.height * 0.45)
                Spacer()
            }
            .padding()
        }
    }
}

final class YNUState: ObservableObject, CustomStringConvertible {
    @State var answer: AnswerState = .no
    var description: String {
        let valueString: String
        switch answer {
        case .unknown:
            valueString = "?! "
        case .yes:
            valueString = "Yes"
        case .no:
            valueString = "No "
        }
       return "YNUState: \(valueString)"
    }
}

struct YesNoStack_Previews: PreviewProvider {
    static let ynuState = YNUState()
    @State static var last: String = "NONE"
    static var previews: some View {
        VStack(alignment: .center) {
            Spacer()
            YesNoStack(boundState: ynuState.$answer)
                .frame(height: 100, alignment: .center)
            Spacer()
            Text("The setting is \(last)")
        }
#if G_BARS
        .environmentObject(DASIResponseList())
        .environmentObject(DASIPages())
#endif
    }
}
