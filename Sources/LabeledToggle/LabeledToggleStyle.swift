import SwiftUI

public struct LabeledToggleStyle: ToggleStyle {
    private let on, off: String
    @State private var isPressing: Bool = false
    @State private var viewWidth: CGFloat = 0
    @State private var isRightSide: Bool = false

    public init(off: String, on: String) {
        self.off = off
        self.on = on
    }

    public func makeBody(configuration: Configuration) -> some View {
        Toggle(configuration)
            .toggleStyle(.switch)
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
                Image(systemName: systemName(for: configuration))
                    .offset(x: offset(for: configuration))
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

    private func offset(for configuration: Configuration) -> CGFloat {
        if isPressing && isRightSide || configuration.isOn && !isPressing {
            return 13
        } else {
            return -11
        }
    }

    private func systemName(for configuration: Configuration) -> String {
        if isPressing && isRightSide || configuration.isOn && !isPressing{
            return on
        } else {
            return off
        }
    }
}

extension ToggleStyle where Self == LabeledToggleStyle {
    public static func labeled(off: String, on: String) -> Self {
        LabeledToggleStyle(off: off, on: on)
    }
}

@available(iOS 17, *)
#Preview {
    @Previewable @State var isEnabled: Bool = true

    HStack {
        Text("Do you like coffee?")
            .font(.title3)
        Spacer()
        Toggle("Do You Like Coffee", isOn: $isEnabled)
        .toggleStyle(.labeled(off: "heart", on: "heart.fill"))
        .tint(.brown)
        .foregroundStyle(.red)
    }
    .padding(40)
    .background(.ultraThinMaterial)
    .frame(maxHeight: .infinity)
}
