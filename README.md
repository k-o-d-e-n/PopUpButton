# PopUpButton

A control for selecting an item from a list. In other words, single motion version of `NSPopUpButton` for iOS, and original version for Mac Catalyst.

```swift
public final class PopUpButton : UIControl {

    public var itemsColor: UIColor? { get set }

    public var selectedItemColor: UIColor? { get set }

    public var cover: Cover { get set }

    public var anchor: Anchor { get set }

    public var items: [Item] { get set }

    public var currentIndex: Int { get set }
    
    public var selectionTouchInsideOnly: Bool { get set }

    public struct Item {
        public let title: String
    }

    public enum Anchor {
        case window
        case superview
    }
    
    public enum Cover {
        case color(UIColor?)
        case blur(UIBlurEffect.Style)
    }
}

```

## Example

<p align="center">
  <img src="Resources/demo.gif">
</p>

## Requirements

Swift 5+

## Installation

Cocoapods

```ruby
pod 'PopUpButton'
```

Swift Package Manager

```
.package(url: "https://github.com/k-o-d-e-n/PopUpButton.git", .branch("master"))
```

## Author

k-o-d-e-n, koden.u8800@gmail.com

## License

PopUpButton is available under the MIT license. See the LICENSE file for more info.
