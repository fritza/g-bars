//
//  YesNoView.swift
//  Better Step
//
//  Created by Fritz Anderson on 12/29/21.
//

import SwiftUI


// TODO: Generic over some kind of response view (different labels, different response types).

// MARK: - ViewChoice (button config)
final class ViewChoice: Identifiable {
    let id: Int
    let title: String
    // Add action closure

    init(_ id: Int, _ title: String) {
        (self.id, self.title) = (id, title)
    }

    static func choices(from strings: [String]) -> [ViewChoice] {
        var result: [ViewChoice] = []
        for (n, string) in strings.enumerated() {
            let element = ViewChoice(n, string)
            result.append(element)
        }
        return result
    }
}


// MARK: - YesNoView
struct YesNoView: View {
    var viewConfig: [ViewChoice]
    let completion: (ViewChoice) -> Void

    init(_ titles: [String],
         completion: @escaping (ViewChoice) -> Void) {
        viewConfig = ViewChoice.choices(from: titles)
        self.completion = completion
    }

    var body: some View {
        GeometryReader { context in
            VStack(alignment: .center) {
                ForEach(viewConfig) { vc in
                    YesNoButton(id: vc.id,
                                title: vc.title,
                                width: context.size.width,
                                completion: { btn in
                        completion(vc)
                    })
                    .frame(width: context.size.width,
                           height: context.size.height * 0.4)
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Preview
struct YesNoView_Previews: PreviewProvider {
    static let choices: [String] = [
        "Yes", "No"
    ]

    static var hitYes = false

    static var previews: some View {
        VStack {
            YesNoView(choices) {
                vchoice in
                hitYes = vchoice.title == "Yes"
//                print("Beep! YNView")
            }
            Spacer()
        }
        .frame(width: .infinity, height: 160, alignment: .center)
        .padding()
#if G_BARS
        .environmentObject(DASIResponseList())
        .environmentObject(DASIPages())
#endif
    }
}
