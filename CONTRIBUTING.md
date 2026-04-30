# Contributing to everything-codex-unity

Thanks for your interest in improving Unity game development with Codex!

## How to Contribute

### Adding a New Skill

Skills are the easiest way to contribute. A skill is a SKILL.md file in `skills/<category>/<skill-name>/`.

1. Create the directory: `skills/<category>/<your-skill>/`
2. Create `SKILL.md` with frontmatter:

```yaml
---
name: your-skill-name
description: "One-line description of when this skill should be loaded"
globs: ["**/Pattern*.cs", "**/*Match*"]
---
```

3. Write comprehensive content with:
   - Clear architecture patterns
   - Production-quality C# code examples
   - Common mistakes to avoid
   - Integration points with other systems

**Skill ideas we're looking for:**
- Genre: racing, survival, tower defense, simulation, rhythm, visual novel
- Systems: ProBuilder, Spline, 2D Animation, Localization, Cloud Save
- Networking: FishNet, Dark Rift, custom UDP
- Third-party: Rewired, Wwise, PlayFab, Firebase, Steamworks

### Adding a New Agent

Agents live in `.codex-legacy/agents/`. Create a markdown file with frontmatter:

```yaml
---
name: agent-name
description: "When to use this agent"
model: opus|sonnet|haiku
color: colorname
tools: Read, Write, Edit, Glob, Grep, Bash, mcp__unityMCP__*
skills: skill1, skill2
---
```

### Adding a New Command

Commands live in `.codex-legacy/commands/`. Create a markdown file with:

```yaml
---
name: command-name
description: "What this command does"
user-invocable: true
args: optional_argument_name
---
```

### Improving Hooks

Hooks are shell scripts in `.codex-legacy/hooks/`. Key conventions:
- Read JSON from stdin (tool input)
- Exit 2 to block (PreToolUse), exit 0 to allow/warn
- Write warnings to stderr
- Keep execution under 5 seconds

### Improving Rules

Rules in `.codex-legacy/rules/` are always loaded. Keep them:
- Scannable (headers, short bullet points)
- Actionable (show the correct code, not just "don't do X")
- Focused (one topic per file)

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b add-racing-skill`)
3. Make your changes
4. Test: install into a Unity project with `./install.sh`
5. Submit a PR with:
   - What you added/changed
   - Why it's useful
   - How you tested it

## Code Style

- Shell scripts: `bash`, `set -euo pipefail`, colored output
- Markdown: ATX headings, fenced code blocks, tables where appropriate
- C# examples: follow the conventions in `.codex-legacy/rules/csharp-unity.md`

## Reporting Issues

Open an issue with:
- What you expected to happen
- What actually happened
- Unity version and OS
- Steps to reproduce

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
