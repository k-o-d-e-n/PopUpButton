//
//  PopUpButton.swift
//  PopUpButton
//
//  Created by Denis Koryttsev on 26.06.2020.
//  Copyright © 2020 k-o-d-e-n. All rights reserved.
//

import UIKit

public final class PopUpButton: UIControl {
    private var views: [ItemView] = []
    private var coverView: UIView? {
        willSet { coverView?.removeFromSuperview() }
    }
    private var _selectedIndex: Int? {
        didSet {
            guard oldValue != _selectedIndex else { return }
            if window != nil {
                if let old = oldValue {
                    let oldView = views[old]
                    if !isPresented {
                        oldView.removeFromSuperview()
                    } else {
                        oldView.backgroundColor = itemsColor ?? backgroundColor
                    }
                }
                if let new = _selectedIndex {
                    let newView = views[new]
                    if !isPresented {
                        addSubview(newView)
                    }
                    newView.backgroundColor = selectedItemColor ?? tintColor
                }
            }
        }
    }
    private var isPresented: Bool {
        #if targetEnvironment(macCatalyst)
        return isFirstResponder
        #else
        return isTracking
        #endif
    }

    public override var canBecomeFirstResponder: Bool { true }
    #if targetEnvironment(macCatalyst)
    public override var frame: CGRect {
        didSet {
            if oldValue.origin != frame.origin, isPresented {
                layoutViews(from: convert(bounds, to: coverView), index: _selectedIndex ?? currentIndex)
            }
        }
    }
    #endif

    public var itemsColor: UIColor?
    public var selectedItemColor: UIColor?
    public var cover: Cover = .color(#colorLiteral(red: 0.07058823529, green: 0.07058823529, blue: 0.07058823529, alpha: 0.9))

    public var anchor: Anchor = .window
    public var items: [Item] = [] {
        didSet {
            if superview != nil {
                reloadViews()
            }
            if window != nil {
                updateViews()
            }
        }
    }
    public var currentIndex: Int = 0 {
        didSet {
            guard window != nil, views.count > 0 else { return }
            let newView = views[currentIndex]
            if !isPresented {
                views[oldValue].removeFromSuperview()
                addSubview(newView)
            }
            newView.backgroundColor = nil
        }
    }
    public var selectionTouchInsideOnly: Bool = false

    public convenience init(items: [Item], frame: CGRect = .zero) {
        precondition(items.count > 0, "Items cannot be empty")
        self.init(frame: frame)
        self.items = items
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        reloadViews()
    }

    public override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        updateViews()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if isPresented, window != nil, let index = _selectedIndex {
            let currentView = views[index]
            layoutViews(from: currentView.frame, index: index)
        } else if views.count > currentIndex {
            views[currentIndex].frame = bounds
        }
    }

    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard let spaceView = anchor.view(for: self) else { return false }
        guard super.beginTracking(touch, with: event) && super.becomeFirstResponder() else { return false }

        _selectedIndex = currentIndex

        let (cover, content) = self.cover.build()
        #if targetEnvironment(macCatalyst)
        let tapCover = UITapGestureRecognizer(target: self, action: #selector(_tapInCover(_:)))
        let hoverCover = UIHoverGestureRecognizer(target: self, action: #selector(_hoverInCover(_:)))
        cover.addGestureRecognizer(tapCover)
        cover.addGestureRecognizer(hoverCover)
        #endif
        cover.frame = spaceView.bounds
        spaceView.addSubview(cover)

        let current = views[currentIndex]
        current.backgroundColor = selectedItemColor ?? tintColor
        let anchorRect = cover.convert(current.frame, from: self)
        layoutViews(from: anchorRect, index: currentIndex)
        views.enumerated().forEach({ i, v in
            if i != currentIndex {
                v.backgroundColor = itemsColor ?? backgroundColor
            }
            content.addSubview(v)
        })
        self.coverView = cover

        return true
    }

    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        guard let cover = coverView else { return false }
        let pointInCover = convert(touch.location(in: self), to: cover)
        _onTracking(in: cover, point: pointInCover)
        return true
    }

    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        #if !targetEnvironment(macCatalyst)
        resignFirstResponder()
        #endif
    }

    public override func becomeFirstResponder() -> Bool { false }

    @discardableResult
    public override func resignFirstResponder() -> Bool {
        guard super.resignFirstResponder() else { return false }
        _onResignFirstResponder()
        return true
    }

    private func _onTracking(in cover: UIView, point pointInCover: CGPoint) {
        guard let index = views.firstIndex(where: { $0.frame.minY < pointInCover.y && $0.frame.maxY > pointInCover.y }) else { return }
        let selected = views[index]
        guard !selectionTouchInsideOnly || selected.frame.contains(pointInCover) else {
            _selectedIndex = nil
            return
        }
        _selectedIndex = index
        var nextIndex = index
        if pointInCover.y <= (frame.height + cover.safeAreaInsets.top) {
            nextIndex = max(0, index - 1)
        } else if pointInCover.y >= (cover.bounds.maxY - frame.height - cover.safeAreaInsets.bottom) {
            nextIndex = min(views.count - 1, index + 1)
        }
        if nextIndex != _selectedIndex {
            _selectedIndex = nextIndex
            layoutViews(from: views[index].frame, index: nextIndex)
        }
    }

    private func _onResignFirstResponder() {
        coverView = nil
        guard let newIndex = _selectedIndex, newIndex != currentIndex else {
            let current = views[currentIndex]
            current.backgroundColor = nil
            addSubview(current)
            return
        }
        _selectedIndex = nil
        currentIndex = newIndex
        sendActions(for: .valueChanged)
    }

    private func layoutViews(from rect: CGRect, index: Int) {
        views.enumerated().forEach { i, view in
            view.frame = CGRect(
                x: rect.minX,
                y: rect.minY + (CGFloat(i - index) * rect.height),
                width: rect.width, height: rect.height
            )
        }
    }

    private func reloadViews() {
        views = views.prefix(items.count) + (min(items.count, views.count)..<items.count).map({ i -> ItemView in
            let view = ItemView(frame: bounds)
            if i == 0 {
                view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                view.layer.cornerRadius = layer.cornerRadius
            } else if i == items.count - 1 {
                view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                view.layer.cornerRadius = layer.cornerRadius
            }
            view.isUserInteractionEnabled = false
            return view
        })
    }

    private func updateViews() {
        zip(items, views).enumerated().forEach { (i, item) in
            item.1.titleLabel.text = item.0.title
            if i == currentIndex {
                addSubview(item.1)
            }
        }
    }

    #if targetEnvironment(macCatalyst)
    @objc func _tapInCover(_ gesture: UITapGestureRecognizer) {
        defer { resignFirstResponder() }
        guard views.count > 0 else { return }
        let location = gesture.location(in: gesture.view)
        guard views[0].frame.minX < location.x, views[0].frame.minY < location.y else { return }
        guard views.last!.frame.maxX > location.x, views.last!.frame.maxY > location.y else { return }
        _selectedIndex = Int((location.y - views[0].frame.minY) / views[0].frame.height)
    }

    @objc func _hoverInCover(_ gesture: UIHoverGestureRecognizer) {
        _onTracking(in: gesture.view!, point: gesture.location(in: gesture.view))
    }
    #endif
}
extension PopUpButton {
    public struct Item {
        public let title: String

        public init(title: String) {
            self.title = title
        }
    }

    public enum Anchor {
        case window
        case superview
        case view(View)
        case viewController(ViewController)

        public static func view(_ view: UIView) -> Anchor {
            .view(View(view: view))
        }
        public static func viewController(_ viewController: UIViewController) -> Anchor {
            .viewController(ViewController(controller: viewController))
        }

        public struct View {
            weak var view: UIView?
        }
        public struct ViewController {
            weak var controller: UIViewController?
        }

        func view(for view: UIView) -> UIView? {
            switch self {
            case .window: return view.window
            case .superview: return view.superview
            case .view(let custom): return custom.view
            case .viewController(let custom): return custom.controller?.view
            }
        }
    }

    public enum Cover {
        case color(UIColor?)
        case blur(UIBlurEffect.Style)

        func build() -> (view: UIView, contentView: UIView) {
            switch self {
            case .color(let color):
                let view = UIView()
                view.backgroundColor = color
                view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                return (view, view)
            case .blur(let style):
                let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
                view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                return (view, view.contentView)
            }
        }
    }

    private final class ItemView: UIView {
        lazy var titleLabel: UILabel = {
            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.textColor = .white
            addSubview(lbl)
            NSLayoutConstraint.activate([
                lbl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                lbl.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            return lbl
        }()
    }
}
