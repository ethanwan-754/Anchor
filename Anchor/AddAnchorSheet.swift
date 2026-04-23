import SwiftUI


struct AddAnchorSheet: View {
    @Bindable var viewModel: AnchorViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @FocusState private var titleFocused: Bool

    private var canSave: Bool {
        !viewModel.draftTitle.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {

                    GeocodingStatusCard(viewModel: viewModel)

                    VStack(alignment: .leading, spacing: 14) {
                        SectionLabel(text: "Details")

                        VStack(alignment: .leading, spacing: 5) {
                            Label("Title", systemImage: "textformat")
                                .font(AnchorDesign.captionFont)
                                .foregroundStyle(.secondary)
                            TextField("Name this anchor…", text: $viewModel.draftTitle)
                                .font(.system(size: 16, weight: .medium))
                                .focused($titleFocused)
                                .padding(12)
                                .background(Color(.secondarySystemBackground),
                                            in: RoundedRectangle(cornerRadius: AnchorDesign.chipRadius))
                        }

                        VStack(alignment: .leading, spacing: 5) {
                            Label("Note", systemImage: "note.text")
                                .font(AnchorDesign.captionFont)
                                .foregroundStyle(.secondary)
                            TextField("What made this moment?", text: $viewModel.draftNote, axis: .vertical)
                                .font(AnchorDesign.bodyFont)
                                .lineLimit(3...6)
                                .padding(12)
                                .background(Color(.secondarySystemBackground),
                                            in: RoundedRectangle(cornerRadius: AnchorDesign.chipRadius))
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(text: "Tag")
                        TagGrid(selected: $viewModel.draftTag)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(text: "Mood")
                        MoodRow(selected: $viewModel.draftMood)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(text: "Environment")
                        EnvironmentRow(selected: $viewModel.draftEnvironment)
                    }

                    ScorePreviewCard(viewModel: viewModel)
                }
                .padding(20)
            }
            .navigationTitle("New Anchor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.flowState = .map
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveAnchor(context: modelContext)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(!canSave)
                }
            }
            .onAppear { titleFocused = true }
        }
    }
}



struct GeocodingStatusCard: View {
    @Bindable var viewModel: AnchorViewModel

    var body: some View {
        HStack(spacing: 12) {
            switch viewModel.geocodingState {
            case .idle:
                Image(systemName: "location.slash")
                    .foregroundStyle(.secondary)
                Text("No location")
                    .font(AnchorDesign.captionFont)
                    .foregroundStyle(.secondary)

            case .loading:
                ProgressView()
                    .tint(AnchorDesign.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Detecting environment…")
                        .font(.system(size: 13, weight: .medium))
                    Text("Using reverse geocoding")
                        .font(AnchorDesign.captionFont)
                        .foregroundStyle(.secondary)
                }

            case .success(let result):
                Image(systemName: "location.fill")
                    .foregroundStyle(.green)
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.shortAddress.isEmpty ? "Location saved" : result.shortAddress)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.draftEnvironment.systemIcon)
                            .font(.system(size: 10))
                        Text("Auto-detected: \(viewModel.draftEnvironment.rawValue)")
                            .font(AnchorDesign.captionFont)
                    }
                    .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 16))

            case .failure(let error):
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Could not detect environment")
                        .font(.system(size: 13, weight: .medium))
                  
                    Text(error.localizedDescription ?? "Set it manually below")
                        .font(AnchorDesign.captionFont)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: AnchorDesign.chipRadius))
    }
}


struct TagGrid: View {
    @Binding var selected: AnchorTag
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(AnchorTag.allCases, id: \.self) { tag in
                Button { selected = tag } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tag.systemIcon)
                            .font(.system(size: 15))
                        Text(tag.rawValue)
                            .font(.system(size: 10, weight: .medium))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundStyle(selected == tag ? .white : .primary)
                    .background(
                        selected == tag ? tag.color : Color(.secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: AnchorDesign.chipRadius)
                    )
                }
            }
        }
    }
}


struct MoodRow: View {
    @Binding var selected: Mood

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    Button { selected = mood } label: {
                        VStack(spacing: 4) {
                            Text(mood.emoji).font(.system(size: 22))
                            Text(mood.rawValue).font(.system(size: 10, weight: .medium))
                        }
                        .frame(width: 66, height: 64)
                        .background(
                            selected == mood
                                ? mood.color.opacity(0.2)
                                : Color(.secondarySystemBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AnchorDesign.chipRadius)
                                .stroke(selected == mood ? mood.color : .clear, lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AnchorDesign.chipRadius))
                        .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
}


struct EnvironmentRow: View {
    @Binding var selected: AnchorEnvironment

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AnchorEnvironment.allCases, id: \.self) { env in
                    Button { selected = env } label: {
                        HStack(spacing: 6) {
                            Image(systemName: env.systemIcon).font(.system(size: 13))
                            Text(env.rawValue).font(.system(size: 13, weight: .medium))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .foregroundStyle(selected == env ? .white : .primary)
                        .background(
                            selected == env ? AnchorDesign.accent : Color(.secondarySystemBackground),
                            in: Capsule()
                        )
                    }
                }
            }
        }
    }
}


struct ScorePreviewCard: View {
    @Bindable var viewModel: AnchorViewModel

    private var previewScore: Int {
        10 + viewModel.draftMood.scoreWeight + viewModel.draftEnvironment.scoreWeight
        + (viewModel.draftNote.count > 20 ? 3 : viewModel.draftNote.isEmpty ? 0 : 1)
        + 2  
    }

    private var previewGrade: String {
        switch previewScore {
        case 35...:  return "S"
        case 28..<35: return "A"
        case 21..<28: return "B"
        case 14..<21: return "C"
        default:     return "D"
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                SectionLabel(text: "Starting Score")
                Text("Grows with visits, time & mood")
                    .font(AnchorDesign.captionFont)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("\(previewScore)")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(AnchorDesign.accent)
                Text(previewGrade)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(AnchorDesign.accentAlt)
            }
        }
        .cardStyle()
    }
}
