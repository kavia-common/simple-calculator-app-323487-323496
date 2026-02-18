import SwiftUI

enum CalculatorButtonKind: Hashable {
    case digit
    case operation
    case action
    case equals
}

struct CalculatorButton: View {
    let title: String
    let kind: CalculatorButtonKind
    let isWide: Bool
    let onTap: () -> Void

    private var background: Color {
        switch kind {
        case .digit:
            return .white
        case .operation:
            return Color(red: 0.231, green: 0.51, blue: 0.965) // #3b82f6
        case .equals:
            return Color(red: 0.024, green: 0.714, blue: 0.831) // #06b6d4
        case .action:
            return Color(red: 0.392, green: 0.455, blue: 0.545) // #64748b
        }
    }

    private var foreground: Color {
        switch kind {
        case .digit:
            return Color(red: 0.067, green: 0.09, blue: 0.153) // #111827
        default:
            return .white
        }
    }

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(foreground)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(kind == .digit ? 0.06 : 0), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        .gridCellColumns(isWide ? 2 : 1)
        .accessibilityLabel(title)
    }
}
