#!/bin/bash

# .github/prompts/xxx.prompt.md
# .github/skills
# .github/instructions/xxx.instructions.md

set -euo pipefail

REPO_URL="https://github.com/obra/superpowers.git"
ELEMENTS_OF_STYLE_REPO_URL="https://github.com/obra/the-elements-of-style.git"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p .github/skills .github/prompts .github/instructions

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

for file in "$SUPERPOWERS_DIR"/commands/*.md; do
	[ -e "$file" ] || continue
	name="$(basename "$file" .md)"
	target=".github/prompts/${name}.prompt.md"

	awk -v prompt_name="$name" '
	BEGIN {
		in_frontmatter = 0
		frontmatter_started = 0
		name_line = ""
		other_count = 0
	}
	NR == 1 && $0 == "---" {
		frontmatter_started = 1
		in_frontmatter = 1
		print "---"
		next
	}
	in_frontmatter && $0 == "---" {
		if (name_line == "") {
			name_line = "name: " prompt_name
		}
		print name_line
		for (i = 1; i <= other_count; i++) {
			print other_lines[i]
		}
		print "---"
		in_frontmatter = 0
		next
	}
	in_frontmatter {
		if ($0 ~ /^name:[[:space:]]*/) {
			name_line = $0
			next
		}
		other_count++
		other_lines[other_count] = $0
		next
	}
	{
		if (!frontmatter_started) {
			print "---"
			print "name: " prompt_name
			print "---"
			frontmatter_started = 1
		}
		print
	}
	' "$file" > "$target"
done

USING_SUPERPOWERS_SKILL="$SUPERPOWERS_DIR/skills/using-superpowers/SKILL.md"
if [ ! -f "$USING_SUPERPOWERS_SKILL" ]; then
	echo "Error: using-superpowers skill not found at $USING_SUPERPOWERS_SKILL" >&2
	exit 1
fi

# Strip YAML frontmatter from SKILL.md to match upstream bootstrap injection behavior.
USING_SUPERPOWERS_CONTENT="$({
	awk '
	BEGIN {
		in_frontmatter = 0
		frontmatter_done = 0
	}
	NR == 1 && $0 == "---" {
		in_frontmatter = 1
		next
	}
	in_frontmatter && $0 == "---" {
		in_frontmatter = 0
		frontmatter_done = 1
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
When superpowers skills reference tools that are not available in this environment, use these equivalents:
- `TodoWrite` -> `manage_todo_list`
- `Task` tool with subagents -> `runSubagent` (or `search_subagent` for codebase exploration)
- `Skill` tool -> Read the matching skill file from `.github/skills/<skill>/SKILL.md` and follow it
- `Read`, `Write`, `Edit`, `Bash` -> Use your native workspace tools

**Skills location:**
Superpowers skills are in `.github/skills/`.
</EXTREMELY_IMPORTANT>
EOF
} > .github/instructions/superpowers.instructions.md
