![example workflow](https://git.happyeyez.com/cove/scaffold_app/actions/workflows/build_release.yaml/badge.svg)

# Scaffold App

一个基于 Flutter 的脚手架应用模板，采用模块化架构设计，提供完整的项目基础框架。

## 项目概述

本项目是一个 Flutter 应用脚手架模板，采用分层模块化架构，包含核心基础库、共享组件库、功能模块等，为快速开发 Flutter 应用提供完整的基础框架。

## 技术栈

- **Flutter**: >=3.35.1
- **Dart SDK**: >=3.9.0<4.0.0
- **状态管理**: GetX
- **网络请求**: Dio
- **屏幕适配**: flutter_screenutil
- **日志系统**: Talker
- **路由管理**: GetX Router

## 项目目录结构

```
scaffold_app/
├── android/                    # Android 平台相关文件
│   ├── app/                   # Android 应用配置
│   ├── build.gradle.kts       # Android 构建配置
│   └── gradle/                # Gradle 构建工具配置
├── ios/                       # iOS 平台相关文件
│   ├── Runner/                # iOS 应用配置
│   ├── Podfile               # CocoaPods 依赖管理
│   └── Runner.xcodeproj/      # Xcode 项目文件
├── build/                     # 构建输出目录
├── core/                      # 核心基础库
│   └── lib/
│       ├── core_extensions/   # 核心扩展功能
│       ├── core_network/      # 网络请求模块
│       └── core_utils/        # 核心工具类
├── features/                  # 功能模块目录
│   ├── feature_auth/          # 认证功能模块
│   └── feature_debug/         # 调试功能模块
├── shared/                    # 共享组件库
│   └── lib/
│       ├── shared_app_style.dart    # 应用样式配置
│       ├── shared_services/         # 共享服务
│       └── shared_widget/           # 共享组件
├── lib/                       # 主应用代码
│   ├── app/                   # 应用主模块
│   │   ├── app.dart          # 应用入口
│   │   ├── configs/          # 应用配置
│   │   ├── root_page.dart    # 根页面
│   │   └── splash_page.dart  # 启动页
│   └── main.dart             # 应用启动入口
├── scripts/                   # 构建和部署脚本
├── pubspec.yaml              # 项目依赖配置
└── README.md                 # 项目说明文档
```

## 目录说明

### 核心模块 (core/)
核心基础库，提供应用的基础功能支持：
- **core_extensions/**: 核心扩展功能，包含常用的扩展方法
- **core_network/**: 网络请求模块，基于 Dio 封装的网络请求库
- **core_utils/**: 核心工具类，包含日志、存储、权限、加密等工具

### 共享模块 (shared/)
共享组件库，提供可复用的 UI 组件和服务：
- **shared_app_style.dart**: 应用全局样式配置
- **shared_services/**: 共享服务，如主题服务、本地化服务等
- **shared_widget/**: 共享 UI 组件，如通用按钮、输入框等

### 功能模块 (features/)
按功能划分的独立模块，每个模块包含完整的业务逻辑：
- **feature_auth/**: 用户认证相关功能
- **feature_debug/**: 调试和开发工具功能

### 应用主模块 (lib/app/)
应用的主要配置和入口：
- **app.dart**: 应用主类，继承自 ScaffoldApp
- **configs/**: 应用配置文件，包含路由、服务、常量等配置
- **root_page.dart**: 应用根页面
- **splash_page.dart**: 应用启动页面

### 平台目录
- **android/**: Android 平台相关配置和资源
- **ios/**: iOS 平台相关配置和资源
- **build/**: 构建输出目录，包含编译后的文件

### 脚本目录 (scripts/)
- **build.sh**: 构建脚本
- **deploy.sh**: 部署脚本
- **spider.yaml**: 用于资源图片的名称映射脚本

## 架构特点

1. **模块化设计**: 采用分层模块化架构，核心功能、共享组件、业务功能分离
2. **依赖注入**: 使用 GetX 进行状态管理和依赖注入
3. **统一配置**: 集中管理应用配置、路由、样式等
4. **工具集成**: 集成日志、网络、存储、权限等常用工具
5. **跨平台支持**: 支持 Android 和 iOS 平台

## 快速开始

1. 克隆项目到本地
2. 运行 `flutter pub get` 安装依赖
3. 运行 `flutter run` 启动应用

## 开发指南

- 新增功能模块时，请在 `features/` 目录下创建对应的模块
- 通用组件请放在 `shared/` 目录下
- 核心工具类请放在 `core/` 目录下
- 遵循模块化开发原则，保持代码结构清晰
