//
//  SharedFunctions.swift
//  FitBurst
//
//  Created by Piero Sierra on 24/11/2024.
//

import Foundation
import SwiftUI
import WebKit

/// Define custom colors
extension Color {
    static let grayBackground: Color = Color(hex: 0xaaaaaa)
    static let limeAccentColor: Color = Color(hex: 0x86fc1e)
    /// --------------------------------------------------------------------------------
    static let lightShadow = Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
    static let darkShadow = Color(red: 163 / 255, green: 177 / 255, blue: 198 / 255)
    static let background = Color(red: 224 / 255, green: 229 / 255, blue: 236 / 255)
    static let pinkAccentColor: Color = Color(hex: 0xff41ff)
    static let blueAccentColor: Color = Color(hex: 0x01b3f7)
    static let greenBrandColor: Color = Color(hex: 0xa6d1b9)
    static let blueBrandColor: Color = Color(hex: 0xbec5e2)
    static let pinkBrandColor: Color = Color(hex: 0xd2bee2)
    static let orangeBrandColor: Color = Color(hex: 0xe2d3be)
    static let purpleBrandColor: Color = Color(hex: 0x95cadf)
    static let darkGreenBrandColor: Color = Color(hex: 0x6ba584)
}

/// HEX color code extension
extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

/// Mix Color Extension
extension Color {
    func mix(with color: Color, by percentage: CGFloat) -> Color {
        let uiColor1 = UIColor(self)
        let uiColor2 = UIColor(color)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let r = r1 * (1 - percentage) + r2 * percentage
        let g = g1 * (1 - percentage) + g2 * percentage
        let b = b1 * (1 - percentage) + b2 * percentage
        let a = a1 * (1 - percentage) + a2 * percentage
        
        return Color(red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
    }
}

/// Detect Orientation Changes
/// Add @State private var orientation = UIDeviceOrientation.unknown to a view, then add
/// .onRotate { newOrientation in
///     orientation = newOrientation
/// }
/// then call if orientation.isPortrait, if orientation.isLandscape
///  NOTE: this also detects "flat"
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

/// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

/// SortOrder
enum SortOrder {
    case ascending, descending
}


/// Growing button style (grows when pressed)
struct GrowingButtonStyle: ButtonStyle {
    @State private var scale: CGFloat = 0.6
    @State private var wasPressed: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .padding(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20))
            .background(
                Color.limeAccentColor.mix(with: .white, by: wasPressed ? 0.5 : 0.0)
            )
            .foregroundStyle(.black)
            .clipShape(Capsule())
            .scaleEffect(wasPressed ? 0.9 : scale)
            .animation(.spring(response: 0.2), value: wasPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        wasPressed = true
                    }
                    .onEnded { _ in
                        wasPressed = true
                        // Schedule wasPressed to be reset after 200ms
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            wasPressed = false
                        }
                    }
            )
            .onAppear {
                scale = 0.6
                withAnimation(.bouncy) { scale = 1.15 }
                withAnimation(.bouncy.delay(0.25)) { scale = 1 }
            }
    }
}

/// Calculates the shorter segment of a line divided by the golden ratio
func goldenRatio(_ length: CGFloat) -> CGFloat {
    return length / 1.618
}


struct SingleVideoView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let youtubeURL = URL(string: "https://www.youtube.com/embed/\(videoID)") else { return }
        uiView.scrollView.isScrollEnabled = false
        uiView.load(URLRequest(url: youtubeURL))
    }
}
