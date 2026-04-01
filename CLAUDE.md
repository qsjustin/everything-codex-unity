# everything-claude-unity — Development Guide

This is the development CLAUDE.md for the everything-claude-unity project itself.

## Project Structure

```
.claude/          — The installable payload (agents, commands, skills, hooks, rules)
scripts/          — Validation shell scripts
templates/        — C# code templates
examples/         — Example CLAUDE.md files per game type
docs/             — Documentation
```

## Development Conventions

- **Skills** are in `.claude/skills/<category>/<name>/SKILL.md` with YAML frontmatter
- **Agents** are in `.claude/agents/<name>.md` with YAML frontmatter
- **Commands** are in `.claude/commands/<name>.md` with YAML frontmatter
- **Hooks** are bash scripts in `.claude/hooks/` — blocking hooks exit 2, warning hooks exit 0
- **Rules** are markdown files in `.claude/rules/`
- **Scripts** are bash scripts in `scripts/` — all use `set -euo pipefail` and colored output

## Skill Frontmatter

```yaml
---
name: skill-name
description: "When to load this skill"
alwaysApply: true|false
globs: ["**/*.pattern"]
---
```

## Agent Frontmatter

```yaml
---
name: agent-name
description: "What this agent does"
model: opus|sonnet|haiku
color: colorname
tools: Read, Write, Edit, Glob, Grep, Bash, mcp__unityMCP__*
skills: skill1, skill2
---
```

## Testing Changes

After making changes, test by installing into a real Unity project:
```bash
./install.sh --project-dir /path/to/unity/project
```

## Quality Checklist

- [ ] All C# code examples follow `.claude/rules/csharp-unity.md`
- [ ] YAML frontmatter is valid
- [ ] Globs patterns match realistic file paths
- [ ] Descriptions are clear and specific
- [ ] No broken markdown formatting
