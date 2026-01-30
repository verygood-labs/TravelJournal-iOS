//
//  EditorDividerRow.swift
//  TravelJournal-iOS
//

import SwiftUI

struct EditorDividerRow: View {
    let block: EditorBlock
    var isDragging: Bool = false
    let onTap: () -> Void
    
    // Coordinate space name for hit testing (same as EditorBlockCard)
    static let dragHandleCoordinateSpace = "dragHandle"
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            // Drag handle with named coordinate space
            DragHandle(isActive: isDragging)
                .coordinateSpace(name: EditorDividerRow.dragHandleCoordinateSpace)
            
            // Divider content
            HStack(spacing: AppTheme.Spacing.sm) {
                Rectangle()
                    .fill(AppTheme.Colors.passportInputBorder)
                    .frame(height: 1)
                
                Image(systemName: "airplane")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.passportTextMuted)
                
                Rectangle()
                    .fill(AppTheme.Colors.passportInputBorder)
                    .frame(height: 1)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
        }
        .padding(.leading, AppTheme.Spacing.md)
        .padding(.trailing, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppTheme.Colors.passportPageDark
            .ignoresSafeArea()
        
        VStack(spacing: AppTheme.Spacing.md) {
            EditorDividerRow(
                block: EditorBlock.newDivider(order: 0),
                isDragging: false,
                onTap: {}
            )
            
            EditorDividerRow(
                block: EditorBlock.newDivider(order: 1),
                isDragging: true,
                onTap: {}
            )
        }
        .padding()
    }
}
