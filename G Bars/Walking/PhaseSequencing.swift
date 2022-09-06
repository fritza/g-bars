//
//  PhaseSequencing.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/11/22.
//

import SwiftUI

protocol PhaseSequencing {
    // How do we ensure there's a callback?
}

struct CallbackOwningView: View {
    let completion: () -> Void
    func finish() {
        completion()
    }
    var body: some View {
        Text("Dummy")
    }
}

protocol HasVoidCompletion {
    var completion: ()->Void { get }
}

struct AnySubphase<V, T> where
V: View & HasVoidCompletion,
T: Hashable & CustomStringConvertible
{
    let current: T
    let next   : T
    let view   : V
    @Binding var boundState: T?
    init(_ current: T, next: T, state: Binding<T?>, destination: V) {
        self._boundState = state
        (self.current, self.next, self.view) =
        (current, next, destination)
    }

    func goNext() {
        boundState = next
    }

    @ViewBuilder
    func theNavLink() -> some View {
        NavigationLink(current.description, tag: current,
                       selection: $boundState,
                       destination: { view })
        .padding()
        .navigationBarBackButtonHidden(true)
        // Now you want to call its completion when it's done.
    }

    // the tag is "current".
    // I don't know how to make a generic destination
}

/*
 All I really want is to demonstrate that the current/next
 states in a list of nav links are consecutive and unique.
 */
