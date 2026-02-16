# copilot-superpowers

A simple installer that migrates superpowers skills, commands, and auto-injected instructions into GitHub Copilot (VS Code) compatible formats.
一个简单的安装脚本，用于把 superpowers 的 skills、commands 和自动注入指令迁移为 GitHub Copilot（VS Code）可用格式。

After running, it automatically creates the required files under `.github/skills/`, `.github/prompts/`, and `.github/instructions/`.
执行后，它会自动在 `.github/skills/`、`.github/prompts/` 和 `.github/instructions/` 下生成所需文件。

Quick start (recommended):
快速开始（推荐）：

```bash
curl -fsSL https://raw.githubusercontent.com/Jinghao-Tu/copilot-superpowers/main/install.sh | bash
```
