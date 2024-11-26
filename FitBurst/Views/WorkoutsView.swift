//
//  WorkoutsView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI

struct WorkoutsView: View {
    @State var selectedDate: Date = Date()

    var body: some View {        
        VStack{
            VStack() {
                Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 28))
                    .bold()
                    .foregroundColor(Color.black)
                    .padding()
                    .animation(.spring(), value: selectedDate)
                    .frame(width: 500)
                Divider().frame(height: 1)
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                    .padding(.horizontal)
                    .datePickerStyle(.graphical)
                Divider()
            }
            .padding(.vertical, 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greenBrandColor)
    }
}

#Preview {
    WorkoutsView()
}
