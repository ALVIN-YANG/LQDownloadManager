
# LQDownloadManager

LQDownloadManager is a download manager in Swift, support background mode.


## Example

  Clone the repo, Run the example project.

## Requirements
- iOS 8.0+ 
- Xcode 8.0+

## Installation

CocoaPods 1.0.0+ is required to build MarkyMark

To integrate LQDownloadManager into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'LQDownloadManager'
```

## Usage

```swift
LQDownloadManager.shared.download("#download file url string#", progress: { progress in
      print("progress: \(progress)")
    }) { status in
      switch status {
      case .start:
        ...
      case .suspend:
        ...
      case .complete:
        ...
      case .failed:
        ...
      }
    }
```

## Contact me

Email: ylq.win@gmail.com
weibo: [青木KON] (http://weibo.com/5012041775/profile?topnav=1&wvr=6&is_all=1)

## License

MarkyMark is available under the MIT license. See the LICENSE file for more info.


