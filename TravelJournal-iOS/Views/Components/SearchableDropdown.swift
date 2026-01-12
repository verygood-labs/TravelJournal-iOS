import SwiftUI

/// A reusable searchable dropdown component that works with any Identifiable & Equatable type
/// Supports async search with debouncing, loading states, and passport-style theming
struct SearchableDropdown<Item: Identifiable & Equatable>: View {
    // Configuration
    let label: String
    let placeholder: String
    let helperText: String
    let selectedHelperText: String
    let displayText: (Item) -> String
    let search: (String) async throws -> [Item]
    
    // Binding to selected item
    @Binding var selectedItem: Item?
    
    // Internal state
    @State private var searchText = ""
    @State private var searchResults: [Item] = []
    @State private var isSearching = false
    @State private var showDropdown = false
    @State private var searchTask: Task<Void, Never>? = nil
    
    // Focus state
    @FocusState private var isFocused: Bool
    
    // Debounce delay in milliseconds
    var debounceDelay: UInt64 = 300_000_000
    
    init(
        label: String,
        placeholder: String = "Search...",
        helperText: String = "Type to search",
        selectedHelperText: String = "Selected",
        selectedItem: Binding<Item?>,
        displayText: @escaping (Item) -> String,
        search: @escaping (String) async throws -> [Item]
    ) {
        self.label = label
        self.placeholder = placeholder
        self.helperText = helperText
        self.selectedHelperText = selectedHelperText
        self._selectedItem = selectedItem
        self.displayText = displayText
        self.search = search
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
            // Label
            Text(label.uppercased())
                .font(AppTheme.Typography.inputLabel())
                .tracking(1)
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            // Search input and dropdown
            VStack(spacing: 0) {
                inputField
                
                if showDropdown && !searchResults.isEmpty {
                    dropdownList
                }
            }
            
            // Helper text
            Text(selectedItem != nil ? selectedHelperText : helperText)
                .font(AppTheme.Typography.monoCaption())
                .foregroundColor(AppTheme.Colors.passportTextMuted)
        }
        .onChange(of: searchText) { _, newValue in
            performSearch(query: newValue)
        }
        .onChange(of: isFocused) { _, focused in
            if !focused {
                // Delay hiding dropdown to allow button tap to register
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showDropdown = false
                }
            }
        }
    }
    
    // MARK: - Input Field
    private var inputField: some View {
        HStack {
            if let item = selectedItem {
                // Show selected item with clear button
                Text(displayText(item))
                    .font(AppTheme.Typography.monoMedium())
                    .foregroundColor(AppTheme.Colors.passportTextPrimary)
                
                Spacer()
                
                Button {
                    clearSelection()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.passportTextMuted)
                }
            } else {
                // Show search input
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.passportTextMuted)
                
                TextField(
                    "",
                    text: $searchText,
                    prompt: Text(placeholder)
                        .foregroundColor(AppTheme.Colors.passportTextPlaceholder)
                )
                .font(AppTheme.Typography.monoMedium())
                .foregroundColor(AppTheme.Colors.passportTextPrimary)
                .focused($isFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                
                if isSearching {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, 14)
        .background(
            isFocused
                ? AppTheme.Colors.passportInputBackground.opacity(1.5)
                : AppTheme.Colors.passportInputBackground
        )
        .overlay(
            RoundedRectangle(cornerRadius: showDropdown && !searchResults.isEmpty ? 0 : AppTheme.CornerRadius.medium)
                .stroke(
                    isFocused
                        ? AppTheme.Colors.passportInputBorderFocused
                        : AppTheme.Colors.passportInputBorder,
                    lineWidth: 2
                )
        )
        .clipShape(
            RoundedCorner(
                radius: AppTheme.CornerRadius.medium,
                corners: showDropdown && !searchResults.isEmpty ? [.topLeft, .topRight] : [.allCorners]
            )
        )
    }
    
    // MARK: - Dropdown List
    private var dropdownList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(searchResults) { item in
                    Button {
                        selectItem(item)
                    } label: {
                        HStack {
                            Text(displayText(item))
                                .font(AppTheme.Typography.monoMedium())
                                .foregroundColor(AppTheme.Colors.passportTextPrimary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, 12)
                        .background(AppTheme.Colors.passportInputBackground)
                    }
                    
                    if item.id as AnyHashable != searchResults.last?.id as AnyHashable {
                        Divider()
                            .background(AppTheme.Colors.passportInputBorder)
                    }
                }
            }
        }
        .frame(maxHeight: 180)
        .background(AppTheme.Colors.passportInputBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(AppTheme.Colors.passportInputBorder, lineWidth: 2)
        )
        .clipShape(
            RoundedCorner(radius: AppTheme.CornerRadius.medium, corners: [.bottomLeft, .bottomRight])
        )
    }
    
    // MARK: - Actions
    private func performSearch(query: String) {
        searchTask?.cancel()
        
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            showDropdown = false
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: debounceDelay)
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                isSearching = true
                showDropdown = true
            }
            
            do {
                let results = try await search(query)
                
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    searchResults = results
                    isSearching = false
                }
            } catch {
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    searchResults = []
                    isSearching = false
                }
            }
        }
    }
    
    private func selectItem(_ item: Item) {
        selectedItem = item
        searchText = ""
        searchResults = []
        showDropdown = false
        isFocused = false
    }
    
    private func clearSelection() {
        selectedItem = nil
        searchText = ""
        searchResults = []
    }
}

// MARK: - Rounded Corner Shape
/// A shape that allows rounding specific corners
struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
#Preview {
    struct PreviewItem: Identifiable, Equatable {
        let id: String
        let name: String
    }
    
    struct PreviewWrapper: View {
        @State private var selected: PreviewItem? = nil
        
        var body: some View {
            PassportPageBackgroundView {
                SearchableDropdown<PreviewItem>(
                    label: "Country",
                    placeholder: "Search for a country...",
                    helperText: "Type to search for your country",
                    selectedHelperText: "Your home country",
                    selectedItem: $selected,
                    displayText: { $0.name },
                    search: { query in
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        return [
                            PreviewItem(id: "1", name: "🇺🇸 United States"),
                            PreviewItem(id: "2", name: "🇬🇧 United Kingdom"),
                            PreviewItem(id: "3", name: "🇨🇦 Canada")
                        ].filter { $0.name.localizedCaseInsensitiveContains(query) }
                    }
                )
                .padding()
            }
        }
    }
    
    return PreviewWrapper()
}
