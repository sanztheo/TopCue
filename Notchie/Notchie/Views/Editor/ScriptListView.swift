//
//  ScriptListView.swift
//  Notchie
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI
import SwiftData

/// Sidebar : liste des scripts avec recherche, ajout et suppression.
struct ScriptListView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Script.modifiedAt, order: .reverse) private var scripts: [Script]

    @Binding var selectedScript: Script?

    @State private var searchText = ""

    private var filteredScripts: [Script] {
        if searchText.isEmpty {
            return scripts
        }
        return scripts.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List(selection: $selectedScript) {
            ForEach(filteredScripts) { script in
                NavigationLink(value: script) {
                    scriptRow(script)
                }
            }
            .onDelete(perform: deleteScripts)
        }
        .searchable(text: $searchText, prompt: "Rechercher...")
        .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        .toolbar {
            ToolbarItem {
                Button(action: addScript) {
                    Label("Nouveau script", systemImage: "plus")
                }
            }
        }
    }

    // MARK: - Subviews

    private func scriptRow(_ script: Script) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if script.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
                Text(script.title)
                    .font(.headline)
                    .lineLimit(1)
            }
            HStack(spacing: 8) {
                Text("\(script.wordCount) mots")
                Text("·")
                Text(script.formattedDuration)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    // MARK: - Actions

    private func addScript() {
        withAnimation {
            let script = Script(title: "Sans titre", content: "")
            modelContext.insert(script)
            selectedScript = script
        }
    }

    private func deleteScripts(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let script = filteredScripts[index]
                if selectedScript?.id == script.id {
                    selectedScript = nil
                }
                modelContext.delete(script)
            }
        }
    }
}
