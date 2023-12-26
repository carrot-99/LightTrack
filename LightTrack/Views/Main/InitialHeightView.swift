//  InitialHeightView.swift

import SwiftUI

struct InitialHeightView: View {
    @State private var height: String = ""
    var onHeightSet: (Double) -> Void

    var body: some View {
        VStack {
            Group {
                Text("身長を入力してください")
                Text("BMIの計算にのみ使用されます")
            }
            .font(.headline)
            .padding(.top, 20)

            TextField("身長(cm)", text: $height)
                .keyboardType(.decimalPad)
                .padding()
                .frame(maxWidth: .infinity)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                .padding(.horizontal, 20)

            Button("保存") {
                if let heightValue = Double(height) {
                    onHeightSet(heightValue)
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.top, 10)

            Spacer()
        }
        .padding()
    }
}
