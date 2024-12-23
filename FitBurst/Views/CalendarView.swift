//
//  WorkoutsView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI
import UIKit
import FSCalendar

/// Main Calendar View
struct CalendarView: View {
    @State var selectedDate: Date = Date()
    @State var scale: CGFloat = 1
    @State private var showWorkoutView: Bool = false
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        ZStack {
            /// Blackboard waves
            Image("GradientWaves").resizable().ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                        selectedYear -= 1
                    }) {
                        Image(systemName: "chevron.backward.circle")
                            .foregroundColor(.white)
                            .imageScale(.large)
                    }
                    
                    Text(String(format: "%d", selectedYear))
                        .font(.custom("Futura Bold", size: 40))
                        .foregroundColor(.white)
                    
                    Button(action: {
                        selectedYear += 1
                    }) {
                        Image(systemName:"chevron.forward.circle")
                            .foregroundColor(.white)
                            .imageScale(.large)
                    }
                }
                
                ScrollView {
                    // CalendarViewMonth(selectedDate: $selectedDate).scaleEffect(scale)
                    
                    // Custom year view with grid of months
                    CalendarViewYear(
                        selectedDate: $selectedDate,
                        year: selectedYear
                    )
                    .scaleEffect(scale)
                    .frame(height:650)
                    
                    
                    HStack (alignment: .top) {
                        VStack (alignment: .leading){
                            Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                                .animation(.bouncy(), value: selectedDate)
                                .fontWeight(.bold)
                            HStack {
                                /* TrophyIconView(
                                 showTrophyDisplayView: $showTrophyDisplayView,
                                 selectedTrophy: $selectedTrophy,
                                 trophyType: trophy
                                 )*/
                                Text("5 in a row!")
                                Spacer()
                                Image(systemName: "trash.fill")
                                    .imageScale(.large)
                                    .foregroundColor(Color.red)
                            }
                            HStack {
                                Text("First Perfect Week")
                                Spacer()
                                Image(systemName: "trash.fill")
                                    .imageScale(.large)
                                    .foregroundColor(Color.red)
                            }
                        }
                        .padding()
                        .foregroundColor(.white)
                        .font(.body)
                        
                        Spacer()
                        
                        Button (action: {
                            showWorkoutView.toggle()
                        }) {
                            HStack {
                                Image(systemName: "dumbbell.fill").imageScale(.large)
                                Text("Record")
                            }
                        }.padding()
                            .buttonStyle(GrowingButtonStyle())
                    }
                    
                    Spacer()
                    Spacer()
                   
                }
                /*                .onAppear {
                 scale = 0.6
                 withAnimation(.bouncy) { scale = 1 }
                 withAnimation(.bouncy.delay(0.25)) { scale = 1 }
                 }*/
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // .background(Color.greenBrandColor)
            
            
            
            if showWorkoutView == true {
                RecordWorkoutView(showWorkoutView: $showWorkoutView, selectedDate: $selectedDate)
            }
        }.onAppear { showWorkoutView = false }
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
    var year: Int = Calendar.current.component(.year, from: Date())
    
    // Add this to track the current year for refresh purposes
    private let id: Int
    
    init(selectedDate: Binding<Date>, config: CalendarViewConfigurable = YearCalendarConfig(), year: Int) {
        self._selectedDate = selectedDate
        self.config = config
        self.year = year
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
        .id(id)  // Force view refresh when year changes
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
                .padding(.vertical, 2)
            
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
        calendar.appearance.selectionColor = UIColor(Color.limeAccentColor)
        calendar.appearance.titleSelectionColor = .black
        calendar.appearance.todayColor = .white
        calendar.appearance.titleTodayColor = .black
        calendar.appearance.eventDefaultColor = .clear
        calendar.appearance.titleFont = config.titleFont
        calendar.appearance.titleDefaultColor = .white
        calendar.appearance.titleWeekendColor = .white
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
        
        // Force single selection per calendar instance
        calendar.allowsMultipleSelection = false
        
        // Force 6 rows display and handle placeholders
        calendar.placeholderType = .fillSixRows  // Change from .fillHeadTail
        calendar.appearance.titlePlaceholderColor = UIColor(white: 1, alpha: 0.2) // Make placeholders visible but subtle
        
        // Ensure calendar fills all available space
        calendar.adjustsBoundingRectWhenChangingMonths = false
        
        if let currentPage = currentPage {
            calendar.setCurrentPage(currentPage, animated: false)
            calendar.scrollEnabled = false
        }
        
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
        // Always start fresh
        for date in uiView.selectedDates {
            uiView.deselect(date)
        }
        
        // If currentPage is set, check if selectedDate is in the same month
        if let currentPage = currentPage {
            let cal = Calendar.current
            let sameMonth = cal.isDate(selectedDate, equalTo: currentPage, toGranularity: .month)
            
            // 3. If the global selectedDate is in this month, visually select it
            if sameMonth {
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
            // This is all you need: set the single global binding,
            // which triggers SwiftUI to update the entire view hierarchy.
            parent.selectedDate = date
        }
        
        func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
            let calendar = Calendar.current
            
            // Check if the date is tomorrow
            if calendar.isDateInTomorrow(date) {
                // Determine if we're in year view by checking config type
                let isYearView = parent.config is YearCalendarConfig
                
                // Adjust sizes based on view type
                let size: CGSize = isYearView ? CGSize(width: 13, height: 13) : CGSize(width: 34, height: 34)
                let checkmarkSize: CGFloat = isYearView ? 6 : 16
                let yOffset: CGFloat = isYearView ? 1.5 : 8
                
                // Create a checkmark image
                let checkmarkConfig = UIImage.SymbolConfiguration(pointSize: checkmarkSize, weight: .black)
                let checkmark = UIImage(systemName: "checkmark", withConfiguration: checkmarkConfig)?
                    .withTintColor(.black, renderingMode: .alwaysTemplate)
                
                UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                
                if let context = UIGraphicsGetCurrentContext() {
                    // Draw lime circle
                    let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size))
                    UIColor(Color.limeAccentColor).setFill()
                    circlePath.fill()
                    
                    // Draw checkmark in center
                    if let checkmark = checkmark {
                        let checkmarkRect = CGRect(
                            x: (size.width - checkmark.size.width) / 2,
                            y: (size.height - checkmark.size.height) / 2,
                            width: checkmark.size.width,
                            height: checkmark.size.height
                        )
                        checkmark.draw(in: checkmarkRect)
                    }
                }
                
                let finalImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                // Add offset to move image up
                let finalSize = CGSize(width: size.width, height: size.height + (isYearView ? 4 : 16))
                UIGraphicsBeginImageContextWithOptions(finalSize, false, 0.0)
                finalImage?.draw(at: CGPoint(x: 0, y: yOffset))
                let offsetImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                return offsetImage
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
            return Date.distantFuture
        }
        
        func minimumDate(for calendar: FSCalendar) -> Date {
            return Date.distantPast
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
