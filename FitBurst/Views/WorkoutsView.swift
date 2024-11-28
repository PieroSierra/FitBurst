//
//  WorkoutsView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI
import UIKit
import FSCalendar


struct WorkoutsView: View {
    @State var selectedDate: Date = Date()
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "dumbbell")
                    .imageScale(.large)
                Text("Workouts")
                    .font(.title)
                    .bold()
            }
            
            CalendarView(selectedDate: $selectedDate)
                .frame(height:400)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .padding()
            
            Divider()
            
            HStack {
                Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.title3)
                    .padding()
                    .animation(.bouncy(), value: selectedDate)
                Spacer()
            }
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greenBrandColor)
    }
}


struct CalendarView: View {
    @Binding var selectedDate: Date
    var body: some View {
        CalendarViewRepresentable(selectedDate: $selectedDate)
            .padding(.bottom)
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            .ignoresSafeArea(.all, edges: .top)
    }
}

struct CalendarViewRepresentable: UIViewRepresentable {
    typealias UIViewType = FSCalendar
    
    fileprivate var calendar = FSCalendar()
    @Binding var selectedDate: Date
    
    func makeUIView(context: Context) -> FSCalendar {
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        
        // Add this line to set Monday as first day
        calendar.firstWeekday = 2  // 1 is Sunday, 2 is Monday
        
        // Added the below code to change calendar appearance
        calendar.appearance.todayColor = UIColor( Color.darkGreenBrandColor)
        calendar.appearance.titleTodayColor = .black
        calendar.appearance.selectionColor = .orange
        calendar.appearance.eventDefaultColor = .orange
        calendar.appearance.titleTodayColor = .black
        calendar.appearance.titleFont = .boldSystemFont(ofSize: 20)
        calendar.appearance.titleWeekendColor = UIColor( Color.darkGreenBrandColor)
        calendar.appearance.headerMinimumDissolvedAlpha = 0.12
        calendar.appearance.headerTitleFont = .systemFont(ofSize: 20, weight: .bold )
        calendar.appearance.headerTitleColor = UIColor( Color.darkGreenBrandColor)
        calendar.appearance.headerDateFormat = "MMMM"
        calendar.scrollDirection = .vertical
        calendar.scope = .month
        calendar.clipsToBounds = false
        
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
                    let size = CGSize(width: 50, height: 50)
                    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                    originalImage.draw(in: CGRect(origin: .zero, size: size))
                    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    return resizedImage
                }
            }
            else if isWeekend(date: date) {
                return UIImage(systemName: "dumbbell")
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
            if isWeekend(date: date) {
                return false
            }
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
    WorkoutsView()
}

/*Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
 .font(.system(size: 28))
 .bold()
 .foregroundColor(Color.black)
 .padding()
 .animation(.spring(), value: selectedDate)
 .frame(width: 500)
 Divider().frame(height: 1) */
/* DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
 .padding(.horizontal)
 .datePickerStyle(.graphical) */
