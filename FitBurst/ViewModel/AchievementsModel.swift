//
//  AchievementsModel.swift
//  FitBurst
//
//  Created by Piero Sierra on 27/12/2024.
//
import CoreData

enum TrophyType: CaseIterable {
    case newbie
    case fiveX
    case tenX
    case twentyFiveX
    case fiftyX
    case oneHundredX
    case twoHundredX
    case firstPerfectWeek
    case secondPerfectWeek
    case thirdPerfectWeek
    case fourthPerfectWeek
    case fifthPerfectWeek
    case sixthPerfectWeek
    case seventhPerfectWeek
    case twoInADay
    case threeInADay
    case lotsInADay
    //  case testCASE
    
    var displayName: String {
        switch self {
        case .newbie: return "First workout"
        case .fiveX: return "5 in a row"
        case .tenX: return "10 in a row"
        case .twentyFiveX: return "25 in a row"
        case .fiftyX: return "50 in a row"
        case .oneHundredX: return "100 in a row"
        case .twoHundredX: return "200 in a row"
        case .firstPerfectWeek: return "First Perfect Week"
        case .secondPerfectWeek: return "Second Perfect Week"
        case .thirdPerfectWeek: return "Third Perfect Week"
        case .fourthPerfectWeek: return "Fourth Perfect Week"
        case .fifthPerfectWeek: return "Fifth Perfect Week"
        case .sixthPerfectWeek: return "Sixth Perfect Week"
        case .seventhPerfectWeek: return "Seventh Perfect Week"
        case .twoInADay: return "Two in a day"
        case .threeInADay: return "Three in a day"
        case .lotsInADay: return "Lots in a day"
            //   case .testCASE: return "Test Case"
        }
    }
    
    var fileName: String {
        switch self {
        case .newbie: return "Coin_Star_Gold.usdz"
        case .fiveX: return "Coin_Zap_Silver.usdz"
        case .tenX: return "Coin_Zap_Gold.usdz"
        case .twentyFiveX: return "Coin_Crown_Gold.usdz"
        case .fiftyX: return "Star_Cup.usdz"
        case .oneHundredX: return "1_Stack_Coins.usdz"
        case .twoHundredX: return "3_Stacks_Coins.usdz"
        case .firstPerfectWeek: return "Gem_01_Red.usdz"
        case .secondPerfectWeek: return "Gem_02_Red.usdz"
        case .thirdPerfectWeek: return "Diamond_Red.usdz"
        case .fourthPerfectWeek: return "Gem_01_Green.usdz"
        case .fifthPerfectWeek: return "Gem_02_Green.usdz"
        case .sixthPerfectWeek: return "Diamond_Green.usdz"
        case .seventhPerfectWeek: return "Diamond_Blue.usdz"
        case .twoInADay: return "2_Coins_Silver.usdz"
        case .threeInADay: return "3_Coins_Gold.usdz"
        case .lotsInADay: return "5_Coins_Gold.usdz"
            //    case .testCASE: return "Red_Diamond_Metal.usdz"
        }
    }
}

class AchievementCalculator {
    private let persistenceController: PersistenceController
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }
    
    struct AchievementResult {
        let newAchievements: Set<TrophyType>
        let removedAchievements: Set<TrophyType>
    }
    
    func calculateAchievements() -> AchievementResult {
        let context = persistenceController.container.viewContext
        
        // Fetch all workouts, sorted by date
        let fetchRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Workouts.timestamp, ascending: true)]
        
        // Fetch existing achievements
        let achievementsFetch: NSFetchRequest<Achievements> = Achievements.fetchRequest()
        
        do {
            let workouts = try context.fetch(fetchRequest)
            let existingAchievements = try context.fetch(achievementsFetch)
            let existingTypes = Set(existingAchievements.map { achievement in
                let index = Int(achievement.achievementType)
                let trophyType = TrophyType.allCases[index]
                return trophyType
            })
            
            let calculatedAchievements = calculateEarnedAchievements(from: workouts)
            
            // Determine new and removed achievements
            let newAchievements = calculatedAchievements.subtracting(existingTypes)
            let removedAchievements = existingTypes.subtracting(calculatedAchievements)
            
            return AchievementResult(
                newAchievements: newAchievements,
                removedAchievements: removedAchievements
            )
        } catch {
            print("Error calculating achievements: \(error)")
            return AchievementResult(newAchievements: [], removedAchievements: [])
        }
    }
    
    private func calculateEarnedAchievements(from workouts: [Workouts]) -> Set<TrophyType> {
        var earnedAchievements = Set<TrophyType>()
        
        // Early exit if no workouts
        guard !workouts.isEmpty else { return earnedAchievements }
        
        // Newbie achievement - always earned if there's at least one workout
        earnedAchievements.insert(.newbie)
        
        // Calculate streaks and counts
        let streakInfo = calculateStreaks(from: workouts)
        let workoutsByDay = groupWorkoutsByDay(workouts)
        
        // Check streak-based achievements
        checkStreakAchievements(streakInfo.longestStreak, &earnedAchievements)
        
        // Check perfect weeks
        let perfectWeeks = calculatePerfectWeeks(from: workouts)
        checkPerfectWeekAchievements(perfectWeeks, &earnedAchievements)
        
        // Get existing achievements for comparison
        let context = persistenceController.container.viewContext
        let achievementsFetch: NSFetchRequest<Achievements> = Achievements.fetchRequest()
        
        do {
            let existingAchievements = try context.fetch(achievementsFetch)
            let existingByDay = Dictionary(grouping: existingAchievements) { achievement in
                Calendar.current.startOfDay(for: achievement.timestamp!)
            }
            
            // Check multiple workouts per day
            for (date, dayWorkouts) in workoutsByDay {
                let startOfDay = Calendar.current.startOfDay(for: date)
                let existingForDay = existingByDay[startOfDay] ?? []
                let existingTypesForDay = Set(existingForDay.map { Int($0.achievementType) })
                
                let count = dayWorkouts.count
                if count >= 2 && !existingTypesForDay.contains(TrophyType.allCases.firstIndex(of: .twoInADay)!) {
                    earnedAchievements.insert(.twoInADay)
                }
                if count >= 3 && !existingTypesForDay.contains(TrophyType.allCases.firstIndex(of: .threeInADay)!) {
                    earnedAchievements.insert(.threeInADay)
                }
                if count >= 4 && !existingTypesForDay.contains(TrophyType.allCases.firstIndex(of: .lotsInADay)!) {
                    earnedAchievements.insert(.lotsInADay)
                }
            }
            
        } catch {
            print("Error fetching existing achievements: \(error)")
        }
        
        return earnedAchievements
    }
    
    private struct StreakInfo {
        let longestStreak: Int
        let currentStreak: Int
    }
    
    private func calculateStreaks(from workouts: [Workouts]) -> StreakInfo {
        var longestStreak = 0
        var currentStreak = 0
        var lastDate: Date?
        
        let calendar = Calendar.current
        let workoutDays = Set(workouts.map { calendar.startOfDay(for: $0.timestamp!) })
        
        for date in workoutDays.sorted() {
            if let last = lastDate,
               calendar.dateComponents([.day], from: last, to: date).day == 1 {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
            
            longestStreak = max(longestStreak, currentStreak)
            lastDate = date
        }
        
        return StreakInfo(longestStreak: longestStreak, currentStreak: currentStreak)
    }
    
    private func checkStreakAchievements(_ streak: Int, _ achievements: inout Set<TrophyType>) {
        if streak >= 5 { achievements.insert(.fiveX) }
        if streak >= 10 { achievements.insert(.tenX) }
        if streak >= 25 { achievements.insert(.twentyFiveX) }
        if streak >= 50 { achievements.insert(.fiftyX) }
        if streak >= 100 { achievements.insert(.oneHundredX) }
        if streak >= 200 { achievements.insert(.twoHundredX) }
    }
    
    private func calculatePerfectWeeks(from workouts: [Workouts]) -> Int {
        let calendar = Calendar.current
        var perfectWeeks = 0
        
        // Group workouts by week
        let workoutsByWeek = Dictionary(grouping: workouts) { workout in
            calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: workout.timestamp!)
        }
        
        for (_, weekWorkouts) in workoutsByWeek {
            let workoutDays = Set(weekWorkouts.map { calendar.component(.weekday, from: $0.timestamp!) })
            // Check if all weekdays (2-1, Monday-Sunday) have workouts
            let hasAllWeekdays = (2...7).allSatisfy { workoutDays.contains($0) } && workoutDays.contains(1)
            if hasAllWeekdays {
                perfectWeeks += 1
            }
        }
        
        return perfectWeeks
    }
    
    private func checkPerfectWeekAchievements(_ weeks: Int, _ achievements: inout Set<TrophyType>) {
        if weeks >= 1 { achievements.insert(.firstPerfectWeek) }
        if weeks >= 2 { achievements.insert(.secondPerfectWeek) }
        if weeks >= 3 { achievements.insert(.thirdPerfectWeek) }
        if weeks >= 4 { achievements.insert(.fourthPerfectWeek) }
        if weeks >= 5 { achievements.insert(.fifthPerfectWeek) }
        if weeks >= 6 { achievements.insert(.sixthPerfectWeek) }
        if weeks >= 7 { achievements.insert(.seventhPerfectWeek) }
    }
    
    private func groupWorkoutsByDay(_ workouts: [Workouts]) -> [Date: [Workouts]] {
        let calendar = Calendar.current
        return Dictionary(grouping: workouts) { workout in
            calendar.startOfDay(for: workout.timestamp!)
        }
    }
}
