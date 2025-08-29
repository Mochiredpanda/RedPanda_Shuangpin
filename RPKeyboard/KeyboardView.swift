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
  
  @State private var curLayer: KeyboardLayer = .lowercase

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
  private let row3_num = ["#+=", "。", "，", "、", "！", ".", "delete"]
  
  // Symbols Layer
  private let row1_sym = ["【", "】", "{", "}", "#", "%", "^", "*", "+", "="]
  private let row2_sym = ["_", "——", "\\", "|", "～", "《", "》", "€", "&", "·"]
  private let row3_sym = ["123", "…", ",", "?", "!", "'", "^_^", "delete"]
  
  // Bottom Bar
  private let btmRow_alpha = ["123", "emoji", "space", "return"]
  private let btmRow_num   = ["双拼", "emoji", "space", "return"]
  
  // Computed properties decide cur rows
  private var curRow1: [String] {
    switch curLayer {
    case .lowercase: return row1_lower
    case .uppercase: return row1_upper
    case .numeric: return row1_num
    case .symbols: return row1_sym
    }
  }
  
  private var curRow2: [String] {
    switch curLayer {
    case .lowercase: return row2_lower
    case .uppercase: return row2_upper
    case .numeric: return row2_num
    case .symbols: return row2_sym
    }
  }
  
  private var curRow3: [String] {
    switch curLayer {
    case .lowercase: return row3_lower
    case .uppercase: return row3_upper
    case .numeric: return row3_num
    case .symbols: return row3_sym
    }
  }
  
  private var curBtmRow: [String] {
    switch curLayer {
    case .lowercase, .uppercase:
      return btmRow_alpha
    case .numeric, .symbols:
      return btmRow_num
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
  
  // TODO: feat - long hold shift to lock uppercase
  
  // TODO: feat - emoji keyboard layer
  
  // TODO: feat - link special Kaomoji input solutions, with rime(?)
  
  // TODO: feat - add key behavior for space
  
  // TODO: fix - long hold button show better uppercase UI (larger key unit, less transparent, upper location)
  
  // --- BODY ---
  var body: some View {
      VStack(spacing: M.rowGap) {
        GeometryReader { geometry in
          
          VStack(spacing: M.rowGap) {
            // standard width
            let stdW_10Key = (geometry.size.width - (M.interKey * 9)) / 10
            
            // row 1 (10key)
            HStack(spacing: M.interKey) {
              ForEach(curRow1, id: \.self) { key in
                KeyButton(label: key, style: keyStyle(for: key), curLayer: curLayer) {
                  handleKeyPress(for: key)
                }
                .frame(width: stdW_10Key)
              }
            }
            
            // row 2 (dynamic layout of Spacer)
            HStack(spacing: M.interKey) {
              if curRow2.count < 10 {
                Spacer(minLength: 0)
                ForEach(curRow2, id:\.self) {key in
                  KeyButton(label: key, style: keyStyle(for: key), curLayer: curLayer) {
                    handleKeyPress(for: key)
                  }
                  .frame(width: stdW_10Key)
                }
                Spacer(minLength: 0)
              } else {
                ForEach(curRow2, id: \.self) { key in
                  KeyButton(label: key, style: keyStyle(for: key), curLayer: curLayer) { handleKeyPress(for: key) }
                    .frame(width: stdW_10Key)
                }
              }
            }
            
            // row 3 (Dynamic layout)
            HStack(spacing: M.interKey) {
              let specialKeyW = stdW_10Key * 1.5
              let midKeyCount = CGFloat(curRow3.count - 2)
              let midKeysW = geometry.size.width - (specialKeyW * 2) - (M.interKey * (midKeyCount + 1))
              let midKeyW = midKeysW / midKeyCount
              
              ForEach(curRow3, id: \.self) { key in
                let keyWidth: CGFloat = {
                  if key == curRow3.first || key == curRow3.last {
                    return specialKeyW
                  }
                  return midKeyW
                }()
                
                KeyButton(label: key, style: keyStyle(for: key), curLayer: curLayer) {
                  handleKeyPress(for: key)
                }
                .frame(width: keyWidth)
              }
            }
            
            // bottom bar (dynamic)
            HStack(spacing: M.interKey) {
              ForEach(curBtmRow, id: \.self) { key in
                // flexible width for space bar
                if key == "space" {
                  KeyButton(label: key, style: keyStyle(for: key), curLayer: curLayer) {
                    handleKeyPress(for: key)
                  }
                  .frame(maxWidth: .infinity)
                } else {
                  // widths for other btmbar keys
                  let keyWidth: CGFloat = {
                    if key == "return" { return geometry.size.width * 0.2 }
                    // '123'/'ABC' and 'emoji'
                    return stdW_10Key * 1.25
                  }()
                  KeyButton(label: key, style: keyStyle(for: key), curLayer: curLayer) {
                    handleKeyPress(for: key)
                  }
                  .frame(width: keyWidth)
                }
              }
            }
          }
        }
      }
      .padding(.horizontal, M.sideInset)
      .padding(.vertical, 6)
      .frame(height: (M.keyHeight * 4) + (M.rowGap * 3) + 12)
      .background(KeyboardBackground())
    }
  
  // dynamically handles the curLayer behaviors
  private func handleKeyPress(for key: String) {
    switch key {
      // State-changing keys
    case "shift", "#+=":
      withAnimation(.easeInOut(duration: 0.1)) {
        switch curLayer {
        case .lowercase: curLayer = .uppercase
        case .uppercase: curLayer = .lowercase
        case .numeric: curLayer = .symbols
        case .symbols: curLayer = .numeric
        }
      }
    case "123":
      withAnimation(.easeInOut(duration: 0.1)) { curLayer = .numeric }
    case "ABC":
      withAnimation(.easeInOut(duration: 0.1)) { curLayer = .lowercase }
      
      // Engine command keys
    case "delete":
      onKeyPress("{backspace}")
    case "return":
      onKeyPress("\n")
      
      // Character keys
    default:
      onKeyPress(key)
      // After typing an uppercase letter, return to lowercase
      if curLayer == .uppercase {
        curLayer = .lowercase
      }
    }
  }
  
  private func keyEvent(for key:String) -> String {
    switch key {
      // delete and long-press is handled in Controller
      case "delete": return "{backspace}"
      // TODO: build shift key behavior
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
  
}

// handles key button behaviors
struct KeyButton: View {
  let label: String
  let style: KeyStyle
  let curLayer: KeyboardLayer
  var action: () -> Void
  
  
  @State private var isPressed = false
  // long press for rapid delete
  @State private var initialDeleteTimer: Timer?
  @State private var repeatingDeleteTimer: Timer?
  
  var body: some View {
    Button {
      // single tap for all keys
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
        //  pass curLayer
        Group {
          if let sys = style.systemImage(for: label, curLayer: self.curLayer) {
            Image(systemName: sys).font(.system(size: 18, weight: .regular))
          } else {
            Text(style.displayText(for: label))
              .font(.system(size: 20, weight: .regular, design: .default))
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
        .onChanged { _ in 
          if !isPressed {
            isPressed = true
            if label == "delete" {
              startDeleteTimers()
            }
          }
        }
        .onEnded { _ in
          isPressed = false
          cancelDeleteTimers()
        }
    )
  }


  // long press timer helper method
  private func startDeleteTimers() {
    cancelDeleteTimers()
    initialDeleteTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
      self.startRepeatingTimer()
    }
  }

  private func cancelDeleteTimers() {
    initialDeleteTimer?.invalidate()
    repeatingDeleteTimer?.invalidate()
    initialDeleteTimer = nil
    repeatingDeleteTimer = nil
  }

  private func startRepeatingTimer() {
    repeatingDeleteTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
      haptic()
      action() 
    }
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
  
  func systemImage(for label: String, curLayer: KeyboardLayer) -> String? {
    switch label {
      case "shift", "#+=":
        return curLayer == .uppercase || curLayer == .symbols ? "shift.fill" : "shift"
      case "delete": return "delete.left"
      case "emoji": return "face.smiling"
      case "123", "": return "textformat.123"
      case "return": return "return"
      case "space": return nil
      // TODO: resolve the 双拼 button view, and the link to return to main layer
      case "双拼": return "textformat.双拼"
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
