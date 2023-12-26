//  CustomTextField.swift

import SwiftUI

struct CustomTextField: View {
    var placeholderText: String
    var foregroundColor: Color
    var placeholderColor: Color
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholderText)
                    .foregroundColor(placeholderColor)
                    .padding(.leading, 4)
            }
            if isSecure {
                SecureField("", text: $text)
                    .keyboardType(keyboardType)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(foregroundColor)
                    .cornerRadius(8)
            } else {
                TextField("", text: $text)
                    .keyboardType(keyboardType)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(foregroundColor)
                    .cornerRadius(8)
            }
        }
    }
}
