//
//  LabView.swift
//  Week08Example
//
//  Created by sothea007 on 5/1/26.
//

import SwiftUI

struct LabView: View {
    @State private var isToggled = false
    
    var body: some View {
        VStack(spacing: 30) {
            // TODO: Add parent controls
            // TODO: Add child view
            StatusView(isActive: $isToggled)
        }
    }
}
#Preview {
    LabView()
}
