#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

assert_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    echo "Expected to find: $expected" >&2
    echo "--- $file ---" >&2
    cat "$file" >&2
    exit 1
  fi
}

cd "$WORK_DIR"
git init -q
git config user.email "test@example.com"
git config user.name "Test User"

echo "initial" > app.txt
git add app.txt
git commit -q -m "chore: initial release"
git tag v1.0.0

echo "feature" >> app.txt
git add app.txt
git commit -q -m "feat: add OAuth login"

echo "fix" >> app.txt
git add app.txt
git commit -q -m "fix: handle empty changelog"

echo "docs" >> app.txt
git add app.txt
git commit -q -m "docs: clarify setup instructions"

echo "remove" >> app.txt
git add app.txt
git commit -q -m "remove deprecated API"

"$ROOT_DIR/changelog.sh"

assert_contains CHANGELOG.md "## Unreleased"
assert_contains CHANGELOG.md "### Added"
assert_contains CHANGELOG.md "- add OAuth login"
assert_contains CHANGELOG.md "### Fixed"
assert_contains CHANGELOG.md "- handle empty changelog"
assert_contains CHANGELOG.md "### Changed"
assert_contains CHANGELOG.md "- clarify setup instructions"
assert_contains CHANGELOG.md "### Removed"
assert_contains CHANGELOG.md "- remove deprecated API"

echo "changelog generation test passed"
