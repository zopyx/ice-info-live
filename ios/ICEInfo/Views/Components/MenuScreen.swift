import SwiftUI

struct MenuScreenView: View {
    let categories: [MenuCategory]
    let isLoading: Bool
    let onLoad: () -> Void
    let onRefresh: () -> Void

    @State private var selectedCategoryTitle: String? = nil

    private var allCategories: [MenuCategory] {
        categories.isEmpty ? sampleMenuCategories : categories
    }

    var body: some View {
        VStack(spacing: 0) {
            if isLoading && categories.isEmpty {
                loadingView
            } else if allCategories.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
        .onAppear {
            if categories.isEmpty { onLoad() }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Speisekarte wird geladen\u{2026}")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "fork.knife")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Aktuell keine Speisekarte")
                .font(.headline)
            Text("Die Bordgastronomie \u{00F6}ffnet nach Fahrtbeginn.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            categoryFilterBar
            itemList
            disclaimerText
        }
    }

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(allCategories, id: \.title) { category in
                    FilterChip(
                        label: category.title,
                        isSelected: selectedCategoryTitle == nil || selectedCategoryTitle == category.title
                    ) {
                        if selectedCategoryTitle == category.title {
                            selectedCategoryTitle = nil
                        } else {
                            selectedCategoryTitle = category.title
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color(.systemBackground))
    }

    private var itemList: some View {
        let filtered = selectedCategoryTitle.flatMap { sel in
            allCategories.first { $0.title == sel }
        }

        return ScrollView {
            LazyVStack(spacing: 0) {
                if let single = filtered {
                    categorySection(single)
                } else {
                    ForEach(allCategories, id: \.title) { category in
                        categorySection(category)
                    }
                }
            }
        }
        .refreshable { onRefresh() }
    }

    private func categorySection(_ category: MenuCategory) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(category.title)
                .font(.headline.weight(.bold))
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)

            ForEach(category.items) { item in
                MenuItemRow(item: item)
                if item.id != category.items.last?.id {
                    Divider()
                        .padding(.leading, 104)
                }
            }
        }
    }

    private var disclaimerText: some View {
        Text("Alle Preise inkl. gesetzlicher MwSt. \u{00C4}nderungen vorbehalten.")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(12)
    }
}

private struct MenuItemRow: View {
    let item: MenuItem

    var body: some View {
        HStack(spacing: 12) {
            imageView

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)

                if !item.subject.isEmpty {
                    Text(item.subject)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if !item.declarationKeys.isEmpty {
                    Text("Enth\u{00E4}lt: \(item.declarationKeys.joined(separator: ", "))")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }

                if let price = item.eurPrice {
                    Text("€ \(String(format: "%.2f", price))")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(red: 0.925, green: 0, blue: 0.086))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var imageView: some View {
        let urlString = "https://iceportal.de/" + item.imageUrl
        return AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            case .failure:
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
                    .frame(width: 72, height: 72)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.tertiary)
                    }
            case .empty:
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
                    .frame(width: 72, height: 72)
                    .overlay {
                        ProgressView()
                    }
            @unknown default:
                EmptyView()
            }
        }
    }
}

struct FilterChip: View {
    let label: String
    var isSelected: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? Color(.systemBackground) : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color(red: 0.925, green: 0, blue: 0.086) : Color(.systemGray6))
                .clipShape(Capsule())
        }
    }
}

#Preview {
    MenuScreenView(
        categories: [],
        isLoading: false,
        onLoad: {},
        onRefresh: {}
    )
}
