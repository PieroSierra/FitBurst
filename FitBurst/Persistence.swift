//
//  Persistence.swift
//  FitBurst
//
//  Created by Nikola Sierra on 24/11/2024.
//

import CoreData

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

extension PersistenceController {
    func recordWorkout(date: Date, workoutType: Int32) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timestamp == %@ AND workoutType == %d", date as NSDate, workoutType)
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                let newWorkout = Workouts(context: context)
                newWorkout.timestamp = Calendar.current.startOfDay(for: date)
                newWorkout.workoutID = UUID()
                newWorkout.workoutType = workoutType
                try context.save()
            } else {
                print("Workout of this type already exists for the selected date.")
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
        } catch {
            print("Failed to delete all workouts: \(error.localizedDescription)")
        }
    }
}

