# 土豆ToDo - 技术规格

## 技术栈

| 项 | 选型 |
|---|------|
| 语言 | Swift |
| 框架 | SwiftUI |
| 数据持久化 | SwiftData（本地） |
| 最低版本 | iOS 18.0 |
| 小组件 | WidgetKit |
| 通知 | UserNotifications |
| 依赖管理 | 无外部依赖，纯 Apple 生态 |

## 数据模型

### Habit
```
@Model class Habit {
    var id: UUID
    var name: String
    var sfSymbol: String
    var colorRaw: String       // HabitColor 枚举值
    var typeRaw: String        // "single" | "count"
    var dailyTarget: Int       // 计数型每日目标
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var checkIns: [CheckIn]
}
```

### CheckIn
```
@Model class CheckIn {
    var id: UUID
    var date: Date             // 打卡日期（只存日期部分）
    var count: Int             // 当日次数
    var habit: Habit?
}
```

### CountdownEvent
```
@Model class CountdownEvent {
    var id: UUID
    var name: String
    var targetDate: Date
}
```

### 枚举
```
enum HabitColor: String, CaseIterable {
    case yellow  // #FFD60A
    case green   // #34C759
    case pink    // #FF6B6B
}

enum HabitType: String, CaseIterable {
    case single
    case count
}
```

## App 架构

```
TabView
├── TodayView          // 今日打卡
│   ├── DateSelectorBar
│   ├── TaskGridView
│   └── CountdownCard
├── CalendarView       // 日历热力图
├── StatsView          // 统计图表
└── SettingsView       // 设置
    ├── HabitEditorView
    └── CountdownEditorView
```

## 小组件
- Medium Widget：2×4 网格
- App Intent：ToggleCheckInIntent
- TimelineProvider：每 15 分钟刷新

## 通知
- UNUserNotificationCenter
- 每日固定时间触发
- 点击通知打开 App 到今日页
