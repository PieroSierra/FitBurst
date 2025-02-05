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

struct Provider: TimelineProvider {
    let persistence = SharedPersistence.shared
    private let groupDefaults = UserDefaults(suiteName: "group.com.pieroco.FitBurst")!
    
    init() {
        print("Widget Provider - Initialized")
    }
    
    private func getCurrentBackground() -> String {
        let background = groupDefaults.string(forKey: "widget.currentBackground") ?? "BlackTiles"
        print("Widget Provider - Reading background: \(background)")
        
        // Test if image exists in widget bundle
        if let image = UIImage(named: background) {
            print("Widget Provider - Successfully loaded image for \(background) - size: \(image.size)")
        } else {
            print("Widget Provider - ⚠️ Failed to load image for \(background)")
            
            // Try loading from main bundle
            if Bundle.main.path(forResource: background, ofType: nil) != nil {
                print("Widget Provider - Image exists in main bundle but not widget bundle!")
            }
        }
        
        return background
    }
    
    func placeholder(in context: Context) -> WeekEntry {
        print("Widget Provider - Placeholder called")
        return WeekEntry(
            date: Date(),
            workouts: [:],
            backgroundAssetName: getCurrentBackground()
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeekEntry) -> ()) {
        print("Widget Provider - GetSnapshot called")
        let workouts = persistence.getWorkoutsForWeek(startingFrom: Date())
        let entry = WeekEntry(
            date: Date(),
            workouts: workouts,
            backgroundAssetName: getCurrentBackground()
        )
        print("Widget Provider - Snapshot workouts: \(workouts.count)")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeekEntry>) -> ()) {
        print("Widget Provider - GetTimeline called")
        let currentDate = Date()
        let workouts = persistence.getWorkoutsForWeek(startingFrom: currentDate)
        
        let entry = WeekEntry(
            date: currentDate,
            workouts: workouts,
            backgroundAssetName: getCurrentBackground()
        )
        
        // Update very frequently for testing
        let nextUpdate = Date().addingTimeInterval(60) // Every minute
        print("Widget Provider - Next update in 1 minute")
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    //    func relevances() async -> WidgetRelevances<Void> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
}

struct WeekEntry: TimelineEntry {
    let date: Date
    let workouts: [Date: Bool]
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
    
    var smallCalendarView: some View {
        ZStack {
            Circle()
                .stroke(Color.white, lineWidth: 1)
                .frame(width: 108, height: 108)
            
            ForEach(0..<7) { index in
                if let date = Calendar.current.date(byAdding: .day, value: index,
                                                    to: Calendar.current.startOfDay(for: entry.date)),
                   let hasWorkout = entry.workouts[date] {
                    
                    // Day letter
                    Text(weekdays[index])
                        .font(.custom("Futura Bold", fixedSize: 12))
                        .foregroundColor(Calendar.current.isDateInToday(date) ? .limeAccentColor : .white)
                        .offset(getDayPosition(index: index))
                    
                    // Workout indicator
                    Group {
                        if hasWorkout {
                            Image(systemName: "checkmark")
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
                                .background(                            Circle()
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
        VStack(spacing: 4) {
            Text("FitBurst")
                .font(.custom("Futura Bold", fixedSize: 15))
                .foregroundColor(.white)
            
            ZStack {
                Rectangle()
                    .stroke(Color.white, lineWidth: 1)
                    .frame(width: 270, height: 0.5)
                    .offset(y:14)
                
                HStack {
                    ForEach(0..<7) { index in
                        if let date = Calendar.current.date(byAdding: .day, value: index,
                                                            to: Calendar.current.startOfDay(for: entry.date)),
                           let hasWorkout = entry.workouts[date] {
                            
                            VStack(spacing: 4) {
                                // Top label: "M, T, W, T, F, S, S"
                                Text(weekdays[index])
                                    .font(.custom("Futura Bold", fixedSize: 15))
                                    .foregroundColor(Calendar.current.isDateInToday(date) ? .limeAccentColor : .white)
                                    .padding(.bottom, 4)
                                
                                // Bottom: either checkmark or day number
                                
                                Group {
                                    if hasWorkout {
                                        Image(systemName: "checkmark")
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

struct FitBurst_Widget: Widget {
    let kind: String = "FitBurst_Widget"
    
    init() {
        print("Widget - Initialized")
    }
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                FitBurst_WidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        ZStack {
                            Group {
                                if let image = UIImage(named: entry.backgroundAssetName)?
                                    .preparingThumbnail(of: CGSize(width: 800, height: 800)) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else {
                                    Image("BlackTiles")  // Fallback
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                }
                            }
                            Color.black.opacity(0.4)
                        }
                    }
            } else {
                FitBurst_WidgetEntryView(entry: entry)
                    .padding(0)
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
        var sampleWorkouts: [Date: Bool] = [:]
        
        // Ensure we have all 7 days populated
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: today)) {
                sampleWorkouts[date] = (dayOffset+1) % 5 == 0
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
