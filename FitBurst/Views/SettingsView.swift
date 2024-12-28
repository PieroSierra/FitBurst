//
//  SettingsView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI

enum WorkoutType: Int32 {
    case strength = 0
    case run = 1
    case teamSport = 2
    case cardio = 3
    case yoga = 4
    case martialArts = 5
    
    var defaultName: String {
        switch self {
        case .strength: return "Strength"
        case .run: return "Run"
        case .teamSport: return "Team Sport"
        case .cardio: return "Cardio"
        case .yoga: return "Yoga"
        case .martialArts: return "Martial Arts"
        }
    }
    
    var defaultIcon: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .run: return "figure.run"
        case .teamSport: return "soccerball"
        case .cardio: return "figure.run.treadmill"
        case .yoga: return "figure.yoga"
        case .martialArts: return "figure.martial.arts"
        }
    }
}

/// Class to handle reading/writing overrides from UserDefaults
class WorkoutConfiguration: ObservableObject {
    static let shared = WorkoutConfiguration()
    
    @Published private var nameOverrides: [Int32: String] = [:]
    @Published private var iconOverrides: [Int32: String] = [:]
    
    private let defaults = UserDefaults.standard
    
    private init() {
        // Load saved overrides
        loadOverrides()
    }
    
    func getName(for type: Int32) -> String {
        nameOverrides[type] ?? WorkoutType(rawValue: type)?.defaultName ?? "Unknown"
    }
    
    func getIcon(for type: Int32) -> String {
        iconOverrides[type] ?? WorkoutType(rawValue: type)?.defaultIcon ?? "questionmark.circle"
    }
    
    func setName(_ name: String?, for type: Int32) {
        nameOverrides[type] = name
        saveOverrides()
    }
    
    func setIcon(_ icon: String?, for type: Int32) {
        iconOverrides[type] = icon
        saveOverrides()
    }
    
    private func loadOverrides() {
        if let savedNames = defaults.dictionary(forKey: "workoutNameOverrides") as? [String: String] {
            nameOverrides = savedNames.reduce(into: [:]) { result, pair in
                if let type = Int32(pair.key) {
                    result[type] = pair.value
                }
            }
        }
        
        if let savedIcons = defaults.dictionary(forKey: "workoutIconOverrides") as? [String: String] {
            iconOverrides = savedIcons.reduce(into: [:]) { result, pair in
                if let type = Int32(pair.key) {
                    result[type] = pair.value
                }
            }
        }
    }
    
    private func saveOverrides() {
        let namesDict = nameOverrides.reduce(into: [:]) { result, pair in
            result[String(pair.key)] = pair.value
        }
        let iconsDict = iconOverrides.reduce(into: [:]) { result, pair in
            result[String(pair.key)] = pair.value
        }
        
        defaults.set(namesDict, forKey: "workoutNameOverrides")
        defaults.set(iconsDict, forKey: "workoutIconOverrides")
    }
    
    func resetToDefaults() {
        nameOverrides.removeAll()
        iconOverrides.removeAll()
        
        // Clear UserDefaults
        defaults.removeObject(forKey: "workoutNameOverrides")
        defaults.removeObject(forKey: "workoutIconOverrides")
    }
}

struct SettingsView: View {
    /// Shared states
    @StateObject private var config = WorkoutConfiguration.shared
    @State private var context = PersistenceController.shared.container.viewContext
    
    /// View states
    @State private var showIconPickerView = false
    @State private var editingWorkoutType: Int32?
    @State private var showResetAlert = false
#if DEBUG
    @State private var showDeleteWorkoutsAlert = false
    @State private var showDeleteAchievementsAlert = false
#endif
    
    var body: some View {
        ZStack {
            Image("GradientWaves").resizable().ignoresSafeArea()
            
            VStack {
                Text("Settings")
                    .font(.custom("Futura Bold", size: 40))
                    .padding(.bottom, 20)
                    .foregroundStyle(.white)
                
                Text ("Customize your workout types")
                    .foregroundStyle(.white)
                
                ScrollView {
                    
                    VStack (alignment: .center) {
                        
                        ForEach(0..<6) { index in
                            let type = Int32(index)
                            
                            HStack {
                                Button(action: {
                                    editingWorkoutType = type
                                    showIconPickerView = true
                                }) {
                                    Image(systemName: config.getIcon(for: type))
                                        .font(.title2)
                                        .frame(width: 40, height: 40)
                                        .background(Color.white)
                                        .foregroundStyle(Color.black)
                                        .cornerRadius(10)
                                }
                                TextField(WorkoutType(rawValue: type)?.defaultName ?? "",
                                          text: Binding(
                                            get: { config.getName(for: type) },
                                            set: { config.setName($0, for: type) }
                                          ))
                                .font(.custom("Futura", size: 15))
                                .frame(width: 150, height:40)
                                .padding(.horizontal, 10)
                                .background(.black.opacity(0.3))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        
                        Button(action: {
                            showResetAlert = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                    .font(.title2)
                                Text("Reset to defaults")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.6))
                            .cornerRadius(10)
                        }
                        .padding(.top, 30)
#if DEBUG
                        Button(action: {
                            showDeleteWorkoutsAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .font(.title2)
                                Text("Delete all workouts")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.6))
                            .cornerRadius(10)
                        }
                        .padding(.top, 30)
                        
                        Button(action: {
                            showDeleteAchievementsAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .font(.title2)
                                Text("Delete all Achievements")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.6))
                            .cornerRadius(10)
                        }
                        .padding(.top, 30)
#endif
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(35)
                }
            }
            
            if showIconPickerView {
                if let type = editingWorkoutType {
                    IconPickerView(
                        showIconPickerView: $showIconPickerView,
                        workoutType: type
                    )
                }
            }
        }
        .alert("Reset Settings", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                config.resetToDefaults()
            }
        } message: {
            Text("This will reset all workout names and icons to their defaults.")
        }
        #if DEBUG
        .alert("Reset Settings", isPresented: $showDeleteWorkoutsAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                PersistenceController.shared.deleteAllWorkouts()
            }
        } message: {
            Text("This will delete all recorded workouts. This action cannot be undone.")
        }
        .alert("Reset Settings", isPresented: $showDeleteAchievementsAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                PersistenceController.shared.deleteAllAchievements()
            }
        } message: {
            Text("This will delete all achievements. This action cannot be undone.")
        }
        #endif
    }
}

#Preview {
    SettingsView()
}
