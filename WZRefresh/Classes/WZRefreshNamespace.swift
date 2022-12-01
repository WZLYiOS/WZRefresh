//
//  WZRefreshNamespace.swift
//  WZRefresh
//
//  Created by qiuqixiang on 2021/10/26.
//

import Foundation
import Foundation

/// MARK - 定义个命名空间
/*
 在对 TypeWrapperProtocol 这个协议做 extension 时， where 后面的 WrappedType 约束可以使用 == 或者 :，两者是有区别的。如果扩展的是值类型，比如 String，Date 等，就必须使用 ==，如果扩展的是类，则两者都可以使用，区别是如果使用 == 来约束，则扩展方法只对本类生效，子类无法使用。如果想要在子类也使用扩展方法，则使用 : 来约束。
 还有一些注意的地方
 对类型扩展实现 NamespaceWrappable 协议，只需要写一次。如果对 UIView 已经写了 NamespaceWrappable 协议实现，则 UILabel 不需要再写。实际上写了之后，编译会报错。
 如果在实现的 func 前加上 static 关键字，可以扩展出静态方法。
 */
public struct WZRefreshNamespaceWrappable<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}
public protocol WZRefreshNamespaceCompatible: AnyObject { }
public protocol WZRefreshNamespaceCompatibleValue {}

extension WZRefreshNamespaceCompatible {
    public var wz: WZRefreshNamespaceWrappable<Self> {
        get { return WZRefreshNamespaceWrappable(self) }
        set { }
    }
    
    public static var wz: WZRefreshNamespaceWrappable<Self>.Type {
        return WZRefreshNamespaceWrappable<Self>.self
    }
}

/// 值类型
extension WZRefreshNamespaceCompatibleValue {
    public var wz: WZRefreshNamespaceWrappable<Self> {
        get { return WZRefreshNamespaceWrappable(self) }
        set { }
    }
    
    public static var wz: WZRefreshNamespaceWrappable<Self>.Type {
            return WZRefreshNamespaceWrappable<Self>.self
    }
}

extension NSObject: WZRefreshNamespaceCompatible { }

