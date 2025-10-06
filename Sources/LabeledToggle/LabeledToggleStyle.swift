import SwiftUI

@available(iOS 16, *)
public struct LabeledToggleStyle: ToggleStyle {
    @State private var isEnabled: Bool = false
    private let systemNames: (left: String, right: String)
    @State private var isPressing: Bool = false
    @State private var viewWidth: CGFloat = 0
    @State private var isRightSide: Bool = false

    public init(systemNames: (left: String, right: String)) {
        self.systemNames = systemNames
    }

    public func makeBody(configuration: Configuration) -> some View {
        Toggle(configuration)
            .onAppear {
                isEnabled = configuration.isOn
                isPressing = configuration.isMixed
            }
            .onChange(of: configuration.isOn) { newValue in
                isEnabled = newValue
            }
            .onChange(of: configuration.isMixed) { newValue in
                isPressing = newValue
            }
            .contentShape(.rect)
            .labelsHidden()
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { viewWidth = geo.size.width }
                        .onChange(of: geo.size.width) { newWidth in
                            viewWidth = newWidth
                        }
                }
            )
            .overlay {
                Image(systemName: systemName())
                    .offset(x: offset())
                    .animation(.linear.speed(3), value: isPressing)
                    .animation(.linear.speed(3), value: isRightSide)
                    .allowsHitTesting(false)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        if !isPressing { isPressing = true }
                        let x = value.location.x
                        let width = max(viewWidth, 1)
                        isRightSide = x > width / 2
                    }
                    .onEnded { _ in
                        isPressing = false
                        isRightSide = false
                    }
            )
    }

    private func offset() -> CGFloat {
        if isPressing && isRightSide || isEnabled && !isPressing {
            return 13
        } else {
            return -11
        }
    }

    private func systemName() -> String {
        if isPressing && isRightSide || isEnabled && !isPressing{
            return systemNames.right
        } else {
            return systemNames.left
        }
    }
}

@available(iOS 17, *)
#Preview {
    @Previewable @State var isEnabled: Bool = true

    Toggle("Do You Like Coffee", isOn: $isEnabled)
        .font(.title3)
        .toggleStyle(LabeledToggleStyle(systemNames: ("heart", "heart.fill")))
        .tint(.brown)
        .foregroundStyle(.red)
        .padding(40)
        .background(.ultraThinMaterial)
        .frame(maxHeight: .infinity)
}
