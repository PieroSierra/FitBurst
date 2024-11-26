//
//  FormattedData.swift
//  FitBurst
//
//  Created by Piero Sierra on 26/11/2024.
//

import SwiftUI

struct FormattedDate: View {
    var selectedDate: Date
    var omitTime: Bool = false
    var body: some View {
        Text(selectedDate.formatted(date: .abbreviated, time:
                                        omitTime ? .omitted : .standard))
        .font(.system(size: 28))
        .bold()
        .foregroundColor(Color.accentColor)
        .padding()
        .animation(.spring(), value: selectedDate)
        .frame(width: 500)
    }
}

struct FormattedDate_Previews: PreviewProvider {
    static var previews: some View {
        FormattedDate(selectedDate: Date())
    }
}
