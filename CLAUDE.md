# 土豆ToDo - 项目指引

习惯打卡 iPhone App。SwiftUI + SwiftData，iOS 18+，纯 Apple 生态。

## 标准文件路径

| 文件 | 路径 | 用途 |
|------|------|------|
| 功能需求 | `docs/requirements.md` | 全部功能需求清单 |
| 技术规格 | `docs/tech-specs.md` | 数据模型、架构、技术选型 |
| 设计规范 | `docs/design-specs.md` | 色彩、字体、圆角、组件规格 |
| 实施步骤 | `docs/implementation-steps.md` | 分步执行计划 |
| 设计文档 | `docs/superpowers/specs/2026-05-13-habit-tracker-design.md` | 完整设计规格 |
| 开发日志 | `dev-logs/` | 每日开发记录 |

## 工作约定

### 开发前
1. 阅读 `docs/requirements.md` 了解功能全貌
2. 阅读 `docs/tech-specs.md` 了解技术约束
3. 阅读 `docs/design-specs.md` 了解视觉规范
4. 检查 `docs/implementation-steps.md` 当前进度

### 开发后
1. 更新 `dev-logs/YYYY-MM-DD.md` 记录当天完成和待办
2. 更新 `docs/implementation-steps.md` 勾选已完成项
3. 如有设计/需求变更，同步更新对应 docs 文件

### 每日日志
- 每天首次工作时，在 `dev-logs/` 创建当天日期 `.md` 文件
- 模板：已完成 + 待办清单
- 会话结束时更新待办状态

## 关键约束
- 无外部依赖，纯 Apple 生态
- App Groups 数据共享：`group.com.potato.todo`
- 主色调 #FFD60A，深色模式支持
- 计数型习惯显示进度（已做/目标）
- 土豆钟与计数型互斥

## 项目架构

```
土豆ToDo/
├── 土豆ToDo.xcodeproj              # Xcode 项目
├── CLAUDE.md                       # 本文件
├── docs/                           # 标准文档
├── dev-logs/                       # 每日开发日志
├── 土豆ToDo/                       # 主 App 源码
│   ├── Models/                     # Habit, CheckIn, CountdownEvent, TimerSession
│   ├── Enums/                      # HabitColor, HabitType
│   ├── Utilities/                  # AppConfig, ColorConstants, TimerManager, etc.
│   └── Views/                      # Today, Calendar, Stats, Settings
└── 土豆ToDoWidget/                 # 小组件
    ├── CheckInWidget.swift          # 打卡小组件（交互 + 土豆钟）
    ├── CalendarWidget.swift         # 日历小组件（5天日期条）
    ├── CountdownWidget.swift        # 倒计时小组件
    └── WidgetContainer.swift        # 小组件数据容器
```

## 交付后维护

### Git 版本管理
- 每次改完一个功能就 commit，消息写清楚做了什么
- 大改动前先开分支：`git checkout -b feature/xxx`
- 不要在 main 分支上直接改未经测试的代码

### 文档更新
- 新增功能 → 更新 `docs/requirements.md`
- 改了数据模型 → 更新 `docs/tech-specs.md`
- 改了 UI → 更新 `docs/design-specs.md`
- 完成一个阶段 → 更新 `docs/implementation-steps.md` + `dev-logs/`

### 数据迁移
- `Habit` 等 Model 加了新字段 → 必须删 App 重装
- 上线前需要做 SwiftData 版本迁移（`SchemaMigrationPlan`）
- 参考：developer.apple.com → SwiftData → Schema Migration

### 真机测试
- 模拟器通过后，连 iPhone 真机跑一次
- 测试小组件在真机桌面的交互
- 测试通知推送

### App Store 上线
- 注册 Apple Developer Program：developer.apple.com
- Xcode → Signing & Capabilities → 选你的 Team
- Product → Archive → Distribute App
- App Store Connect 填元数据（截图、描述、隐私政策）

### 常见问题
- 小组件数据不同步 → 删 App 重装
- 编译报 model 字段错 → 旧数据库不兼容，删 App 重装
- pbxproj 损坏 → 新建 Xcode 项目 + 手动加文件（之前遇到过）
