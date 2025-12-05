//
//  HomeView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI
import SceneKit
import WidgetKit

struct HomeView: View {
    @Binding var selectedTab: Tab
    @Bindable private var appState = AppState.shared
    
    
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
                    
                    Spacer().frame(height: 200)
                }
                Spacer()
                
            }
            
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
        //  .frame(height:.infinity)
        .ignoresSafeArea(edges:.bottom)
        .onAppear {
            showWorkoutView = false
            // Refresh SimpleWeekRow when view appears
            weekViewRefreshTrigger = UUID()
            // Update workout count when view appears
            animateRotation()
            workoutCount = PersistenceController.shared.countWorkouts()
            // Refresh widgets to sync with app
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onReceive(NotificationCenter.default.publisher(for: .workoutAdded)) { _ in
            // Update workout count when notification is received
            animateRotation()  // Trigger animation when workout is added
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                workoutCount = PersistenceController.shared.countWorkouts()
                // Refresh widgets when workouts change
                WidgetCenter.shared.reloadAllTimelines()
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
        .tabViewStyle(.page(indexDisplayv))
        .frame(height: 120)
        .onChange(of: currentIndex) {
            if currentIndex == 0 || currentIndex == 2 {
                weekOffset += (currentIndex == 0) ? -1 : 1
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
        return calendar.date(byAdding: .day, value: (weekOffset + offset) * 7, to: calendar.startOfWeek(for: selectedDate)) ?? selectedDate
    }
    
}

private struct WeekView: View {
    let baseDate: Date
    @Binding var selectedDate: Date
    let onDateSelected: (Date) -> Void
    
    private let weekdays = ["M","T","W","T","F","S","S"]
    
    /// Returns an array of sequential workout day pairs (indices) within the current week
    private func getSequentialWorkoutPairs() -> [(Int, Int)] {
        var pairs: [(Int, Int)] = []
        let cal = Calendar.current
        let weekStart = cal.startOfWeek(for: baseDate)
        
        // Check consecutive days within the week
        for i in 0..<6 {
            let date1 = cal.date(byAdding: .day, value: i, to: weekStart)!
            let date2 = cal.date(byAdding: .day, value: i+1, to: weekStart)!
            
            if !getWorkouts(for: date1).isEmpty && !getWorkouts(for: date2).isEmpty {
                pairs.append((i, i+1))
            }
        }
        return pairs
    }
    
    var body: some View {
        let cal = Calendar.current
        let start = cal.startOfWeek(for: baseDate)
        
        ZStack {
            // Base white line using Path - now extends to outer edges
            Path { path in
                path.move(to: CGPoint(x: 34, y: 65.5))
                path.addLine(to: CGPoint(x: 328, y: 65.5))
            }
            .stroke(Color.white, lineWidth: 1)
            
            // Colored segments for sequential workouts
            ForEach(getSequentialWorkoutPairs(), id: \.0) { pair in
                let segmentWidth = 294 / 6.0 // Total width divided by number of days
                let startX = 34 + (CGFloat(pair.0) * segmentWidth)
                let endX = startX + segmentWidth
                
                Path { path in
                    path.move(to: CGPoint(x: startX, y: 65.5))
                    path.addLine(to: CGPoint(x: endX, y: 65.5))
                }
                .stroke(Color.limeAccentColor, lineWidth: 5)
            }
            
            HStack {
                ForEach(0..<7, id: \.self) { i in
                    let day = cal.date(byAdding: .day, value: i, to: start)!
                    let workouts = getWorkouts(for: day)
                    
                    VStack(spacing: 4) {
                        // Top label: "M, T, W, T, F, S, S"
                        Text(weekdays[i])
                            .font(.custom("Futura Bold", fixedSize: 15))
                            .foregroundColor(cal.isDateInToday(day) ? .limeAccentColor : .white)
                            .padding(.bottom, 4)
                        
                        // Main day circle (workout icon or day number)
                        ZStack(alignment: .center) {
                            if cal.isDate(day, inSameDayAs: selectedDate) {
                                if !workouts.isEmpty {
                                    // First workout icon in white circle
                                    let firstWorkout = workouts[0]
                                    Image(systemName: WorkoutConfiguration.shared.getIcon(for: firstWorkout.workoutType))
                                        .foregroundColor(.black)
                                        .frame(width: 31, height: 31)
                                        .background(Circle().foregroundColor(.white))
                                } else {
                                    Text("\(cal.component(.day, from: day))")
                                        .foregroundColor(.black)
                                        .frame(width: 31, height: 31)
                                        .background(Circle().foregroundColor(.white))
                                }
                            } else if !workouts.isEmpty {
                                // First workout icon in green circle
                                let firstWorkout = workouts[0]
                                Image(systemName: WorkoutConfiguration.shared.getIcon(for: firstWorkout.workoutType))
                                    .foregroundColor(.black)
                                    .frame(width: 31, height: 31)
                                    .background(Circle().foregroundColor(.limeAccentColor))
                            } else if cal.isDateInToday(day) {
                                Text("\(cal.component(.day, from: day))")
                                    .foregroundColor(.black)
                                    .frame(width: 31, height: 31)
                                    .background(Circle().foregroundColor(.limeAccentColor))
                            } else {
                                Text("\(cal.component(.day, from: day))")
                                    .foregroundColor(.white)
                                    .frame(width: 31, height: 31)
                                    .background(Circle()
                                        .fill(Color.black.opacity(0.9))
                                        .stroke(Color.white, lineWidth: 1)
                                        .frame(width: 31, height: 31)
                                    )
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                        
                        // Additional workouts indicator
                        if workouts.count > 1 {
                            Text("+\(workouts.count - 1)")
                                .font(.custom("Futura", fixedSize: 10))
                                .foregroundColor(.white)
                                .padding(.top, 2)
                        } else {
                            // Empty spacer to maintain consistent height
                            Spacer().frame(height: 12)
                        }
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
    }
    
    // Update the hasWorkout helper to return an array of workouts instead of a boolean
    private func getWorkouts(for date: Date) -> [Workouts] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timestamp == %@", Calendar.current.startOfDay(for: date) as NSDate)
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching workouts for date \(date): \(error.localizedDescription)")
            return []
        }
    }
    
    // Keep this for backward compatibility with existing code
    private func hasWorkout(on date: Date) -> Bool {
        return !getWorkouts(for: date).isEmpty
    }
}

#Preview ("Full Content View") {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environment(\.dynamicTypeSize, .medium)
        .preferredColorScheme(.light)
}

#Preview ("Just Home") {
    HomeView(selectedTab: .constant(.home))
        .environment(\.dynamicTypeSize, .medium)
        .preferredColorScheme(.light)
}
