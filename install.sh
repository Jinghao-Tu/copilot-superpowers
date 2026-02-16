#!/bin/bash

set -euo pipefail

REPO_URL="https://github.com/obra/superpowers.git"
ELEMENTS_OF_STYLE_REPO_URL="https://github.com/obra/the-elements-of-style.git"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p .github/skills .github/instructions

git clone "$REPO_URL" "$TMP_DIR/superpowers"
SUPERPOWERS_DIR="$TMP_DIR/superpowers"

git clone "$ELEMENTS_OF_STYLE_REPO_URL" "$TMP_DIR/the-elements-of-style"
ELEMENTS_OF_STYLE_DIR="$TMP_DIR/the-elements-of-style"

cp -ar "$SUPERPOWERS_DIR/skills/." .github/skills/

ELEMENTS_STYLE_SKILL_DIR="$ELEMENTS_OF_STYLE_DIR/skills/writing-clearly-and-concisely"
if [ -d "$ELEMENTS_STYLE_SKILL_DIR" ]; then
	cp -ar "$ELEMENTS_STYLE_SKILL_DIR" .github/skills/
else
	echo "Warning: writing-clearly-and-concisely skill not found in the-elements-of-style repo" >&2
fi

USING_SUPERPOWERS_SKILL="$SUPERPOWERS_DIR/skills/using-superpowers/SKILL.md"
if [ ! -f "$USING_SUPERPOWERS_SKILL" ]; then
	echo "Error: using-superpowers skill not found at $USING_SUPERPOWERS_SKILL" >&2
	exit 1
fi

USING_SUPERPOWERS_CONTENT="$({
	awk '
	BEGIN {
		in_frontmatter = 0
	}
	NR == 1 && $0 == "---" {
		in_frontmatter = 1
		next
	}
	in_frontmatter && $0 == "---" {
		in_frontmatter = 0
		next
	}
	!in_frontmatter {
		print
	}
	' "$USING_SUPERPOWERS_SKILL"
})"

{
	cat <<'EOF'
---
applyTo: '**'
---
<EXTREMELY_IMPORTANT>
You have superpowers.

**IMPORTANT: The using-superpowers skill content is included below. It is ALREADY LOADED - you are currently following it. Do NOT try to load "using-superpowers" again.**

EOF

	printf '%s\n\n' "$USING_SUPERPOWERS_CONTENT"

	cat <<'EOF'
**Tool Mapping for GitHub Copilot (VS Code):**
Use VS Code Agent Skills for automatic skill loading
Use VS Code built-in tools directly when required.

**Skills location:**
Superpowers skills are in `.github/skills/`.
</EXTREMELY_IMPORTANT>
EOF
} > .github/instructions/superpowers.instructions.md
