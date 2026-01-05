//
//  ContentView.swift
//  FirstSwiftUIApp
//
//  Created by sothea007 on 22/12/25.
//

import SwiftUI

struct items: Identifiable {
    var id = UUID()

    var title: String
}


struct ContentView: View {
    
    let items: [items] = [
        .init(title: "Apple"),
        .init(title: "Banana"),
        .init(title: "Orange"),
        .init(title: "Pineapple"),
    ]
    
    
    var body: some View {
    
        List(items) { item in
            VStack(alignment: .leading) {
               Image("ios-ipados-26-96x96_2x")
                    .frame(width: 50, height: 50)
                Text(item.title)
            }
        }
      
        .padding()
    }
}

#Preview {
    ContentView()
}
