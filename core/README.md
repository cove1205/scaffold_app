# Core 基础组件库

## 概述

Core 是一个 Flutter 基础组件库，提供了应用开发中常用的核心功能模块，包括网络请求、工具类、扩展方法等。该库采用模块化设计，便于维护和扩展。

## 目录结构

```
core/
├── lib/                          # 核心代码目录
│   ├── core_extensions/          # 扩展方法模块
│   │   ├── date_time_extension.dart    # 日期时间扩展
│   │   ├── function_extension.dart     # 函数扩展
│   │   └── string_extension.dart       # 字符串扩展
│   ├── core_network/             # 网络请求模块
│   │   ├── core_network.dart           # 网络客户端核心类
│   │   ├── exception.dart              # 网络异常处理
│   │   ├── request.dart                # 请求封装
│   │   ├── response.dart               # 响应封装
│   │   ├── status_codes.dart           # HTTP状态码
│   │   └── interceptors/               # 拦截器目录
│   │       └── retry_interceptor.dart  # 重试拦截器
│   └── core_utils/               # 工具类模块
│       ├── common_util.dart            # 通用工具类
│       ├── connectivity_util.dart      # 网络连接工具
│       ├── crypt_util.dart             # 加密工具
│       ├── image_util.dart             # 图片处理工具
│       ├── info_util.dart              # 设备信息工具
│       ├── lifecycle_util.dart         # 生命周期工具
│       ├── link_util.dart              # 链接处理工具
│       ├── loading_util.dart           # 加载提示工具
│       ├── log_util.dart               # 日志工具
│       ├── permission_util.dart        # 权限管理工具
│       └── storage_util.dart           # 存储工具
├── pubspec.yaml                  # 依赖配置
├── pubspec.lock                  # 依赖锁定文件
└── README.md                     # 说明文档
```

## 模块说明

### 1. core_extensions - 扩展方法模块

提供常用数据类型的扩展方法，增强原有类型的功能。

#### 文件说明：
- **date_time_extension.dart**: 日期时间扩展
  - 提供日期格式化方法（年-月-日、时:分:秒等）
  - 中文格式化（年月日、周几等）
  - 时间差计算（几天前、几小时前等）
  - 获取一天的开始和结束时间

- **function_extension.dart**: 函数扩展
  - 提供函数相关的扩展方法

- **string_extension.dart**: 字符串扩展
  - 类型转换（toDouble、toInt）
  - 首字母大写、单词首字母大写
  - 金额格式化
  - 正则验证（手机号、邮箱、身份证等）

### 2. core_network - 网络请求模块

基于 Dio 封装的网络请求框架，提供统一的网络请求接口。

#### 文件说明：
- **core_network.dart**: 网络客户端核心类
  - NetworkClient 单例类
  - 支持 GET、POST、PUT、DELETE 等请求方法
  - 支持文件上传和下载
  - 支持请求重试机制

- **exception.dart**: 网络异常处理
  - NetworkException 异常类
  - 支持多种异常类型（超时、连接错误、取消等）
  - 自动解析 Dio 异常并转换为自定义异常

- **request.dart**: 请求封装
  - NetworkRequest 请求构建类
  - 支持请求参数、头部、进度回调等

- **response.dart**: 响应封装
  - NetworkResponse 响应处理类
  - 统一响应数据格式

- **status_codes.dart**: HTTP状态码
  - 定义常用HTTP状态码常量

- **interceptors/retry_interceptor.dart**: 重试拦截器
  - 网络请求失败时自动重试

### 3. core_utils - 工具类模块

提供各种实用工具类，简化开发中的常见操作。

#### 文件说明：
- **common_util.dart**: 通用工具类
  - 生成随机颜色
  - 生成随机字符串

- **connectivity_util.dart**: 网络连接工具
  - 检测网络连接状态
  - 监听网络变化

- **crypt_util.dart**: 加密工具
  - 提供数据加密和解密功能

- **image_util.dart**: 图片处理工具
  - 图片压缩、裁剪等处理功能

- **info_util.dart**: 设备信息工具
  - 获取设备信息、应用信息等

- **lifecycle_util.dart**: 生命周期工具
  - 应用生命周期管理

- **link_util.dart**: 链接处理工具
  - URL 启动、深度链接处理

- **loading_util.dart**: 加载提示工具
  - 统一的加载提示界面

- **log_util.dart**: 日志工具
  - 基于 Talker 的日志系统
  - 支持不同日志级别
  - 提供网络请求日志拦截器

- **permission_util.dart**: 权限管理工具
  - 权限请求和状态检查

- **storage_util.dart**: 存储工具
  - 基于 SharedPreferences 的键值存储
  - 支持对象序列化存储
  - 缓存管理功能

## 主要依赖

- **dio**: 网络请求库
- **talker_flutter**: 日志系统
- **shared_preferences**: 本地存储
- **path_provider**: 路径获取
- **permission_handler**: 权限管理
- **crypto**: 加密库
- **package_info_plus**: 应用信息
- **device_info_plus**: 设备信息
- **connectivity_plus**: 网络状态
- **url_launcher**: URL启动
- **app_links**: 深度链接

## 使用示例

### 网络请求
```dart
// 初始化网络客户端
NetworkClient.init(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 30),
);

// 发起请求
final response = await NetworkClient().fetch(
  NetworkRequest(
    apiPath: '/users',
    method: RequestMethod.get,
  ),
);
```

### 存储操作
```dart
// 初始化存储
await StorageUtil.init();

// 存储数据
await StorageUtil.setValue('key', 'value');
await StorageUtil.setObject('user', {'name': 'John'});

// 读取数据
final value = StorageUtil.getValue('key');
final user = StorageUtil.getObject('user');
```

### 日志记录
```dart
// 记录日志
LogUtil.info('这是一条信息日志');
LogUtil.error('这是一条错误日志');
LogUtil.debug('这是一条调试日志');
```

### 字符串扩展
```dart
// 使用字符串扩展
final phone = '13800138000';
if (phone.isMobileExact()) {
  print('有效的手机号');
}

final amount = '1234.56';
print(amount.toMoneyFormat()); // 输出: 1,234.56
```

## 版本信息

- 当前版本: 1.0.0
- Flutter SDK: >=3.35.1
- Dart SDK: >=3.9.0<4.0.0