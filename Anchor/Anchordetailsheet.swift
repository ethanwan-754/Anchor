import SwiftUI

struct AnchorDetailSheet: View {
    let anchor: AnchorItem
    @Bindable var viewModel: AnchorViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                   
                    DetailHeroView(anchor: anchor)

                    ScoreTriptych(anchor: anchor)

                    ScoreBreakdownCard(anchor: anchor)

                    MetadataTiles(anchor: anchor)

                    if !anchor.note.isEmpty {
                        NoteCard(note: anchor.note)
                    }

                    if let addr = anchor.resolvedAddress, !addr.isEmpty {
                        AddressCard(address: addr, environment: anchor.environment)
                    }

                    DetailActions(
                        anchor: anchor,
                        viewModel: viewModel,
                        showDeleteConfirm: $showDeleteConfirm,
                        dismiss: dismiss
                    )
                }
                .padding(20)
            }
            .navigationTitle(anchor.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        viewModel.flowState = .map
                        dismiss()
                    }
                }
            }
            .confirmationDialog("Remove this anchor?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Remove", role: .destructive) {
                    viewModel.delete(anchor, context: modelContext)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}


struct DetailHeroView: View {
    let anchor: AnchorItem

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AnchorDesign.cardRadius)
                .fill(anchor.tag.color.opacity(0.18))
                .frame(height: 110)

            HStack(spacing: 20) {
                Text(anchor.mood.emoji)
                    .font(.system(size: 52))

                VStack(alignment: .leading, spacing: 6) {
                    Label(anchor.tag.rawValue, systemImage: anchor.tag.systemIcon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(anchor.tag.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(anchor.tag.color.opacity(0.15), in: Capsule())

                    Text(anchor.date.formatted(date: .abbreviated, time: .shortened))
                        .font(AnchorDesign.captionFont)
                        .foregroundStyle(.secondary)

                    Text(anchor.mood.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(anchor.mood.color)
                }
                Spacer()
            }
            .padding(.horizontal, 18)
        }
    }
}


struct ScoreTriptych: View {
    let anchor: AnchorItem

    var body: some View {
        HStack(spacing: 0) {
            TriptychCell(value: anchor.scoreGrade, label: "Grade", color: anchor.gradeColor)
            Divider().frame(height: 44)
            TriptychCell(value: "\(anchor.score)", label: "Score", color: AnchorDesign.accent)
            Divider().frame(height: 44)
            TriptychCell(value: "\(anchor.visitCount)", label: "Visits", color: AnchorDesign.accentAlt)
        }
        .cardStyle()
    }
}

struct TriptychCell: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}


struct ScoreBreakdownCard: View {
    let anchor: AnchorItem

    private var rows: [(String, Int, Color)] {
        let ageWeeks = Calendar.current.dateComponents([.weekOfYear], from: anchor.date, to: Date()).weekOfYear ?? 0
        return [
            ("Base",         10,                                 .primary),
            ("Visits (×2)",  min(anchor.visitCount * 2, 20),    AnchorDesign.accentAlt),
            ("Mood",         anchor.mood.scoreWeight,            anchor.mood.color),
            ("Environment",  anchor.environment.scoreWeight,     AnchorDesign.accent),
            ("Note quality", anchor.note.count > 20 ? 3 : anchor.note.isEmpty ? 0 : 1, .orange),
            ("Age (weeks)",  min(ageWeeks, 5),                   .purple),
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "Score Breakdown")

            ForEach(rows, id: \.0) { label, points, color in
                HStack {
                    Text(label)
                        .font(.system(size: 13))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("+\(points)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(points > 0 ? color : .secondary)
                }
            }

            Divider()

            HStack {
                Text("Total")
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                Text("\(anchor.score)")
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .foregroundStyle(AnchorDesign.accent)
            }
        }
        .cardStyle()
    }
}


struct MetadataTiles: View {
    let anchor: AnchorItem

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetaTile(icon: anchor.environment.systemIcon, label: "Environment", value: anchor.environment.rawValue)
            MetaTile(icon: "location", label: "Coordinates",
                     value: String(format: "%.4f°N %.4f°E", anchor.latitude, anchor.longitude))
            MetaTile(icon: "calendar", label: "Added", value: anchor.date.formatted(date: .abbreviated, time: .omitted))
            MetaTile(icon: "repeat", label: "Visit count", value: "\(anchor.visitCount) time\(anchor.visitCount == 1 ? "" : "s")")
        }
    }
}

struct MetaTile: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 10))
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.8)
            }
            .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(padding: 12)
    }
}


struct NoteCard: View {
    let note: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(text: "Note")
            Text(note)
                .font(AnchorDesign.bodyFont)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .cardStyle()
    }
}


struct AddressCard: View {
    let address: String
    let environment: AnchorEnvironment

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: environment.systemIcon)
                .foregroundStyle(AnchorDesign.accent)
            VStack(alignment: .leading, spacing: 2) {
                SectionLabel(text: "Location (reverse geocoded)")
                Text(address)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .cardStyle()
    }
}


struct DetailActions: View {
    let anchor: AnchorItem
    @Bindable var viewModel: AnchorViewModel
    @Binding var showDeleteConfirm: Bool
    let dismiss: DismissAction

    var body: some View {
        VStack(spacing: 10) {
            Button {
                viewModel.markVisit(anchor)
            } label: {
                Label("Mark Visit  (+score)", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(colors: [AnchorDesign.accent, AnchorDesign.accentAlt],
                                       startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: AnchorDesign.buttonRadius)
                    )
            }

            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("Remove Anchor", systemImage: "trash")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(.secondarySystemBackground),
                                in: RoundedRectangle(cornerRadius: AnchorDesign.buttonRadius))
            }
        }
    }
}
