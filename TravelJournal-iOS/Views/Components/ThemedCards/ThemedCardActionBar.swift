//
//  ThemedCardActionBar.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/9/26.
//

import SwiftUI

// MARK: - Card Action Configuration

/// Configuration for card action buttons (save, etc.)
struct CardActionConfig {
    let saveCount: Int
    let isSaved: Bool
    let isInteractive: Bool
    let onSave: (() -> Void)?
    
    /// Preview configuration - shows action bar but disabled with 0 counts
    static var preview: CardActionConfig {
        CardActionConfig(saveCount: 0, isSaved: false, isInteractive: false, onSave: nil)
    }
    
    /// Interactive configuration for public journal view
    static func interactive(saveCount: Int, isSaved: Bool, onSave: @escaping () -> Void) -> CardActionConfig {
        CardActionConfig(saveCount: saveCount, isSaved: isSaved, isInteractive: true, onSave: onSave)
    }
}

// MARK: - Themed Card Action Bar

/// A themed action bar that appears at the bottom of cards.
struct ThemedCardActionBar: View {
    let config: CardActionConfig
    @Environment(\.journalTheme) private var theme
    
    var body: some View {
        HStack {
            Spacer()
            saveButton
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 16)
    }
    
    private var saveButton: some View {
        Button(action: {
            config.onSave?()
        }) {
            HStack(spacing: 4) {
                Image(systemName: config.isSaved ? "heart.fill" : "heart")
                    .font(.system(size: 14, weight: .medium))
                Text("\(config.saveCount)")
                    .font(theme.typography.labelFont(size: 12, weight: .medium))
            }
            .foregroundColor(config.isSaved ? Color.red : theme.colors.textMutedColor)
        }
        .buttonStyle(.plain)
        .disabled(!config.isInteractive)
        .opacity(config.isInteractive ? 1.0 : 0.6)
    }
}

// MARK: - Preview

#Preview("Interactive") {
    VStack(spacing: 20) {
        ThemedCardActionBar(config: .interactive(saveCount: 24, isSaved: false, onSave: {}))
            .background(Color.white)
        
        ThemedCardActionBar(config: .interactive(saveCount: 42, isSaved: true, onSave: {}))
            .background(Color.white)
    }
    .padding()
    .background(Color.gray.opacity(0.2))
    .journalTheme(.passport)
}

#Preview("Preview Mode") {
    ThemedCardActionBar(config: .preview)
        .background(Color.white)
        .padding()
        .background(Color.gray.opacity(0.2))
        .journalTheme(.passport)
}
