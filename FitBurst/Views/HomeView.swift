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
                        .background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color.black.opacity(0.4)))
                        .padding(.horizontal)
                    
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

import CoreData
struct SimpleWeekRow: View {
    @Binding var selectedDate: Date
    // Add state for tracking which week is displayed
    @State private var weekOffset: Int = 0
    @State private var currentIndex: Int = 1  // Start in middle
    
    private let weekdays = ["M","T","W","T","F","S","S"]
    
    var body: some View {
        TabView(selection: $currentIndex) {
            WeekView(baseDate: offsetDate(-1), 
                    selectedDate: $selectedDate,
                    onDateSelected: handleDateSelection)
                .tag(0)
            WeekView(baseDate: offsetDate(0), 
                    selectedDate: $selectedDate,
                    onDateSelected: handleDateSelection)
                .tag(1)
            WeekView(baseDate: offsetDate(1), 
                    selectedDate: $selectedDate,
                    onDateSelected: handleDateSelection)
                .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 100)
        .onChange(of: currentIndex) { newIndex in
            if newIndex == 0 || newIndex == 2 {
                weekOffset += (newIndex == 0) ? -1 : 1
                currentIndex = 1  // Reset immediately
            }
        }
    }
    
    // New function to handle date selection
    private func handleDateSelection(_ date: Date) {
        withAnimation(.spring(response: 0.3)) {
            selectedDate = date
            // Reset week offset when selecting a date
            weekOffset = 0
            currentIndex = 1
        }
    }
    
    // Helper to calculate date for each week view
    private func offsetDate(_ offset: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: (weekOffset + offset) * 7, to: startOfWeek(for: selectedDate)) ?? selectedDate
    }
    
    // StartOfWeek helper here
    private func startOfWeek(for date: Date) -> Date {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday
        let weekday = cal.component(.weekday, from: date)
        let daysFromMonday = (weekday - cal.firstWeekday + 7) % 7
        return cal.date(byAdding: .day, value: -daysFromMonday, to: date) ?? date
    }
}

private struct WeekView: View {
    let baseDate: Date
    @Binding var selectedDate: Date
    let onDateSelected: (Date) -> Void
    
    private let weekdays = ["M","T","W","T","F","S","S"]
    
    var body: some View {
        // Use baseDate instead of selectedDate for calculating the week's dates
        let cal = Calendar.current
        let start = baseDate 
        
        HStack {
            ForEach(0..<7, id: \.self) { i in
                let day = cal.date(byAdding: .day, value: i, to: start)!
                
                VStack(spacing: 4) {
                    // Top label: "M, T, W, T, F, S, S"
                    Text(weekdays[i])
                        .font(.custom("Futura Bold", fixedSize: 15))
                        .foregroundColor(cal.isDateInToday(day) ? .limeAccentColor : .white)
                        .padding(.bottom, 4)
                    
                    // Bottom: either checkmark or day number
                    Group {
                        if cal.isDate(day, inSameDayAs: selectedDate) {
                            if hasWorkout(on: day) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.black)
                                    .frame(width: 31, height:31)
                                    .background(Circle().foregroundColor(.white))
                            } else {
                                Text("\(cal.component(.day, from: day))")
                                    .foregroundColor(.black)
                                    .frame(width: 31, height:31)
                                    .background(Circle().foregroundColor(.white))
                            }
                        } else if hasWorkout(on: day) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.black)
                                .frame(width: 31, height:31)
                                .background(Circle().foregroundColor(.limeAccentColor))
                        } else if cal.isDateInToday(day) {
                            Text("\(cal.component(.day, from: day))")
                                .foregroundColor(.black)
                                .frame(width: 31, height:31)
                                .background(Circle().foregroundColor(.limeAccentColor))
                        } else {
                            Text("\(cal.component(.day, from: day))")
                                .foregroundColor(.white)
                                .frame(width: 31, height:31)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                .font(.custom("Futura Bold", fixedSize: 15))
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    onDateSelected(day)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // Include your existing hasWorkout helper here
    private func hasWorkout(on date: Date) -> Bool {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timestamp == %@", Calendar.current.startOfDay(for: date) as NSDate)
        
        do {
            let count = try context.count(for: fetchRequest)
            if count > 0 {
                return true
            }
            else {
                return false
            }
        } catch {
            print("Error fetching workouts for date \(date): \(error.localizedDescription)")
        }
        return false
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
