//
//  ThemedStatsBar.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/9/26.
//

import SwiftUI

// MARK: - Header Stats Configuration

/// Configuration for header stats bar (views + saves)
struct HeaderStatsConfig {
    let viewCount: Int
    let saveCount: Int
    
    /// Preview configuration - shows stats bar with 0 counts
    static var preview: HeaderStatsConfig {
        HeaderStatsConfig(viewCount: 0, saveCount: 0)
    }
}

// MARK: - Themed Header Stats Bar

/// A themed stats pill that appears at the bottom of the journal header card.
struct ThemedHeaderStatsBar: View {
    let config: HeaderStatsConfig
    @Environment(\.journalTheme) private var theme
    
    var body: some View {
        HStack(spacing: 12) {
            // View count
            HStack(spacing: 4) {
                Image(systemName: "eye")
                    .font(.system(size: 12, weight: .medium))
                Text("\(config.viewCount)")
                    .font(theme.typography.labelFont(size: 12, weight: .medium))
            }
            
            // Save count
            HStack(spacing: 4) {
                Image(systemName: "bookmark")
                    .font(.system(size: 12, weight: .medium))
                Text("\(config.saveCount)")
                    .font(theme.typography.labelFont(size: 12, weight: .medium))
            }
        }
        .foregroundColor(theme.colors.textMutedColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(theme.colors.borderColor.opacity(0.15))
        )
    }
}

// MARK: - Preview

#Preview("Stats Bar") {
    VStack(spacing: 20) {
        ThemedHeaderStatsBar(config: HeaderStatsConfig(viewCount: 1234, saveCount: 56))
        ThemedHeaderStatsBar(config: .preview)
    }
    .padding()
    .background(Color(hex: "#f5f1e8"))
    .journalTheme(.passport)
}
