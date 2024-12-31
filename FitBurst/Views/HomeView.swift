//
//  HomeView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI
import SceneKit

struct HomeView: View {
    @Binding var selectedTab: Tab
    
    /// View controls
    @State private var showWorkoutView: Bool = false
    @State private var showTrophyDisplayView: Bool = false
    @State private var selectedTrophy: TrophyWithDate? = nil
    
    /// track the selected date
    @State var selectedDate: Date = Date()
    
    /// Add refresh triggers
    @State private var calendarRefreshTrigger = UUID()
    @State private var weekViewRefreshTrigger = UUID()
    
    /// maintain total workout count
    @State private var workoutCount: Int = 0
    
    /// For 3d Text
    @State private var cameraPosition: SCNVector3 = SCNVector3(x: 0, y: 0, z: 20)
    @State private var rotationX: CGFloat = 0
    @State private var rotationY: CGFloat = 0
    @State private var rotationZ: CGFloat = 0
    
    /// Add refresh trigger for TrophyBox
    @State private var trophyBoxRefreshTrigger = UUID()
    
    var body: some View {
        ZStack {
            /// Background gradient
            Image("GradientWaves").resizable().edgesIgnoringSafeArea(.all)
            
            /// 3d Workout count
            VStack() {
                ThreeDTextView(text: "\(workoutCount)",
                               extrusionDepth: 4,
                               fontFace: "Futura Bold",
                               fontSize: 13,
                               fontColor: .limeAccentColor,
                               cameraPosition: cameraPosition,
                               rotationX: rotationX,
                               rotationY: rotationY,
                               rotationZ: rotationZ,
                               animationDuration: 0.5)
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .background(Color.clear)
                Spacer()
            }
            
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
                            triggerHeartbeat()
                        }
                    
                    Spacer().frame(height: 40)
                    
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
                    .onTapGesture { selectedTab = Tab.trophies }
                    .id(trophyBoxRefreshTrigger)  // Force refresh when trigger changes
                    
                    SimpleWeekRow(selectedDate: $selectedDate)
                        .id(weekViewRefreshTrigger)  // Force refresh when trigger changes
                    
                    Spacer().frame(height: 30)
                    
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
                    
                    Spacer().frame(height: 40)
             
                }
                .onTapGesture { selectedTab = Tab.calendar }
                
                Spacer()
                
            }
            //     .frame(maxWidth: .infinity, maxHeight: .infinity)
            //.background(Color.greenBrandColor)
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
                    trophyType: trophy.type,
                    earnedDate: trophy.earnedDate
                )
            }
            
        }.onAppear {
            showWorkoutView = false
            // Refresh SimpleWeekRow when view appears
            weekViewRefreshTrigger = UUID()
            // Update workout count when view appears
            animateRotation()
            workoutCount = PersistenceController.shared.countWorkouts()
        }.onReceive(NotificationCenter.default.publisher(for: .workoutAdded)) { _ in
            // Update workout count when notification is received
            animateRotation()  // Trigger animation when workout is added
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                workoutCount = PersistenceController.shared.countWorkouts()
            }
        }.onReceive(NotificationCenter.default.publisher(for: .achievementsChanged)) { _ in
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
            rotationX = .pi * 2  // Two full rotations
            rotationY = .pi * 2  // Two full rotations
        }
    }
    
    /// Note used but just in case
    private func triggerHeartbeat() {
        // Create a camera animation
        if let sceneView = getSceneView() {
            let intensity = 5.0
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
