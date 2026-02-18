import Foundation
import Observation

@MainActor
final class CalculatorViewModel: ObservableObject {
    // MARK: - Public UI state

    @Published private(set) var primaryDisplayText: String = "0"
    @Published private(set) var secondaryDisplayText: String = ""

    @Published var isShowingError: Bool = false
    @Published var errorMessage: String = ""

    // MARK: - Calculator state

    private var currentInput: String = "0" // user-typed number as string
    private var storedValue: Decimal? = nil
    private var pendingOperation: CalculatorOperation? = nil
    private var isEnteringNewNumber: Bool = true

    // MARK: - Button layout

    let buttons: [CalculatorButtonModel] = [
        .action("AC", action: .clear),
        .action("⌫", action: .backspace),
        .action("%", action: .percent),
        .operation(.divide),

        .digit(7), .digit(8), .digit(9), .operation(.multiply),
        .digit(4), .digit(5), .digit(6), .operation(.subtract),
        .digit(1), .digit(2), .digit(3), .operation(.add),

        .digit(0),
        .action(".", action: .decimal, kind: .digit),
        .equals
    ]

    init() {
        syncDisplay()
    }

    // PUBLIC_INTERFACE
    func handleTap(_ button: CalculatorButtonModel) {
        /** Handle a button press from the calculator grid. */
        if let digit = button.digit {
            inputDigit(digit)
            return
        }
        if let action = button.action {
            handleAction(action)
            return
        }
        if let op = button.operation {
            setOperation(op)
            return
        }
        if button == .equals {
            evaluate()
            return
        }
    }

    // MARK: - Input handling

    private func inputDigit(_ digit: Int) {
        if isEnteringNewNumber {
            currentInput = "\(digit)"
            isEnteringNewNumber = false
        } else {
            if currentInput == "0" && digit == 0 && !currentInput.contains(".") {
                // prevent leading "0000"
                return
            }
            currentInput.append("\(digit)")
        }
        syncDisplay()
    }

    private func handleAction(_ action: CalculatorAction) {
        switch action {
        case .clear:
            clearAll()
        case .decimal:
            inputDecimalPoint()
        case .percent:
            applyPercent()
        case .sign:
            toggleSign()
        case .backspace:
            backspace()
        }
    }

    private func inputDecimalPoint() {
        if isEnteringNewNumber {
            currentInput = "0."
            isEnteringNewNumber = false
        } else if !currentInput.contains(".") {
            currentInput.append(".")
        }
        syncDisplay()
    }

    private func backspace() {
        guard !isEnteringNewNumber else { return }
        if currentInput.count <= 1 || (currentInput.count == 2 && currentInput.hasPrefix("-")) {
            currentInput = "0"
            isEnteringNewNumber = true
        } else {
            currentInput.removeLast()
        }
        syncDisplay()
    }

    private func toggleSign() {
        guard currentInput != "0" else { return }
        if currentInput.hasPrefix("-") {
            currentInput.removeFirst()
        } else {
            currentInput = "-" + currentInput
        }
        syncDisplay()
    }

    private func applyPercent() {
        guard let value = decimal(from: currentInput) else {
            showError("Invalid number.")
            return
        }
        let result = value / Decimal(100)
        currentInput = format(result)
        isEnteringNewNumber = true
        syncDisplay()
    }

    // MARK: - Operations

    private func setOperation(_ op: CalculatorOperation) {
        // If there's a pending operation and user already typed a second operand, evaluate first (classic calculator behavior)
        if pendingOperation != nil, !isEnteringNewNumber {
            evaluate()
        }

        guard let value = decimal(from: currentInput) else {
            showError("Invalid number.")
            return
        }

        storedValue = value
        pendingOperation = op
        isEnteringNewNumber = true
        secondaryDisplayText = "\(format(value)) \(op.rawValue)"
    }

    private func evaluate() {
        guard let op = pendingOperation else {
            // Nothing to evaluate; just keep current display
            syncDisplay()
            return
        }
        guard let lhs = storedValue else {
            pendingOperation = nil
            syncDisplay()
            return
        }
        guard let rhs = decimal(from: currentInput) else {
            showError("Invalid number.")
            return
        }

        do {
            let result = try perform(lhs: lhs, rhs: rhs, op: op)
            currentInput = format(result)
            primaryDisplayText = currentInput
            secondaryDisplayText = ""
            storedValue = nil
            pendingOperation = nil
            isEnteringNewNumber = true
        } catch {
            showError(error.localizedDescription)
        }
    }

    private func perform(lhs: Decimal, rhs: Decimal, op: CalculatorOperation) throws -> Decimal {
        switch op {
        case .add:
            return lhs + rhs
        case .subtract:
            return lhs - rhs
        case .multiply:
            return lhs * rhs
        case .divide:
            if rhs == 0 {
                throw CalculatorError.divisionByZero
            }
            return lhs / rhs
        }
    }

    // MARK: - Helpers

    private func clearAll() {
        currentInput = "0"
        storedValue = nil
        pendingOperation = nil
        isEnteringNewNumber = true
        secondaryDisplayText = ""
        syncDisplay()
    }

    private func syncDisplay() {
        primaryDisplayText = currentInput
        if secondaryDisplayText.isEmpty, let op = pendingOperation, let lhs = storedValue {
            secondaryDisplayText = "\(format(lhs)) \(op.rawValue)"
        }
    }

    private func decimal(from string: String) -> Decimal? {
        Decimal(string: string, locale: Locale(identifier: "en_US_POSIX"))
    }

    private func format(_ value: Decimal) -> String {
        // Keep formatting simple for scaffold: no scientific notation, trim trailing zeros.
        let ns = value as NSDecimalNumber
        if ns == NSDecimalNumber.notANumber {
            return "0"
        }

        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 12
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = false

        return formatter.string(from: ns) ?? "\(ns)"
    }

    private func showError(_ message: String) {
        errorMessage = message
        isShowingError = true
        clearAll()
    }
}

enum CalculatorError: LocalizedError {
    case divisionByZero

    var errorDescription: String? {
        switch self {
        case .divisionByZero:
            return "Cannot divide by zero."
        }
    }
}
