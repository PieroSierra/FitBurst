//
//  WorkoutsView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI
import UIKit
import FSCalendar
import CoreData

/// Main Calendar View
struct CalendarView: View {
    @StateObject private var config = WorkoutConfiguration.shared
    @State var selectedDate: Date = Date()
    @State var scale: CGFloat = 1
    @State private var showWorkoutView: Bool = false
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var context = PersistenceController.shared.container.viewContext
    @State private var workoutToDelete: Workouts? = nil
    @State private var showingDeleteConfirmation = false
    @State private var refreshCounter: Int = 0
    @State private var scrollToMonth: Int?
    
    var body: some View {
        ZStack {
            backgroundView
            mainContent
        }
        .onAppear { showWorkoutView = false }
        .alert("Delete Workout", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let workout = workoutToDelete {
                    PersistenceController.shared.deleteWorkout(workout: workout)
                    refreshCalendar()
                    RecordWorkoutView.recalculateAchievements()
                }
            }
        } message: {
            Text("Are you sure you want to delete this workout?")
        }
    }
    
    private var backgroundView: some View {
        Image("GradientWaves")
            .resizable()
            .ignoresSafeArea()
    }
    
    private var yearSelector: some View {
        HStack {
  
                Button(action: {
                    selectedYear -= 1
                }) {
                    Text(String(format: "%d", selectedYear-1))
                        .font(.custom("Futura Bold", fixedSize: 40))
                        .foregroundStyle(Color.gray)
                }
                
                Text(String(format: "%d", selectedYear))
                    .font(.custom("Futura Bold", fixedSize: 40))
                    .foregroundColor(.white)
                
                Button(action: {
                    selectedYear += 1
                }) {
                    Text(String(format: "%d", selectedYear+1))
                        .font(.custom("Futura Bold", fixedSize: 40))
                        .foregroundStyle(Color.gray)
                }
            
        }
    }
    
    private var calendarGrid: some View {
        ScrollViewReader { proxy in
            ScrollView {
                CalendarViewYear(
                    selectedDate: $selectedDate,
                    year: selectedYear,
                    refreshTrigger: refreshCounter
                )
                .scaleEffect(scale)
                .frame(height:600)
                .onChange(of: selectedDate) {
                    let month = Calendar.current.component(.month, from: selectedDate)
                    withAnimation {
                        proxy.scrollTo(month, anchor: .center)
                    }
                }
            }
        }
    }
    
    private var workoutsList: some View {
        VStack(alignment: .leading) {
            Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                .animation(.bouncy(), value: selectedDate)
                .fontWeight(.bold)
            
            let workouts = fetchWorkouts(for: selectedDate)
            
            ForEach(workouts, id: \Workouts.workoutID) { workout in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.limeAccentColor)
                    
                    let workoutName = config.getName(for: workout.workoutType)
                    Text(workoutName)
                    
                    Spacer()
                    Button(action: {
                        workoutToDelete = workout
                        showingDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, 7)
                .transition(.scale.combined(with: .opacity))
            }
            .animation(.bouncy(duration: 0.3), value: workouts)
        }
        .padding()
        .foregroundColor(.white)
        .background(Color.clear)
        .font(.body)
    }
    
    private var recordButton: some View {
        Button(action: {
            showWorkoutView.toggle()
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill").imageScale(.large)
                Text("Record")
            }
        }
        .padding()
        .buttonStyle(GrowingButtonStyle())
    }
    
    private var mainContent: some View {
        VStack {
            yearSelector
            calendarGrid
            
            HStack(alignment: .bottom) {
                workoutsList
                Spacer()
                recordButton
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(workoutOverlay)
    }
    
    @ViewBuilder
    private var workoutOverlay: some View {
        if showWorkoutView {
            RecordWorkoutView(
                showWorkoutView: $showWorkoutView,
                selectedDate: $selectedDate
            )
            .onDisappear {
                refreshCalendar()
            }
        }
    }
    
    private func fetchWorkouts(for date: Date) -> [Workouts] {
        let fetchRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timestamp == %@", Calendar.current.startOfDay(for: date) as NSDate)
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch workouts: \(error.localizedDescription)")
            return []
        }
    }
    
    private func refreshCalendar() {
        refreshCounter += 1
        NotificationCenter.default.post(name: NSNotification.Name("RefreshCalendar"), object: nil)
    }
}

// Create a base protocol for common calendar configuration
protocol CalendarViewConfigurable {
    var titleFont: UIFont { get }
    var weekdayFont: UIFont { get }
    var headerTitleFont: UIFont { get }
}

// Default configuration
struct DefaultCalendarConfig: CalendarViewConfigurable {
    var titleFont: UIFont = UIFont(name: "", size: 25) ?? .boldSystemFont(ofSize: 20)
    var weekdayFont: UIFont = UIFont(name: "", size: 16) ?? .boldSystemFont(ofSize: 10)
    var headerTitleFont: UIFont = UIFont(name: "", size: 25) ?? .systemFont(ofSize: 20, weight: .bold)
}

// Update YearCalendarConfig with even smaller fonts for better fit
struct YearCalendarConfig: CalendarViewConfigurable {
    var titleFont: UIFont = UIFont(name: "", size: 10) ?? .boldSystemFont(ofSize: 8)
    var weekdayFont: UIFont = UIFont(name: "", size: 8) ?? .boldSystemFont(ofSize: 6)
    var headerTitleFont: UIFont = UIFont(name: "", size: 12) ?? .systemFont(ofSize: 10, weight: .bold)
}

// Week view configuration
struct WeekCalendarConfig: CalendarViewConfigurable {
    var titleFont: UIFont = UIFont(name: "", size: 20) ?? .boldSystemFont(ofSize: 16)
    var weekdayFont: UIFont = UIFont(name: "", size: 14) ?? .boldSystemFont(ofSize: 10)
    var headerTitleFont: UIFont = UIFont(name: "", size: 20) ?? .systemFont(ofSize: 16, weight: .bold)
}

// Base calendar view
struct CalendarViewBase: View {
    @Binding var selectedDate: Date
    var config: CalendarViewConfigurable
    var scope: FSCalendarScope
    var height: CGFloat
    var rowHeight: CGFloat = 40
    var headerHeight: CGFloat = 40
    var weekdayHeight: CGFloat = 40
    var headerAlpha: CGFloat = 0.12
    var currentPage: Date?
    var allowsScrolling: Bool = true
    var showMonthHeader: Bool = true
    var showWeekdayHeader: Bool = true
    
    var body: some View {
        CalendarViewRepresentable(
            selectedDate: $selectedDate,
            config: config,
            scope: scope,
            rowHeight: rowHeight,
            headerHeight: headerHeight,
            weekdayHeight: weekdayHeight,
            headerAlpha: headerAlpha,
            currentPage: currentPage,
            allowsScrolling: allowsScrolling,
            showMonthHeader: showMonthHeader,
            showWeekdayHeader: showWeekdayHeader
        )
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .padding(EdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7))
    }
}

// Three specialized calendar views
struct CalendarViewMonth: View {
    @Binding var selectedDate: Date
    var config: CalendarViewConfigurable = DefaultCalendarConfig()
    
    var body: some View {
        CalendarViewBase(
            selectedDate: $selectedDate,
            config: config,
            scope: .month,
            height: 400
        )
    }
}

// Modify CalendarViewYear to use month scope with adjusted settings
struct CalendarViewYear: View {
    @Binding var selectedDate: Date
    var config: CalendarViewConfigurable = YearCalendarConfig()
    var year: Int = Calendar.current.component(.year, from: Date())
    var refreshTrigger: Int
    
    // Add this to track the current year for refresh purposes
    private let id: Int
    
    init(selectedDate: Binding<Date>, config: CalendarViewConfigurable = YearCalendarConfig(), year: Int, refreshTrigger: Int = 0) {
        self._selectedDate = selectedDate
        self.config = config
        self.year = year
        self.refreshTrigger = refreshTrigger
        self.id = year  // Store the year as an ID
    }
    
    // Define columns with equal flexible width and no spacing
    private let columns = [
        GridItem(.flexible(minimum: 0), spacing: 0),
        GridItem(.flexible(minimum: 0), spacing: 0),
        GridItem(.flexible(minimum: 0), spacing: 0)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let cellWidth = geometry.size.width / 3
            
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(0..<12) { monthIndex in
                    if let monthDate = Calendar.current.date(from: DateComponents(year: year, month: monthIndex + 1, day: 1)) {
                        MonthCell(date: monthDate,
                                  selectedDate: $selectedDate,
                                  config: config)
                        .frame(width: cellWidth)  // Force exact width
                    }
                }
            }
        }
        .id("\(id)_\(refreshTrigger)")  // Force view refresh when year changes
    }
}

// Helper view for individual month cells in the year view
private struct MonthCell: View {
    let date: Date
    @Binding var selectedDate: Date
    var config: CalendarViewConfigurable
    
    var body: some View {
        VStack(spacing: 0) {
            Text(date.formatted(.dateTime.month(.wide)))
                .font(.custom("Futura Bold", size: 14))
                .fontWeight(.bold)
                .foregroundColor(.limeAccentColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 0)
            
            CalendarViewBase(
                selectedDate: $selectedDate,
                config: config,
                scope: .month,
                height: 120,
                rowHeight: 20,
                headerHeight: 0,
                weekdayHeight: 15,
                headerAlpha: 1,
                currentPage: date,
                allowsScrolling: false,
                showMonthHeader: false,
                showWeekdayHeader: true
            )//.background(Color.red)
        }
        .id(Calendar.current.component(.month, from: date))
    }
}

// Helper extension to get start of year
extension Calendar {
    func startOfYear() -> Date {
        let components = DateComponents(year: component(.year, from: Date()), month: 1, day: 1)
        return date(from: components) ?? Date()
    }
}

struct CalendarViewWeekStatic: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        CalendarViewBase(
            selectedDate: $selectedDate,
            config: WeekCalendarConfig(),
            scope: .week,
            height: 100,               // Enough for 1 row + weekday labels
            rowHeight: 40,
            headerHeight: 0,          // No month header
            weekdayHeight: 20,        // Show day names
            currentPage: startOfThisWeek, // Monday of the current week
            allowsScrolling: false,
            showMonthHeader: false,
            showWeekdayHeader: true
        )
    }
    
    private var startOfThisWeek: Date {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: Date())
        // If firstWeekday=2 => Monday
        let daysSinceMonday = (weekday + 5) % 7 
        return cal.date(byAdding: .day, value: -daysSinceMonday, to: Date())!
    }
}


struct CalendarViewWeek: View {
    @Binding var selectedDate: Date
    var config: CalendarViewConfigurable = WeekCalendarConfig()
    var showMonthHeader: Bool = true
    var showWeekdayHeader: Bool = false
    
    // Optional external refresh trigger if you want to programmatically force it:
    @State private var localRefreshID = UUID()
    
    var body: some View {
        CalendarViewBase(
            selectedDate: $selectedDate,
            config: config,
            scope: .week,
            height: 300,
            rowHeight: 50,
            headerHeight: showMonthHeader ? 40 : 0,
            weekdayHeight: showWeekdayHeader ? 40 : 0
        )
        .id(localRefreshID)        // If you ever need to force redraw, just do localRefreshID = UUID()
        .frame(maxWidth: .infinity)
        .frame(height: 300)
    }
}

// Update CalendarViewRepresentable to handle year view differently
struct CalendarViewRepresentable: UIViewRepresentable {
    typealias UIViewType = FSCalendar
    
    fileprivate var calendar = FSCalendar()
    @Binding var selectedDate: Date
    var config: CalendarViewConfigurable
    var scope: FSCalendarScope
    var rowHeight: CGFloat
    var headerHeight: CGFloat
    var weekdayHeight: CGFloat
    var headerAlpha: CGFloat
    var currentPage: Date?
    var allowsScrolling: Bool
    var showMonthHeader: Bool
    var showWeekdayHeader: Bool
    
    func makeUIView(context: Context) -> FSCalendar {
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        
        calendar.firstWeekday = 2  // Monday = 2, Sunday = 1, etc.
        
        // --- Appearance configuration ---
        calendar.appearance.weekdayTextColor = .white
        calendar.appearance.weekdayFont = config.weekdayFont
        calendar.appearance.selectionColor = .white
        calendar.appearance.titleSelectionColor = .black
        calendar.appearance.todayColor = .gray
        calendar.appearance.titleTodayColor = .black
        calendar.appearance.eventDefaultColor = .clear
        calendar.appearance.titleFont = config.titleFont
        calendar.appearance.titleDefaultColor = .white
        calendar.appearance.titleWeekendColor = .white
        calendar.appearance.headerMinimumDissolvedAlpha = headerAlpha
        calendar.appearance.headerTitleFont = config.headerTitleFont
        calendar.appearance.headerTitleColor = .white
        calendar.appearance.headerDateFormat = "MMMM"
        
        calendar.headerHeight = headerHeight
        calendar.weekdayHeight = weekdayHeight
        calendar.appearance.caseOptions = .weekdayUsesSingleUpperCase
        
        // Hide or show headers according to flags
        calendar.appearance.headerTitleColor = showMonthHeader ? .white : .clear
        calendar.appearance.weekdayTextColor = showWeekdayHeader ? .white : .clear
        
        // Layout & scrolling
        calendar.rowHeight = rowHeight
        calendar.scrollDirection = .horizontal
        calendar.scope = scope
        calendar.clipsToBounds = false
        
        // The key fix for the “only one day” glitch in week scope:
        if scope == .week {
            calendar.placeholderType = .none
            calendar.adjustsBoundingRectWhenChangingMonths = true
            calendar.scrollEnabled = true
        } else {
            calendar.placeholderType = .none
            calendar.adjustsBoundingRectWhenChangingMonths = true
            // Single-selection
            calendar.allowsMultipleSelection = false
            
            if let currentPage = currentPage {
                calendar.setCurrentPage(currentPage, animated: false)
                calendar.scrollEnabled = false
            }
        }
        return calendar
    }
    
    var mondayOfSelectedDate: Date {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: selectedDate)
        let daysSinceMonday = (weekday + 5) % 7  // if Monday=2, Sunday=1, etc.
        return cal.date(byAdding: .day, value: -daysSinceMonday, to: selectedDate) ?? selectedDate
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
        uiView.scope = scope
        
        if scope == .week {
            let dateToSelect = mondayOfSelectedDate
            uiView.select(dateToSelect)
            uiView.reloadData()
        } else {
            // Clear old selections:
            for date in uiView.selectedDates {
                uiView.deselect(date)
            }
            if let currentPage = currentPage {
                let cal = Calendar.current
                // For month scope, we check the month
                // For week scope, you can check the weekOfYear or just let FSCalendar handle it
                let sameMonth = cal.isDate(selectedDate, equalTo: currentPage, toGranularity: .month)
                if sameMonth {
                    uiView.select(selectedDate)
                }
            } else {
                // If no fixed currentPage, just select the global selectedDate
                uiView.select(selectedDate)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        var parent: CalendarViewRepresentable
        
        init(_ parent: CalendarViewRepresentable) {
            self.parent = parent
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            let oldDate = parent.selectedDate
            print(">>> didSelect in subcalendar for month \(Calendar.current.component(.month, from: calendar.currentPage))")
            print("    oldDate = \(oldDate), newDate = \(date)")
            print("oldDate in local time = \(oldDate.formatted(date: .numeric, time: .omitted))")

            parent.selectedDate = date
            // Force calendar to refresh its appearance
            calendar.reloadData()
        }
        
        func calendar(_ calendar: FSCalendar,
                      numberOfEventsFor date: Date) -> Int {
            let eventDates = [Date(), Date(),
                              Date.now.addingTimeInterval(400000),
                              Date.now.addingTimeInterval(100000),
                              Date.now.addingTimeInterval(-600000),
                              Date.now.addingTimeInterval(-1000000)]
            var eventCount = 0
            eventDates.forEach { eventDate in
                if eventDate.formatted(date: .complete, time: .omitted) == date.formatted(date: .complete, time: .omitted) {
                    eventCount += 1;
                }
            }
            return eventCount
        }
        
        func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            true
        }
        
        func maximumDate(for calendar: FSCalendar) -> Date {
            .distantFuture
        }
        
        func minimumDate(for calendar: FSCalendar) -> Date {
            .distantPast
        }
    }
}

func isWeekend(date: Date) -> Bool {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    let day: String = dateFormatter.string(from: date)
    if day == "Saturday" || day == "Sunday" {
        return true
    }
    return false
}

// CalendarViewRepresentable Coordinator Update
extension CalendarViewRepresentable.Coordinator {
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timestamp == %@", Calendar.current.startOfDay(for: date) as NSDate)
        
        do {
            let count = try context.count(for: fetchRequest)
            
            if count > 0 {
                let isYearView = parent.config is YearCalendarConfig
                let isSelectedDate = Calendar.current.isDate(date, inSameDayAs: parent.selectedDate)
                
                let size: CGSize = isYearView ? CGSize(width: 13, height: 13) : CGSize(width: 34, height: 34)
                let checkmarkSize: CGFloat = isYearView ? 6 : 16
                let yOffset: CGFloat = isYearView ? 1.5 : 8
                
                let checkmarkConfig = UIImage.SymbolConfiguration(pointSize: checkmarkSize, weight: .black)
                let checkmark = UIImage(systemName: "checkmark", withConfiguration: checkmarkConfig)?.withTintColor(.black, renderingMode: .alwaysTemplate)
                
                UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
           //     if let context = UIGraphicsGetCurrentContext() {
                    let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size))
                    
                    if isSelectedDate {
                        UIColor.white.setFill()
                    } else {
                        UIColor(Color.limeAccentColor).setFill()
                    }
                    circlePath.fill()
                    
                    if let checkmark = checkmark {
                        let checkmarkRect = CGRect(
                            x: (size.width - checkmark.size.width) / 2,
                            y: (size.height - checkmark.size.height) / 2,
                            width: checkmark.size.width,
                            height: checkmark.size.height
                        )
                        checkmark.draw(in: checkmarkRect)
                    }
              // }
                
                let finalImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                let finalSize = CGSize(width: size.width, height: size.height + (isYearView ? 4 : 16))
                UIGraphicsBeginImageContextWithOptions(finalSize, false, 0.0)
                finalImage?.draw(at: CGPoint(x: 0, y: yOffset))
                let offsetImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                return offsetImage
            }
        } catch {
            print("Error fetching workouts for date \(date): \(error.localizedDescription)")
        }
        return nil
    }
}

struct SimpleWeekRow: View {
    @Binding var selectedDate: Date
    
    private let weekdays = ["M","T","W","T","F","S","S"]
    
    var body: some View {
        let cal = Calendar.current
        let start = startOfWeek(for: selectedDate)
        
        HStack(spacing: 20) {
            ForEach(0..<7, id: \.self) { i in
                let day = cal.date(byAdding: .day, value: i, to: start)!
                
                VStack(spacing: 4) {
                    // Top label: "M, T, W, T, F, S, S"
                    Text(weekdays[i])
                        .font(.custom("Futura Bold", fixedSize: 15))
                        .foregroundColor(.white)
                        .padding(.bottom, 4)
                    
                    // Bottom: either checkmark or day number
                    Group {
                        if cal.isDate(day, inSameDayAs: selectedDate) {
                            if hasWorkout(on: day) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.black)
                                    .frame(width: 31, height:31)
                                    .background(Circle().foregroundColor(.white))
                            } else {
                                Text("\(cal.component(.day, from: day))")
                                    .foregroundColor(.black)
                                    .frame(width: 31, height:31)
                                    .background(Circle().foregroundColor(.white))
                            }
                        } else if hasWorkout(on: day) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.black)
                                .frame(width: 31, height:31)
                                .background(Circle().foregroundColor(.limeAccentColor))
                        } else if cal.isDateInToday(day) {
                            Text("\(cal.component(.day, from: day))")
                                .foregroundColor(.black)
                                .frame(width: 31, height:31)
                                .background(Circle().foregroundColor(.gray))
                        } else {
                            Text("\(cal.component(.day, from: day))")
                                .foregroundColor(.white)
                                .frame(width: 31, height:31)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                .font(.custom("Futura Bold", fixedSize: 15))
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        selectedDate = day
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    /// Computes the Monday of the selectedDate’s week, assuming Monday is firstWeekday = 2.
    private func startOfWeek(for date: Date) -> Date {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday
        let weekday = cal.component(.weekday, from: date)
        let daysFromMonday = (weekday - cal.firstWeekday + 7) % 7
        return cal.date(byAdding: .day, value: -daysFromMonday, to: date) ?? date
    }
    
    /// Stub: replace with Core Data check for workouts, e.g. fetchWorkouts(day).count > 0
    private func hasWorkout(on date: Date) -> Bool {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timestamp == %@", Calendar.current.startOfDay(for: date) as NSDate)
        
        do {
            let count = try context.count(for: fetchRequest)
            if count > 0 {
                return true
            }
            else {
                return false
            }
        } catch {
            print("Error fetching workouts for date \(date): \(error.localizedDescription)")
        }
        return false
    }
}

#Preview ("12 month Calendar") {
    CalendarView()
        .environment(\.dynamicTypeSize, .medium)
        .preferredColorScheme(.light)
}

#Preview ("This Week Calendar") {
    ZStack {
        Image("GradientWaves")
            .resizable()
            .ignoresSafeArea()
        SimpleWeekRow(selectedDate: .constant(Date()))
    }

}
