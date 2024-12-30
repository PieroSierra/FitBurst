//  TrophyView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI
import Model3DView
import CoreData

// Add this struct at the top level
struct TrophyWithDate {
    let type: TrophyType
    let earnedDate: Date
}

struct TrophyPageView: View {
    let showDummyData: Bool
    @State private var showTrophyDisplayView: Bool = false
    @State private var selectedTrophy: TrophyWithDate? = nil
    
    var body: some View {
        ZStack {
            Image("GradientWaves").resizable().ignoresSafeArea()
            
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
                    trophyType: trophy.type,
                    earnedDate: trophy.earnedDate
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
    
    // Add observation of CoreData changes
    @Environment(\.managedObjectContext) private var viewContext
    
    private func loadTrophies() {
        if showDummyData {
            // Generate random trophies with dates for dummy data
            trophies = (0..<24).map { _ in
                TrophyWithDate(
                    type: TrophyType.allCases.randomElement()!,
                    earnedDate: Date().addingTimeInterval(-Double.random(in: 0...(86400 * 30))) // Random date within last 30 days
                )
            }
        } else {
            // Load real trophies from CoreData
            let context = PersistenceController.shared.container.viewContext
            let fetchRequest: NSFetchRequest<Achievements> = Achievements.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Achievements.timestamp, ascending: false)]
            
            do {
                let achievements = try context.fetch(fetchRequest)
                trophies = achievements.map { achievement in
                    TrophyWithDate(
                        type: TrophyType.allCases[Int(achievement.achievementType)],
                        earnedDate: achievement.timestamp ?? Date()
                    )
                }
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
            trophyType: trophy.type,
            earnedDate: trophy.earnedDate
        )
        .scaleEffect(appearingItems.contains(index) ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appearingItems.contains(index))
    }
    
    var body: some View {
        Group {
            if scrollHorizontally {
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
        // Add listener for achievement changes
        .onReceive(NotificationCenter.default.publisher(for: .workoutAdded)) { _ in
            loadTrophies() // Reload trophies when a workout is added
        }
    }
    
}


#Preview("Real Data") {
    TrophyPageView(showDummyData: false)
        .environment(\.dynamicTypeSize, .medium)
        .preferredColorScheme(.light)
}

#Preview("Sample Data") {
    TrophyPageView(showDummyData: true)
        .environment(\.dynamicTypeSize, .medium)
        .preferredColorScheme(.light)
}
