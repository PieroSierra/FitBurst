//
//  FitBurst_Widget.swift
//  FitBurst Widget
//
//  Created by Piero Sierra on 01/02/2025.
//

import WidgetKit
import SwiftUI
import Foundation
import Darwin
import Intents

struct Provider: IntentTimelineProvider {
    // Specify the timeline entry type
    typealias Entry = WeekEntry
    // Specify the intent type
    typealias Intent = ConfigureWidgetBackgroundIntent
    
    let persistence = SharedPersistence.shared
    private let groupDefaults = UserDefaults(suiteName: "group.com.pieroco.FitBurst")!
    
    init() {
        // print("Widget Provider - Initialized")
        // Register to get notified when workouts change
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// Returns the background asset name by checking the widget configuration.
    /// If the background value is not 0 ("Same as app"), then the corresponding asset name is returned.
    private func getCurrentBackground(configuration: ConfigureWidgetBackgroundIntent) -> String {
        // Debug print
        // print("Widget background requested: \(configuration.background)")
        
        let assetName = switch configuration.background {
        case .unknown, .appSync:   // Both unknown and appSync will sync with the app
            groupDefaults.string(forKey: "widget.currentBackground") ?? "BlackTiles"
        case .blackTiles:
            "BlackTiles"
        case .darkForest:
            "DarkForest"
        case .runningTracks:
            "RunningTracks"
        case .dunes:
            "Dunes"
        case .gradientWaves:
            "GradientWaves"
        case .oceanBg:
            "Ocean"
        case .blackAndWhite:
            "BlackAndWhite"
        case .frond:
            "Frond"
        case .skylights:
            "Skylights"
        case .pinkPalm:
            "PinkPalm"
        case .elCapitan:
            "ElCapitan"
        case .rainier:
            "Rainier"
        case .fuji:
            "Fuji1"
        case .matterhorn:
            "Matterhorn"
        case .snowcap:
            "Snowcap"
        case .lion:
            "Lion"
        case .kettleBell:
            "KettleBell"
        case .darkCrystals:
            "DarkCrystals"
        @unknown default:
            "BlackTiles"
        }
        
        // Verify the asset exists and can be loaded
        if let _ = UIImage(named: assetName)?.preparingThumbnail(of: CGSize(width: 800, height: 800)) {
            //print("Successfully loaded and resized: \(assetName)")
            return assetName
        } else {
            print("Failed to load/resize asset: \(assetName), falling back to BlackTiles")
            return "BlackTiles"
        }
    }
    
    func placeholder(in context: Context) -> WeekEntry {
        //print("Widget Provider - Placeholder called")
        return WeekEntry(
            date: Date(),
            workouts: [:],
            backgroundAssetName: groupDefaults.string(forKey: "widget.currentBackground") ?? "BlackTiles"
        )
    }
    
    func getSnapshot(for configuration: ConfigureWidgetBackgroundIntent, in context: Context, completion: @escaping (WeekEntry) -> ()) {
        //print("Widget Provider - GetSnapshot called")
        let workouts = persistence.getWorkoutsForWeek(startingFrom: Date())
        let backgroundAssetName = getCurrentBackground(configuration: configuration)
        let entry = WeekEntry(
            date: Date(),
            workouts: workouts,
            backgroundAssetName: backgroundAssetName
        )
        //print("Widget Provider - Snapshot workouts: \(workouts.count)")
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigureWidgetBackgroundIntent, in context: Context, completion: @escaping (Timeline<WeekEntry>) -> ()) {
        
        // Ensure we're using the current date
        let currentDate = Date()
        
        // Force refresh from persistent store before fetching data
        try? persistence.container.viewContext.refreshAllObjects()
        
        // Get workouts for the current week
        let workouts = persistence.getWorkoutsForWeek(startingFrom: currentDate)
        
        // Count days with workouts
        let daysWithWorkouts = workouts.filter { !$0.value.isEmpty }.count
        
        // Log dates with workouts
        let workoutDates = workouts.filter { !$0.value.isEmpty }.keys.sorted()
        
        let backgroundAssetName = getCurrentBackground(configuration: configuration)
        
        let entry = WeekEntry(
            date: currentDate,
            workouts: workouts,
            backgroundAssetName: backgroundAssetName
        )
        
        // Update more frequently to ensure fresh data
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate) ?? Date().addingTimeInterval(900)
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct WeekEntry: TimelineEntry {
    let date: Date
    let workouts: [Date: [Workouts]]
    let backgroundAssetName: String  // Simplified to just store the assetName
}

struct FitBurst_WidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    private let weekdays = ["M","T","W","T","F","S","S"]
    
    var body: some View {
        switch family {
        case .systemSmall:
            smallCalendarView
        case .systemMedium:
            mediumCalendarView
        default:
            smallCalendarView
        }
    }
    
    /// Returns an array of sequential workout day pairs (indices)
    private func getSequentialWorkoutPairs() -> [(Int, Int)] {
        var pairs: [(Int, Int)] = []
        let weekStart = Calendar.current.startOfWeek(for: entry.date)
        
        // Check consecutive days
        for i in 0..<6 {
            guard let date1 = Calendar.current.date(byAdding: .day, value: i, to: weekStart),
                  let date2 = Calendar.current.date(byAdding: .day, value: i+1, to: weekStart),
                  let workouts1 = entry.workouts[date1],
                  let workouts2 = entry.workouts[date2] else {
                continue
            }
            
            if !workouts1.isEmpty && !workouts2.isEmpty {
                pairs.append((i, i+1))
            }
        }
        return pairs
    }
    
    // Helper to get workout icon for a date
    private func getWorkoutIcon(for date: Date) -> String {
        guard let workouts = entry.workouts[Calendar.current.startOfDay(for: date)], !workouts.isEmpty else {
            print("Widget - No workouts found for date: \(date)")
            return "questionmark.circle" // Fallback icon
        }
        
        // Debug: Print workout type and icon
        let workout = workouts[0]
        let workoutType = workout.workoutType
        let icon = SharedPersistence.shared.getWorkoutIcon(for: workoutType)
        
        // Return the icon for the first workout using SharedPersistence
        return icon
    }
    
    var smallCalendarView: some View {
        GeometryReader { geometry in
            ZStack {
                // Base white arc
                Path { path in
                    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    let radius: CGFloat = min(geometry.size.width, geometry.size.height) / 2.4
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(230),
                        clockwise: false
                    )
                }
                .stroke(Color.white, lineWidth: 1)
                
                // Colored segments for sequential workouts
                ForEach(getSequentialWorkoutPairs(), id: \.0) { pair in
                    Path { path in
                        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        let radius: CGFloat = min(geometry.size.width, geometry.size.height) / 2.4
                        
                        let degreesPerDay = 360.0 / 7.0
                        let startAngle = Angle(degrees: -90 + (Double(pair.0) * degreesPerDay))
                        let endAngle = Angle(degrees: -90 + (Double(pair.1) * degreesPerDay))
                        
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: false
                        )
                    }
                    .stroke(Color.limeAccentColor, lineWidth: 4)
                }
                
                ForEach(0..<7) { index in
                    let weekStart = Calendar.current.startOfWeek(for: entry.date)
                    if let date = Calendar.current.date(byAdding: .day, value: index, to: weekStart),
                       let workouts = entry.workouts[date] {
                        
                        // Day letter
                        Text(weekdays[index])
                            .font(.custom("Futura Bold", fixedSize: 12))
                            .foregroundColor(Calendar.current.isDateInToday(date) ? .limeAccentColor : .white)
                            .offset(getDayPosition(index: index))
                        
                        // Workout indicator
                        Group {
                            if !workouts.isEmpty {
                                // Show the first workout's icon
                                Image(systemName: getWorkoutIcon(for: date))
                                    .foregroundColor(.black)
                                    .frame(width: 23, height: 23)
                                    .background(Circle().foregroundColor(.limeAccentColor))
                            } else if Calendar.current.isDateInToday(date) {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .foregroundColor(.black)
                                    .frame(width: 23, height: 23)
                                    .background(Circle().foregroundColor(.white))
                            } else {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .foregroundColor(.white)
                                    .frame(width: 23, height: 23)
                                    .background(Circle()
                                        .fill(Color.black.opacity(0.9))
                                        .stroke(Color.white, lineWidth: 1)
                                        .frame(width: 23, height: 23)
                                    )
                            }
                        }
                        .font(.custom("Futura Bold", fixedSize: 12))
                        .offset(getWorkoutPosition(index: index))
                    }
                }
                
                Image("LogoSqClear100")
                    .resizable()
                    .frame(width: 25, height: 25)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func getDayPosition(index: Int) -> CGSize {
        // Inner circle - radius 30
        let radius: CGFloat = 31
        let angleInDegrees = -90 + (Double(index) * (360.0 / 7.0)) // Start at -90° (top) and divide circle by 7
        let angleInRadians = angleInDegrees * .pi / 180
        
        return CGSize(
            width: radius * Darwin.cos(angleInRadians),
            height: radius * Darwin.sin(angleInRadians)
        )
    }
    
    private func getWorkoutPosition(index: Int) -> CGSize {
        // Outer circle - radius 50
        let radius: CGFloat = 54
        let angleInDegrees = -90 + (Double(index) * (360.0 / 7.0)) // Start at -90° (top) and divide circle by 7
        let angleInRadians = angleInDegrees * .pi / 180
        
        return CGSize(
            width: radius * Darwin.cos(angleInRadians),
            height: radius * Darwin.sin(angleInRadians)
        )
    }
    
    var mediumCalendarView: some View {
        GeometryReader { geometry in
            VStack(spacing: 4) {
                Text("FitBurst")
                    .font(.custom("Futura Bold", fixedSize: 15))
                    .foregroundColor(.white)
                
                ZStack {
                    // Base white line
                    Path { path in
                        let yPosition = geometry.size.height * 0.45 // Position at 51% of height
                        path.move(to: CGPoint(x: 20, y: yPosition))
                        path.addLine(to: CGPoint(x: 274, y: yPosition))
                    }
                    .stroke(Color.white, lineWidth: 1)
                    
                    // Colored segments for sequential workouts
                    ForEach(getSequentialWorkoutPairs(), id: \.0) { pair in
                        let yPosition = geometry.size.height * 0.45 // Position at 51% of height
                        let segmentWidth = 254 / 6.0 // Total width divided by number of days
                        let startX = 20 + (CGFloat(pair.0) * segmentWidth)
                        let endX = startX + segmentWidth
                        
                        Path { path in
                            path.move(to: CGPoint(x: startX, y: yPosition))
                            path.addLine(to: CGPoint(x: endX, y: yPosition))
                        }
                        .stroke(Color.limeAccentColor, lineWidth: 4)
                    }
                    
                    HStack {
                        ForEach(0..<7) { index in
                            let weekStart = Calendar.current.startOfWeek(for: entry.date)
                            if let date = Calendar.current.date(byAdding: .day, value: index, to: weekStart),
                               let workouts = entry.workouts[date] {
                                
                                VStack(spacing: 4) {
                                    // Top label: "M, T, W, T, F, S, S"
                                    Text(weekdays[index])
                                        .font(.custom("Futura Bold", fixedSize: 15))
                                        .foregroundColor(Calendar.current.isDateInToday(date) ? .limeAccentColor : .white)
                                        .padding(.bottom, 4)
                                    
                                    // Main day circle (workout icon or day number)
                                    ZStack(alignment: .center) {
                                        if !workouts.isEmpty {
                                            // First workout icon in green circle
                                            Image(systemName: getWorkoutIcon(for: date))
                                                .foregroundColor(.black)
                                                .frame(width: 31, height: 31)
                                                .background(Circle().foregroundColor(.limeAccentColor))
                                        } else if Calendar.current.isDateInToday(date) {
                                            Text("\(Calendar.current.component(.day, from: date))")
                                                .foregroundColor(.black)
                                                .frame(width: 31, height: 31)
                                                .background(Circle().foregroundColor(.white))
                                        } else {
                                            Text("\(Calendar.current.component(.day, from: date))")
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
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct FitBurst_Widget: Widget {
    let kind: String = "FitBurst_Widget"
    
    init() {
        print("Widget - Initialized")
    }
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigureWidgetBackgroundIntent.self, provider: Provider()) { entry in
            FitBurst_WidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    ZStack {
                        if let image = UIImage(named: entry.backgroundAssetName)?
                            .preparingThumbnail(of: CGSize(width: 800, height: 800)) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            if let fallbackImage = UIImage(named: "BlackTiles")?
                                .preparingThumbnail(of: CGSize(width: 800, height: 800)) {
                                Image(uiImage: fallbackImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            }
                        }
                        Color.black.opacity(0.2)
                    }
                }
        }
        .configurationDisplayName("FitBurst Calendar")
        .description("See your workout calendar at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// Preview helper
extension WeekEntry {
    static var sampleEntry: WeekEntry {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.startOfWeek(for: today)
        var sampleWorkouts: [Date: [Workouts]] = [:]
        
        // Create mock Workouts objects with different types
        let context = SharedPersistence.shared.container.viewContext
        
        // Create different workout types for different days
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                if dayOffset >= 2 {
                    // Create a workout with a type based on the day
                    let mockWorkout = Workouts(context: context)
                    mockWorkout.workoutID = UUID()
                    mockWorkout.timestamp = date
                    
                    // Assign different workout types based on the day
                    // This ensures we see different icons in the preview
                    mockWorkout.workoutType = Int32(dayOffset % 6) // Use modulo to cycle through workout types
                    
                    if dayOffset == 3 {
                        // Day with multiple workouts
                        let secondWorkout = Workouts(context: context)
                        secondWorkout.workoutID = UUID()
                        secondWorkout.timestamp = date
                        secondWorkout.workoutType = (Int32(dayOffset % 6) + 1) % 6 // Different type from the first workout
                        
                        sampleWorkouts[date] = [mockWorkout, secondWorkout]
                    } else {
                        // Day with single workout
                        sampleWorkouts[date] = [mockWorkout]
                    }
                } else {
                    // Day with no workouts
                    sampleWorkouts[date] = []
                }
            }
        }
        
        return WeekEntry(
            date: today,
            workouts: sampleWorkouts,
            backgroundAssetName: "BlackTiles"  // Default preview background
        )
    }
}

#Preview("Small Widget", as: .systemSmall) {
    FitBurst_Widget()
} timeline: {
    WeekEntry.sampleEntry
}

#Preview("Medium Widget", as: .systemMedium) {
    FitBurst_Widget()
} timeline: {
    WeekEntry.sampleEntry
}
