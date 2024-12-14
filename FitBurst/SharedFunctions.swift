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

/// FillUpButton style (fills up when held, with haptic feedback)
struct FillUpButtonStyle: ButtonStyle {
    @State private var fillAmount: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    @State private var isPressed: Bool = false
    @State private var shakeOffset: CGFloat = 0
    @State private var isCompleted: Bool = false
    @State private var currentTimer: Timer?
    @State private var scheduledTasks: [DispatchWorkItem] = []
    @State private var completionTask: DispatchWorkItem?
    private let fillDuration: Double = 2.0
    private let maxScale: CGFloat = 1.2
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .padding(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20))
            .background(
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Base color
                        Color.white
                        
                        // Fill color that animates
                        Color.limeAccentColor
                            .frame(width: geometry.size.width * fillAmount)
                    }
                }
            )
            .foregroundStyle(.black)
            .clipShape(Capsule())
            .scaleEffect(scale)
            .offset(x: shakeOffset)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed && !isCompleted {
                            startFillAnimation()
                        }
                    }
                    .onEnded { _ in
                        if !isCompleted {
                            cancelFillAnimation()
                        }
                    }
            )
    }
    
    private func startFillAnimation() {
        // Cancel any existing tasks first
        cancelAllTasks()
        
        isPressed = true
        
        // Start with smaller scale
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.8
        }
        
        // Gradually increase scale during fill
        withAnimation(.linear(duration: fillDuration)) {
            fillAmount = 1.0
            scale = 1.1
        }
        
        // Start shake animation
        withAnimation(.linear(duration: 0.05).repeatForever()) {
            shakeOffset = 2
        }
        
        // Alternate shake direction
        currentTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if !isPressed || isCompleted {
                timer.invalidate()
                return
            }
            withAnimation(.linear(duration: 0.05)) {
                shakeOffset = shakeOffset == 2 ? -2 : 2
            }
        }
        
        // Schedule haptic feedback
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        
        // Schedule multiple haptic pulses
        scheduledTasks = []
        for i in 0...30 {
            let task = DispatchWorkItem {
                if isPressed && !isCompleted {
                    let intensity = min(1.0, Double(i) / 20.0)
                    feedbackGenerator.impactOccurred(intensity: intensity)
                }
            }
            scheduledTasks.append(task)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * (fillDuration/30), execute: task)
        }
        
        // Schedule completion events
        completionTask = DispatchWorkItem {
            if isPressed {
                finishButton()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + fillDuration, execute: completionTask!)
    }
    
    private func cancelAllTasks() {
        // Cancel timer
        currentTimer?.invalidate()
        currentTimer = nil
        
        // Cancel all scheduled haptic tasks
        scheduledTasks.forEach { $0.cancel() }
        scheduledTasks.removeAll()
        
        // Cancel completion task
        completionTask?.cancel()
        completionTask = nil
    }
    
    private func cancelFillAnimation() {
        isPressed = false
        cancelAllTasks()
        
        withAnimation(.spring(response: 0.3)) {
            fillAmount = 0
            scale = 1.0
            shakeOffset = 0
        }
    }
    
    private func finishButton() {
        isCompleted = true
        isPressed = false
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = maxScale
            shakeOffset = 0
            fillAmount = 1.0
        }
        
        // Final success haptic
        let notificationGenerator = UINotificationFeedbackGenerator()
        notificationGenerator.notificationOccurred(.success)
        
        // Set final state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3)) {
                scale = 1.0
            }
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
