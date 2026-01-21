import SwiftUI

struct CountryStampView: View {
    let stamp: CountryStamp
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xxs) {
            // Stamp image area
            ZStack(alignment: .topTrailing) {
                // Stamp image or placeholder
                stampImage
                
                // Visit count badge (only if > 1)
                if stamp.visitCount > 1 {
                    visitBadge
                }
            }
            
            // Country name
            Text(stamp.countryName.uppercased())
                .font(AppTheme.Typography.monoCaption())
                .tracking(0.5)
                .foregroundColor(AppTheme.Colors.passportTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
    
    private var stampImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.8),
                            Color.white.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .aspectRatio(1, contentMode: .fit)
            
            if let imageUrl = stamp.stampImageUrl,
               let url = APIService.shared.fullMediaURL(for: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(AppTheme.Spacing.xs)
                    case .failure:
                        flagPlaceholder
                    @unknown default:
                        flagPlaceholder
                    }
                }
            } else {
                flagPlaceholder
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 2, dash: [4, 4])
                )
                .foregroundColor(AppTheme.Colors.passportTextMuted.opacity(0.4))
        )
    }
    
    private var flagPlaceholder: some View {
        Text(flag(for: stamp.countryCode))
            .font(.system(size: 32))
    }
    
    private var visitBadge: some View {
        Text("\(stamp.visitCount)")
            .font(AppTheme.Typography.monoCaption())
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: 20, height: 20)
            .background(AppTheme.Colors.primary)
            .clipShape(Circle())
            .offset(x: 4, y: -4)
    }
    
    private func flag(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var flag = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            if let unicode = UnicodeScalar(base + scalar.value) {
                flag.append(String(unicode))
            }
        }
        return flag
    }
}//
//  CountryStampView.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/20/26.
//

