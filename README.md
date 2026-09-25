# DebugCenter

[![CI Status](https://img.shields.io/travis/fenghanxu/DebugCenter.svg?style=flat)](https://travis-ci.org/fenghanxu/DebugCenter)
[![Version](https://img.shields.io/cocoapods/v/DebugCenter.svg?style=flat)](https://cocoapods.org/pods/DebugCenter)
[![License](https://img.shields.io/cocoapods/l/DebugCenter.svg?style=flat)](https://cocoapods.org/pods/DebugCenter)
[![Platform](https://img.shields.io/cocoapods/p/DebugCenter.svg?style=flat)](https://cocoapods.org/pods/DebugCenter)

## Example

记录日志时可以直接使用简写形式：

```swift
FHXLog("请求失败", .error)
FHXLog("崩溃信息", .crash)
```

该写法与原有的 `FHXLog.shared.log(...)`、`FHXLog.shared.debug(...)` 等 API
共用同一份日志数据和配置。原有调用方式仍然支持。

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

DebugCenter is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DebugCenter'
```

## Author

fenghanxu, qq384170231@gmail.com

## License

DebugCenter is available under the MIT license. See the LICENSE file for more info.
