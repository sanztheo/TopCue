#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

WORKSPACE_PATH="$REPO_ROOT/TopCue/TopCue.xcodeproj/project.xcworkspace"
SCHEME="TopCue"
CONFIGURATION="Debug"
DESTINATION="platform=macOS,arch=arm64"

LOGS_DIR="$REPO_ROOT/docs/logs"
mkdir -p "$LOGS_DIR"

TIMESTAMP="$(date +"%Y-%m-%d_%H-%M-%S")"
LOG_FILE="$LOGS_DIR/launch-$TIMESTAMP.log"
RESULT_BUNDLE="$LOGS_DIR/TopCue-$TIMESTAMP.xcresult"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "[TopCue] Launch avec logs"
echo "[TopCue] Date: $(date)"
echo "[TopCue] Log: $LOG_FILE"
echo "[TopCue] Result bundle: $RESULT_BUNDLE"

echo
echo "[TopCue] Step 1/3: Build"
xcodebuild \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -workspace "$WORKSPACE_PATH" \
    -destination "$DESTINATION" \
    -resultBundlePath "$RESULT_BUNDLE" \
    -allowProvisioningUpdates \
    build

echo
echo "[TopCue] Step 2/3: Resolve executable path"
BUILD_SETTINGS="$(xcodebuild \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -workspace "$WORKSPACE_PATH" \
    -destination "$DESTINATION" \
    -showBuildSettings)"

TARGET_BUILD_DIR="$(printf '%s\n' "$BUILD_SETTINGS" | awk -F' = ' '/TARGET_BUILD_DIR/ {print $2; exit}')"
EXECUTABLE_PATH="$(printf '%s\n' "$BUILD_SETTINGS" | awk -F' = ' '/EXECUTABLE_PATH/ {print $2; exit}')"

if [[ -z "$TARGET_BUILD_DIR" || -z "$EXECUTABLE_PATH" ]]; then
    echo "[TopCue] ERROR: Impossible de resoudre le binaire"
    exit 1
fi

BINARY_PATH="$TARGET_BUILD_DIR/$EXECUTABLE_PATH"

if [[ ! -x "$BINARY_PATH" ]]; then
    echo "[TopCue] ERROR: Binaire non executable: $BINARY_PATH"
    exit 1
fi

echo "[TopCue] Binaire: $BINARY_PATH"

echo
echo "[TopCue] Step 3/3: Run"
echo "[TopCue] Appuyez sur Ctrl+C pour arreter (le log est deja sauvegarde)."
set +e
"$BINARY_PATH" &
APP_PID=$!

cleanup() {
    if kill -0 "$APP_PID" >/dev/null 2>&1; then
        kill "$APP_PID" >/dev/null 2>&1 || true
    fi
}

trap cleanup INT TERM
wait "$APP_PID"
APP_EXIT_CODE=$?
trap - INT TERM
set -e

if [[ $APP_EXIT_CODE -eq 130 ]]; then
    echo "[TopCue] Arret manuel detecte (Ctrl+C)."
    exit 0
fi

if [[ $APP_EXIT_CODE -eq 143 ]]; then
    echo "[TopCue] Arret manuel detecte."
    exit 0
fi

exit $APP_EXIT_CODE
