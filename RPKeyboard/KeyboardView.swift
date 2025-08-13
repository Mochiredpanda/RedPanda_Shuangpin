//
//  KeyboardView.swift
//  RedPandaShuangpin
//
//  Created by Jiyu He on 8/11/25.
//

import SwiftUI

enum KeyboardLayer {
  case lowercase
  case uppercase
  case numeric
  case symbols
  
}

struct KeyboardView: View {
  var onKeyPress: (String) -> Void
  
  @State private var currentLayer: KeyboardLayer = .lowercase
  
  
  // Main lowercase layer
  private let row1_lower = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]
  private let row2_lower = ["a", "s", "d", "f", "g", "h", "j", "k", "l"]
  private let row3_lower = ["shift", "z", "x", "c", "v", "b", "n", "m", "delete"]
  
  // Main uppercase layer
  private let row1_upper = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
  private let row2_upper = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
  private let row3_upper = ["shift", "Z", "X", "C", "V", "B", "N", "M", "delete"]
  
  // Numeric Layer
  private let row1_num = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
  private let row2_num = ["-", "/", "：", "；", "（", "）", "$", "@", "“", "”"]
  private let row3_num = ["。", "，", "、", "！", "."]
  
  // Symbols Layer
  private let row1_sym = ["【", "】", "{", "}", "#", "%", "^", "*", "+", "="]
  private let row2_sym = ["_", "——", "\\", "|", "～", "《", "》", "€", "&", "·"]
  private let row3_sym = ["…", ",", "?", "!", "'", "^_^"]
  
  // Bottom Bar
  private let btmRow = ["123", "emoji", "space", "return"]
  
  // Computed properties decide cur rows
  private var curRow1: [String] {
    switch currentLayer {
    case .lowercase: return row1_lower
    case .uppercase: return row1_upper
    case .numeric: return row1_num
    case .symbols: return row1_sym
    }
  }
  
  private var curRow2: [String] {
    switch currentLayer {
    case .lowercase: return row2_lower
    case .uppercase: return row2_upper
    case .numeric: return row2_num
    case .symbols: return row2_sym
    }
  }
  
  private var curRow3: [String] {
    switch currentLayer {
    case .lowercase: return row3_lower
    case .uppercase: return row3_upper
    case .numeric: return row3_num
    case .symbols: return row3_sym
    }
  }
  
  // Metrics for custom iOS keyboard
  private struct M{
    static let keyHeight: CGFloat = 46
    static let interKey: CGFloat = 6
    static let rowGap: CGFloat = 10
    static let sideInset: CGFloat = 4
  }

  @Environment(\.colorScheme) private var scheme
  
  // --- BODY ---
  var body: some View {
      VStack(spacing: M.rowGap) {
        GeometryReader { geometry in
          let unitW = (geometry.size.width - (M.interKey * CGFloat(curRow1.count - 1))) / CGFloat(curRow1.count)
          
          VStack(spacing: M.rowGap) {
            // row 1
            HStack(spacing: M.interKey) {
              ForEach(curRow1, id: \.self) { key in
                KeyButton(label: key, style: keyStyle(for: key)) {
                  onKeyPress(key)
                }
                .frame(width: unitW)
              }
            }
            
            // row 2
            HStack(spacing: M.interKey) {
              Spacer(minLength: 0)
              ForEach(curRow2, id:\.self) {key in
                KeyButton(label: key, style: keyStyle(for: key)) {
                  onKeyPress(key)
                }
                .frame(width: unitW)
              }
              Spacer(minLength: 0)
            }
            
            // row 3, with special keys "shift" and "delete"
            HStack(spacing: M.interKey) {
              let specialKeyW = unitW * 1.5
              let midKeysW = geometry.size.width - (specialKeyW * 2) - (M.interKey * CGFloat(curRow3.count - 1))
              let midKeyW = midKeysW / CGFloat(curRow3.count - 2)
              
              KeyButton(label: "shift", style: keyStyle(for: "shift")) {
                onKeyPress(keyEvent(for: "shift"))
              }
              .frame(width: specialKeyW)
              
              ForEach(curRow3.dropFirst().dropLast(), id:\.self) {key in
                KeyButton(label: key, style: keyStyle(for: key)) {
                  onKeyPress(key)
                }
                .frame(width: midKeyW)
              }
              
              KeyButton(label: "delete", style: keyStyle(for: "delete")) {
                onKeyPress(keyEvent(for: "delete"))
              }
              .frame(width: specialKeyW)
            }
            
            // bottom bar
            HStack(spacing: M.interKey) {
              let modKeyW = unitW * 1.25
              
              KeyButton(label: "123", style: keyStyle(for: "123")) {
                onKeyPress("mode: 123")
              }
              .frame(width: modKeyW)
              
              KeyButton(label: "emoji", style: keyStyle(for: "emoji")) {
                onKeyPress("emoji")
              }
              .frame(width: modKeyW)
              
              KeyButton(label: "space", style: keyStyle(for: "space")) {
                onKeyPress(" ")
              }
              .frame(maxWidth: .infinity)
              
              // Right return key
              KeyButton(label: "return", style: keyStyle(for: "return")) {
                onKeyPress("\n")
              }
              .frame(width: geometry.size.width * 0.2)
            }
          }
        }
      }
      .padding(.horizontal, M.sideInset)
      .padding(.vertical, 6)
      .frame(height: (M.keyHeight * 4) + (M.rowGap * 3) + 12)
      .background(KeyboardBackground())
    }
}
  
  // TODO: implement special key event
  private func keyEvent(for key:String) -> String {
    switch key {
    case "delete": return "{backspace}"
    case "shift": return "{shift}"
    default: return key
    }
  }
  
  private func keyStyle(for key:String) -> KeyStyle {
    switch key {
    case "shift", "delete", "emoji", "123", "return":
      return .systemFunction
    case "space":
      return .space
    default:
      return .letter
    }
  }

struct KeyButton: View {
  let label: String
  let style: KeyStyle
  var action: () -> Void
  
  @State private var isPressed = false
  
  var body: some View {
    Button {
      haptic()
      action()
    } label: {
      ZStack {
        RoundedRectangle(cornerRadius: KeyStyle.metrics.corner)
          .fill(style.background(isPressed: isPressed))
          .overlay(
            RoundedRectangle(cornerRadius: KeyStyle.metrics.corner)
              .stroke(style.strokeColor, lineWidth: 0.5)
          )
          .shadow(radius: isPressed ? 0:1, x:0, y:1)
        
        // icon or text
        Group {
          if let sys = style.systemImage(for: label) {
            Image(systemName: sys).font(.system(size: 18, weight: .regular))
          } else {
            Text(style.displayText(for: label))
              .font(.system(size: 20, weight: .regular, design: .default))
              .textCase(.lowercase)
          }
        }
        .foregroundStyle(style.foreground)
        .padding(.horizontal, 4)
      }
      .overlay(alignment: .top) {
        if isPressed, style.showsCallout {
          KeyCallout(text: style.calloutText(for: label))
            .offset(y: -6)
        }
      }
      .contentShape(RoundedRectangle(cornerRadius: KeyStyle.metrics.corner))
    }
    .buttonStyle(.plain)
    .simultaneousGesture(
      DragGesture(minimumDistance:0)
        .onChanged { _ in withAnimation(.easeOut(duration: 0.06)) { isPressed = true} }
        .onEnded { _ in withAnimation(.easeIn(duration: 0.08)) { isPressed = false} }
    )
  }
  
  private func haptic() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }
  
}

struct KeyStyle {
  struct metrics {
    static let corner: CGFloat = 7
  }
  
  enum Kind { case letter, systemFunction, space }
  
  let kind:Kind
  
  static let letter = KeyStyle(kind: .letter)
  static let systemFunction = KeyStyle(kind: .systemFunction)
  static let space = KeyStyle(kind: .space)
  
  var showsCallout: Bool {kind == .letter}
  
  func background(isPressed: Bool) -> some ShapeStyle {
    switch kind {
    case .letter:
      return (isPressed ? Color(uiColor: .tertiarySystemFill) : Color(uiColor: .secondarySystemFill))
    case .systemFunction, .space:
      return (isPressed ? Color(uiColor: .systemGray4) : Color(uiColor: .systemGray5))
    }
  }
  
  var strokeColor: Color {
    Color.black.opacity(0.08)
  }
  
  var shadowColor: Color {
    Color.black.opacity(0.15)
  }
  
  var foreground: Color {
    Color.primary
  }
  
  func displayText(for label: String) -> String {
    label == "space" ? "" : label
  }
  
  func calloutText(for label: String) -> String {
    switch label {
    case "space": return ""
    default: return label.uppercased()
    }
  }
  
  func systemImage(for label: String) -> String? {
    switch label {
    case "shift": return "shift"
    case "delete": return "delete.left"
    case "emoji": return "face.smiling"
    case "123": return "textformat.123"
    case "return": return "return"
    case "space": return nil
    default: return nil
    }
  }
}

// TODO: Improve UI style
struct KeyCallout: View {
  let text: String
  var body: some View {
    VStack(spacing: 0) {
      Text(text)
        .font(.system(size: 24, weight: .regular))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 8).fill(.background))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black.opacity(0.12), lineWidth: 0.5))
        .shadow(radius: 2, x: 0, y: 1)
      Triangle().fill(.background)
        .frame(width: 12, height: 6)
        .overlay(Triangle().stroke(Color.black.opacity(0.12), lineWidth: 0.5))
    }
  }
}

struct Triangle: Shape {
  func path(in rect: CGRect) -> Path {
    var p = Path()
    p.move(to: CGPoint(x: rect.midX, y: rect.minY))
    p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    p.closeSubpath()
    return p
  }
}

struct KeyboardBackground: View {
  var body: some View {
    ZStack {
      Color(uiColor: .systemGray6)
      VStack { Divider().opacity(0.4); Spacer() }
    }
  }
}
