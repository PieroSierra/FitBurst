//
//  SharedFunctions.swift
//  FitBurst
//
//  Created by Piero Sierra on 24/11/2024.
//

import Foundation
import SwiftUI

/// Define custom colors
extension Color {
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
    @State private var scale: CGFloat = 0.6  // Start with a smaller scale for pop-in effect
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .padding(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20))
            .background(Color.white)
            .foregroundStyle(.blue)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.9 : scale)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeInOut, value: configuration.isPressed)
            .onAppear {
                scale = 0.6
                withAnimation(.bouncy) { scale = 1.15 }
                withAnimation(.bouncy.delay(0.25)) { scale = 1 }
            }
    }
}



struct GlowGradientButton: View {
    // Define gradient colors for the button
    let gradientColors = Gradient(colors: [.blueBrandColor, .orangeBrandColor,.greenBrandColor,.blueBrandColor,.purpleBrandColor,.pinkBrandColor])
    var buttonText: String
    
    // State variables to control animation and press state
    @State var isAnimating = false
    @State var isPressed = false
    
    var body: some View {
        ZStack{
            // Background of the button with stroke, blur, and offset effects
            RoundedRectangle(cornerRadius: 20)
                .stroke(AngularGradient(gradient: gradientColors, center: .center, angle: .degrees(isAnimating ? 360 : 0)), lineWidth: 14)
                .blur(radius: 20)
                .offset(y: 10)
                .frame(width: 220, height: 50)
            
            // Text label for the button
            Text(buttonText)
                .font(.system(size: 18))
                .frame(width: 220, height: 50)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 30))
                .foregroundStyle(.blue)
                .overlay(
                    // Overlay to create glow effect
                    
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(AngularGradient(gradient: gradientColors, center: .center, angle: .degrees(isAnimating ? 360 : 0)), lineWidth: 4)
                        .overlay(
                            // Inner glow effect
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(lineWidth: 4)
                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.greenBrandColor, .greenBrandColor, .clear]), startPoint: .top, endPoint: .bottom))
                        )
                )
        }
        // Scale effect when pressed
        .scaleEffect(isPressed ? 0.95 : 1)
        .animation(.easeInOut(duration: 0.2), value: isPressed)
        .onAppear() {
            // Animation to rotate gradient colors infinitely
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        // Gesture to detect button press
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged({_ in isPressed = true})
                .onEnded({_ in isPressed = false})
        )
    }
}
