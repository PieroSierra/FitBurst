//
//  WorkoutsView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI
import UIKit
import FSCalendar

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
        .frame(height: height)
        .padding(.bottom)
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
        .ignoresSafeArea(.all, edges: .top)
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
    var year: Int = Calendar.current.component(.year, from: Date())  // Default to current year
    private let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(0..<12) { monthIndex in
                if let monthDate = Calendar.current.date(from: DateComponents(year: year, month: monthIndex + 1, day: 1)) {
                    MonthCell(date: monthDate, 
                             selectedDate: $selectedDate, 
                             config: config)
                }
            }
        }
    }
}

// Helper view for individual month cells in the year view
private struct MonthCell: View {
    let date: Date
    @Binding var selectedDate: Date
    var config: CalendarViewConfigurable
    
    var body: some View {
        VStack {
            Text(date.formatted(.dateTime.month(.wide)))
                .font(.custom("", size: 14))
                .foregroundColor(.limeAccentColor)
                .padding(0)
            
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
            )
            .scaleEffect(1)
            .padding(0)
        }
   
    }
}

// Helper extension to get start of year
extension Calendar {
    func startOfYear() -> Date {
        let components = DateComponents(year: component(.year, from: Date()), month: 1, day: 1)
        return date(from: components) ?? Date()
    }
}

struct CalendarViewWeek: View {
    @Binding var selectedDate: Date
    var config: CalendarViewConfigurable = WeekCalendarConfig()
    // Add toggles for header elements
    var showMonthHeader: Bool = true
    var showWeekdayHeader: Bool = false
    
    var body: some View {
        CalendarViewBase(
            selectedDate: $selectedDate,
            config: config,
            scope: .week,
            height: 300,
            headerHeight: showMonthHeader ? 40 : 0,
            weekdayHeight: showWeekdayHeader ? 40 : 0
        )
    }
}

struct CalendarView: View {
    @State var selectedDate: Date = Date()
    @State var scale: CGFloat = 0.6
    @State private var showWorkoutView: Bool = false
    
    var body: some View {
        ZStack {
            /// Blackboard waves
            Image("GradientWaves").resizable().ignoresSafeArea()
            
            VStack {
                Text("Calendar")
                    .font(.custom("Futura Bold", size: 40))
                    .foregroundColor(.white)
                
                ScrollView {
                    // CalendarViewMonth(selectedDate: $selectedDate).scaleEffect(scale)

                    // Custom year view with grid of months
                    CalendarViewYear(
                        selectedDate: $selectedDate,
                        year: 2024  // Or use current year: Calendar.current.component(.year, from: Date())
                    )
                    .scaleEffect(scale)
                    
                    
                    HStack {
                        Text("Awards for\n" + selectedDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .animation(.bouncy(), value: selectedDate)
                        Spacer()
                    }
                    Spacer()
                }
                .onAppear {
                    scale = 0.6
                    withAnimation(.bouncy) { scale = 1.15 }
                    withAnimation(.bouncy.delay(0.25)) { scale = 1 }
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
           // .background(Color.greenBrandColor)
            .overlay(
                Button (action: {
                    showWorkoutView.toggle()
                }) {
                    HStack {
                        Image(systemName: "dumbbell.fill").imageScale(.large)
                        Text("Record Workout")
                    }
                }.padding()
                    .buttonStyle(GrowingButtonStyle()),
                alignment: .bottomTrailing)
           
            
            if showWorkoutView == true {
                RecordWorkoutView(showWorkoutView: $showWorkoutView, selectedDate: $selectedDate)
            }
        }.onAppear { showWorkoutView = false }
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
        calendar.firstWeekday = 2
        
        // Apply configuration
        calendar.appearance.weekdayTextColor = .white
        calendar.appearance.weekdayFont = config.weekdayFont
        calendar.appearance.selectionColor = .orange
        calendar.appearance.todayColor = UIColor(Color.limeAccentColor)
        calendar.appearance.titleTodayColor = .black
        calendar.appearance.eventDefaultColor = .orange
        calendar.appearance.titleFont = config.titleFont
        calendar.appearance.titleDefaultColor = .white
        calendar.appearance.titleWeekendColor = UIColor(Color.gray)
        calendar.appearance.headerMinimumDissolvedAlpha = headerAlpha
        calendar.appearance.headerTitleFont = config.headerTitleFont
        calendar.appearance.headerTitleColor = .white
        calendar.appearance.headerDateFormat = "MMMM"
        
        // Add these lines to properly hide headers
        calendar.headerHeight = headerHeight
        calendar.weekdayHeight = weekdayHeight
        calendar.appearance.headerMinimumDissolvedAlpha = headerAlpha
        calendar.appearance.caseOptions = .weekdayUsesSingleUpperCase
        
        // These are the proper toggles to hide headers
        calendar.appearance.headerTitleColor = showMonthHeader ? .white : .clear
        calendar.appearance.weekdayTextColor = showWeekdayHeader ? .white : .clear
        
        calendar.rowHeight = rowHeight
        calendar.scrollDirection = .horizontal
        calendar.scope = scope
        calendar.clipsToBounds = false
        
        // Disable scrolling for year view cells
        calendar.scrollEnabled = allowsScrolling
        
        // Set the current page if provided and prevent it from changing
        if let currentPage = currentPage {
            calendar.setCurrentPage(currentPage, animated: false)
        }
        
        // Add these lines to control placeholder dates
        calendar.placeholderType = .fillHeadTail // or .fillSixRows
        calendar.appearance.titlePlaceholderColor = UIColor.clear // Adjust color as needed
        
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        var parent: CalendarViewRepresentable
        
        init(_ parent: CalendarViewRepresentable) {
            self.parent = parent
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
        }
        
        func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
            // Create calendar instance for date comparison
            let calendar = Calendar.current
            
            // Check if the date is tomorrow
            if calendar.isDateInTomorrow(date) {
                // Get the custom image
                if let originalImage = UIImage(named: "LogoSqClear") {
                    // Resize the image to appropriate size for calendar (e.g., 20x20)
                    let size = CGSize(width: 20, height: 20)
                    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                    originalImage.draw(in: CGRect(origin: .zero, size: size))
                    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    return resizedImage
                }
            }
            else if isWeekend(date: date) {
                return nil ///return UIImage(systemName: "dumbbell")
            }
            return nil
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
            // Remove or comment out the weekend check to allow weekend selection
            // if isWeekend(date: date) {
            //     return false
            // }
            return true
        }
        
        func maximumDate(for calendar: FSCalendar) -> Date {
            Date.now.addingTimeInterval(86400 * 30)
        }
        
        func minimumDate(for calendar: FSCalendar) -> Date {
            Date.now.addingTimeInterval(-86400 * 30 * 4)
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

func isAward(date: Date) -> Bool {
    
    return false
}

func isWorkoutDay(date: Date) -> Bool {
    
    return false
}


#Preview {
    CalendarView()
}
