# Shared 共享组件库

Shared 是一个 Flutter 共享组件库，提供应用中可复用的 UI 组件、服务、样式配置等通用功能。

## 目录结构

```
shared/
├── lib/
│   ├── shared_app_style.dart          # 应用全局样式配置
│   ├── shared_services/               # 共享服务
│   │   ├── interfaces/                # 服务接口定义
│   │   │   └── debug_interface.dart   # 调试接口
│   │   ├── models/                    # 数据模型
│   │   │   └── item.dart              # 通用数据项模型
│   │   └── services/                  # 服务实现
│   │       └── http_helper.dart       # HTTP 请求辅助工具
│   └── shared_widget/                 # 共享 UI 组件
│       ├── assets_file_picker.dart    # 资源文件选择器
│       ├── badge.dart                 # 徽章组件
│       ├── bottom_nav_widget.dart     # 底部导航组件
│       ├── bottom_sheet.dart          # 底部弹窗组件
│       ├── buttons.dart               # 通用按钮组件
│       ├── default_not_found_page.dart # 默认404页面
│       ├── dialogs.dart               # 对话框组件
│       ├── lazy_load_indexed_stack.dart # 懒加载索引栈
│       ├── qr_scan_widget.dart        # 二维码扫描组件
│       ├── refreshable_paging_widget.dart # 可刷新分页组件
│       ├── refreshable_widget.dart    # 可刷新组件
│       └── scaffold_app.dart          # 应用脚手架基类
└── pubspec.yaml                       # 依赖配置
```

## 主要功能模块

### 1. 应用样式配置 (shared_app_style.dart)
- **颜色定义**: 提供应用统一的颜色规范
- **设计尺寸**: 定义设计稿基准尺寸 (375x812)
- **系统UI样式**: 配置状态栏和导航栏样式
- **主题配置**: 提供 Material Design 主题配置

### 2. 共享服务 (shared_services/)

#### 服务接口 (interfaces/)
- **debug_interface.dart**: 调试功能接口定义

#### 数据模型 (models/)
- **item.dart**: 通用数据项模型，用于列表展示

#### 服务实现 (services/)
- **http_helper.dart**: HTTP 请求辅助工具
  - 提供网络请求的扩展方法
  - 支持错误处理和数据处理
  - 集成日志记录功能

### 3. 共享组件 (shared_widget/)

#### 基础组件
- **scaffold_app.dart**: 应用脚手架基类
  - 提供应用生命周期管理
  - 统一错误处理机制
  - 应用启动流程控制

- **buttons.dart**: 通用按钮组件
  - CommonButton: 标准按钮组件
  - 支持图标、文本、颜色自定义
  - 提供多种按钮样式

#### 交互组件
- **dialogs.dart**: 对话框组件
  - 提供各种类型的对话框
  - 支持自定义样式和内容

- **bottom_sheet.dart**: 底部弹窗组件
  - 底部滑出式弹窗
  - 支持自定义内容

- **badge.dart**: 徽章组件
  - 数字徽章显示
  - 支持位置和样式自定义

#### 导航组件
- **bottom_nav_widget.dart**: 底部导航组件
  - 底部标签导航
  - 支持图标和文本

- **lazy_load_indexed_stack.dart**: 懒加载索引栈
  - 按需加载页面内容
  - 优化内存使用

#### 功能组件
- **qr_scan_widget.dart**: 二维码扫描组件
  - 集成 ultra_qr_scanner
  - 支持闪光灯控制
  - 自动开始/停止扫描

- **assets_file_picker.dart**: 资源文件选择器
  - 图片、文件选择功能
  - 支持多选和预览

#### 列表组件
- **refreshable_widget.dart**: 可刷新组件
  - 下拉刷新功能
  - 支持自定义刷新逻辑
  - 集成 EasyRefresh

- **refreshable_paging_widget.dart**: 可刷新分页组件
  - 下拉刷新 + 上拉加载更多
  - 分页数据管理
  - 空数据状态处理

#### 页面组件
- **default_not_found_page.dart**: 默认404页面
  - 统一的错误页面样式
  - 支持自定义错误信息

## 依赖说明

### 主要依赖
- **core**: 核心基础库
- **fpdart**: 函数式编程工具
- **badges**: 徽章组件
- **flutter_screenutil**: 屏幕适配
- **wechat_assets_picker**: 资源选择器
- **wechat_camera_picker**: 相机选择器
- **easy_refresh**: 下拉刷新
- **waterfall_flow**: 瀑布流布局
- **ultra_qr_scanner**: 二维码扫描

## 使用方式

### 1. 样式配置
```dart
import 'package:shared/shared_app_style.dart';

// 使用预定义颜色
Container(
  color: AppStyle.primaryColor,
  child: Text('Hello'),
)
```

### 2. 通用按钮
```dart
import 'package:shared/shared_widget/buttons.dart';

CommonButton(
  text: '点击我',
  onPressed: () {
    // 处理点击事件
  },
)
```

### 3. 可刷新组件
```dart
import 'package:shared/shared_widget/refreshable_widget.dart';

RefreshableWidget<String>(
  request: () async {
    // 数据请求逻辑
    return '数据';
  },
  builder: (context, data) {
    return Text(data);
  },
)
```

## 设计原则

1. **可复用性**: 所有组件都设计为可复用的通用组件
2. **一致性**: 遵循统一的设计规范和交互模式
3. **可扩展性**: 支持自定义配置和样式
4. **性能优化**: 采用懒加载和按需渲染策略
5. **错误处理**: 统一的错误处理和用户反馈机制

## 开发指南

- 新增组件时，请遵循现有的命名和结构规范
- 组件应该支持自定义配置，避免硬编码
- 添加适当的文档注释和使用示例
- 确保组件的可测试性和可维护性
