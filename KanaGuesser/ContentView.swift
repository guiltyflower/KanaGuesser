import SwiftUI

enum AppMode {
    case menu
    case learn
    case multiplayer
}

struct ContentView: View {
    @State private var mode: AppMode = .menu
    @State private var selectedScripts: Set<Script> = [.hiragana, .katakana]

    var body: some View {
        Group {
            switch mode {
            case .menu:
                MenuView(
                    selectedScripts: $selectedScripts,
                    onLearn: { mode = .learn },
                    onMultiplayer: { mode = .multiplayer }
                )
            case .learn:
                LearnView(scripts: selectedScripts) { mode = .menu }
            case .multiplayer:
                MultiplayerView(scripts: selectedScripts) { mode = .menu }
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

private struct MenuView: View {
    @Binding var selectedScripts: Set<Script>
    let onLearn: () -> Void
    let onMultiplayer: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 6) {
                Text("KanaGuesser")
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                Text("Scegli una modalità")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            scriptSelector
                .padding(.top, 4)

            VStack(spacing: 14) {
                modeButton(
                    title: "Impara",
                    subtitle: "Allenati da solo",
                    system: "book.fill",
                    tint: .accentColor,
                    action: onLearn
                )

                modeButton(
                    title: "Sfida",
                    subtitle: "2 giocatori a turni",
                    system: "person.2.fill",
                    tint: .orange,
                    action: onMultiplayer
                )
            }
            .padding(.horizontal, 8)

            Spacer()
        }
        .padding(24)
    }

    private var scriptSelector: some View {
        VStack(spacing: 8) {
            Text("Alfabeti")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(Script.allCases) { script in
                    let on = selectedScripts.contains(script)
                    Button {
                        toggle(script)
                    } label: {
                        Text(script.label)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule().fill(on ? Color.accentColor : Color(.tertiarySystemFill))
                            )
                            .foregroundStyle(on ? Color.white : Color.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func toggle(_ script: Script) {
        var next = selectedScripts
        if next.contains(script) {
            if next.count > 1 { next.remove(script) }
        } else {
            next.insert(script)
        }
        selectedScripts = next
    }

    private func modeButton(
        title: String,
        subtitle: String,
        system: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: system)
                    .font(.title.bold())
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(tint.opacity(0.15)))
                    .foregroundStyle(tint)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(.tertiary)
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
