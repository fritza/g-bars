//
//  AtEnvironment.swift
//  G Bars
//
//  Created by Fritz Anderson on 7/29/22.
//

import Foundation
import SwiftUI

/**
 @Environment values for what otherwise would be observable globals.

 ## Topics

 ### Speech
 - ``View/shouldUseSpeech(_:)``
 - ``EnvironmentValues/shouldUseSpeech``
 */

//- ``G_Bars/SpeechEnvironmentKey``

private struct SpeechEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var shouldUseSpeech: Bool {
        get { self[SpeechEnvironmentKey.self] }
        set { self[SpeechEnvironmentKey.self] = newValue }
    }
}

extension View {
    func shouldUseSpeech(_ shouldUseSpeech: Bool) -> some View {
        environment(\.shouldUseSpeech, shouldUseSpeech)
    }
}
