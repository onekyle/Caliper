//
//  Caliper.swift
//  Caliper
//
//  Created by Kyle on 2020/5/6
//  Copyright © 2020 kyle. All rights reserved.
//
#if os(OSX)
    import AppKit
    public typealias CaliperLayoutView = NSView
    public typealias LayoutPriority = NSLayoutPriority
    
    @available(OSX 10.11, *)
    public typealias LayoutGuide = NSLayoutGuide
#elseif os(iOS) || os(tvOS)
    import UIKit
    public typealias CaliperLayoutView = UIView
    public typealias LayoutPriority = UILayoutPriority
    
    @available(iOS 9.0, *)
    public typealias LayoutGuide = UILayoutGuide
#endif

extension CaliperLayoutView {
    public var clp: CaliperLayoutDSL {
        return CaliperLayoutDSL.init(view: self)
    }
}

public class CaliperLayoutDSL {
    fileprivate unowned(unsafe) var view: CaliperLayoutView
    init(view: CaliperLayoutView) {
        self.view = view
    }
    
    func makeConstraint(_ closure: (CaliperConstraintMaker)->()) {
        let maker = CaliperConstraintMaker(view: self.view)
        maker.make(closure)
    }
}

class CaliperConstraintExtender {
    
}

class CaliperConstraintMaker {
    fileprivate unowned(unsafe) var view: CaliperLayoutView
    fileprivate var items = [LayoutItem]()
    fileprivate var constants = [NSLayoutConstraint]()
    init(view: CaliperLayoutView) {
        self.view = view
    }
    func make(_ closure: (CaliperConstraintMaker)->()) {
        self.view.translatesAutoresizingMaskIntoConstraints = false
        closure(self)
        NSLayoutConstraint.activate(constants)
        constants.removeAll()
    }
}

extension CaliperConstraintMaker {
    var left: CaliperConstraintMaker {
        let item: LayoutItem = layoutItem(self.view, .left)
      items.append(item)
      return self
    }
    var right: CaliperConstraintMaker {
      let item: LayoutItem = layoutItem(self.view, .right)
      items.append(item)
      return self
    }
    var top: CaliperConstraintMaker {
      let item: LayoutItem = layoutItem(self.view, .top)
      items.append(item)
      return self
    }
    var bottom: CaliperConstraintMaker {
      let item: LayoutItem = layoutItem(self.view, .bottom)
      items.append(item)
      return self
    }
    var leading: CaliperConstraintMaker {
      let item: LayoutItem = layoutItem(self.view, .leading)
      items.append(item)
      return self
    }
    var trailing: CaliperConstraintMaker {
      let item: LayoutItem = layoutItem(self.view, .trailing)
      items.append(item)
      return self
    }
    var width: CaliperConstraintMaker {
      let item: LayoutItem = layoutItem(self.view, .width)
      items.append(item)
      return self
    }
    var height: CaliperConstraintMaker {
      let item: LayoutItem = layoutItem(self.view, .height)
      items.append(item)
      return self
    }
    var centerX: CaliperConstraintMaker {
      let item: LayoutItem = layoutItem(self.view, .centerX)
      items.append(item)
      return self
    }
    var centerY: CaliperConstraintMaker {
      let item: LayoutItem = layoutItem(self.view, .centerY)
      items.append(item)
      return self
    }
    
    func equalTo(_ item: LayoutItem) {
        for it in items {
            let const = it == item
            constants.append(const)
        }
        items.removeAll()
    }
    
    func equalTo(_ item: CGFloat) {
        let dimensionContTyps: [NSLayoutConstraint.Attribute] = [.width, .height, .centerX, .centerY]
        let spv = view.superview!
        for it in items {
            let const: NSLayoutConstraint
            if !dimensionContTyps.contains(it.attribute) {
                let newItem = LayoutItem.init(item: spv, attribute: it.attribute, multiplier: 1.0, constant: item)
                const = it == newItem
            } else {
                const = it == item
            }
            constants.append(const)
        }
        items.removeAll()
    }
    
    func equalToSuperView() {
        let spv = view.superview!
        for it in items {
            let newItem = layoutItem(spv, it.attribute)
            let const = it == newItem
            constants.append(const)
        }
        items.removeAll()
    }
}

public protocol LayoutRegion: AnyObject {}
extension CaliperLayoutView: LayoutRegion {}

@available(iOS 9.0, OSX 10.11, *)
extension LayoutGuide: LayoutRegion {}

public final class LayoutItem {
    public let item: AnyObject
    public let attribute: NSLayoutConstraint.Attribute
    public let multiplier: CGFloat
    public let constant: CGFloat
    
    public init(item: AnyObject, attribute: NSLayoutConstraint.Attribute, multiplier: CGFloat, constant: CGFloat) {
        self.item = item
        self.attribute = attribute
        self.multiplier = multiplier
        self.constant = constant
    }
    
    fileprivate func constrain(_ secondItem: LayoutItem, relation: NSLayoutConstraint.Relation) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: attribute, relatedBy: relation, toItem: secondItem.item, attribute: secondItem.attribute, multiplier: secondItem.multiplier, constant: secondItem.constant)
    }
    
    fileprivate func constrain(_ constant: CGFloat, relation: NSLayoutConstraint.Relation) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: attribute, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: constant)
    }
    
    fileprivate func itemWithMultiplier(_ multiplier: CGFloat) -> LayoutItem {
        let item = LayoutItem(item: self.item, attribute: self.attribute, multiplier: multiplier, constant: self.constant)

        return item
    }
    
    fileprivate func itemWithConstant(_ constant: CGFloat) -> LayoutItem {
        let item = LayoutItem(item: self.item, attribute: self.attribute, multiplier: self.multiplier, constant: constant)
        return item
    }
}

public func *(lhs: LayoutItem, rhs: CGFloat) -> LayoutItem {
    return lhs.itemWithMultiplier(lhs.multiplier * rhs)
}

public func /(lhs: LayoutItem, rhs: CGFloat) -> LayoutItem {
    return lhs.itemWithMultiplier(lhs.multiplier / rhs)
}

public func +(lhs: LayoutItem, rhs: CGFloat) -> LayoutItem {
    return lhs.itemWithConstant(lhs.constant + rhs)
}

public func -(lhs: LayoutItem, rhs: CGFloat) -> LayoutItem {
    return lhs.itemWithConstant(lhs.constant - rhs)
}

public func ==(lhs: LayoutItem, rhs: LayoutItem) -> NSLayoutConstraint {
    return lhs.constrain(rhs, relation: .equal)
}

public func ==(lhs: LayoutItem, rhs: CGFloat) -> NSLayoutConstraint {
    return lhs.constrain(rhs, relation: .equal)
}

public func >=(lhs: LayoutItem, rhs: LayoutItem) -> NSLayoutConstraint {
    return lhs.constrain(rhs, relation: .greaterThanOrEqual)
}

public func >=(lhs: LayoutItem, rhs: CGFloat) -> NSLayoutConstraint {
    return lhs.constrain(rhs, relation: .greaterThanOrEqual)
}

public func <=(lhs: LayoutItem, rhs: LayoutItem) -> NSLayoutConstraint {
    return lhs.constrain(rhs, relation: .lessThanOrEqual)
}

public func <=(lhs: LayoutItem, rhs: CGFloat) -> NSLayoutConstraint {
    return lhs.constrain(rhs, relation: .lessThanOrEqual)
}

private func layoutItem(_ item: AnyObject, _ attribute: NSLayoutConstraint.Attribute) -> LayoutItem {
    return LayoutItem(item: item, attribute: attribute, multiplier: 1.0, constant: 0.0)
}

public extension LayoutRegion {
    var left: LayoutItem { return layoutItem(self, .left) }
    var right: LayoutItem { return layoutItem(self, .right) }
    var top: LayoutItem { return layoutItem(self, .top) }
    var bottom: LayoutItem { return layoutItem(self, .bottom) }
    var leading: LayoutItem { return layoutItem(self, .leading) }
    var trailing: LayoutItem { return layoutItem(self, .trailing) }
    var width: LayoutItem { return layoutItem(self, .width) }
    var height: LayoutItem { return layoutItem(self, .height) }
    var centerX: LayoutItem { return layoutItem(self, .centerX) }
    var centerY: LayoutItem { return layoutItem(self, .centerY) }
}

precedencegroup PriorityPrecedence {
  lowerThan: ComparisonPrecedence
  higherThan: AssignmentPrecedence
}
infix operator ~ : PriorityPrecedence

public func ~(lhs: NSLayoutConstraint, rhs: LayoutPriority) -> NSLayoutConstraint {
    guard let firstItem = lhs.firstItem, let secondItem = lhs.secondItem else { return lhs }
    let newConstraint = NSLayoutConstraint(item: firstItem, attribute: lhs.firstAttribute, relatedBy: lhs.relation, toItem: secondItem, attribute: lhs.secondAttribute, multiplier: lhs.multiplier, constant: lhs.constant)
    newConstraint.priority = rhs
    return newConstraint
}
