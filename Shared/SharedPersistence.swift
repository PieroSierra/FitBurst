import CoreData
import WidgetKit

class SharedPersistence {
    static let shared = SharedPersistence()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "FitBurst")
        
        print("SharedPersistence init - Starting") // Debug
        
        // Configure for App Group container
        if let storeURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.pieroco.FitBurst")?
            .appendingPathComponent("FitBurst.sqlite") {
            
            print("SharedPersistence init - Got store URL:", storeURL) // Debug
            let storeDescription = NSPersistentStoreDescription(url: storeURL)
            container.persistentStoreDescriptions = [storeDescription]
        } else {
            print("SharedPersistence init - Failed to get store URL") // Debug
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            } else {
                print("SharedPersistence init - Successfully loaded store:", description)
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func hasWorkout(for date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "timestamp >= %@ AND timestamp < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        do {
            let count = try container.viewContext.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking for workout: \(error)")
            return false
        }
    }
    
    func getWorkoutsForWeek(startingFrom date: Date) -> [Date: Bool] {
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfWeek(for: date)
        var results: [Date: Bool] = [:]
        
        // Create the date range for the week
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        
        print("SharedPersistence - Getting workouts from \(startOfWeek) to \(endOfWeek)")
        
        // Fetch all workouts for the week in one go
        let fetchRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "timestamp >= %@ AND timestamp <= %@",
            startOfWeek as NSDate,
            endOfWeek as NSDate
        )
        
        do {
            let workouts = try container.viewContext.fetch(fetchRequest)
            print("SharedPersistence - Raw workouts fetched: \(workouts.count)")
            print("SharedPersistence - Workout timestamps: \(workouts.map { $0.timestamp?.description ?? "nil" })")
            
            let workoutDates = workouts.map { calendar.startOfDay(for: $0.timestamp!) }
            
            // Initialize all days of the week
            for dayOffset in 0..<7 {
                let currentDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
                let startOfDay = calendar.startOfDay(for: currentDate)
                results[startOfDay] = workoutDates.contains(startOfDay)
                print("SharedPersistence - Day \(dayOffset): \(startOfDay) = \(results[startOfDay] ?? false)")
            }
            
            print("SharedPersistence - Final results count: \(results.count)")
            print("SharedPersistence - Days with workouts: \(results.filter { $0.value }.count)")
        } catch {
            print("SharedPersistence - Error fetching workouts: \(error)")
        }
        
        return results
    }
} 
