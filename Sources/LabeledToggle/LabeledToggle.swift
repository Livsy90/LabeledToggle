import SwiftUI

public struct LabeledToggle: View {
    @Binding private var isEnabled: Bool
    private let systemNames: (left: String, right: String)
    @State private var isPressing: Bool = false
    @State private var viewWidth: CGFloat = 0
    @State private var isRightSide: Bool = false
    
    public init(
        isEnabled: Binding<Bool>,
        systemNames: (left: String, right: String)
    ) {
        _isEnabled = isEnabled
        self.systemNames = systemNames
    }
    
    public var body: some View {
        Toggle("", isOn: $isEnabled)
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
    
    private let rightOffset: CGFloat = if #available(iOS 26, *) {
        13
    } else {
        11.4
    }

    private let leftOffset: CGFloat = if #available(iOS 26, *) {
        -11
    } else {
        -9.4
    }

    private func offset() -> CGFloat {
        if isPressing && isRightSide || isEnabled && !isPressing {
            return rightOffset
        } else {
            return leftOffset
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

#Preview {
    struct Demo: View {
        @State private var isEnabled: Bool = true
        var body: some View {
            HStack {
                Text("Do you like coffee?")
                    .font(.title3)
                Spacer()
                LabeledToggle(
                    isEnabled: $isEnabled,
                    systemNames: ("heart", "heart.fill")
                )
                .tint(.brown)
                .foregroundStyle(.red)
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .frame(maxHeight: .infinity)
        }
    }
    return Demo()
}
