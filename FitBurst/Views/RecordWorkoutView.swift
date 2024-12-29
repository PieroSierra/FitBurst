//  RecordWorkoutView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 30/11/2024.
//

import SwiftUI
import CoreData

extension Notification.Name {
    static let workoutAdded = Notification.Name("workoutAdded")
    static let workoutDeleted = Notification.Name("workoutDeleted")
    static let achievementsChanged = Notification.Name("achievementsChanged")
}

enum SoundScape: String {
    case buildup = "Cinematic Riser Sound Effect"
    case release = "TikTok Boom Bling Sound Effect"
}


struct RecordWorkoutView: View {
    @Binding var showWorkoutView: Bool
    @Binding var selectedDate: Date
    
    @State private var scale: CGFloat = 0.6
    
    ///for ripple
    @State private var rippleCounter: Int = 0
    @State private var ripplePosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
    
    func triggerRipple(at position: CGPoint) {
        let adjustedPosition = CGPoint(
            x: position.x,
            y: position.y - 65  // Subtract the VStack offset
        )
        ripplePosition = adjustedPosition
        rippleCounter += 1
    }
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .modifier(RippleEffect(at: ripplePosition, trigger: rippleCounter, amplitude: -22, frequency: 15, decay: 4, speed: 600))
            
 
            VStack {
                Spacer().frame(height: 50)

                Text("**Press & hold** to record:")
                    .foregroundColor(.white)
                    .onTapGesture {
                        rippleCounter += 1
                    }

                Spacer().frame(height: 30)

                
                // First row (3 buttons)
                HStack(spacing: 10) {
                    ForEach(0..<2) { index in
                        if WorkoutConfiguration.shared.isVisible(for: Int32(index)) {
                                workoutButton(for: Int32(index))
                        }
                    }
                }
                
                Spacer().frame(height: 10)
                
                // Second row (3 buttons)
                HStack(spacing: 10) {
                    ForEach(2..<4) { index in
                        if WorkoutConfiguration.shared.isVisible(for: Int32(index)) {
                            workoutButton(for: Int32(index))
                        }
                    }
                }
                Spacer().frame(height: 10)
                
                // Second row (3 buttons)
                HStack(spacing: 10) {
                    ForEach(4..<6) { index in
                        if WorkoutConfiguration.shared.isVisible(for: Int32(index)) {
                            workoutButton(for: Int32(index))
                        }
                    }
                }
                
                Spacer().frame(height: 60)
            }
            .frame(width:350,height:330)
            .padding(.bottom, 40)
            .background(Color.black.opacity(0.9).clipShape(RoundedRectangle(cornerRadius: 40))
                .shadow(color: .limeAccentColor, radius: 10))
            .overlay(dismissButton, alignment: .topTrailing)
            .scaleEffect(scale)
            .onAppear {
                scale = 0.6
                withAnimation(.bouncy) { scale = 1.15 }
                withAnimation(.bouncy.delay(0.25)) { scale = 1 }
            }
            .modifier(RippleEffect(
                at: CGPoint(
                    x: ripplePosition.x - (UIScreen.main.bounds.width - 350)/2,  // Center X in VStack
                    y: ripplePosition.y - (UIScreen.main.bounds.height - 330)/2+65  // Center Y in VStack
                ),
                trigger: rippleCounter,
                amplitude: -12,
                frequency: 15,
                decay: 8,
                speed: 650
            ))
            /* /// Debug circle to visualize the ripple position
           Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .position(ripplePosition) */
            
            HStack {
                Text("Workout date:")
                    .foregroundColor(.white)
                
                DatePicker("",
                           selection: $selectedDate,
                           displayedComponents: [.date])
                .labelsHidden()
                .accentColor(.black)
                .colorScheme(.dark)
                .background(Color.white.opacity(0.3))
                .cornerRadius(8)
            }
            .padding(.horizontal)
            .scaleEffect(scale)
            .onAppear {
                scale = 0.6
                withAnimation(.bouncy) { scale = 1.15 }
                withAnimation(.bouncy.delay(0.25)) { scale = 1 }
            }
            .offset(y: +150)
            
        }
        .onTapGesture {
            showWorkoutView = false
        }

    }
    
    private var dismissButton: some View {
        Button(action: {
            showWorkoutView = false
        }) {
            Image(systemName: "xmark.circle")
                .foregroundColor(.gray)
                .imageScale(.large)
        }
        .padding(25)
    }
    
    @ViewBuilder
    private func workoutButton(for type: Int32) -> some View {
        Button(action: { }) {
            HStack {
                Image(systemName: WorkoutConfiguration.shared.getIcon(for: type))
                    .imageScale(.large)
                Text(WorkoutConfiguration.shared.getName(for: type))
                    .lineLimit(1)
//                    .minimumScaleFactor(0.5)
            }
  //          .frame(width: 100)
        }
        .padding(5)
        .buttonStyle(FillUpButtonStyle(onComplete: { position in
            triggerRipple(at: position)
            PersistenceController.shared.recordWorkout(date: selectedDate, workoutType: type)
            calculateNewAchievements()
            NotificationCenter.default.post(name: .workoutAdded, object: nil)
        }))
    }
    
    private func calculateNewAchievements() {
        RecordWorkoutView.recalculateAchievements()
    }
}

extension RecordWorkoutView {
    public static func recalculateAchievements() {
        let calculator = AchievementCalculator()
        let result = calculator.calculateAchievements()
        
        do {
            let context = PersistenceController.shared.container.viewContext
            let fetchRequest: NSFetchRequest<Achievements> = Achievements.fetchRequest()
            let existingAchievements = try context.fetch(fetchRequest)
            
            // Convert existing achievements to our record type
            let existingRecords = existingAchievements.compactMap { achievement -> AchievementRecord? in
                guard let timestamp = achievement.timestamp else { return nil }
                return AchievementRecord(
                    type: TrophyType.allCases[Int(achievement.achievementType)],
                    date: timestamp
                )
            }
            
            // Compare as sets to ignore order
            if Set(existingRecords) != Set(result.achievements) {
                // Calculate new achievements for UI purposes
                let existingTypes = Set(existingRecords.map { $0.type })
                let newTypes = Set(result.achievements.map { $0.type })
                let newlyEarned = newTypes.subtracting(existingTypes)
                
                if !newlyEarned.isEmpty {
                    print("New achievements earned: \(newlyEarned)")
                }
                
                // Delete all existing achievements
                for achievement in existingAchievements {
                    context.delete(achievement)
                }
                
                // Save the complete new set
                for achievement in result.achievements {
                    let achievementIndex = TrophyType.allCases.firstIndex(of: achievement.type)!
                    PersistenceController.shared.recordAchievement(
                        date: achievement.date,
                        achievementType: Int32(achievementIndex)
                    )
                }
                
                NotificationCenter.default.post(name: .achievementsChanged, object: nil)
            }
        } catch {
            print("Error managing achievements: \(error)")
        }
    }
}

#Preview {
    RecordWorkoutView(showWorkoutView: .constant(true), selectedDate: .constant(Date()))
}
