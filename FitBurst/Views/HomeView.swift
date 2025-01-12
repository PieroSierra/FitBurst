//
//  HomeView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI
import SceneKit

struct BackgroundView: View {
    @AppStorage("selectedBackground") private var selectedBackground: String = "Black Tiles"
    @State private var shouldRipple = false
    @State private var previousAssetName: String = ""
    @State private var isTransitioning = false
    @State private var opacity: Double = 0
    
    private var currentAssetName: String {
        AppBackgrounds.options.first { $0.displayName == selectedBackground }?.assetName ?? "BlackTiles"
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base black layer
                Rectangle()
                    .fill(Color.black)
                    .frame(width: .infinity, height: .infinity)
                
                // Image layers group with ripple effect
                ZStack {
                    // Previous background
                    Image(previousAssetName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                    
                    // Current background (only during transition)
                    if isTransitioning {
                        Image(currentAssetName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .opacity(opacity)
                    }
                }
                .modifier(RippleEffect(at: CGPoint(
                    x: UIScreen.main.bounds.width / 2,
                    y: UIScreen.main.bounds.height / 2),
                                       trigger: shouldRipple,
                                       amplitude: -22, frequency: 15, decay: 4, speed: 600))
            }
        }
        .ignoresSafeArea()
        .onChange(of: selectedBackground) {
            if currentAssetName != previousAssetName {
                isTransitioning = true
                shouldRipple.toggle()
                opacity = 0
                
                // Animate opacity change
                withAnimation(.easeInOut(duration: 1.5)) {
                    opacity = 1
                }
                
                // After transition completes, update previous asset and end transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    previousAssetName = currentAssetName
                    isTransitioning = false
                    opacity = 0
                }
            }
        }
        .onAppear {
            // Initialize previous background only if it hasn't been set
            if previousAssetName.isEmpty {
                previousAssetName = currentAssetName
            }
        }
    }
}

struct HomeView: View {
    @Binding var selectedTab: Tab
    
    /// View controls
    @State private var showWorkoutView: Bool = false
    @State private var showTrophyDisplayView: Bool = false
    @State private var selectedTrophy: TrophyWithDate? = nil
    
    /// track the selected date
    @State var selectedDate: Date = Date()
    
    /// refresh triggers
    @State private var calendarRefreshTrigger = UUID()
    @State private var weekViewRefreshTrigger = UUID()
    
    /// maintain total workout count
    @State private var workoutCount: Int = 0
    
    /// For 3d Text
    @State private var cameraPosition: SCNVector3 = SCNVector3(x: 0, y: 0, z: 20)
    @State private var rotationX: CGFloat = 0
    @State private var rotationY: CGFloat = 0
    @State private var rotationZ: CGFloat = 0
    
    /// Refresh trigger for TrophyBox
    @State private var trophyBoxRefreshTrigger = UUID()
    
    var body: some View {
        ZStack {
            /// Background gradient
            BackgroundView()
            
            /// 3d Workout count
            VStack() {
                ThreeDTextView(text: "\(workoutCount)",
                               extrusionDepth: 4,
                               fontFace: "Futura Bold",
                               fontSize: 12,
                               fontColor: .limeAccentColor,
                               cameraPosition: cameraPosition,
                               rotationX: rotationX,
                               rotationY: rotationY,
                               rotationZ: rotationZ,
                               animationDuration: 0.5)
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .onTapGesture { selectedTab = Tab.calendar }
                Spacer()
            }
            
            /// Main Content
            VStack {
                Text("FitBurst")
                    .font(.custom("Futura Bold", fixedSize: 40))
                    .foregroundColor(.white)
                    .padding(.bottom, 0)
                
                VStack (alignment: .center) {
                    Spacer().frame(height: 180)
                    
                    Text (workoutCount == 1 ? "WORKOUT" : "WORKOUTS")
                        .font(.custom("Futura Bold", fixedSize: 16))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .onTapGesture {
                            animateRotation()
                        }
                }
                
                /// Scrollview contains Trophies, Calendar and Record button
                ScrollView {
                    Spacer().frame(height: 20)
                    TrophyBox(
                        scrollHorizontally: true,
                        showTrophyDisplayView: $showTrophyDisplayView,
                        selectedTrophy: $selectedTrophy,
                        showDummyData: false
                    )
                    .frame(maxWidth:.infinity)
                    .frame(height: 180)
                    .background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color.black.opacity(0.4)))
                    .padding(.horizontal)
                    .id(trophyBoxRefreshTrigger)  // Force refresh when trigger changes
                    .onTapGesture { selectedTab = Tab.trophies }
                    
                    SimpleWeekRow(selectedDate: $selectedDate)
                        .id(weekViewRefreshTrigger)  // Force refresh when trigger changes
                    
                    Spacer().frame(height: 20)
                    
                    /// Record Workout
                    Button (action: {                    showWorkoutView.toggle()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                            Text("Record Workout")
                        }
                    }
                    .buttonStyle(GrowingButtonStyle())
                    
                    Spacer()
                }
               Spacer()
                
            }
            .frame(height:.infinity)

            if showWorkoutView {
                RecordWorkoutView(
                    showWorkoutView: $showWorkoutView,
                    selectedDate: $selectedDate
                )
                .onDisappear {
                    // Refresh SimpleWeekRow when workout view disappears
                    weekViewRefreshTrigger = UUID()
                }
            }
            
            if showTrophyDisplayView, let trophy = selectedTrophy {
                SingleTrophyView(
                    showTrophyDisplayView: $showTrophyDisplayView,
                    trophy: trophy
                )
            }
            
        }
        .frame(height:.infinity)
        .ignoresSafeArea(edges:.bottom)
        .onAppear {
            showWorkoutView = false
            // Refresh SimpleWeekRow when view appears
            weekViewRefreshTrigger = UUID()
            // Update workout count when view appears
            animateRotation()
            workoutCount = PersistenceController.shared.countWorkouts()
        }
        .onReceive(NotificationCenter.default.publisher(for: .workoutAdded)) { _ in
            // Update workout count when notification is received
            animateRotation()  // Trigger animation when workout is added
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                workoutCount = PersistenceController.shared.countWorkouts()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .achievementsChanged)) { _ in
            // Force TrophyBox to refresh
            trophyBoxRefreshTrigger = UUID()
        }
    }
    
    private func animateRotation() {
        // Start from zero each time
        rotationX = 0
        rotationY = 0
        
        // Use a regular state update without SwiftUI animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            rotationX += .pi * 2  // Two full rotations
            rotationY += .pi * 2  // Two full rotations
        }
    }
    
    /// Note used but just in case
    private func triggerHeartbeat() {
        // Create a camera animation
        if let sceneView = getSceneView() {
            let cameraNode = sceneView.pointOfView
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            
            // Start from zero each time
            //feedbackGenerator.impactOccurred(intensity: intensity)
            
            // default position x: 0, y: 10, z: 20
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                cameraNode?.position = SCNVector3(x: 0, y: 0, z: 19.5)
                SCNTransaction.commit()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                cameraNode?.position = SCNVector3(x: 0, y: 0, z: 20)
                SCNTransaction.commit()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                cameraNode?.position = SCNVector3(x: 0, y: 0, z: 19.5)
                SCNTransaction.commit()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                cameraNode?.position = SCNVector3(x: 0, y: 0, z: 20)
                SCNTransaction.commit()
            }
        }
    }
    
    
    private func getSceneView() -> SCNView? {
        // Find the SCNView in the view hierarchy
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let sceneView = window.findView(ofType: SCNView.self) else {
            return nil
        }
        return sceneView
    }
}

struct DebugWeekViewTest: View {
    @State var date = Date()
    var body: some View {
        VStack {
            Text("Weekly test").foregroundColor(.white)
            
            CalendarViewWeek(selectedDate: $date,
                             showMonthHeader: false,
                             showWeekdayHeader: true)
            .frame(height: 120)
        }
        .background(Image("GradientWaves").resizable().ignoresSafeArea())
    }
}

#Preview ("Full Content View") {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environment(\.dynamicTypeSize, .medium)
        .preferredColorScheme(.light)
}

#Preview ("Just Home") {
    HomeView(selectedTab: .constant(.home))
        .environment(\.dynamicTypeSize, .medium)
        .preferredColorScheme(.light)
}
