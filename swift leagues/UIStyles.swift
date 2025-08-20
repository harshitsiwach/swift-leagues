import SwiftUI

// A custom view modifier to add a press-and-scale animation to any view.
// This provides visual feedback when a user interacts with an element.
@available(iOS 26.0, *)
struct PressableViewModifier: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .onLongPressGesture(
                minimumDuration: .infinity,
                maximumDistance: .infinity,
                pressing: { pressing in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        isPressed = pressing
                    }
                },
                perform: {}
            )
    }
}

extension View {
    /// Applies a press-and-scale animation to the view.
    func pressable() -> some View {
        self.modifier(PressableViewModifier())
    }
}

// Example of a custom text modifier, if needed.
struct CustomTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.accentColor)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
    }
}

extension View {
    func customStyled() -> some View {
        self.modifier(CustomTextModifier())
    }
}
