//
//  HomeView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Tab
    /// View controls
    @State private var showWorkoutView: Bool = false
    @State private var showTrophyDisplayView: Bool = false
    @State private var selectedTrophy: TrophyType = .newbie
    
    /// track the selected date
    @State var selectedDate: Date = Date()
    
    /// Add refresh triggers
    @State private var calendarRefreshTrigger = UUID()
    @State private var weekViewRefreshTrigger = UUID()
    
    /// maintain total workout count
    @State private var workoutCount: Int = 0
    
    /// For 3d Text
    @State private var rotationX: CGFloat = 0
    @State private var rotationY: CGFloat = 0
    @State private var rotationZ: CGFloat = 0
    
    var body: some View {
        ZStack {
            /// Background gradient
            Image("GradientWaves").resizable().edgesIgnoringSafeArea(.all)
            
            /// Main scrollview
            ScrollView {
                Text("FitBurst")
                    .font(.custom("Futura Bold", size: 40))
                    .foregroundColor(.white)
                    .padding(.bottom, 0)
            
                VStack (alignment: .center) {
                    ThreeDTextView(text: "\(workoutCount)",
                                   extrusionDepth: 4,
                                   fontFace: "Futura Bold",
                                   fontSize: 20,
                                   fontColor: .limeAccentColor,
                                   rotationX: rotationX,
                                   rotationY: rotationY,
                                   rotationZ: rotationZ,
                                   animationDuration: 0.5)
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    
                    Text (workoutCount == 1 ? "WORKOUT" : "WORKOUTS")
                        .font(.custom("Futura Bold", size: 16))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .onTapGesture {
                            animateRotation()
                        }
                    
                    Spacer().frame(height: 30)
                    
                    SimpleWeekRow(selectedDate: $selectedDate)
                        .id(weekViewRefreshTrigger)  // Force refresh when trigger changes
                    
                    Spacer().frame(height: 30)
                    
                    /// Record Workout
                    Button (action: {
                        showWorkoutView.toggle()
                    }) {
                        HStack {
                            Image(systemName: "dumbbell.fill").imageScale(.large)
                            Text("Record Workout")
                        }
                    }
                    .buttonStyle(GrowingButtonStyle())
                    
                    Spacer().frame(height: 40)
                    
                    TrophyBox(
                        scrollHorizontally: true,
                        showTrophyDisplayView: $showTrophyDisplayView,
                        selectedTrophy: $selectedTrophy
                    )
                    .frame(height: 170)
                    .onTapGesture { selectedTab = Tab.trophies }
                }
                .onTapGesture { selectedTab = Tab.calendar }
                
                Spacer().frame(height: 20)
                
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
            
            if showTrophyDisplayView {
                SingleTrophyView(
                    showTrophyDisplayView: $showTrophyDisplayView,
                    trophyType: selectedTrophy
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

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

#Preview {
    HomeView(selectedTab: .constant(.home))
}
