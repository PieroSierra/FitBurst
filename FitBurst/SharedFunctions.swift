//
//  SharedFunctions.swift
//  FitBurst
//
//  Created by Piero Sierra on 24/11/2024.
//

import Foundation
import SwiftUI
import WebKit
import AVFoundation
import SceneKit

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

struct ViewPositionKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

/// FillUpButton style (fills up when held, with haptic feedback)
struct FillUpButtonStyle: ButtonStyle {
    var onComplete: ((CGPoint) -> Void)? = nil
    @State private var fillAmount: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    @State private var isPressed: Bool = false
    @State private var shakeOffset: CGFloat = 0
    @State private var isCompleted: Bool = false
    @State private var currentTimer: Timer?
    @State private var scheduledTasks: [DispatchWorkItem] = []
    @State private var completionTask: DispatchWorkItem?
    private let fillDuration: Double = 1.2
    private let maxScale: CGFloat = 1.2
    @State private var buttonPosition: CGPoint = .zero
    
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
            .background(
                GeometryReader { geometry in
                    Color.clear // Using clear color to not affect visuals
                        .preference(key: ViewPositionKey.self, value: geometry.frame(in: .global))
                        .onPreferenceChange(ViewPositionKey.self) { frame in
                            buttonPosition = CGPoint(
                                x: frame.midX,
                                y: frame.midY
                            )
                        }
                }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isPressed && !isCompleted {
                            startFillAnimation()
                        }
                    }
                    .onEnded { value in
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
        
        /// Play completion sound
        playSound(named: SoundScape.buildup.rawValue)
        
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
        
        // Stop any playing audio
        audioPlayer?.stop()
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
        
        /// Play completion sound
        playSound(named: SoundScape.release.rawValue)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = maxScale
            shakeOffset = 0
            fillAmount = 1.0
        }
        
        // Final success haptic
        let notificationGenerator = UINotificationFeedbackGenerator()
        notificationGenerator.notificationOccurred(.success)
        
        onComplete?(buttonPosition)
        
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

private var audioPlayer: AVAudioPlayer?

func playSound(named soundName: String, fileExtension: String? = nil) {
    /// Try with provided extension first, then try common audio extensions
    let extensions = fileExtension.map { [$0] } ?? ["wav", "mp3"]
    
    /// Find first matching audio file
    let audioPath = extensions.lazy
        .compactMap { ext in
            Bundle.main.path(forResource: soundName, ofType: ext)
        }
        .first
    
    guard let path = audioPath else {
        print("❌ Sound file not found for \(soundName) with extensions: \(extensions)")
        return
    }
    
    let url = URL(fileURLWithPath: path)
    
    do {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.prepareToPlay()
        
        guard let player = audioPlayer else {
            print("❌ audioPlayer is nil after creation")
            return
        }
        
        player.play()
        
    } catch {
        print("❌ Could not create audio player: \(error)")
    }
}

import SwiftUI
import SceneKit

struct ThreeDTextView: UIViewRepresentable {
    
    /// MARK: - Public Properties
    var text: String
    var extrusionDepth: CGFloat
    var fontFace: String
    var fontSize: CGFloat
    var fontColor: Color
    
    /// Camera position
    var cameraPosition: SCNVector3
    
    /// Rotation in radians about the X, Y, and Z axes.
    var rotationX: CGFloat
    var rotationY: CGFloat
    var rotationZ: CGFloat
    
    var animationDuration: TimeInterval = 1.0
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = SCNScene()
        
        // Allows the user to pan/zoom/rotate the scene
        scnView.allowsCameraControl = true
        
        // Scene background color
        scnView.backgroundColor = .clear
        
        // Add a camera node
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = cameraPosition
        scnView.scene?.rootNode.addChildNode(cameraNode)
        
        // Add a simple omni light
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 20)
        scnView.scene?.rootNode.addChildNode(lightNode)
        
        // Optionally, add an ambient light so the text isn’t fully in shadow
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scnView.scene?.rootNode.addChildNode(ambientLightNode)
        
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        guard let scene = scnView.scene else { return }
        
        // Add HDRI environment but keep background clear
        if let hdriURL = Bundle.main.url(forResource: "studio_small_03_1k", withExtension: "exr") {
            scene.background.contents = UIColor.clear  // Keep background transparent
            scene.lightingEnvironment.contents = hdriURL  // Keep HDRI for reflections
            scene.lightingEnvironment.intensity = 1.0
        }
        
        // Remove existing text nodes
        scene.rootNode.childNodes
            .filter { $0.geometry is SCNText }
            .forEach { $0.removeFromParentNode() }
        
        // Create text geometry
        let textGeometry = SCNText(string: text, extrusionDepth: extrusionDepth)
        
        // Configure material with metallic and reflective properties
        let material = textGeometry.firstMaterial!
        material.diffuse.contents = UIColor(fontColor)
        material.metalness.contents = 1.0  // Full metallic
        material.roughness.contents = 0.5  // Medium roughness (inverse of reflectivity)
        material.lightingModel = .physicallyBased  // Use PBR lighting
        
        // Set the font (now actually used because we're not passing NSAttributedString)
        if let customFont = UIFont(name: fontFace, size: fontSize) {
            textGeometry.font = customFont
        } else {
            // Fallback if the provided fontFace is invalid
            textGeometry.font = UIFont.systemFont(ofSize: fontSize)
        }
        
        // Adjust flatness to control polygon count (optional)
        // textGeometry.flatness = 0.0001 // smoother text
        // textGeometry.chamferRadius = 0.1 // slightly bevel edges, optional
        textGeometry.flatness = 0.01
        textGeometry.chamferRadius = 0.1
        
        // Create a node with the text geometry
        let textNode = SCNNode(geometry: textGeometry)
        
        // Center the text
        let (minBound, maxBound) = textNode.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation(
            (minBound.x + maxBound.x) / 2,
            (minBound.y + maxBound.y) / 2,
            (minBound.z + maxBound.z) / 2
        )
        
        // Create rotation animation
        let rotateAction = SCNAction.rotateBy(
            x: rotationX - CGFloat(textNode.eulerAngles.x),
            y: rotationY - CGFloat(textNode.eulerAngles.y),
            z: rotationZ - CGFloat(textNode.eulerAngles.z),
            duration: animationDuration
        )
        rotateAction.timingMode = .easeOut
        
        // Run the animation
        textNode.runAction(rotateAction)
        
        // Add the node to the scene
        scene.rootNode.addChildNode(textNode)
    }
}

extension UIView {
    func findView<T: UIView>(ofType type: T.Type) -> T? {
        if let typed = self as? T {
            return typed
        }
        for subview in subviews {
            if let found = subview.findView(ofType: type) {
                return found
            }
        }
        return nil
    }
}
