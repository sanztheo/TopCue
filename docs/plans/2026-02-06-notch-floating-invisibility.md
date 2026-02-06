# TopCue Notch/Floating/Visibility Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Ajouter détection notch réelle, mode floating, invisibilité screen-sharing, persistance floating frame, multi-écran et fallback sans notch.

**Architecture:** `WindowManager` devient l’orchestrateur unique de configuration/positionnement du panel selon `PrompterState` (mode + visibilité). `NotchDetector` encapsule les APIs `NSScreen` pour isoler la logique multi-écran/notch. `PrompterView` rend dynamiquement le conteneur notch/floating et expose les nouveaux contrôles visuels.

**Tech Stack:** Swift 5.9+, SwiftUI, AppKit (`NSPanel`, notifications NSWindow/NSApplication), Observation `@Observable`, SwiftData.

---

### Task 1: Détection notch et calculs écran

**Files:**
- Create: `TopCue/TopCue/Utils/NotchDetector.swift`
- Modify: `TopCue/TopCue/Windows/WindowManager.swift`

1. Ajouter `NSScreen.hasNotch`, `NSScreen.notchHeight`, `NSScreen.notchRect`.
2. Ajouter `NotchDetector.screenWithNotch()`.
3. Brancher `WindowManager.positionAtNotch` sur écran avec notch + fallback principal.

### Task 2: État mode/visibilité et dimensions dynamiques

**Files:**
- Modify: `TopCue/TopCue/Models/PrompterState.swift`
- Modify: `TopCue/TopCue/Utils/Constants.swift`
- Modify: `TopCue/TopCue/Windows/WindowManager.swift`

1. Ajouter `PrompterMode` et flags (`isInvisible`, `hasDetectedNotch`, taille courante, etc.).
2. Calculer largeur notch dynamique `max(notchRect.width + 40, openWidth)`.
3. Synchroniser dimensions panel ↔ état UI.

### Task 3: Reconfiguration panel notch/floating + sharingType

**Files:**
- Modify: `TopCue/TopCue/Windows/FloatingPanel.swift`
- Modify: `TopCue/TopCue/Windows/WindowManager.swift`

1. Ajouter `configureInvisible()` / `configureVisible()`.
2. Ajouter configuration notch/floating (movable, shadow, fond, clipping côté vue).
3. Ajouter `toggleMode()` et `toggleVisibility()` dans `WindowManager`.

### Task 4: Persistance frame floating et notifications système

**Files:**
- Modify: `TopCue/TopCue/Windows/WindowManager.swift`

1. Encoder/décoder `CGRect` en string pour persistance.
2. Observer `NSWindow.didMoveNotification` et `NSWindow.didResizeNotification`.
3. Observer `NSApplication.didChangeScreenParametersNotification` pour repositionnement notch.

### Task 5: UI prompter et commandes menu

**Files:**
- Modify: `TopCue/TopCue/Views/Prompter/PrompterView.swift`
- Modify: `TopCue/TopCue/Views/Prompter/NotchShape.swift`
- Modify: `TopCue/TopCue/App/TopCueApp.swift`

1. Adapter `PrompterView` aux dimensions dynamiques et styles notch/floating.
2. Ajouter indicateur verrou visible/invisible + badge flash.
3. Ajouter note discrète “notch non détecté” en mode fallback.
4. Ajouter commandes menu: toggle mode (`⌘⇧P`) et invisibilité (`⌘⇧I`).

### Task 6: Tests ciblés et vérification

**Files:**
- Create/Modify: `TopCue/TopCueTests/PrompterStateTests.swift` (ou `TopCueTests.swift`)

1. Ajouter tests comportementaux pour `PrompterState` (toggle mode, toggle visibilité, états dérivés).
2. Lancer tests unitaires ciblés.
3. Lancer build projet pour validation compile AppKit/SwiftUI.
