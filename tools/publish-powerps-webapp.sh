#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKIP_BUILD=0
PUSH=0
OUTPUT_DIR=""
WEBAPP_REPO="${POWERPS_WEBAPP_REPO:-/home/reza/projects/powerps_all/powerps-webapp}"
WEBAPP_REMOTE="${POWERPS_WEBAPP_REMOTE:-https://github.com/rezahajrahimi/powerps-webapp.git}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-build)
            SKIP_BUILD=1
            shift
            ;;
        --push)
            PUSH=1
            shift
            ;;
        *)
            OUTPUT_DIR="$1"
            shift
            ;;
    esac
done

OUTPUT_DIR="${OUTPUT_DIR:-${PROJECT_ROOT}/dist/powerps-webapp}"
VERSION="$(awk '/^version:/{print $2; exit}' "${PROJECT_ROOT}/pubspec.yaml")"

if [[ "${SKIP_BUILD}" -eq 0 ]]; then
    echo "==> Building Flutter web (release)"
    cd "${PROJECT_ROOT}"
    flutter build web --release
else
    echo "==> Skipping build (using existing build/web)"
    if [[ ! -f "${PROJECT_ROOT}/build/web/index.html" ]]; then
        echo "build/web not found. Run without --skip-build first." >&2
        exit 1
    fi
fi

echo "==> Preparing release directory: ${OUTPUT_DIR}"
rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"
rsync -a --delete "${PROJECT_ROOT}/build/web/" "${OUTPUT_DIR}/"

mkdir -p "${OUTPUT_DIR}/assets"
if [[ -f "${OUTPUT_DIR}/assets/.env" ]]; then
    echo "==> Keeping existing assets/.env"
else
    cp "${PROJECT_ROOT}/tools/assets-dotenv.template" "${OUTPUT_DIR}/assets/.env"
fi

cp "${PROJECT_ROOT}/tools/powerps-webapp-readme.md" "${OUTPUT_DIR}/readme.md"

cat > "${OUTPUT_DIR}/RELEASE.txt" <<EOF
PowerPs WebApp release
Version: ${VERSION}
Built on: $(date -u '+%Y-%m-%d %H:%M:%S UTC')
EOF

echo "==> Release ready at ${OUTPUT_DIR}"
echo "    Version ${VERSION}"

if [[ "${PUSH}" -eq 1 ]]; then
    echo "==> Pushing to ${WEBAPP_REMOTE}"
    if [[ ! -d "${WEBAPP_REPO}/.git" ]]; then
        git clone "${WEBAPP_REMOTE}" "${WEBAPP_REPO}"
    fi

    rsync -a --delete \
        --exclude '.git' \
        --exclude 'assets/.env' \
        "${OUTPUT_DIR}/" "${WEBAPP_REPO}/"

    if [[ -f "${OUTPUT_DIR}/assets/.env" ]] && [[ ! -f "${WEBAPP_REPO}/assets/.env" ]]; then
        cp "${OUTPUT_DIR}/assets/.env" "${WEBAPP_REPO}/assets/.env"
    fi

    cd "${WEBAPP_REPO}"
    git add -A
    if git diff --cached --quiet; then
        echo "No changes to push."
        exit 0
    fi

    git commit -m "$(cat <<EOF
release: web v${VERSION}

Publish Flutter web build for powerps-webapp.
EOF
)"
    git push origin main
    echo "==> Pushed to ${WEBAPP_REMOTE}"
else
    echo ""
    echo "Next steps:"
    echo "  ./tools/publish-powerps-webapp.sh --skip-build --push"
    echo "  # or manually:"
    echo "  cd ${OUTPUT_DIR} && git push ..."
fi
