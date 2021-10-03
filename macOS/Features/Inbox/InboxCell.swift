//
//  InboxCell.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 16/09/21.
//

import SwiftUI

struct InboxCell: View {
        
    var username: String
    var subject: String
    var excerpt: String
    var isSeen: Bool
    var date: Date
    
    var dateString: String {
        
        if Calendar.current.isDateInToday(date) {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return formatter.localizedString(for: date, relativeTo: Date())
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6.0) {
            HStack {
                Circle()
                    .foregroundColor(.accentColor)
                    .frame(width: 8, height: 8)
                    .padding(.leading, 2)
                    .opacity(isSeen ? 0 : 1)
                
                Text(username)
                    .font(.system(size: 13))
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Spacer()
                Text(dateString)
                    .font(.system(size: 11))
                    .opacity(0.7)
            }

            Text(subject)
                .font(.system(size: 11))
                .lineLimit(/*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                .padding(.leading, 20)

            Text(excerpt)
                .font(.system(size: 11))
                .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                .opacity(0.7)
                .padding(.leading, 20)
            Divider()
                .padding(.leading, 20)
        }
        .padding(.leading, 8)
    }
}

struct InboxCell_Previews: PreviewProvider {
    static var previews: some View {
        InboxCell(username: "Swiggy",
                  subject: "Your Swiggy order was delivered superfast!",
                  excerpt: "Your order was delivered within 43 minutes."
                    + "Rate this lightning fast delivery and add a tip for your delivery partner here",
                  isSeen: true,
                  date: Date())
    }
}
