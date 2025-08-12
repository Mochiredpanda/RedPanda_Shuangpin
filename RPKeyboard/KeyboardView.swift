//
//  KeyboardView.swift
//  RedPandaShuangpin
//
//  Created by Jiyu He on 8/11/25.
//

import SwiftUI

struct KeyboardView: View {
  var onKeyPress: (String) -> Void
  
  // Isolate each row on keyboard
  private let row1 = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]
  private let row2 = ["a", "s", "d", "f", "g", "h", "j", "k", "l"]
  private let row3 = ["shift", "z", "x", "c", "v", "b", "n", "m", "delete"]
  private let btmRow = ["globe", "123", "space", "return"]
  
  // Metrics for custom iOS keyboard
  private struct M{
    static let keyHeight: CGFloat = 46
    static let keyCorner: CGFloat = 7
    static let interKey: CGFloat = 6
    static let rowGap: CGFloat = 10
    static let sideInset: CGFloat = 4
    static let row2Indent: CGFloat = 12 // left + right
    static let row3Indent: CGFloat = 43 // left + right + shift/delete
  }
  
  @Environment(\.colorScheme) private var scheme
  
  var body: some View {
    VStack(spacing: M.rowGap) {
      row(row1)
      row(row2, horizontalPadding: M.row2Indent)
      row(row3, horizontalPadding: M.row3Indent, specialWidths: true)
      bottomBar()
    }
    .padding(.horizontal, M.sideInset)
    .padding(.vertical, 6)
    .background(KeyboardBackground())
    .ignoresSafeArea(.keyboard, edges: .bottom)
  }
  
  private func row(_ keys: [String], horizontalPadding: CGFloat? = 0, specialWidths: Bool = false) -> some View {
    HStack(spacing: M.interKey) {
      ForEach(keys, id:\.self) { key in
        KeyButton(label: key, style: keyStyle(for: key)) {
          onKeyPress(keyEvent(for: key))
        }
        .frame(height: M.keyHeight)
        .frame(minWidth: specialWidths ? specialWidth(for: key): nil)
      }
    }
    .padding(.horizontal, horizontalPadding)
  }
  
  // special keys
  private func bottomBar() -> some View {
    HStack(spacing: M.interKey) {
        KeyButton(label: "globe", style: keyStyle(for: "globe")) {
          onKeyPress("globe")
        }
        .frame(height: M.keyHeight)
        .frame(minWidth: 64)
      
        KeyButton(label: "123", style: keyStyle(for: "123")) {
          onKeyPress("mode: 123")
        }
        .frame(height: M.keyHeight)
        .frame(minWidth: 64)
      
        KeyButton(label: "space", style: keyStyle(for: "space")) {
          onKeyPress(" ")
        }
        .frame(height: M.keyHeight)
        .frame(minWidth: 0)
        .layoutPriority(1)
        
        KeyButton(label: "return", style: keyStyle(for: "return")) {
          onKeyPress("\n")
        }
        .frame(height: M.keyHeight)
        .frame(minWidth: 88)
      }
    }
  
  private func specialWidth(for key: String) -> CGFloat? {
    switch key {
      case "shift", "delete": return 56
      default: return nil
    }
  }
  
  // special keys
  private func keyEvent(for key:String) -> String {
    switch key {
      case "delete": return "{backspace}"
      case "shift": return "{shift}"
      default: return key
    }
  }
  
  private func keyStyle(for key:String) -> KeyStyle {
    switch key {
      case "shift", "delete", "globe", "123", "return":
        return .systemFunction
      case "space":
        return .space
      default:
        return .letter
    }
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
    case "globe": return "globe"
    case "123": return "textformat.123"
    case "return": return "return"
    case "space": return nil
    default: return nil
    }
  }
  
}

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
