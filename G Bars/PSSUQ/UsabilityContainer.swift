//
//  UsabilityContainer.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/12/22.
//

import SwiftUI

struct UsabilityContainer: View {
    @EnvironmentObject var controller: UsabilityController

    init() {
//        controller.currentPhase = .start
    }

    var body: some View {
        List {
            NavigationLink(
                tag: UsabilityPhase.questions,
                selection: $controller.currentPhase) {
                    UsabilityView(
                        questionID: controller.questionID,
                        selectedAnswer: $controller.currentResponse)
                    { newAnswer in
                        print("Here there's a new answer:", newAnswer)
                        print("duplicative?")

                       // controller.receive(answer: newAnswer)
                    }   // Questions destination
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("← Back") { controller.decrement() }
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Next →") { controller.increment() }
                        }
                    }

                    .navigationBarBackButtonHidden(true)
                } label: {
                    Text("Should not appear.")
                } // Questions label
                  // NavigationLink for UsabilityPhase.questions

            NavigationLink(tag: UsabilityPhase.start, selection: $controller.currentPhase) {
                Text("Opening interstitial")
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Next →") { controller.increment() }
                        }
                    }
            } label: {
                Text("Opening: should not appear")
            }

            NavigationLink(tag: UsabilityPhase.end, selection: $controller.currentPhase) {
                Text("Ending interstitial")
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("← Back") { controller.decrement() }
                        }
                    }

            } label: {
                Text("Ending: should not appear")
            }
        }   // List
    }
}

struct UsabilityContainer_Previews: PreviewProvider {
    static var previews: some View {
        UsabilityContainer()
            .environmentObject(UsabilityController())
            .previewDevice(.init(stringLiteral: "iPhone 12"))
            .previewDevice(.init(stringLiteral: "iPhone SE (3rd generation)"))
    }
}
