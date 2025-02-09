//
//  Persistence.swift
//  FitBurst
//
//  Created by Nikola Sierra on 24/11/2024.
//

import CoreData
import WidgetKit

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FitBurst")
        
        // Configure for App Group container
        if let storeURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.pieroco.FitBurst")?
            .appendingPathComponent("FitBurst.sqlite") {
            
            let storeDescription = NSPersistentStoreDescription(url: storeURL)
            container.persistentStoreDescriptions = [storeDescription]
        }
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

/// Workout Management Extensions
extension PersistenceController {
    func recordWorkout(date: Date, workoutType: Int32) {
        let context = container.viewContext
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        let newWorkout = Workouts(context: context)
        newWorkout.timestamp = startOfDay
        newWorkout.workoutID = UUID()
        newWorkout.workoutType = workoutType
        
        do {
            try context.save()
            // Force sync and widget update
            container.viewContext.automaticallyMergesChangesFromParent = true
            try container.viewContext.save()
            
            DispatchQueue.main.async {
                WidgetCenter.shared.reloadAllTimelines()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        } catch {
            print("Failed to record workout: \(error.localizedDescription)")
        }
    }
    
    func deleteWorkout(workout: Workouts) {
        let context = container.viewContext
        context.delete(workout)
        do {
            try context.save()
            // Force sync and widget update
            container.viewContext.automaticallyMergesChangesFromParent = true
            try context.save()
            
            DispatchQueue.main.async {
                WidgetCenter.shared.reloadAllTimelines()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        } catch {
            print("Failed to delete workout: \(error.localizedDescription)")
        }
    }
    
    func countWorkouts() -> Int {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
        
        do {
            return try context.count(for: fetchRequest)
        } catch {
            print("Failed to count workouts: \(error.localizedDescription)")
            return 0
        }
    }
    
    func deleteAllWorkouts() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Workouts.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            try context.save()
            // Trigger widget update after successful delete all
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Failed to delete all workouts: \(error.localizedDescription)")
        }
    }
}


/// Award Management Extensions
extension PersistenceController {
    func recordAchievement(date: Date, achievementType: Int32) {
        let context = container.viewContext
        
        // Get start and end of the workout's day (not today's date)
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Get count of achievements already recorded for this specific day
        let existingCountRequest = NSFetchRequest<Achievements>(entityName: "Achievements")
        existingCountRequest.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", 
            startOfDay as NSDate, 
            endOfDay as NSDate
        )
        
        // Check if this specific achievement already exists for this specific day
        let achievementExistsRequest = NSFetchRequest<Achievements>(entityName: "Achievements")
        achievementExistsRequest.predicate = NSPredicate(
            format: "achievementType == %d AND timestamp >= %@ AND timestamp < %@",
            achievementType,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        do {
            let existingCount = try context.count(for: existingCountRequest)
            let achievementExists = try context.count(for: achievementExistsRequest) > 0
            
            /// Only proceed if we haven't already recorded this achievement type today
            if !achievementExists {
                /// Add minutes to the start of the achievement's day
                let achievementDate = Calendar.current.date(byAdding: .minute, value: existingCount, to: startOfDay)!
                
                let newAchievement = Achievements(context: context)
                newAchievement.timestamp = achievementDate
                newAchievement.achievementID = UUID()
                newAchievement.achievementType = achievementType
                try context.save()
            } else {
                print("Achievement of type \(achievementType) already exists for this day")
            }
        } catch {
            print("Failed to record achievement: \(error)")
        }
    }
    
    func deleteAchievement(achievement: Achievements) {
        let context = container.viewContext
        context.delete(achievement)
        do {
            try context.save()
        } catch {
            print("Failed to delete achievement: \(error.localizedDescription)")
        }
    }
    
    func countAchievements() -> Int {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Achievements> = Achievements.fetchRequest()
        
        do {
            return try context.count(for: fetchRequest)
        } catch {
            print("Failed to count achievements: \(error.localizedDescription)")
            return 0
        }
    }
    
    func deleteAllAchievements() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Achievements.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            try context.save()
        } catch {
            print("Failed to delete all achievements: \(error.localizedDescription)")
        }
    }
}


