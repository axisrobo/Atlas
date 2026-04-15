# Project Copilot Instructions

## 1. 🌿 Git Branch Workflow
When executing `/opsx:new` or `/opsx:ff`, you MUST follow `.github/skills/git-branch-workflow/SKILL.md` to create a dedicated branch BEFORE any `openspec` commands.

## 2. 🧪 UAT & UI Verification (Non-Commit Mode)

### 触发条件
当用户发起以下任意请求时，进入 UAT 模式：
- 显式指令：`/uat [scenario]`、`/visual-check`、`/codegen`
- 自然语言：`测试 UI`、`验证 EA Request 流程`、
  `Check the [page] flow with gstack`

### 执行规范
严格读取并遵循 `.github/skills/uat-testing/protocol.md`，
以下为其核心摘要：

**资源定位（唯一权威路径）**

| 资源类型 | 路径 |
|:---------|:-----|
| BDD 场景 | `tests/uat/features/*.feature` |
| Step 实现 | `tests/uat/steps/*.steps.ts` |
| Playwright Spec | `tests/uat/specs/*.spec.ts` |
| 业务数据 | `test-data/uat/sample-data/ea-request/` |
| 应用架构图 | `test-data/uat/asset/app-diagram/` |
| 技术架构图 | `test-data/uat/asset/tech-diagram/` |
| 测试报告 | `playwright-report/` |
| 审计日志 | `test-results/ea-ids.log` |

**gstack 执行模式**

1. **环境自检**：确认 `localhost:3000` 就绪，读取 `config/test.config.ts`
2. **感知驱动**：启动 Playwright 验证业务闭环（EA Request 创建、审批流等）
3. **自愈循环**（MAX_RETRY=3）：
4. **SSO 协同断点**：检测到未登录状态时，**立即挂起**并提示用户，
   每 5 秒轮询一次，5 分钟内未完成则终止并报告

### 安全边界（不可逾越）
- ❌ 严禁自动执行任何 `git commit` / `git push`
- ❌ 严禁修改 `src/` 下的业务源代码
- ❌ 严禁在 SSO 未完成时盲目继续执行
- ✅ 修复范围仅限：Page Objects、Step Definitions
- ✅ 修改 `.feature` 文件前须获得用户确认
## 3. 🚀 Pre-commit Safety (The Harness Protocol)
当用户要求“提交”、“push”或确认“合并”时，必须执行双层验证：

### 1. Logic Integrity (Superpowers Mode)
- **目标**：核心逻辑、API、Utils。
- **操作**：引用 `.github/skills/test-and-commit/SKILL.md`，运行 Vitest/Jest 确保 **100% 通过**。

### 2. UI/UX Regression (gstack Mode)
- **目标**：组件、样式、路由、静态资源。
- **操作**：启动 Headless 浏览器验证 "Critical User Path"。
- **自愈**：若 UI 失败，必须先 **Self-correct** 代码并重跑测试。

### 3. 执行门禁
- 只有 Logic 测试和 UI 测试 **全部通过**，才可执行 `git add/commit/push` 操作。

## 4. 🧹 Post-Archive Branch Cleanup
After `/opsx:archive` completes, if on a feature/fix branch, you MUST offer to merge and cleanup:

1. **先置条件**：必须先执行上述 `Pre-commit Safety` 协议。
2. **操作流程**：
   - Commit changes (Only if tests pass).
   - `git checkout main`
   - `git merge <branch> --no-ff`
   - `git push origin main`
   - `git branch -d <branch>`

Always ask for user confirmation before performing the merge and deletion.

> **Important**: Any user confirmation to "merge", "yes", "是", or "合并" counts as a commit/push request. You MUST run the full test-and-commit protocol first.