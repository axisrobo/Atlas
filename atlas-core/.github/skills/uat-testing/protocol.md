# UI 自动化测试执行规范 (UI Test Protocol)

本协议定义了使用 **gstack** 逻辑进行 UI 验证与 **UAT 验收** 的标准流程。其核心目标是通过自动化手段确保业务流（Business Flow）的闭环、视觉正确性及逻辑一致性。

> **注意**：本流程仅用于验证与代码自愈，**严禁**在未获得显式授权的情况下执行 Git 提交操作。

---

## 1. 目录资产结构 (Directory Map)

AI 在执行任务时，必须严格遵循以下路径规范来定位和解析资源：

| 资源类型 | 物理路径 | 描述 |
| :--- | :--- | :--- |
| **测试场景 (BDD)** | `tests/uat/features/*.feature` | 定义业务逻辑的 Gherkin 文件 |
| **测试脚本 (Specs)** | `tests/uat/specs/*.spec.ts` | 底层 Playwright 实现代码 (POM 模式) |
| **业务数据 (Data)** | `test-data/uat/sample-data/` | 包含 `sample.json` 等输入配置 |
| **架构资源 (Diagrams)**| `test-data/uat/asset/` | 物理图片/资源 (app, tech, logic 等) |
| **输出报告 (Reports)** | `playwright-report/` | 视觉验证与 Trace 证据 |

---

## 2. 测试范围界定 (Scope)

在启动前，AI 必须评估变更影响并自动选择验证深度：

* **Mode A: 组件冒烟 (Component)**：修改了原子组件。执行 Playwright Component Tests。
* **Mode B: 流程验证 (Flow/UAT)**：修改了页面、路由或业务逻辑。执行特定的 `.feature` 脚本。
* **Mode C: 全量回归 (Regression)**：修改了全局样式或核心配置。运行 `tests/uat/features/` 下所有脚本。

---

## 3. 执行流程 (The gstack Workflow)

### 第一步：环境与资源自检
1.  **Server 状态**：确认本地开发服务 (默认 `localhost:3000`) 已启动。若未启动，尝试执行 `npm run dev`。
2.  **文件预检**：根据用户提及的功能名，在 `tests/uat/features/` 中匹配对应的 Feature。
3.  **资源映射**：
    * 若提及 `app-diagram`，强制映射至 `test-data/ea-request/app-diagram/`。
    * 若提及 `tech-diagram`，强制映射至 `test-data/ea-request/tech-diagram/`。
    * 若提及 `sample.json`，强制读取 `test-data/ea-request/sample.json`。

### 第二步：执行自动化测试
在终端执行以下指令，并根据复杂度切换：
* **标准运行**：`npx playwright test tests/uat/features/{target}.feature`
* **交互调试**：使用 `--debug` 模式（当出现不可预知的 UI 阻塞时）。
* **元素录制**：使用 `codegen` 捕获新页面的 POM 选择器，辅助更新 Page Objects。

### 第三步：感知化观察 (Role: QA-Tester)
验证标准不仅是“全绿”，AI 还需进行“视觉与体验”双重检查：
* **视觉对齐**：检查元素是否重叠、位移。
* **状态捕捉**：验证 Loading 动画、Toast 提示及最终成功文案（如：*"in queue"*）。
* **人工交口**：若涉及 **EA Request 人工登录**，必须在 `Given` 阶段自动停顿并提示用户输入凭证，等待 URL 变化后再继续。

---

## 4. 自愈与修复循环 (Auto-Fix Loop)

**禁止直接向用户抛出错误日志。** AI 必须尝试以下闭环：

1.  **失效分析**：读取测试报告中的 Trace 或 HTML 截图。
2.  **定位根因**：
    * **选择器失效**：UI 结构变动。-> **Action**: 更新对应的 Page Object 文件。
    * **脚本过期**：BDD 步骤与新流程不符。-> **Action**: 同步更新 `.feature` 和 `Step Definitions`。
    * **逻辑 Bug**：代码缺失处理（如漏写 `onClick`）。-> **Action**: 尝试修改源代码并重跑。
3.  **重新验证**：修复后自动重新运行。最大重试次数：**3次**。

---

## 5. 结果汇报标准

任务结束后，AI 必须提供结构化反馈：

* ✅ **状态**：[直接通过 / 修复后通过 / 失败待修]
* 📝 **场景**：列出已执行的 Scenario 及关键断点。
* 🔧 **修复**：若执行了 Auto-Fix，请列出修改的文件名及原因。
* 📸 **证据**：告知报告位置（如 `playwright-report/index.html`）。

---

## 6. 触发暗号 (Trigger)
- `/uat [功能]`
- `测试 UI`
- `验证 EA Request 流程`
- `Check the [page name] flow with gstack`