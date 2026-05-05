// Reports/Views/BarShape.swift
import SwiftUI

struct BarShape: Shape {
    var heightFraction: CGFloat  // 0.0 … 1.0

    // Enables SwiftUI to animate height changes with withAnimation {}
    var animatableData: CGFloat {
        get { heightFraction }
        set { heightFraction = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let clamped = max(0, min(1, heightFraction))
        let barH    = rect.height * clamped
        p.addRect(CGRect(
            x:      0,
            y:      rect.height - barH,
            width:  rect.width,
            height: barH
        ))
        return p
    }
}
