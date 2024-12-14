//
//  HomeView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Tab
    @State private var showWorkoutView: Bool = false
    @State var selectedDate: Date = Date()
    
    let gradientColors = Gradient(colors: [.blueBrandColor, .orangeBrandColor,.greenBrandColor,.blueBrandColor,.purpleBrandColor,.pinkBrandColor])
    
    var body: some View {
        ZStack {
            Image("GradientWaves").resizable().edgesIgnoringSafeArea(.all)
            ScrollView {
                Text("FitBurst")
                    .font(.custom("Futura Bold", size: 40))
                    .foregroundColor(.white)
                    .padding(.bottom, 0)
        
                /// Workouts Counter
                VStack (alignment: .center) {
                    Text("18")
                        .font(.custom("Futura Bold", size: 80))
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .foregroundColor(.limeAccentColor)
                        .padding(0)
                        .padding(.top, -10)
                    Text ("WORKOUTS")
                        .font(.custom("Futura Bold", size: 16))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                }
                .frame(minWidth: 190, minHeight: 130)
                .onTapGesture { selectedTab = Tab.calendar }
                
                Spacer().frame(height: 20)

                /// Week view with optional headers
                CalendarViewWeek(
                    selectedDate: $selectedDate,
                    showMonthHeader: false,     /// show Month
                    showWeekdayHeader: false    /// show Days
                )
                .frame(height: 50)
                .offset(y: 130)
                
                
                Spacer().frame(height: 30)

                Button (action: {
                    showWorkoutView.toggle()
                }) {
                    HStack {
                        Image(systemName: "dumbbell.fill").imageScale(.large)
                        Text("Record Workout")
                    }
                }.buttonStyle(GrowingButtonStyle())
                
                Spacer().frame(height: 40)
                
                /*
                 HStack {
                 Text("Your trophies:")
                 Spacer()
                 }.padding()*/
                
                TrophyBox(height: 200, scrollHorizontally: true)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .onTapGesture { selectedTab = Tab.trophies }
                
            }
            //     .frame(maxWidth: .infinity, maxHeight: .infinity)
            //.background(Color.greenBrandColor)
            if showWorkoutView == true {
                RecordWorkoutView(showWorkoutView: $showWorkoutView, selectedDate: $selectedDate)
            }
            
        }.onAppear {showWorkoutView = false }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

#Preview {
    HomeView(selectedTab: .constant(.home))
}
