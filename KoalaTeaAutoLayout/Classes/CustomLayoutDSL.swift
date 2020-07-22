//
//  CustomLayoutDSL.swift
//  KoalaTeaAutoLayout
//
//  Created by Craig Holliday on 7/17/19.
//

import UIKit

public protocol LayoutAnchor {
    func constraint(equalTo anchor: Self, constant: CGFloat) -> NSLayoutConstraint
    func constraint(greaterThanOrEqualTo anchor: Self, constant: CGFloat) -> NSLayoutConstraint
    func constraint(lessThanOrEqualTo anchor: Self, constant: CGFloat) -> NSLayoutConstraint
}

public protocol LayoutDimension {
    func constraint(equalToConstant c: CGFloat) -> NSLayoutConstraint
    func constraint(greaterThanOrEqualToConstant c: CGFloat) -> NSLayoutConstraint
    func constraint(lessThanOrEqualToConstant c: CGFloat) -> NSLayoutConstraint

    func constraint(equalTo anchor: Self, multiplier m: CGFloat, constant c: CGFloat) -> NSLayoutConstraint
    func constraint(greaterThanOrEqualTo anchor: Self, multiplier m: CGFloat, constant c: CGFloat) -> NSLayoutConstraint
    func constraint(lessThanOrEqualTo anchor: Self, multiplier m: CGFloat, constant c: CGFloat) -> NSLayoutConstraint
}

extension NSLayoutAnchor: LayoutAnchor {}

extension NSLayoutDimension: LayoutDimension {}

public class LayoutProperty<Anchor: LayoutAnchor> {
    fileprivate let anchor: Anchor
    var constraints: [NSLayoutConstraint] = []

    internal init(anchor: Anchor) {
        self.anchor = anchor
    }
}

public class LayoutDimensionProperty<Anchor: LayoutAnchor & LayoutDimension> {
    fileprivate let anchor: Anchor
    var constraints: [NSLayoutConstraint] = []

    internal init(anchor: Anchor) {
        self.anchor = anchor
    }
}

public class LayoutProxy {
    public lazy var leading = property(with: view.leadingAnchor)
    public lazy var trailing = property(with: view.trailingAnchor)
    public lazy var top = property(with: view.topAnchor)
    public lazy var bottom = property(with: view.bottomAnchor)
    public lazy var width = dimensionProperty(with: view.widthAnchor)
    public lazy var height = dimensionProperty(with: view.heightAnchor)
    public lazy var centerXAnchor = property(with: view.centerXAnchor)
    public lazy var centerYAnchor = property(with: view.centerYAnchor)

    private let view: UIView

    fileprivate init(view: UIView) {
        self.view = view
    }

    private func property<A: LayoutAnchor>(with anchor: A) -> LayoutProperty<A> {
        return LayoutProperty(anchor: anchor)
    }

    private func dimensionProperty<A: LayoutDimension>(with anchor: A) -> LayoutDimensionProperty<A> {
        return LayoutDimensionProperty(anchor: anchor)
    }

    var constraints: [NSLayoutConstraint] {
        return leading.constraints +
            trailing.constraints +
            top.constraints +
            bottom.constraints +
            width.constraints +
            height.constraints +
            centerXAnchor.constraints +
            centerYAnchor.constraints
    }
}

public extension LayoutProperty {
    func equal(to otherAnchor: Anchor, constant: CGFloat = 0) {
        let constraint = anchor.constraint(equalTo: otherAnchor, constant: constant)
        constraint.isActive = true
        constraints.append(constraint)
    }

    func greaterThanOrEqual(to otherAnchor: Anchor, constant: CGFloat = 0) {
        let constraint = anchor.constraint(greaterThanOrEqualTo: otherAnchor, constant: constant)
        constraint.isActive = true
        constraints.append(constraint)
    }

    func lessThanOrEqual(to otherAnchor: Anchor, constant: CGFloat = 0) {
        let constraint = anchor.constraint(lessThanOrEqualTo: otherAnchor, constant: constant)
        constraint.isActive = true
        constraints.append(constraint)
    }
}

public extension LayoutDimensionProperty {
    func equal(to constant: CGFloat) {
        let constraint = anchor.constraint(equalToConstant: constant)
        constraint.isActive = true
        constraints.append(constraint)
    }

    func greaterThanOrEqual(to constant: CGFloat) {
        let constraint = anchor.constraint(greaterThanOrEqualToConstant: constant)
        constraint.isActive = true
        constraints.append(constraint)
    }

    func lessThanOrEqual(to constant: CGFloat) {
        let constraint = anchor.constraint(lessThanOrEqualToConstant: constant)
        constraint.isActive = true
        constraints.append(constraint)
    }

    func equal(to otherAnchor: Anchor, multiplier m: CGFloat = 1.0, constant c: CGFloat = 0) {
        let constraint = anchor.constraint(equalTo: otherAnchor, multiplier: m, constant: c)
        constraint.isActive = true
        constraints.append(constraint)
    }

    func greaterThanOrEqual(to otherAnchor: Anchor, multiplier m: CGFloat = 1.0, constant c: CGFloat = 0) {
        let constraint = anchor.constraint(greaterThanOrEqualTo: otherAnchor, multiplier: m, constant: c)
        constraint.isActive = true
        constraints.append(constraint)
    }

    func lessThanOrEqual(to otherAnchor: Anchor, multiplier m: CGFloat = 1.0, constant c: CGFloat = 0) {
        let constraint = anchor.constraint(lessThanOrEqualTo: otherAnchor, multiplier: m, constant: c)
        constraint.isActive = true
        constraints.append(constraint)
    }

    func equal(to property: LayoutDimensionProperty, multiplier m: CGFloat = 1.0, constant c: CGFloat = 0) {
        let constraint = anchor.constraint(equalTo: property.anchor, multiplier: m, constant: c)
        constraint.isActive = true
        constraints.append(constraint)
    }

    func greaterThanOrEqual(to property: LayoutDimensionProperty, multiplier m: CGFloat = 1.0, constant c: CGFloat = 0) {
        let constraint = anchor.constraint(greaterThanOrEqualTo: property.anchor, multiplier: m, constant: c)
        constraint.isActive = true
        constraints.append(constraint)
    }

    func lessThanOrEqual(to property: LayoutDimensionProperty, multiplier m: CGFloat = 1.0, constant c: CGFloat = 0) {
        let constraint = anchor.constraint(lessThanOrEqualTo: property.anchor, multiplier: m, constant: c)
        constraint.isActive = true
        constraints.append(constraint)
    }
}

// MARK: - UIView Extensions

public extension UIView {
    @discardableResult
    func layout(_ closure: (LayoutProxy) -> Void) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let proxy = LayoutProxy(view: self)
        closure(proxy)
        return proxy.constraints
    }

    @discardableResult
    func constrainEdgesToSuperview() -> [NSLayoutConstraint]? {
        guard let superview = self.superview else { return nil }
        return layout {
            $0.top == superview.topAnchor
            $0.bottom == superview.bottomAnchor
            $0.leading == superview.leadingAnchor
            $0.trailing == superview.trailingAnchor
        }
    }

    @discardableResult
    func constrainCenterToSuperview() -> [NSLayoutConstraint]? {
        guard let superview = self.superview else { return nil }
        return layout {
            $0.centerXAnchor == superview.centerXAnchor
            $0.centerYAnchor == superview.centerYAnchor
        }
    }

    @discardableResult
    func constrainEdges(to otherView: UIView) -> [NSLayoutConstraint] {
        return layout {
            $0.top == otherView.topAnchor
            $0.bottom == otherView.bottomAnchor
            $0.leading == otherView.leadingAnchor
            $0.trailing == otherView.trailingAnchor
        }
    }
}

// MARK: - LayoutAnchor Override Operators

public func + <A: LayoutAnchor>(lhs: A, rhs: CGFloat) -> (A, CGFloat) {
    return (lhs, rhs)
}

public func - <A: LayoutAnchor>(lhs: A, rhs: CGFloat) -> (A, CGFloat) {
    return (lhs, -rhs)
}

// MARK: - LayoutAnchor Operators

// MARK: - LayoutProperty -> LayoutAnchor

public func == <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: A) {
    lhs.equal(to: rhs)
}

public func >= <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: A) {
    lhs.greaterThanOrEqual(to: rhs)
}

public func <= <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: A) {
    lhs.lessThanOrEqual(to: rhs)
}

// MARK: - LayoutProperty -> LayoutAnchor, Constant

public func == <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: (A, CGFloat)) {
    lhs.equal(to: rhs.0, constant: rhs.1)
}

public func >= <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: (A, CGFloat)) {
    lhs.greaterThanOrEqual(to: rhs.0, constant: rhs.1)
}

public func <= <A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: (A, CGFloat)) {
    lhs.lessThanOrEqual(to: rhs.0, constant: rhs.1)
}

// MARK: - LayoutDimension Override Operators

public func + <A: LayoutDimension & LayoutAnchor>(lhs: A, rhs: CGFloat) -> (A, CGFloat) {
    return (lhs, rhs)
}

public func - <A: LayoutDimension & LayoutAnchor>(lhs: A, rhs: CGFloat) -> (A, CGFloat) {
    return (lhs, -rhs)
}

public func + <A: LayoutDimension & LayoutAnchor>(lhs: LayoutDimensionProperty<A>, rhs: CGFloat) -> (A, CGFloat) {
    return (lhs.anchor, rhs)
}

public func - <A: LayoutDimension & LayoutAnchor>(lhs: LayoutDimensionProperty<A>, rhs: CGFloat) -> (A, CGFloat) {
    return (lhs.anchor, -rhs)
}

// MARK: - LayoutDimension Operators

// MARK: - LayoutDimensionProperty -> LayoutDimension

public func == <A: LayoutDimension>(lhs: LayoutDimensionProperty<A>, rhs: A) {
    lhs.equal(to: rhs)
}

public func >= <A: LayoutDimension>(lhs: LayoutDimensionProperty<A>, rhs: A) {
    lhs.greaterThanOrEqual(to: rhs)
}

public func <= <A: LayoutDimension>(lhs: LayoutDimensionProperty<A>, rhs: A) {
    lhs.lessThanOrEqual(to: rhs)
}

// MARK: - LayoutDimensionProperty -> LayoutDimensionProperty

public func == <A: LayoutDimension>(lhs: LayoutDimensionProperty<A>, rhs: LayoutDimensionProperty<A>) {
    lhs.equal(to: rhs)
}

public func >= <A: LayoutDimension>(lhs: LayoutDimensionProperty<A>, rhs: LayoutDimensionProperty<A>) {
    lhs.greaterThanOrEqual(to: rhs)
}

public func <= <A: LayoutDimension>(lhs: LayoutDimensionProperty<A>, rhs: LayoutDimensionProperty<A>) {
    lhs.lessThanOrEqual(to: rhs)
}

// MARK: - LayoutDimensionProperty -> Constant

public func == <A: LayoutDimension>(lhs: LayoutDimensionProperty<A>, rhs: CGFloat) {
    lhs.equal(to: rhs)
}

public func >= <A: LayoutDimension>(lhs: LayoutDimensionProperty<A>, rhs: CGFloat) {
    lhs.greaterThanOrEqual(to: rhs)
}

public func <= <A: LayoutDimension>(lhs: LayoutDimensionProperty<A>, rhs: CGFloat) {
    lhs.lessThanOrEqual(to: rhs)
}

// MARK: - LayoutDimensionProperty -> LayoutDimension, Constant

public func == <A: LayoutDimension>(lhs: LayoutDimensionProperty<A>, rhs: (A, CGFloat)) {
    lhs.equal(to: rhs.0, constant: rhs.1)
}

public func >= <A: LayoutDimension>(lhs: LayoutDimensionProperty<A>, rhs: (A, CGFloat)) {
    lhs.greaterThanOrEqual(to: rhs.0, constant: rhs.1)
}

public func <= <A: LayoutDimension>(lhs: LayoutDimensionProperty<A>, rhs: (A, CGFloat)) {
    lhs.lessThanOrEqual(to: rhs.0, constant: rhs.1)
}

// MARK: - LayoutDimensionProperty -> LayoutDimensionProperty, Constant

public func == <A: LayoutDimension>(lhs: LayoutDimensionProperty<A>, rhs: (LayoutDimensionProperty<A>, CGFloat)) {
    lhs.equal(to: rhs.0, constant: rhs.1)
}

public func >= <A: LayoutDimension>(lhs: LayoutDimensionProperty<A>, rhs: (LayoutDimensionProperty<A>, CGFloat)) {
    lhs.greaterThanOrEqual(to: rhs.0, constant: rhs.1)
}

public func <= <A: LayoutDimension>(lhs: LayoutDimensionProperty<A>, rhs: (LayoutDimensionProperty<A>, CGFloat)) {
    lhs.lessThanOrEqual(to: rhs.0, constant: rhs.1)
}

// MARK: - NSLayoutConstraint Extensions

public extension NSLayoutConstraint {
    func activate() {
        isActive = true
    }

    func deactivate() {
        isActive = false
    }
}

public extension Array where Element: NSLayoutConstraint {
    func activateAll() {
        forEach { $0.activate() }
    }

    func deactivateAll() {
        forEach { $0.deactivate() }
    }
}
