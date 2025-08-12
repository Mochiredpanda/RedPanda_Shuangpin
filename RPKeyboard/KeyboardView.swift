//
//  KeyboardView.swift
//  RedPandaShuangpin
//
//  Created by Jiyu He on 8/11/25.
//

import SwiftUI

struct KeyboardView: View {
  var onKeyPress: (String) -> Void
  
  let layout: [[String]] = [
    ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
    ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
    ["z", "x", "c", "v", "b", "n", "m"]
  ]
  
  var body: some View {
    VStack(spacing: 8) {
      ForEach(layout, id: \.self) { row in
        HStack(spacing: 4) {
          ForEach(row, id: \.self) { key in
            Button(action: {
              onKeyPress(key)
            }) {
              Text(key)
                .font(.system(size: 20))
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(Color.gray.opacity(0.5))
                .cornerRadius(5)
            }
          }
        }
      }
    }
    .padding(4)
    .foregroundStyle(.white)
  }
}
