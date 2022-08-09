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

enum HowWalked: String, Hashable {
    case straightLine, backAndForth
}

enum EffortWalked: String, Hashable, CaseIterable {
    case light, somewhat, hard
    case veryHard = "Very Hard"
}

struct WalkInfoForm: View {
    var summary: String {
        var content = "Info: "
        //        print(walkedAtHome ? "Home" : "Away",
        print((whereWalked == .atHome) ? "Home" : "Away",
              terminator: " ", to: &content)
        print("Length:", lengthOfCourse ?? -1, terminator: " ", to: &content)
        return content
    }

    @State private var whereWalked: WhereWalked = .atHome
    @State private var howWalked: HowWalked = .straightLine
    @State private var lengthOfCourse: Int? = nil
    @State private var effort: EffortWalked = .somewhat
    @State private var fearOfFalling: Bool = false

    var body: some View {
        Form {
            Section {
                VStack {
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
            }  // Home/away section
            /*
            Section {
                VStack(alignment: .leading) {
                    Text("About how long was the area you walked in, in feet?").lineLimit(2)
                        .minimumScaleFactor(0.75)
                    HStack {
                        if lengthOfCourse == nil { Text("⚠️") }
                        Spacer()
                        TextField("feet", value: $lengthOfCourse, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                    }
                }
            }  // length of runway section
             */

/*
 NOT HAPPY with no longer having room for an invalid/empty length flag (⚠️). Nor that while the field format rejects non-numerics, it doesn't show the rejection.
 */


            Section {
                TextField("feet", value: $lengthOfCourse, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
//                    .frame(width: 80)
                    .safeAreaInset(edge: .leading,
                                   spacing: 12.0
                    ) {
                        Text("In feet, about how long was the area you walked in?")
                            .foregroundColor(
                                (lengthOfCourse == nil) ?
                                    .red : .primary
                            )
                            .frame(maxWidth: 240)
                    }
            }
            // Length of runway

            Section {
                VStack {
                    Text("Did you walk back-and-forth, or in a straight line?")
                        .minimumScaleFactor(0.6)
                    Picker("How did you walk?",
                           selection: $howWalked) {
                        Text("Back and Forth")
                            .tag(HowWalked.backAndForth)
                        Text("In a Straight Line")
                            .tag(HowWalked.straightLine)
                    }
                    .pickerStyle(.segmented)                }
            }  // Back-and-forth section

            Section {
                Picker("How hard was your body working?", selection: $effort) {
                    ForEach(EffortWalked.allCases, id: \.rawValue) { effort in
                        Text(effort.rawValue.capitalized)
                            .tag(effort)
                    }
                }
            }   // Effort section

            Section {
                VStack {
                    Text("Were you concerned about falling during the walks?")
                        .minimumScaleFactor(0.6)
                    Picker("Concerned about falling?",
                           selection: $fearOfFalling) {
                        Text("Yes")
                            .tag(true)
                        Text("No")
                            .tag(false)
                    }
                           .pickerStyle(.segmented)

                }
            }  // falling section
        }
        .safeAreaInset(edge: .top, content: {
            Text("Tell us about your walking conditions — Where you chose for your walk, and how you felt while performing it.")
                .padding()
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Submit") {  }
            }
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
