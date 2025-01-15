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

struct BackgroundOption {
    let displayName: String
    let assetName: String
}

struct AppBackgrounds {
    static let options: [BackgroundOption] = [
        BackgroundOption(displayName: "Black Tiles", assetName: "BlackTiles"),
        BackgroundOption(displayName: "Dark Forest", assetName: "DarkForest"),
        BackgroundOption(displayName: "Night Dunes", assetName: "Dunes"),
        BackgroundOption(displayName: "Gradient Waves", assetName: "GradientWaves"),
        BackgroundOption(displayName: "Ocean Ripples", assetName: "Ocean"),
        BackgroundOption(displayName: "Black & White", assetName: "BlackAndWhite"),
        BackgroundOption(displayName: "Palm Frond", assetName: "Frond"),
        BackgroundOption(displayName: "Sky lights", assetName: "Skylights"),
        BackgroundOption(displayName: "Pink Palm", assetName: "PinkPalm"),
        BackgroundOption(displayName: "El Capitan", assetName: "ElCapitan"),
        BackgroundOption(displayName: "Mr. Rainier", assetName: "Rainier"),
        BackgroundOption(displayName: "Mt. Fuji", assetName: "Fuji1"),
        BackgroundOption(displayName: "Matterhorn", assetName: "Matterhorn"),
        BackgroundOption(displayName: "Snowcap", assetName: "Snowcap"),
        BackgroundOption(displayName: "Lion", assetName: "Lion"),
        BackgroundOption(displayName: "Kettle Bell", assetName: "KettleBell"),
        BackgroundOption(displayName: "Running Tracks", assetName: "RunningTracks"),
        BackgroundOption(displayName: "Dark Crystals", assetName: "DarkCrystals")
    ]
}

/// Class to handle reading/writing overrides from UserDefaults
class WorkoutConfiguration: ObservableObject {
    static let shared = WorkoutConfiguration()
    
    @Published private var nameOverrides: [Int32: String] = [:]
    @Published private var iconOverrides: [Int32: String] = [:]
    @Published private var visibilityOverrides: [Int32: Bool] = [:]
    @AppStorage("selectedBackground") private var selectedBackground : String  = "Dark Tiles"
    
    private let defaults = UserDefaults.standard
    
    private init() {
        // Load saved overrides
        loadOverrides()
    }
    
    func countWorkouts() -> Int {
        let visibleCount = (0...5).filter { isVisible(for: Int32($0)) }.count
        return visibleCount
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
    
    func readVisibility (_ visible: Bool?,for type: Int32)
    {
        visibilityOverrides[type] = visible
        saveOverrides()
    }
    
    func isVisible(for type: Int32) -> Bool {
        visibilityOverrides[type] ?? true  // Default to visible if not set
    }
    
    func setVisibility(_ visible: Bool, for type: Int32) {
        // If trying to disable and this is the last visible type, prevent the action
        if !visible {
            let visibleCount = (0...5).filter { isVisible(for: Int32($0)) }.count
            if visibleCount <= 1 {
                return // Don't allow disabling the last visible type
            }
        }
        
        visibilityOverrides[type] = visible
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
        
        if let savedVisibility = defaults.dictionary(forKey: "workoutVisibilityOverrides") as? [String: Bool] {
            visibilityOverrides = savedVisibility.reduce(into: [:]) { result, pair in
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
        
        let visibilityDict = visibilityOverrides.reduce(into: [:]) { result, pair in
            result[String(pair.key)] = pair.value
        }
        defaults.set(visibilityDict, forKey: "workoutVisibilityOverrides")
    }
    
    func resetToDefaults() {
        nameOverrides.removeAll()
        iconOverrides.removeAll()
        visibilityOverrides.removeAll()
        
        // Clear UserDefaults
        defaults.removeObject(forKey: "workoutNameOverrides")
        defaults.removeObject(forKey: "workoutIconOverrides")
        defaults.removeObject(forKey: "workoutVisibilityOverrides")
        selectedBackground = "Dark Tiles"
    }
}

struct SettingsView: View {
    @StateObject private var config = WorkoutConfiguration.shared
    @State private var context = PersistenceController.shared.container.viewContext
    
    @AppStorage("firstRunComplete") private var firstRunComplete = false
    @AppStorage("selectedBackground") private var selectedBackground : String  = "Dark Tiles"
    
    @State private var showIconPickerView = false
    @State private var showBackgroundPickerView = false
    @State private var editingWorkoutType: Int32?
    @State private var showResetAlert = false
#if DEBUG
    @State private var showDeleteWorkoutsAlert = false
    @State private var showDeleteAchievementsAlert = false
    @State private var showResetFirstRunAlert = false
#endif
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                ScrollView {
                    Text("Settings")
                        .font(.custom("Futura Bold", fixedSize: 40))
                        .padding(.bottom, 20)
                        .foregroundStyle(.white)
                    
                    /// Workout Customizations
                    VStack {
                        Text("Rename or customize icons for up to six of your favorite workout types, or disable them altogether.")
                            .foregroundStyle(.white)
                            .padding(.top, 30)
                            .padding(.horizontal, 30)
                        
                        VStack(alignment: .center) {
                            ForEach(0..<6) { index in
                                WorkoutTypeRow(
                                    type: Int32(index),
                                    config: config,
                                    editingWorkoutType: $editingWorkoutType,
                                    showIconPickerView: $showIconPickerView
                                )
                            }
                        }
                        .padding()
                        .padding(.bottom, 10)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20).foregroundColor(Color.black.opacity(0.4)))
                    .padding()
                    
                    backgroundPicker
#if DEBUG
                    SettingsButtons(
                        config: config,
                        showResetAlert: $showResetAlert,showDeleteWorkoutsAlert: $showDeleteWorkoutsAlert,
                        showDeleteAchievementsAlert: $showDeleteAchievementsAlert, showResetFirstRunAlert: $showResetFirstRunAlert)
#else
                    SettingsButtons(
                        config: config,
                        showResetAlert: $showResetAlert)
#endif
                }
            }
            
            if showIconPickerView, let type = editingWorkoutType {
                IconPickerView (
                    showIconPickerView: $showIconPickerView,
                    workoutType: type,
                    textHint: WorkoutConfiguration.shared.getName(for: Int32(type))
                )
            } else if showBackgroundPickerView {
                BackgroundPickerView (showBackgroundPickerView: $showBackgroundPickerView)
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
        .alert("Delere Workouts", isPresented: $showDeleteWorkoutsAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                PersistenceController.shared.deleteAllWorkouts()
            }
        } message: {
            Text("This will delete all recorded workouts. This action cannot be undone.")
        }
        .alert("Delete Achievements", isPresented: $showDeleteAchievementsAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                PersistenceController.shared.deleteAllAchievements()
            }
        } message: {
            Text("This will delete all achievements. This action cannot be undone.")
        }
        .alert("Reset First Run", isPresented: $showResetFirstRunAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                firstRunComplete = false
            }
        } message: {
            Text("This will reset First Run.  Close app and relaunch to see changes.")
        }
#endif
    }
    
    private var backgroundPicker: some View {
        HStack {
            Button(action: {
                showBackgroundPickerView = true
            }) {
                HStack {
                    Image(systemName: "paintbrush.fill")
                        .font(.title2)
                    Text("Select Background")
                }
            }
            .buttonStyle(GrowingButtonStyle())
            .padding(.top, 20)
        }
    }
}

struct WorkoutTypeRow: View {
    let type: Int32
    @ObservedObject var config: WorkoutConfiguration
    @Binding var editingWorkoutType: Int32?
    @Binding var showIconPickerView: Bool
    
    var body: some View {
        let isLastVisible = (0...5)
            .filter { WorkoutConfiguration.shared.isVisible(for: Int32($0)) }
            .count == 1 && WorkoutConfiguration.shared.isVisible(for: type)
        let isRowDisabled = !WorkoutConfiguration.shared.isVisible(for: Int32(type))
        
        HStack {
            Group {
                Button(action: {
                    editingWorkoutType = type
                    showIconPickerView = true
                }) {
                    Image(systemName: config.getIcon(for: type))
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .background(isRowDisabled ? Color.white.mix(with: Color.black, by: 0.3) : Color.white)
                        .foregroundStyle(Color.black)
                        .cornerRadius(10)
                }
                
                TextField(WorkoutType(rawValue: type)?.defaultName ?? "",
                          text: Binding(
                            get: { config.getName(for: type) },
                            set: { config.setName($0, for: type) }
                          ))
                .font(.custom("Futura", size: 15))
                .frame(height:40)
                .padding(.horizontal, 10)
                .background(isRowDisabled ? Color.white.mix(with: Color.black, by: 0.3) : Color.white)
                .cornerRadius(10)
                .foregroundColor(isRowDisabled ? Color.black : Color.black)
            }.disabled(isRowDisabled)
            
            Toggle("", isOn: Binding(
                get: { config.isVisible(for: type) },
                set: { config.setVisibility($0, for: type) }
            ))
            .frame(width: 40)
            .tint(Color.limeAccentColor.opacity(0.7))
            .disabled(isLastVisible) // Disable toggle if this is the last visible type
        }.padding(.horizontal)
    }
}

struct SettingsButtons: View {
    @ObservedObject var config: WorkoutConfiguration
    @Binding var showResetAlert: Bool
    
#if DEBUG
    @Binding var showDeleteWorkoutsAlert: Bool
    @Binding var showDeleteAchievementsAlert: Bool
    @Binding var showResetFirstRunAlert: Bool
#endif
    
    var body: some View {
        VStack {
            Button(action: { showResetAlert = true }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.title2)
                    Text("Reset to defaults")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red.mix(with:.black, by: 0.15))
                .cornerRadius(30)
            }
            .padding(.top, 30)
            
#if DEBUG
            Text ("Debug only controls:")
                .foregroundColor(.white)
                .padding(.top, 30)
            HStack {
                Button(action: { showDeleteWorkoutsAlert = true }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .font(.title2)
                        Text("Workouts")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red.mix(with:.black, by: 0.15))
                    .cornerRadius(30)
                }
                
                Button(action: { showDeleteAchievementsAlert = true }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .font(.title2)
                        Text("Trophies")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red.mix(with:.black, by: 0.15))
                    .cornerRadius(30)
                }
            }
            Button(action: { showResetFirstRunAlert = true }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.title2)
                    Text("Reset First Run")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red.opacity(0.8))
                .cornerRadius(30)
            }
#endif
        }
    }
}

#Preview {
    SettingsView()
        .environment(\.dynamicTypeSize, .medium)
        .preferredColorScheme(.light)
}
