//
//  ParentView.swift
//  Week08Example
//
//  Created by sothea007 on 5/1/26.
//
import SwiftUI

struct ParentView: View {
    
    @State private var parentToggle = false  // 👑 Owner
    @State private var intIndex = 1
    
    var body: some View {
        
        VStack {
            Toggle("Control", isOn: $parentToggle)
            
            ChildView(childToggle: $parentToggle, index: $intIndex)  // 💫 Pass Binding
        }
        .padding()
    }
}
#Preview {
    ParentView()
}
