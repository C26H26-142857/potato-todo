# 土豆ToDo — 习惯打卡 iPhone App

**WHAT:** 每日习惯打卡工具。4 Tab（今日/日历/统计/设置）+ 3 小组件 + 土豆钟计时。

**WHY SwiftUI + SwiftData:** 纯 Apple 生态，零外部依赖，iOS 18+ 能用最新 API。
**WHY 本地存储:** 无 iCloud 同步需求，App Groups 共享小组件数据。
**WHY 浅色锁定:** 温暖土豆品牌色系在浅色下最佳，小组件跟随系统深色。

## 文档索引

| 文档 | 何时读 |
|------|--------|
| `docs/requirements.md` | 新功能前了解全貌 |
| `docs/tech-specs.md` | 改数据模型/架构 |
| `docs/design-specs.md` | 改 UI/颜色/字体 |
| `docs/implementation-steps.md` | 查看当前进度 |

## 架构速览

```
土豆ToDo/                              土豆ToDoWidget/
├── Models/    Habit, CheckIn,         ├── CheckInWidget   # 打卡（含土豆钟）
│              CountdownEvent,         ├── CalendarWidget  # 5天日期条
│              TimerSession            ├── CountdownWidget # 倒计时列表
├── Enums/     HabitColor, HabitType   └── WidgetContainer # 数据容器
├── Utilities/ AppConfig, ColorConstants,
│              TimerManager, NotificationManager...
└── Views/     Today, Calendar, Stats, Settings
```

## 工作原则

**开发前:** 扫一眼 `docs/implementation-steps.md` 知道当前状态。不确定功能细节时读对应的 docs 文件。

**开发中:** 保持数据模型在应用、小组件两个 target 同步（改了 Model 就 copy 到 Widget 目录）。颜色用 `ColorConstants` 里的常量，别写死 hex。

**开发后:** 更新 `dev-logs/YYYY-MM-DD.md`，勾选 `docs/implementation-steps.md` 完成项。

## 硬约束

- `group.com.potato.todo` — App Groups 共享容器
- `#FFD60A` — 主色调，别改
- 土豆钟和计数型互斥
- 新增 Model 字段 → 删 App 重装（开发期），上线前加 SchemaMigrationPlan
- pbxproj 损坏 → 新建 Xcode 项目 + 手动加文件（遇到过）

## 常见坑

- 小组件/App 数据不一致 → 删 App 重装
- 编译报 Model 字段错 → 旧数据库不兼容，删 App 重装
- 深色模式 → App 锁死浅色 `.preferredColorScheme(.light)`，小组件自动跟系统
- Widget 不支持 ScrollView，溢出用 `+N 个更多`
