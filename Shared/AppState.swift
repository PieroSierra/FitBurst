import SwiftUI
import SceneKit
import WidgetKit

struct BackgroundOption {
    let displayName: String
    let assetName: String
}

@Observable
class AppState {
    static let shared = AppState()
    private let groupDefaults = UserDefaults(suiteName: "group.com.pieroco.FitBurst")!
    
    let backgroundOptions: [BackgroundOption] = [
        BackgroundOption(displayName: "Black Tiles", assetName: "BlackTiles"),
        BackgroundOption(displayName: "Dark Forest", assetName: "DarkForest"),
        BackgroundOption(displayName: "Running Tracks", assetName: "RunningTracks"),
        BackgroundOption(displayName: "Night Dunes", assetName: "Dunes"),
        BackgroundOption(displayName: "Gradient Waves", assetName: "GradientWaves"),
        BackgroundOption(displayName: "Ocean Ripples", assetName: "Ocean"),
        BackgroundOption(displayName: "Black & White", assetName: "BlackAndWhite"),
        BackgroundOption(displayName: "Palm Frond", assetName: "Frond"),
        BackgroundOption(displayName: "Sky lights", assetName: "Skylights"),
        BackgroundOption(displayName: "Pink Palm", assetName: "PinkPalm"),
        BackgroundOption(displayName: "El Capitan", assetName: "ElCapitan"),
        BackgroundOption(displayName: "Mr. Rainier", assetName: "Rainier"),
        BackgroundOption(displayName: "Mt. Fuji", assetName: "Fuji1"),
        BackgroundOption(displayName: "Matterhorn", assetName: "Matterhorn"),
        BackgroundOption(displayName: "Snowcap", assetName: "Snowcap"),
        BackgroundOption(displayName: "Lion", assetName: "Lion"),
        BackgroundOption(displayName: "Kettle Bell", assetName: "KettleBell"),
        BackgroundOption(displayName: "Dark Crystals", assetName: "DarkCrystals")
    ]
    
    // Private storage
    private var _currentBackground: String
    private var _previousBackground: String
    
    // Public interface
    var currentBackground: String {
        get {             print("AppState - Reading currentBackground: \(_currentBackground)")
            return _currentBackground 
        }
        set {
            _previousBackground = _currentBackground
            _currentBackground = newValue
            
            // Save to both keys
            groupDefaults.set(newValue, forKey: "currentBackground")
            groupDefaults.set(newValue, forKey: "widget.currentBackground")
            groupDefaults.synchronize()
            
            // Force widget reload with multiple attempts
            DispatchQueue.main.async {
                // Immediate reload
                WidgetCenter.shared.reloadAllTimelines()
                
                // Delayed reloads
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
    }
    
    var previousBackground: String {
        get { _previousBackground }
    }
    
    private init() {
        self._currentBackground = groupDefaults.string(forKey: "currentBackground") ?? "BlackTiles"
        self._previousBackground = groupDefaults.string(forKey: "previousBackground") ?? "BlackTiles"
    }
}

struct BackgroundView: View {
    private let appState = AppState.shared
    @State private var lastKnownBackground: String = ""
    @State private var displayedBackground: String = ""
    @State private var shouldRipple = false
    @State private var isTransitioning = false
    @State private var opacity: Double = 0
    
    var body: some View {
        GeometryReader { _ in  // Changed to ignore geometry parameter
            ZStack {
                // Base black layer
                Rectangle()
                    .fill(Color.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                
                // Show the current display image
                Image(displayedBackground)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)  // Use screen bounds
                    .clipped()
                
                // Show new image on top during transition
                if isTransitioning {
                    Image(appState.currentBackground)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)  // Use screen bounds
                        .clipped()
                        .opacity(opacity)
                }
            }
            .modifier(RippleEffect(
                at: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2),
                trigger: shouldRipple,
                amplitude: -22,
                frequency: 15,
                decay: 4,
                speed: 600
            ))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)  // Added to ensure full size
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            lastKnownBackground = appState.currentBackground
            displayedBackground = appState.currentBackground
        }
        .onChange(of: appState.currentBackground) { _, newValue in
            if lastKnownBackground != newValue {
                withAnimation {
                    isTransitioning = true
                    shouldRipple.toggle()
                    opacity = 0
                    
                    withAnimation(.easeInOut(duration: 1.5)) {
                        opacity = 1
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isTransitioning = false
                        displayedBackground = newValue  // Update the displayed background after transition
                        lastKnownBackground = newValue
                        print("BackgroundView - Transition complete, updating lastKnownBackground to: \(newValue)")
                    }
                }
            } else {
                print("BackgroundView - No transition needed, backgrounds match")
            }
        }
    }
} 
