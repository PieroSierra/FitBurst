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
                    
                // Blackboard
                ZStack {
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
                  /*  .background(
                        Image("Blackboard")
                            .resizable()
                            .scaledToFill()
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10)
                    )
                    .shadow(radius: 10)
                    .scaleEffect(0.9)*/
                    .onTapGesture { selectedTab = Tab.calendar }

                    
                  /*  MascotView()
                        .offset(CGSize(width: -70, height: 0))*/
                }
                
                Spacer().frame(height: 20)
                
                
                Button (action: {
                    showWorkoutView.toggle()
                }) {
                    HStack {
                        Image(systemName: "dumbbell.fill").imageScale(.large)
                        Text("Record Workout")
                    }
                }.buttonStyle(GrowingButtonStyle())
                
                Spacer().frame(height: 20)
                
                /*
                 HStack {
                 Text("Your trophies:")
                 Spacer()
                 }.padding()*/
                
                TrophyBox(height: 200, scrollHorizontally: true)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                
                HStack {
                    Spacer()
                    Button (action: {
                        selectedTab = Tab.trophies
                    }) {
                        HStack {
                            //                            Image(systemName: "medal.fill").imageScale(.large)
                            Text("See all")
                        }
                    }.buttonStyle(GrowingButtonStyle())
                        .padding(0)
                        .padding(.trailing, 20)
                }
                
            }
            //     .frame(maxWidth: .infinity, maxHeight: .infinity)
            //.background(Color.greenBrandColor)
            if showWorkoutView == true {
                RecordWorkoutView(showWorkoutView: $showWorkoutView, selectedDate: $selectedDate)
            }
            // Week view with optional headers
            CalendarViewWeek(
                selectedDate: $selectedDate,
                showMonthHeader: false,     // These will now properly hide the headers
                showWeekdayHeader: false
            ).offset(y: 450)
        }.onAppear {showWorkoutView = false }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

#Preview {
    HomeView(selectedTab: .constant(.home))
}
