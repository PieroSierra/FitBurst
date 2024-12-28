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

struct AchievementRecord: Equatable, Hashable {
    let type: TrophyType
    let date: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(date)
    }
}

struct AchievementResult {
    let achievements: [AchievementRecord]
    let dates: [TrophyType: Date]
}

class AchievementCalculator {
    private let persistenceController: PersistenceController
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }
    
    func calculateAchievements() -> AchievementResult {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Workouts.timestamp, ascending: true)]
        
        do {
            let workouts = try context.fetch(fetchRequest)
            var achievements: [AchievementRecord] = []
            var achievementDates: [TrophyType: Date] = [:]
            
            // Early exit if no workouts
            guard !workouts.isEmpty,
                  let firstWorkoutDate = workouts[0].timestamp else {
                return AchievementResult(achievements: achievements, dates: achievementDates)
            }
            
            // Newbie achievement - first workout
            achievements.append(AchievementRecord(type: .newbie, date: firstWorkoutDate))
            achievementDates[.newbie] = firstWorkoutDate
            
            // Calculate streaks
            let streakInfo = calculateStreaks(from: workouts)
            checkStreakAchievements(streakInfo.longestStreak, &achievements, &achievementDates, latestDate: workouts.last?.timestamp)
            
            // Check perfect weeks
            let perfectWeeks = calculatePerfectWeeks(from: workouts)
            checkPerfectWeekAchievements(perfectWeeks, &achievements, &achievementDates)
            
            // Check multiple workouts per day
            let workoutsByDay = groupWorkoutsByDay(workouts)
            checkMultipleWorkoutsPerDay(workoutsByDay, &achievements)
            
            return AchievementResult(achievements: achievements, dates: achievementDates)
            
        } catch {
            print("Failed to fetch workouts: \(error)")
            return AchievementResult(achievements: [], dates: [:])
        }
    }
    
    private struct StreakInfo {
        let longestStreak: Int
        let currentStreak: Int
        let streakEndDate: Date?
    }
    
    private func calculateStreaks(from workouts: [Workouts]) -> StreakInfo {
        var longestStreak = 0
        var currentStreak = 0
        var lastDate: Date?
        var streakEndDate: Date?
        
        let calendar = Calendar.current
        let workoutDays = Set(workouts.map { calendar.startOfDay(for: $0.timestamp!) })
        let sortedDays = workoutDays.sorted()
        
        for date in sortedDays {
            if let last = lastDate,
               calendar.dateComponents([.day], from: last, to: date).day == 1 {
                currentStreak += 1
                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                    streakEndDate = date
                }
            } else {
                currentStreak = 1
            }
            lastDate = date
        }
        
        return StreakInfo(
            longestStreak: longestStreak,
            currentStreak: currentStreak,
            streakEndDate: streakEndDate
        )
    }
    
    private func checkStreakAchievements(
        _ streak: Int,
        _ achievements: inout [AchievementRecord],
        _ dates: inout [TrophyType: Date],
        latestDate: Date?
    ) {
        guard let date = latestDate else { return }
        
        if streak >= 5 {
            achievements.append(AchievementRecord(type: .fiveX, date: date))
            dates[.fiveX] = date
        }
        if streak >= 10 {
            achievements.append(AchievementRecord(type: .tenX, date: date))
            dates[.tenX] = date
        }
        if streak >= 25 {
            achievements.append(AchievementRecord(type: .twentyFiveX, date: date))
            dates[.twentyFiveX] = date
        }
        if streak >= 50 {
            achievements.append(AchievementRecord(type: .fiftyX, date: date))
            dates[.fiftyX] = date
        }
        if streak >= 100 {
            achievements.append(AchievementRecord(type: .oneHundredX, date: date))
            dates[.oneHundredX] = date
        }
        if streak >= 200 {
            achievements.append(AchievementRecord(type: .twoHundredX, date: date))
            dates[.twoHundredX] = date
        }
    }
    
    private func calculatePerfectWeeks(from workouts: [Workouts]) -> [(weekCount: Int, endDate: Date)] {
        let calendar = Calendar.current
        var perfectWeeks: [(weekCount: Int, endDate: Date)] = []
        
        // Group workouts by week
        let workoutsByWeek = Dictionary(grouping: workouts) { workout in
            calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: workout.timestamp!)
        }
        
        // Sort weeks by comparing year and week components
        let sortedWeeks = workoutsByWeek.sorted { week1, week2 in
            if week1.key.yearForWeekOfYear != week2.key.yearForWeekOfYear {
                return week1.key.yearForWeekOfYear! < week2.key.yearForWeekOfYear!
            }
            return week1.key.weekOfYear! < week2.key.weekOfYear!
        }
        
        for (_, weekWorkouts) in sortedWeeks {
            let workoutDays = Set(weekWorkouts.map { calendar.component(.weekday, from: $0.timestamp!) })
            // Check if all weekdays (1-7, Sunday-Saturday) have workouts
            let hasAllWeekdays = (1...7).allSatisfy { workoutDays.contains($0) }
            
            if hasAllWeekdays {
                let weekEndDate = weekWorkouts.map { $0.timestamp! }.max()!
                perfectWeeks.append((perfectWeeks.count + 1, weekEndDate))
            }
        }
        
        return perfectWeeks
    }
    
    private func checkPerfectWeekAchievements(
        _ perfectWeeks: [(weekCount: Int, endDate: Date)],
        _ achievements: inout [AchievementRecord],
        _ dates: inout [TrophyType: Date]
    ) {
        for week in perfectWeeks {
            switch week.weekCount {
            case 1:
                achievements.append(AchievementRecord(type: .firstPerfectWeek, date: week.endDate))
                dates[.firstPerfectWeek] = week.endDate
            case 2:
                achievements.append(AchievementRecord(type: .secondPerfectWeek, date: week.endDate))
                dates[.secondPerfectWeek] = week.endDate
            case 3:
                achievements.append(AchievementRecord(type: .thirdPerfectWeek, date: week.endDate))
                dates[.thirdPerfectWeek] = week.endDate
            case 4:
                achievements.append(AchievementRecord(type: .fourthPerfectWeek, date: week.endDate))
                dates[.fourthPerfectWeek] = week.endDate
            case 5:
                achievements.append(AchievementRecord(type: .fifthPerfectWeek, date: week.endDate))
                dates[.fifthPerfectWeek] = week.endDate
            case 6:
                achievements.append(AchievementRecord(type: .sixthPerfectWeek, date: week.endDate))
                dates[.sixthPerfectWeek] = week.endDate
            case 7:
                achievements.append(AchievementRecord(type: .seventhPerfectWeek, date: week.endDate))
                dates[.seventhPerfectWeek] = week.endDate
            default: break
            }
        }
    }
    
    private func checkMultipleWorkoutsPerDay(
        _ workoutsByDay: [Date: [Workouts]],
        _ achievements: inout [AchievementRecord]
    ) {
        let sortedDays = workoutsByDay.keys.sorted()
        
        for date in sortedDays {
            let dayWorkouts = workoutsByDay[date]!
            let count = dayWorkouts.count
            
            if count >= 2 {
                print("Adding twoInADay achievement for \(date)")
                achievements.append(AchievementRecord(type: .twoInADay, date: date))
            }
            if count >= 3 {
                print("Adding threeInADay achievement for \(date)")
                achievements.append(AchievementRecord(type: .threeInADay, date: date))
            }
            if count >= 4 {
                print("Adding lotsInADay achievement for \(date)")
                achievements.append(AchievementRecord(type: .lotsInADay, date: date))
            }
        }
    }
    
    private func groupWorkoutsByDay(_ workouts: [Workouts]) -> [Date: [Workouts]] {
        Dictionary(grouping: workouts) { workout in
            Calendar.current.startOfDay(for: workout.timestamp!)
        }
    }
}
