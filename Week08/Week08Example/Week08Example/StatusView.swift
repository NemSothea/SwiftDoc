//
//  StatusView.swift
//  Week08Example
//
//  Created by sothea007 on 5/1/26.
//
import SwiftUI

struct StatusView: View {
    
    @Binding var isActive: Bool
    
    var body: some View {
        VStack {
            Text(isActive ? "ACTIVE" : "INACTIVE")
                .font(.largeTitle)
                .foregroundColor(isActive ? .green : .gray)
            
            // Child can also modify!
            Button("Toggle") { isActive.toggle() }
        }
        .padding()
        .background(isActive ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
