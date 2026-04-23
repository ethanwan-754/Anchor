import SwiftUI
import SwiftData


struct StatsView: View {
    @Bindable var viewModel: AnchorViewModel
    @Environment(\.dismiss) private var dismiss

    @Query private var allAnchors: [AnchorItem]

    private var sortedAnchors: [AnchorItem] {
        switch viewModel.sortOrder {
        case .score:   return allAnchors.sorted { $0.score > $1.score }
        case .visits:  return allAnchors.sorted { $0.visitCount > $1.visitCount }
        case .recent:  return allAnchors.sorted { $0.date > $1.date }
        case .grade:   return allAnchors.sorted { $0.scoreGrade < $1.scoreGrade }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    SummaryStrip(anchors: allAnchors)

                    if !allAnchors.isEmpty {
                        TagDistributionCard(anchors: allAnchors)
                        MoodDistributionCard(anchors: allAnchors)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            SectionLabel(text: "Leaderboard")
                            Spacer()
                            Picker("Sort", selection: $viewModel.sortOrder) {
                                ForEach(StatSortOrder.allCases, id: \.self) { order in
                                    Text(order.rawValue).tag(order)
                                }
                            }
                            .pickerStyle(.menu)
                            .font(AnchorDesign.captionFont)
                        }

                        if allAnchors.isEmpty {
                            EmptyLeaderboard()
                        } else {
                            ForEach(Array(sortedAnchors.enumerated()), id: \.element.id) { rank, anchor in
                                LeaderboardRow(rank: rank + 1, anchor: anchor)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}


struct SummaryStrip: View {
    let anchors: [AnchorItem]

    private var totalVisits: Int { anchors.reduce(0) { $0 + $1.visitCount } }
    private var avgScore: Int {
        guard !anchors.isEmpty else { return 0 }
        return anchors.reduce(0) { $0 + $1.score } / anchors.count
    }
    private var topGrade: String {
        anchors.map(\.scoreGrade).min() ?? "—"   // S < A < B (alphabetically inverted for grade)
    }

    var body: some View {
        HStack(spacing: 0) {
            StatCell(value: "\(anchors.count)", label: "Anchors", color: AnchorDesign.accent)
            Divider().frame(height: 40)
            StatCell(value: "\(totalVisits)", label: "Visits", color: AnchorDesign.accentAlt)
            Divider().frame(height: 40)
            StatCell(value: "\(avgScore)", label: "Avg Score", color: .orange)
        }
        .cardStyle()
    }
}

struct StatCell: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}


struct TagDistributionCard: View {
    let anchors: [AnchorItem]

    private var counts: [(AnchorTag, Int)] {
        AnchorTag.allCases
            .map { tag in (tag, anchors.filter { $0.tag == tag }.count) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
    }
    private var total: Int { anchors.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel(text: "By Tag")

            ForEach(counts, id: \.0) { tag, count in
                HStack(spacing: 10) {
                    Image(systemName: tag.systemIcon)
                        .font(.system(size: 12))
                        .foregroundStyle(tag.color)
                        .frame(width: 20)

                    Text(tag.rawValue)
                        .font(.system(size: 13))
                        .foregroundStyle(.primary)
                        .frame(width: 80, alignment: .leading)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(.systemFill)).frame(height: 8)
                            Capsule()
                                .fill(tag.color)
                                .frame(width: geo.size.width * CGFloat(count) / CGFloat(max(total, 1)), height: 8)
                        }
                    }
                    .frame(height: 8)

                    Text("\(count)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .frame(width: 20, alignment: .trailing)
                }
            }
        }
        .cardStyle()
    }
}


struct MoodDistributionCard: View {
    let anchors: [AnchorItem]

    private var counts: [(Mood, Int)] {
        Mood.allCases
            .map { mood in (mood, anchors.filter { $0.mood == mood }.count) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "By Mood")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(counts, id: \.0) { mood, count in
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(mood.color.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                Text(mood.emoji).font(.system(size: 22))
                            }
                            Text("\(count)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.primary)
                            Text(mood.rawValue)
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
}


struct LeaderboardRow: View {
    let rank: Int
    let anchor: AnchorItem

    private var rankColor: Color {
        switch rank {
        case 1: return Color(hex: "#FFD700")
        case 2: return Color(hex: "#C0C0C0")
        case 3: return Color(hex: "#CD7F32")
        default: return .secondary
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Text("#\(rank)")
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundStyle(rankColor)
                .frame(width: 30)

            Text(anchor.mood.emoji)
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text(anchor.title)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Label(anchor.tag.rawValue, systemImage: anchor.tag.systemIcon)
                        .font(.system(size: 10))
                        .foregroundStyle(anchor.tag.color)
                    Text("· \(anchor.visitCount) visits")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(anchor.score)")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(AnchorDesign.accent)
                Text(anchor.scoreGrade)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(anchor.gradeColor)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: AnchorDesign.chipRadius))
    }
}


struct EmptyLeaderboard: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("⚓")
                .font(.system(size: 40))
            Text("No anchors yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("Drop your first anchor to see stats here")
                .font(AnchorDesign.captionFont)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(30)
    }
}
