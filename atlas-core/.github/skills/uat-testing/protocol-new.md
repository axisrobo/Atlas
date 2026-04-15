# UI 自动化测试执行规范 (UI Test Protocol) v2.0

本协议定义了使用 **gstack** 逻辑进行 UI 验证与 UAT 验收的标准流程。

> **安全边界**：
> - 严禁未授权执行 `git commit` / `git push`
> - 严禁自动修改业务源代码（非测试文件）
> - 所有修复操作须在日志中留下可追溯记录

---

## 1. 目录资产结构 (Directory Map) — 唯一权威定义

> ⚠️ 本节路径为全局唯一标准，所有其他文档中出现的路径应以此为准。

| 资源类型 | 物理路径（唯一标准） | 描述 |
|:---------|:---------------------|:-----|
| **测试场景 (BDD)** | `tests/uat/features/*.feature` | Gherkin 业务场景 |
| **测试脚本 (Specs)** | `tests/uat/specs/*.spec.ts` | Playwright POM 实现 |
| **Step Definitions** | `tests/uat/steps/*.steps.ts` | BDD 步骤实现层 |
| **业务数据** | `test-data/sample-data/` | `sample.json` 等输入配置 |
| **应用架构图** | `test-data/ea-request/app-diagram/` | App Diagram 物理文件 |
| **技术架构图** | `test-data/ea-request/tech-diagram/` | Tech Diagram 物理文件 |
| **测试结果** | `test-results/` | 含时间戳的执行日志 |
| **测试报告** | `playwright-report/` | HTML 报告与 Trace 文件 |
| **统一配置** | `config/test.config.ts` | 路径/超时/环境变量统一入口 |

---

## 2. 测试范围界定 (Scope)

### 模式判断规则（按优先级执行）

1. **用户显式指定** → 遵从用户指令
2. **读取变更列表** → 执行 `git diff --name-only HEAD`，按下表匹配：

| 变更文件路径特征 | 触发模式 |
|:----------------|:---------|
| `src/components/` 下的原子组件 | Mode A: 组件冒烟 |
| `src/pages/`、`src/routes/`、业务逻辑 | Mode B: 流程验证 |
| `src/styles/global`、核心配置文件 | Mode C: 全量回归 |

3. **无法判断** → 默认执行 **Mode B**，并在报告中注明原因

### 三种执行模式

- **Mode A (Component)**：执行 Playwright Component Tests，范围限定单组件
- **Mode B (Flow/UAT)**：执行 `tests/uat/features/{target}.feature`
- **Mode C (Regression)**：执行 `tests/uat/features/` 下全部 Feature 文件

---

## 3. 执行流程 (The gstack Workflow)

### Step 1 · 环境与资源自检

1. **Server 状态**：Ping `localhost:3000`，无响应则执行 `npm run dev` 并等待就绪
2. **配置加载**：读取 `config/test.config.ts` 作为所有路径的最终来源
3. **Feature 匹配**：在 `tests/uat/features/` 中定位目标 `.feature` 文件
4. **资源验证**：确认架构图文件物理存在，缺失时立即报告而非静默失败

### Step 2 · 执行自动化测试

```bash
# 标准运行
npx playwright test tests/uat/features/{target}.feature

# 带 UI 调试（UI 阻塞时使用）
npx playwright test --debug

# 生成新 POM 选择器
npx playwright codegen {url}
```

### Step 3 · 感知化观察

- **视觉完整性**：元素无重叠/位移，响应式布局正常
- **状态完整性**：Loading 动画、Toast 提示、成功文案（`"in queue"`）均验证
- **SSO 协同**：检测到 ADFS 页面时自动挂起，每 5 秒轮询 `"Log Out"` 按钮，
  出现后自动恢复（超时上限：`config/test.config.ts` 中 `sso.maxWaitMs`）

---

## 4. 自愈与修复循环 (Auto-Fix Loop)

**最大重试次数：3次（MAX_RETRY=3）**
**禁止直接向用户抛出原始错误日志。**

### 根因分类与授权边界

| 根因类型 | 判断特征 | 允许操作 | 禁止操作 |
|:---------|:---------|:---------|:---------|
| **选择器失效** | 元素定位超时，DOM 结构变更 | 自动更新 Page Object | — |
| **步骤过期** | Step Definition 与 Feature 不匹配 | 自动更新 Step Definition | 自动修改 `.feature` |
| **业务逻辑 Bug** | 非测试代码缺陷导致断言失败 | 输出诊断报告并挂起 | **修改业务源代码** |
| **环境问题** | Server 未启动、网络超时 | 尝试重启 Server | — |

> ⚠️ **修改 `.feature` 文件须通知用户确认**，因为它代表业务需求变更，
> 不属于纯技术修复范畴。

### 超出重试限制时
✋ Auto-Fix 已达最大重试次数（3次），流程挂起。
📋 诊断报告：{描述根因、失败截图位置、建议修复方向}
👤 等待人工介入...
## 5. 结果汇报标准

任务结束后输出以下结构化报告：
UAT 执行报告 · {timestamp}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 状态        : [直接通过 / 修复后通过 / 失败待修]
📋 场景        : {已执行 Scenario 列表及各自结果}
🔧 修复记录    : {修改的文件名 + 修改原因} (无修复则填 N/A)
🆔 Request IDs : {捕获的 EA Request ID 列表} (适用时)
📸 报告位置    : playwright-report/index.html
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---

## 6. 触发方式

### 指令触发（优先）
| 指令 | 行为 |
|:-----|:-----|
| `/uat [scenario]` | 执行指定场景的 Flow 验证（Mode B） |
| `/uat ea-request` | 执行 EA Request 全流程（含 SSO + 双图上传） |
| `/visual-check` | 仅执行视觉完整性检查 |
| `/codegen` | 启动录制模式，生成新 POM 选择器 |

### 自然语言触发（兜底）
- `测试 UI`
- `验证 EA Request 流程`
- `Check the [page] flow with gstack`