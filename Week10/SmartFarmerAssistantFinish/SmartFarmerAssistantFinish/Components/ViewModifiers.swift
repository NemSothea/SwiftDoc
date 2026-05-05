// Components/ViewModifiers.swift
import SwiftUI

// MARK: - FarmCardModifier

struct FarmCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

// MARK: - FadeInModifier

struct FadeInModifier: ViewModifier {
    let delay: Double
    @State private var opacity: Double = 0

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(delay)) {
                    opacity = 1
                }
            }
    }
}

// MARK: - ScalePressModifier

struct ScalePressModifier: ViewModifier {
    @GestureState private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in state = true }
            )
    }
}

// MARK: - LoadingOverlayModifier

struct LoadingOverlayModifier: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
            if isLoading {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.4)
            }
        }
    }
}

// MARK: - AccessibilityCardModifier

struct AccessibilityCardModifier: ViewModifier {
    let label: String
    let hint: String

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint)
    }
}

// MARK: - View Extensions

extension View {
    func farmCard() -> some View {
        modifier(FarmCardModifier())
    }

    func fadeIn(delay: Double = 0) -> some View {
        modifier(FadeInModifier(delay: delay))
    }

    func scalePress() -> some View {
        modifier(ScalePressModifier())
    }

    func loadingOverlay(isLoading: Bool) -> some View {
        modifier(LoadingOverlayModifier(isLoading: isLoading))
    }

    func accessibilityCard(label: String, hint: String) -> some View {
        modifier(AccessibilityCardModifier(label: label, hint: hint))
    }
}
