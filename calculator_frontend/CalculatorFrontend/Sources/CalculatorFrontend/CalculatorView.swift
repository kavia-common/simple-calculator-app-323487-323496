import SwiftUI

struct CalculatorView: View {
    @StateObject private var viewModel = CalculatorViewModel()

    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .trailing, spacing: 8) {
                Text(viewModel.secondaryDisplayText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text(viewModel.primaryDisplayText)
                    .font(.system(size: 44, weight: .semibold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .accessibilityLabel("Calculator display")
            }
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .padding(.top, 12)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.buttons, id: \.self) { button in
                    CalculatorButton(
                        title: button.title,
                        kind: button.kind,
                        isWide: button.isWide
                    ) {
                        viewModel.handleTap(button)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(red: 0.976, green: 0.98, blue: 0.984)) // #f9fafb
        .alert("Error", isPresented: $viewModel.isShowingError, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(viewModel.errorMessage)
        })
    }
}

#Preview {
    CalculatorView()
}
