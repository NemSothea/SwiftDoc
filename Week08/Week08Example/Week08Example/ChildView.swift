//
//  ChildView.swift
//  Week08Example
//
//  Created by sothea007 on 5/1/26.
//
import SwiftUI

struct ChildView: View {
    
    @Binding var childToggle: Bool  // 🔗 Connection
    @Binding var index: Int
    
    var body: some View {
        Text(childToggle ? "ON" : "OFF")
            .foregroundColor(childToggle ? .green : .red)
        Text(childToggle ? "Child \(index)" : "0")
    }
}
