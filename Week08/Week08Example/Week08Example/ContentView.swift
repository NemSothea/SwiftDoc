//
//  ContentView.swift
//  Week08Example
//
//  Created by sothea007 on 5/1/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isOn = false
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
                .padding()
            Text(isOn ? "On" : "Off")
            
            Button("Toggle") { isOn.toggle() }
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
