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

public protocol CaliperLayoutBase: class {}

extension CaliperLayoutBase {
    
    internal var constraints: [NSLayoutConstraint] {
        return self.constraintsSet.allObjects as! [NSLayoutConstraint]
    }
    
    internal func caliperAdd(constraints: [NSLayoutConstraint]) {
        let constraintsSet = self.constraintsSet
        for constraint in constraints {
            constraintsSet.add(constraint)
        }
    }
    
    internal func caliperRemove(constraints: [NSLayoutConstraint]) {
        let constraintsSet = self.constraintsSet
        for constraint in constraints {
            constraintsSet.remove(constraint)
        }
    }
    
    fileprivate var constraintsSet: NSMutableSet {
        let constraintsSet: NSMutableSet
        
        if let existing = objc_getAssociatedObject(self, &constraintsKey) as? NSMutableSet {
            constraintsSet = existing
        } else {
            constraintsSet = NSMutableSet()
            objc_setAssociatedObject(self, &constraintsKey, constraintsSet, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return constraintsSet
    }
}

private var constraintsKey: UInt8 = 0

extension CaliperLayoutView : CaliperLayoutBase { }

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
    
    public func makeConstraints(_ closure: (CaliperConstraintMaker)->()) {
        let maker = CaliperConstraintMaker(view: self.view)
        maker.make(closure)
    }
    
    public func remakeConstraints(_ closure: (CaliperConstraintMaker)->()) {
        let maker = CaliperConstraintMaker(view: self.view)
        NSLayoutConstraint.deactivate(self.view.constraintsSet.allObjects as! [NSLayoutConstraint])
        maker.make(closure)
    }
}

class CaliperConstraintExtender {
    
}

public class CaliperConstraintMaker {
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
        view.caliperAdd(constraints: constants)
    }
}

public extension CaliperConstraintMaker {
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
    
    var edges: CaliperConstraintMaker {
        return top.left.bottom.right
    }
    
    @discardableResult
    func equalTo(_ item: LayoutItem) -> Self {
        for it in items {
            let const = it == item
            constants.append(const)
        }
        items.removeAll()
        return self
    }
    
    @discardableResult
    func equalTo(_ item: CGFloat) -> Self {
        let dimensionContTyps: [NSLayoutConstraint.Attribute] = [.width, .height]
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
        return self
    }
    
    @discardableResult
    func equalTo(_ toView: CaliperLayoutView) -> Self {
        for it in items {
            let newItem = layoutItem(toView, it.attribute)
            let const = it == newItem
            constants.append(const)
        }
        items.removeAll()
        return self
    }
    
    @discardableResult
    func equalToSuperview() -> Self {
        let spv = view.superview!
        return equalTo(spv)
    }
    
    @discardableResult
    func offset(_ o: CGFloat) -> Self {
        constants.forEach { $0.constant += o }
        return self
    }
    
    @discardableResult
    func multiplier(_ m: CGFloat) -> Self {
        var newConstants = [NSLayoutConstraint]()
        for c in constants {
            let layoutC = NSLayoutConstraint.init(item: c.firstItem!, attribute: c.firstAttribute, relatedBy: c.relation, toItem: c.secondItem, attribute: c.secondAttribute, multiplier: m, constant: c.constant)
            newConstants.append(layoutC)
        }
        constants = newConstants
        return self
    }
}

public protocol LayoutRegion: AnyObject {}
extension CaliperLayoutView: LayoutRegion {}

@available(iOS 9.0, OSX 10.11, *)
extension LayoutGuide: LayoutRegion {}

public class Position {}
public class Dimension {}

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
