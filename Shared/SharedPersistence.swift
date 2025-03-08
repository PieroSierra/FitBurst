import CoreData
import WidgetKit

// Add WorkoutType enum to be accessible from both app and widget
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

class SharedPersistence {
    static let shared = SharedPersistence()
    
    let container: NSPersistentContainer
    private let groupDefaults = UserDefaults(suiteName: "group.com.pieroco.FitBurst")!
    
    init() {
        // Create the container
        container = NSPersistentContainer(name: "FitBurst")
        
        // Set up the shared container URL
        guard let sharedStoreURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.pieroco.FitBurst")?
            .appendingPathComponent("FitBurst.sqlite") else {
                fatalError("Failed to create shared store URL")
        }
        
        // Configure a persistent store description for the shared container
        let storeDescription = NSPersistentStoreDescription(url: sharedStoreURL)
        storeDescription.shouldInferMappingModelAutomatically = true
        storeDescription.shouldMigrateStoreAutomatically = true
        
        // Set the persistent store descriptions
        container.persistentStoreDescriptions = [storeDescription]
        
        // Load persistent stores
        container.loadPersistentStores { description, error in
            if let error = error {
                // Handle error
                print("CoreData failed to load: \(error.localizedDescription)")
                fatalError("Failed to load Core Data: \(error)")
            } else {
                print("SharedPersistence - Successfully loaded store at URL: \(description.url?.absoluteString ?? "unknown")")
            }
        }
        
        // Enable automatic merging of changes
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // Add methods to get workout icons and names
    func getWorkoutIcon(for type: Int32) -> String {
        // Debug: Print UserDefaults values
        let iconOverrides = groupDefaults.dictionary(forKey: "workoutIconOverrides") as? [String: String]
        print("SharedPersistence - getWorkoutIcon for type \(type)")
        print("SharedPersistence - iconOverrides: \(String(describing: iconOverrides))")
        
        // First check if there's a custom icon in UserDefaults
        if let iconOverrides = iconOverrides,
           let icon = iconOverrides[String(type)] {
            print("SharedPersistence - Found custom icon: \(icon)")
            return icon
        }
        
        // Otherwise return the default icon
        let defaultIcon = WorkoutType(rawValue: type)?.defaultIcon ?? "questionmark.circle"
        print("SharedPersistence - Using default icon: \(defaultIcon)")
        return defaultIcon
    }
    
    func getWorkoutName(for type: Int32) -> String {
        // First check if there's a custom name in UserDefaults
        if let nameOverrides = groupDefaults.dictionary(forKey: "workoutNameOverrides") as? [String: String],
           let name = nameOverrides[String(type)] {
            return name
        }
        
        // Otherwise return the default name
        return WorkoutType(rawValue: type)?.defaultName ?? "Unknown"
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
    
    // New method to get workouts with their types for a specific date
    func getWorkoutsForDate(_ date: Date) -> [Workouts] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        let fetchRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timestamp == %@", startOfDay as NSDate)
        
        do {
            return try container.viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching workouts for date \(date): \(error.localizedDescription)")
            return []
        }
    }
    
    // Updated to return workout data instead of just boolean
    func getWorkoutsForWeek(startingFrom date: Date) -> [Date: [Workouts]] {
        let calendar = Calendar.current
        // Ensure we're starting from the correct week
        let startOfWeek = calendar.startOfWeek(for: date)
        var results: [Date: [Workouts]] = [:]
        
        print("SharedPersistence - Getting workouts for week starting at: \(startOfWeek)")
        
        // Create the date range for the week
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        
        // Fetch all workouts for the week in one go
        let fetchRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "timestamp >= %@ AND timestamp <= %@",
            startOfWeek as NSDate,
            endOfWeek as NSDate
        )
        
        // Sort by date for consistency
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        do {
            let workouts = try container.viewContext.fetch(fetchRequest)
            print("SharedPersistence - Fetched \(workouts.count) workouts for week from \(startOfWeek) to \(endOfWeek)")
            
            // Debug: Print all fetched workouts
            for workout in workouts {
                print("SharedPersistence - Workout: date=\(workout.timestamp!), type=\(workout.workoutType)")
            }
            
            // Initialize all days of the week with empty arrays
            for dayOffset in 0..<7 {
                let currentDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
                let startOfDay = calendar.startOfDay(for: currentDate)
                results[startOfDay] = []  // Initialize with empty array
            }
            
            // Now assign workouts to their respective days
            for workout in workouts {
                guard let timestamp = workout.timestamp else { continue }
                let startOfDay = calendar.startOfDay(for: timestamp)
                
                // Append to existing array or create new one
                if results[startOfDay] != nil {
                    results[startOfDay]?.append(workout)
                } else {
                    results[startOfDay] = [workout]
                }
            }
            
            // Debug: Print workouts for each day of the week
            for dayOffset in 0..<7 {
                let currentDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
                let startOfDay = calendar.startOfDay(for: currentDate)
                let workoutsForDay = results[startOfDay] ?? []
                
                // Debug: Print workouts for this day
                if !workoutsForDay.isEmpty {
                    print("SharedPersistence - Day \(dayOffset): \(startOfDay) = \(workoutsForDay.count) workouts:")
                    for workout in workoutsForDay {
                        print("  - Type: \(workout.workoutType), Icon: \(getWorkoutIcon(for: workout.workoutType))")
                    }
                } else {
                    print("SharedPersistence - Day \(dayOffset): \(startOfDay) = No workouts")
                }
            }
            
        } catch {
            print("SharedPersistence - Error fetching workouts: \(error)")
        }
        
        return results
    }
} 
