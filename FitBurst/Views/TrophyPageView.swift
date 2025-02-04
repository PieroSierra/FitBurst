//  TrophyView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI
import Model3DView
import CoreData

struct TrophyWithDate {
    let type: TrophyType
    let earnedDate: Date
    let displayNameOverride: String?
    
    init(type: TrophyType, earnedDate: Date, displayNameOverride: String? = nil) {
        self.type = type
        self.earnedDate = earnedDate
        self.displayNameOverride = displayNameOverride
    }
    
    var displayName: String {
        return displayNameOverride ?? type.displayName
    }
}

struct TrophyPageView: View {
    let showDummyData: Bool
    @State private var showTrophyDisplayView: Bool = false
    @State private var selectedTrophy: TrophyWithDate? = nil
    private let appState = AppState.shared  // Changed to private let since we only read from it
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                Text("Trophies")
                    .font(.custom("Futura Bold", fixedSize: 40))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                ScrollView {
                    TrophyBox(
                        scrollHorizontally: false,
                        showTrophyDisplayView: $showTrophyDisplayView,
                        selectedTrophy: $selectedTrophy,
                        showDummyData: showDummyData
                    )
                }
            }
            
            if showTrophyDisplayView, let trophy = selectedTrophy {
                SingleTrophyView(
                    showTrophyDisplayView: $showTrophyDisplayView,
                    trophy: trophy
                )
            }
        }
    }
}

struct TrophyBox: View {
    var scrollHorizontally: Bool
    @State private var appearingItems: Set<Int> = []
    @State private var scale: CGFloat = 0.6
    @Binding var showTrophyDisplayView: Bool
    @Binding var selectedTrophy: TrophyWithDate?
    let showDummyData: Bool
    
    @State private var trophies: [TrophyWithDate] = []
    
    /// Observe CoreData changes
    @Environment(\.managedObjectContext) private var viewContext
    
    private func loadTrophies() {
        if showDummyData {
            // Generate random trophies with dates for dummy data
            trophies = (0..<24).map { _ in
                TrophyWithDate(
                    type: TrophyType.allCases.randomElement()!,
                    earnedDate: Date().addingTimeInterval(-Double.random(in: 0...(86400 * 30)))
                )
            }
        } else {
            // Load real trophies from CoreData
            let context = PersistenceController.shared.container.viewContext
            let fetchRequest: NSFetchRequest<Achievements> = Achievements.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Achievements.timestamp, ascending: false)]
            
            do {
                let achievements = try context.fetch(fetchRequest)
                
                // Group achievements by type
                var groupedAchievements: [TrophyType: [Achievements]] = [:]
                for achievement in achievements {
                    let type = TrophyType.allCases[Int(achievement.achievementType)]
                    groupedAchievements[type, default: []].append(achievement)
                }
                
                // Process each group
                trophies = groupedAchievements.compactMap { (type, typeAchievements) in
                    // Get the most recent date for this achievement type
                    guard let mostRecent = typeAchievements.first?.timestamp else { return nil }
                    
                    // For repeatable achievements, include count if more than 1
                    let repeatableTypes: Set<TrophyType> = [.twoInADay, .threeInADay, .lotsInADay]
                    if repeatableTypes.contains(type) && typeAchievements.count > 1 {
                        // Create a custom trophy with count in name
                        return TrophyWithDate(
                            type: type,
                            earnedDate: mostRecent,
                            displayNameOverride: "\(type.displayName) (\(typeAchievements.count))"
                        )
                    } else {
                        // Return regular trophy
                        return TrophyWithDate(
                            type: type,
                            earnedDate: mostRecent
                        )
                    }
                }
                
                // Sort by most recent first
                trophies.sort { $0.earnedDate > $1.earnedDate }
                
            } catch {
                print("Failed to fetch achievements: \(error)")
                trophies = []
            }
        }
    }
    
    let columns = [GridItem(.adaptive(minimum: 70))]
    let rows = [GridItem(.adaptive(minimum: 90))]
    let numberOfTrophies = 24
    
    private func trophyIcon(for trophy: TrophyWithDate, at index: Int) -> some View {
        TrophyIconView(
            showTrophyDisplayView: $showTrophyDisplayView,
            selectedTrophy: $selectedTrophy,
            trophy: trophy
        )
        .scaleEffect(appearingItems.contains(index) ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appearingItems.contains(index))
    }
    
    var body: some View {
        Group {
            if trophies.isEmpty {
                Text ("Your trophies will appear here")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 180)
            }
            else if scrollHorizontally {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: rows) {
                        ForEach(Array(trophies.enumerated()), id: \.offset) { index, trophy in
                            trophyIcon(for: trophy, at: index)
                                .scaleEffect(appearingItems.contains(index) ? 1 : 0)
                                .animation(
                                    .spring(response: 0.25, dampingFraction: 0.6)
                                    .delay(Double(index) * 0.05),
                                    value: appearingItems.contains(index)
                                )
                        }
                    }
                    .padding(20)
                    .padding(.top, 0)
                    .scaleEffect(scale)
                }
            } else {
                // For vertical, just the grid without ScrollView
                LazyVGrid(columns: columns) {
                    ForEach(Array(trophies.enumerated()), id: \.offset) { index, trophy in
                        trophyIcon(for: trophy, at: index)
                            .scaleEffect(appearingItems.contains(index) ? 1 : 0)
                            .animation(
                                .spring(response: 0.25, dampingFraction: 0.6)
                                .delay(Double(index) * 0.05),
                                value: appearingItems.contains(index)
                            )
                    }
                }
                .padding(20)
                .padding(.top, 0)
                .scaleEffect(scale)
            }
        }
        .onAppear {
            loadTrophies()
            
            // Animate the box itself (also faster)
            scale = 0.6
            withAnimation(.bouncy.speed(2)) { scale = 1.15 }
            withAnimation(.bouncy.speed(2).delay(0.125)) { scale = 1 }
            
            // Reset appearing items
            appearingItems.removeAll()
            
            // Animate items appearing one by one
            for index in 0..<trophies.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                    appearingItems.insert(index)
                }
            }
        }
        /// Listen for achievement changes
        .onReceive(NotificationCenter.default.publisher(for: .workoutAdded)) { _ in
            loadTrophies() // Reload trophies when a workout is added
        }
    }
    
}

#Preview("Real Data") {
    TrophyPageView(showDummyData: false)
        .environment(\.dynamicTypeSize, .medium)
        .preferredColorScheme(.light)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

#Preview("Sample Data") {
    TrophyPageView(showDummyData: true)
        .environment(\.dynamicTypeSize, .medium)
        .preferredColorScheme(.light)
}
