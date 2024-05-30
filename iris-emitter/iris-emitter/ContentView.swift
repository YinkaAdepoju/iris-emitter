//
//  ContentView.swift
//  iris-emitter
//
//  Created by Yinka Adepoju on 30/5/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            HeartEmitterView()
            ColorHeartEmitterView()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
