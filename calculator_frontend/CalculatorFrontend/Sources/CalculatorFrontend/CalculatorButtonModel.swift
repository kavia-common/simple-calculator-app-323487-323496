import Foundation

enum CalculatorOperation: String, Hashable {
    case add = "+"
    case subtract = "−"
    case multiply = "×"
    case divide = "÷"
}

enum CalculatorAction: Hashable {
    case clear
    case sign
    case percent
    case decimal
    case backspace
}

struct CalculatorButtonModel: Hashable {
    let title: String
    let kind: CalculatorButtonKind
    let isWide: Bool

    let digit: Int?
    let operation: CalculatorOperation?
    let action: CalculatorAction?

    static func digit(_ value: Int) -> CalculatorButtonModel {
        CalculatorButtonModel(
            title: "\(value)",
            kind: .digit,
            isWide: value == 0,
            digit: value,
            operation: nil,
            action: nil
        )
    }

    static func operation(_ op: CalculatorOperation) -> CalculatorButtonModel {
        CalculatorButtonModel(
            title: op.rawValue,
            kind: .operation,
            isWide: false,
            digit: nil,
            operation: op,
            action: nil
        )
    }

    static func action(_ title: String, action: CalculatorAction, kind: CalculatorButtonKind = .action, isWide: Bool = false) -> CalculatorButtonModel {
        CalculatorButtonModel(
            title: title,
            kind: kind,
            isWide: isWide,
            digit: nil,
            operation: nil,
            action: action
        )
    }

    static var equals: CalculatorButtonModel {
        CalculatorButtonModel(
            title: "=",
            kind: .equals,
            isWide: false,
            digit: nil,
            operation: nil,
            action: nil
        )
    }
}
