import SwiftUI

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    
    var body: some View {
        VStack(alignment: .center, spacing: AppTheme.Spacing.xxxs) {
            Text(title)
                .font(AppTheme.Typography.monoSmall())
                .tracking(2)
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(AppTheme.Typography.monoCaption())
                    .foregroundColor(AppTheme.Colors.passportTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    PassportPageBackgroundView {
        VStack(spacing: 40) {
            SectionHeader(title: "VISAS & ENTRIES", subtitle: "Your travel stamps")
            SectionHeader(title: "IDENTIFICATION")
        }
        .padding()
    }
}//
//  SectionHeader.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/20/26.
//

