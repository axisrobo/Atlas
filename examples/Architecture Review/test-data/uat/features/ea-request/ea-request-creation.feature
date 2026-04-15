# language: zh-CN
Feature: EA Request 自动化验收测试 (UAT)

  As a normal user
  I want to create an EA Request by selecting projects and uploading diagrams
  So that the technical review process can be initiated

  # ─────────────────────────────────────────
  # 共享前置条件
  # ─────────────────────────────────────────
  Background:
    Given 用户已打开 EA Portal
    And   系统已通过 ADFS SSO 认证，当前处于已登录状态

  # ─────────────────────────────────────────
  # Scenario 1：SSO 状态检测（独立隔离）
  # ─────────────────────────────────────────
  Scenario: 未登录时系统应挂起并等待用户完成 ADFS 认证
    Given 当前页面右上角不存在 "Log Out" 按钮
    When  Agent 检测到未登录状态
    Then  系统应自动挂起测试流程
    And   向用户发出认证提示："请完成 ADFS 登录后，测试将自动恢复"
    And   每隔 5 秒轮询一次登录状态，直到检测到 "Log Out" 按钮出现

  Scenario: 已登录时系统应直接进入主页面
    Given 当前页面右上角存在 "Log Out" 按钮
    Then  系统确认登录成功
    And   当前页面应为 EA Portal 主页面

  # ─────────────────────────────────────────
  # Scenario 2：使用已有项目创建 EA Request（Happy Path A）
  # ─────────────────────────────────────────
  Scenario: 选择已有项目并上传双架构图完成 EA Request 创建
    When  用户点击主页面的 "Create A Request" 按钮
    And   用户从项目列表中选择与测试数据匹配的已有项目
    And   用户上传应用架构图
    And   用户上传技术架构图
    And   用户检查表单预览确认信息无误
    And   用户点击 "Confirm to Submit" 按钮
    Then  页面应跳转至成功反馈页
    And   页面应显示消息 "This request is in queue, please wait for the EA team to process it."
    And   页面应展示一个有效的 Request ID
    And   该 Request ID 应被记录至审计日志

  # ─────────────────────────────────────────
  # Scenario 3：创建新项目并提交（Happy Path B）
  # ─────────────────────────────────────────
  Scenario: 创建新项目并上传双架构图完成 EA Request 创建
    When  用户点击主页面的 "Create A Request" 按钮
    And   用户选择创建新项目并输入项目名称和描述
    And   用户上传应用架构图
    And   用户上传技术架构图
    And   用户点击 "Confirm to Submit" 按钮
    Then  页面应跳转至成功反馈页
    And   页面应展示一个有效的 Request ID

  # ─────────────────────────────────────────
  # Scenario Outline：不同文件格式的上传验证
  # ─────────────────────────────────────────
  Scenario Outline: 上传 <diagram_type> 架构图（<file_format> 格式）
    When  用户点击 "Create A Request" 并选择已有项目
    And   用户尝试上传 <diagram_type> 文件，格式为 <file_format>
    Then  系统应展示 <expected_result>

    Examples:
      | diagram_type | file_format | expected_result                    |
      | 应用架构图    | .png        | 上传成功，缩略图预览可见            |
      | 应用架构图    | .jpg        | 上传成功，缩略图预览可见            |
      | 应用架构图    | .pdf        | 错误提示："仅支持图片格式"          |
      | 技术架构图    | .png        | 上传成功，缩略图预览可见            |
      | 技术架构图    | .gif        | 错误提示："仅支持图片格式"          |

  # ─────────────────────────────────────────
  # Scenario 4：表单不完整时的阻断验证（Negative Path）
  # ─────────────────────────────────────────
  Scenario: 未上传架构图时系统应阻止提交
    When  用户点击 "Create A Request" 并选择已有项目
    And   用户跳过架构图上传步骤
    And   用户点击 "Confirm to Submit" 按钮
    Then  提交操作应被阻断
    And   页面应显示必填项提示

  Scenario: 未选择项目时系统应阻止提交
    When  用户点击 "Create A Request"
    And   用户不选择任何项目直接上传架构图
    And   用户点击 "Confirm to Submit" 按钮
    Then  提交操作应被阻断
    And   页面应显示项目选择必填提示