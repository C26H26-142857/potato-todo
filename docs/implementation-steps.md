# 土豆ToDo - 实施步骤

## Phase 1：项目搭建
- [x] 创建 Xcode 项目（iOS App + SwiftUI + SwiftData）
- [x] 配置最低版本 iOS 18.0
- [x] 初始化 Git 仓库
- [x] 添加 .gitignore

## Phase 2：数据层
- [x] 定义 Habit、CheckIn、CountdownEvent 模型
- [x] 实现 HabitColor、HabitType 枚举
- [x] 配置 ModelContainer
- [x] 添加示例数据（Preview/Seed）

## Phase 3：今日页
- [x] DateSelectorBar 组件
- [x] TaskGridView + TaskButton 组件
- [x] CountdownCard 组件
- [x] TodayView 整合

## Phase 4：日历页
- [x] CalendarView + 月切换
- [x] 热力图着色逻辑
- [x] 连续天数计算
- [x] 日期点击详情

## Phase 5：统计页
- [x] StatsView
- [x] 周/月切换
- [x] 柱状图组件
- [x] 完成率计算

## Phase 6：设置页
- [x] 习惯列表 + 编辑/删除
- [x] 习惯创建/编辑表单
- [x] 倒计时管理
- [x] 提醒设置
- [x] 付费墙 + 订阅管理

## Phase 7：小组件
- [x] Widget Target
- [x] CheckInWidget（打卡 + 土豆钟）
- [x] CalendarWidget（5 天日期条）
- [x] CountdownWidget（倒计时列表）
- [x] AppIntents（打卡/计时交互）
- [x] TimelineProvider

## Phase 8：通知
- [x] 通知权限请求
- [x] 本地通知调度

## Phase 9：打磨
- [x] 浅色锁定（App 锁死浅色，小组件跟随系统）
- [x] 动画细节
- [x] 空状态引导
- [x] 自定义 App Icon
