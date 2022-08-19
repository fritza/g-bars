//
//  LastWalkingDemoView.swift
//  G Bars
//
//  Created by Fritz Anderson on 8/19/22.
//

import SwiftUI

/*
 Further plan for demo walking:

 (deprecated) The min:sec view has to create/hook up with a MotionManager.
 A consumer for AccelerometerItems has to be created, then hook up with a MotionManager.
    The Items are stored as they come in from the manager.

 The consumer can be anything that appends `AcceleratorItem`s. Append to an array, write to file, whatever.

 The MotionManager can be abandoned when the count is done (though in fact it will survive as a global)
 The TimeWatcher, if any can be shared out of the view that already consumes time updates. The Consumet needs only to detect start and finish. I _think_ this is a good idea, rather than have everybody remember to start/stop the consumer.


 Updates in MotionManager start at MotionManager.makeAsyncIterator. So right when you start the async read loop. Is that wise? It may work out that way — don't go into the for loop until you're ready to accept the elements.

 Remember to MotionManager.cancelUpdates()
 */

struct LastWalkingDemoView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct LastWalkingDemoView_Previews: PreviewProvider {
    static var previews: some View {
        LastWalkingDemoView()
    }
}
