//
//  EditorView.swift
//  Notchie
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI
import SwiftData

/// Vue principale de l'editeur : sidebar (liste) + editeur de texte.
/// Contient le bouton "Presenter" pour ouvrir le prompteur.
struct EditorView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var selectedScript: Script?

    var windowManager: WindowManager

    var body: some View {
        NavigationSplitView {
            ScriptListView(selectedScript: $selectedScript)
        } detail: {
            if let selectedScript {
                EditorDetailView(
                    script: selectedScript,
                    windowManager: windowManager
                )
            } else {
                ContentUnavailableView(
                    "Aucun script selectionne",
                    systemImage: "doc.text",
                    description: Text("Selectionnez un script dans la liste ou creez-en un nouveau.")
                )
            }
        }
    }
}

// MARK: - Editor Detail

/// Vue detail : editeur de texte pour un script individuel.
struct EditorDetailView: View {

    @Bindable var script: Script
    var windowManager: WindowManager

    @FocusState private var isEditorFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar superieure
            editorToolbar

            Divider()

            // Editeur de texte
            TextEditor(text: $script.content)
                .font(.system(.body, design: .monospaced))
                .focused($isEditorFocused)
                .scrollContentBackground(.hidden)
                .padding(8)
                .onChange(of: script.content) {
                    script.modifiedAt = Date()
                }

            Divider()

            // Barre de statut
            statusBar
        }
        .navigationTitle(script.title)
        .onAppear {
            isEditorFocused = true
        }
    }

    // MARK: - Subviews

    private var editorToolbar: some View {
        HStack {
            // Titre editable
            TextField("Titre du script", text: $script.title)
                .textFieldStyle(.plain)
                .font(.title2.bold())
                .padding(.horizontal, 12)

            Spacer()

            // Favori
            Button {
                script.isFavorite.toggle()
            } label: {
                Image(systemName: script.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(script.isFavorite ? .yellow : .secondary)
            }
            .buttonStyle(.plain)

            // Bouton Presenter
            Button {
                windowManager.showPrompter(script: script)
            } label: {
                Label("Presenter", systemImage: "play.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 8)
    }

    private var statusBar: some View {
        HStack {
            Text("\(script.wordCount) mots")
            Text("·")
            Text("Duree estimee : \(script.formattedDuration)")
            Spacer()
            Text("Modifie \(script.modifiedAt.formatted(.relative(presentation: .named)))")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}
