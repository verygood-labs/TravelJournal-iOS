import SwiftUI

// MARK: - Page Turn Transition
/// Custom transition that mimics a passport page turning
struct PageTurnTransition: ViewModifier {
    let isPresented: Bool
    let isForward: Bool // true = turning to next page, false = going back
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isPresented ? 0 : (isForward ? -90 : 90)),
                axis: (x: 0, y: 1, z: 0),
                anchor: isForward ? .leading : .trailing,
                perspective: 0.3
            )
            .opacity(isPresented ? 1 : 0)
    }
}

// MARK: - Page Turn Container
/// Container view that manages page-turn transitions between registration steps
struct PageTurnContainer<Content: View>: View {
    let isPresented: Bool
    let isForward: Bool
    let content: Content
    
    init(isPresented: Bool, isForward: Bool = true, @ViewBuilder content: () -> Content) {
        self.isPresented = isPresented
        self.isForward = isForward
        self.content = content()
    }
    
    var body: some View {
        if isPresented {
            content
                .modifier(PageTurnTransition(isPresented: isPresented, isForward: isForward))
                .animation(.easeInOut(duration: 0.5), value: isPresented)
        }
    }
}

// MARK: - Page Turn Navigation Modifier
/// A view modifier that presents a destination view with a page-turn animation
struct PageTurnNavigationModifier<Destination: View>: ViewModifier {
    @Binding var isPresented: Bool
    let destination: () -> Destination
    
    @State private var showDestination = false
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        ZStack {
            // Current page
            content
                .zIndex(showDestination ? 0 : 1)
                .rotation3DEffect(
                    .degrees(showDestination ? 90 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: .trailing,
                    perspective: 0.3
                )
                .opacity(showDestination ? 0 : 1)
            
            // Next page
            if showDestination || isAnimating {
                destination()
                    .zIndex(showDestination ? 1 : 0)
                    .rotation3DEffect(
                        .degrees(showDestination ? 0 : -90),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: .leading,
                        perspective: 0.3
                    )
                    .opacity(showDestination ? 1 : 0)
            }
        }
        .onChange(of: isPresented) { _, newValue in
            if newValue {
                isAnimating = true
                withAnimation(.easeInOut(duration: 0.6)) {
                    showDestination = true
                }
            } else {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showDestination = false
                } completion: {
                    isAnimating = false
                }
            }
        }
    }
}

// MARK: - View Extension
extension View {
    /// Presents a destination view with a page-turn animation
    func pageTurnNavigation<Destination: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        self.modifier(PageTurnNavigationModifier(isPresented: isPresented, destination: destination))
    }
}

// MARK: - Page Turn Dismiss Action
/// Custom dismiss action for page turn transitions
struct PageTurnDismissAction {
    let dismiss: () -> Void
    
    func callAsFunction() {
        dismiss()
    }
}

// MARK: - Environment Key for Page Turn Dismiss
private struct PageTurnDismissKey: EnvironmentKey {
    static let defaultValue: PageTurnDismissAction? = nil
}

extension EnvironmentValues {
    var pageTurnDismiss: PageTurnDismissAction? {
        get { self[PageTurnDismissKey.self] }
        set { self[PageTurnDismissKey.self] = newValue }
    }
}

// MARK: - Full Screen Page Turn Cover
/// A replacement for fullScreenCover that uses page-turn animation
/// Animates like a book page peeling from bottom-right corner
struct PageTurnCover<Content: View, Destination: View>: View {
    @Binding var isPresented: Bool
    let content: Content
    let destination: () -> Destination
    
    @State private var showDestination = false
    @State private var isAnimating = false
    @State private var progress: CGFloat = 0 // 0 = showing source, 1 = showing destination
    
    private let animationDuration: Double = 0.8
    
    init(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self._isPresented = isPresented
        self.content = content()
        self.destination = destination
    }
    
    var body: some View {
        ZStack {
            // Destination page (underneath, revealed as source peels away)
            if showDestination || isAnimating {
                destination()
                    .environment(\.pageTurnDismiss, PageTurnDismissAction {
                        isPresented = false
                    })
                    .allowsHitTesting(showDestination)
            }
            
            // Source page (on top, peels away from bottom-right corner)
            content
                .allowsHitTesting(!showDestination)
                .modifier(PagePeelEffect(progress: progress))
        }
        .onChange(of: isPresented) { _, newValue in
            if newValue {
                // Forward: peel from bottom-right to left
                isAnimating = true
                showDestination = true
                withAnimation(.easeInOut(duration: animationDuration)) {
                    progress = 1
                }
            } else {
                // Backward: unpeel from left back to bottom-right
                withAnimation(.easeInOut(duration: animationDuration)) {
                    progress = 0
                } completion: {
                    showDestination = false
                    isAnimating = false
                }
            }
        }
    }
}

// MARK: - Page Peel Effect Modifier
/// Creates a realistic page peel effect from the bottom-right corner
struct PagePeelEffect: ViewModifier, Animatable {
    var progress: CGFloat
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            // Main rotation - page turns from right edge toward left
            .rotation3DEffect(
                .degrees(-Double(progress) * 180),
                axis: (x: 0.1, y: 1, z: 0.05), // Slight diagonal tilt for bottom-right peel
                anchor: .leading,
                perspective: 0.4
            )
            // Additional subtle rotation to enhance bottom-right lift
            .rotation3DEffect(
                .degrees(Double(progress) * 15),
                axis: (x: 1, y: 0, z: 0), // Slight lift from bottom
                anchor: .top,
                perspective: 0.3
            )
            // Scale slightly as it peels to add depth
            .scaleEffect(1 - (progress * 0.05), anchor: .leading)
            // Fade out as it completes the turn
            .opacity(progress < 0.5 ? 1 : 1 - Double((progress - 0.5) * 2))
            // Shadow underneath the peeling page
            .shadow(
                color: .black.opacity(0.4 * Double(min(progress * 2, (1 - progress) * 2))),
                radius: 20 * progress,
                x: -15 * progress,
                y: 10 * progress
            )
    }
}

// MARK: - Preview
#Preview {
    struct PreviewContainer: View {
        @State private var showNext = false
        
        var body: some View {
            PageTurnCover(isPresented: $showNext) {
                ZStack {
                    Color.blue
                    VStack {
                        Text("Page 1")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        Button("Next") {
                            showNext = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .ignoresSafeArea()
            } destination: {
                ZStack {
                    Color.green
                    VStack {
                        Text("Page 2")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        Button("Back") {
                            showNext = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .ignoresSafeArea()
            }
        }
    }
    
    return PreviewContainer()
}
