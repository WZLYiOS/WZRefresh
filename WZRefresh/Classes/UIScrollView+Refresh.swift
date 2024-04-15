//
//  UIScrollView+.swift
//  WZLY
//
//  Created by qiuqixiang on 2019/10/23.
//  Copyright © 2019 我主良缘. All rights reserved.
//

import UIKit
import MJRefresh
import Foundation

/// MARK: - 底部刷新状态
public enum WZBottomRefreshState: Int {
    case normal
    case noMoreData
    case hidden
}

/// MARK: - 顶部刷新状态
public enum WZHeadRefreshState: Int {
    case normal
    case hidden
}

/// MARK - 刷新协议
public protocol WZRefresh {
    
    /// 刷新视图
    var refreshView: MJRefreshComponent { get }
    
    /// 刷新block
    /// - Parameter handler: handler description
    func refreshingBlock(handler: @escaping () -> Void)
    
    /// 刷新
    /// - Parameter target: 目标
    /// - Parameter action: 事件
    func refreshingTarget(_ target: Any, refreshingAction action: Selector)
}

/// MARK - 默认实现
public extension WZRefresh {
    
    /// 刷新block
    /// - Parameter handler: handler description
    func refreshingBlock(handler: @escaping () -> Void) {
        self.refreshView.refreshingBlock = {
            handler()
        }
    }
    
    /// 刷新
    /// - Parameter target: 目标
    /// - Parameter action: 事件
    func refreshingTarget(_ target: Any, refreshingAction action: Selector) {
        self.refreshView.setRefreshingTarget(target, refreshingAction: action)
    }
}


/// MARK - 默认头部刷新
public class WZDefaultRefreshHeader: WZRefresh {

    public lazy var refreshView: MJRefreshComponent = {
        let temElement = MJRefreshNormalHeader()
        temElement.isCollectionViewAnimationBug = true
        temElement.isAutomaticallyChangeAlpha = true
        return temElement
    }()
}

/// MARK - 触发模式自动刷新模式
public enum TriggerMode: CustomStringConvertible {
    case percent(CGFloat) //百分比(0-1之间)
    case offset(CGFloat) //偏移量
    case footPercent(CGFloat) // 底部刷新控件出现比例(0-1)
    
    public var description: String {
        switch self {
        case .percent(let value):
            return "百分比\(value)"
        case .offset(let value):
            return "距离底部偏移量\(value)"
        case .footPercent(let value):
            return "底部控件出现比例\(value)"
        }
    }
}

/// MARK - 默认底部自动刷新
public class WZDefaultRefreshAutoFooter: MJRefreshAutoNormalFooter {
    
//    /// 触发模式(默认全部显示才展示)
//    public var triggerMode: TriggerMode = .percent(0) {
//        didSet {
//            if case let .footPercent(value) = triggerMode {
//                triggerAutomaticallyRefreshPercent = value
//            }
//        }
//    }
//
//    /// 当scrollView的contentOffset发生改变的时候调用
//    /// - Parameter change: change
//    public override func scrollViewContentOffsetDidChange(_ change: [AnyHashable : Any]?) {
//        super.scrollViewContentOffsetDidChange(change)
//        guard let temScrollView = scrollView else { return }
//        guard !self.isHidden else { return } //隐藏了
//        if state != .idle || isAutomaticallyRefresh == false || frame.origin.y == 0 { return } // 非空闲状态不触发
//        guard temScrollView.frame.size.height != 0,
//              temScrollView.contentSize.height != 0 else { return } //高度都等于0
//        guard temScrollView.frame.size.height < temScrollView.contentSize.height else { return }//内容高度小于视图高度
//
//        let current = temScrollView.contentOffset.y <= 0 ? 0 : temScrollView.contentOffset.y
//        let total = temScrollView.contentSize.height // 总的可滑动距离
//
//        /// 防止手松开时连续调用
//        guard let old = change?["old"] as? CGPoint, let new = change?["new"] as? CGPoint, new.y > old.y, new.y > 0 else {
//            return
//        }
//
//        /// 预加载的计算逻辑
//        switch self.triggerMode {
//        case let .percent(value):
//
//            let ratio = current / (total - temScrollView.frame.size.height + frame.height)
//            if ratio >= value { // 滑动距离超过比例值
//                // 当底部刷新控件完全出现时，才刷新
//                self.beginRefreshing()
//            }
//        case let .offset(value):
//
//            /// 距离底部的偏移量
//            if current + temScrollView.frame.size.height - frame.height > total - value {
//                self.beginRefreshing()
//            }
//        case .footPercent(_):
//            break
//        }
//    }
}

/// MARK - 默认底部刷新自动回弹
public class WZDefaultBackRefreshAutoFooter: MJRefreshBackNormalFooter {
    
}

// MARK: - UIScrollView + 刷新的扩展
public extension WZRefreshNamespaceWrappable where Base: UIScrollView {
    
    /// 开始刷新
    func beginRefreshing() {
        base.mj_header?.beginRefreshing()
    }
    
    /// 移除顶部刷新控件
    func removeHeadRefreshing() {
        base.mj_header = nil
    }
    
    /// 停止刷新
    func endRefreshing(_ error: Error? = nil) {
        
        /// 头部停止刷新
        if let header = base.mj_header, header.isRefreshing == true {
            headerEndRefreshing(error)
        }
    
        if let foot = base.mj_footer, foot.isRefreshing == true {
            footEndRefreshing(Int.max)
        }
    }
    
    
    /// 刷新顶部视图状态
    /// - Parameter state: 顶部视图状态
   func headRefreshState(state: WZHeadRefreshState) {
       switch state {
        case .hidden:
           base.mj_header?.isHidden = true
        case .normal:
           base.mj_header?.isHidden = false
        }
    }
    
    /// 底部刷新状态
    /// - Parameter state: 状态
    func bottomRefreshState(state: WZBottomRefreshState) {
        switch state {
        case .hidden:
            base.mj_footer?.isHidden = true
        case .noMoreData:
            base.mj_footer?.isHidden = false
            base.mj_footer?.endRefreshingWithNoMoreData()
        case .normal:
            base.mj_footer?.isHidden = false
            base.mj_footer?.resetNoMoreData()
        }
    }
    
    /// 重置底部状态
    func resetNoMoreData() {
        if base.mj_footer?.state == .noMoreData {
            base.mj_footer?.resetNoMoreData()
        }
    }
    
    /// 底部停止刷新
    func footEndRefreshing(_ count: Int = Int.max) {
        if count == 0 {
            return bottomRefreshState(state: .noMoreData)
        }
        base.mj_footer?.endRefreshing()
    }
    
    /// 头部刷新结束
    func headerEndRefreshing(_ error: Error? = nil) {
        /// 头部停止刷新
        base.mj_header?.endRefreshing()
        if let err = error {
            base.emptyView?.uploadState(.error(err))
        }else {
            base.emptyView?.uploadState(.noData)
        }
        
        if let empty = base.emptyView?.originView(), empty.superview == nil {
            let superView = base.superview
            superView?.addSubview(empty)
            empty.frame = base.bounds
            empty.center = base.center
        }

        /// 重置底部
        resetNoMoreData()
    }
    
    /// 下拉刷新
    /// - Parameter header: 头部刷新
    /// - Parameter handler: handler description
    func pullToRefresh(target: Any, refreshingAction action: Selector) {
        
        let header = WZDefaultRefreshHeader()
        header.refreshingTarget(target, refreshingAction: action)
        base.mj_header = (header.refreshView as! MJRefreshHeader)
    }
    
    /// 下拉刷新
    /// - Parameter handler: handler description
    func pullToRefresh(handler: @escaping () -> Void) {
        
        let header = WZDefaultRefreshHeader()
        base.mj_header = (header.refreshView as! MJRefreshHeader)
        header.refreshingBlock(handler: handler)
    }
    

    /// 加载更多
    /// - Parameter target: target description
    /// - Parameter action: action description
    func loadMoreFooter(target: Any, percent: CGFloat = -3, refreshingAction action: Selector) {
            
        let refreshFooter = WZDefaultRefreshAutoFooter(refreshingTarget: target, refreshingAction: action)
        refreshFooter.triggerAutomaticallyRefreshPercent = percent
        base.mj_footer = refreshFooter
    }
    
    /// 加载更多
    /// - Parameter handler: handler description
    func loadMoreFooter(handler: @escaping () -> Void, percent: CGFloat = -3) {

        let refreshFooter = WZDefaultRefreshAutoFooter(refreshingBlock: handler)
        refreshFooter.triggerAutomaticallyRefreshPercent = percent
        base.mj_footer = refreshFooter
    }
    
    /// 加载更多
    /// - Parameter target: target description
    /// - Parameter action: action description
    func loadMoreBackFooter(target: Any, isAutomaticallyChangeAlpha: Bool = true,refreshingAction action: Selector) {
        let refreshFooter = WZDefaultBackRefreshAutoFooter(refreshingTarget: target, refreshingAction: action)
        refreshFooter.isAutomaticallyChangeAlpha = isAutomaticallyChangeAlpha
        base.mj_footer = refreshFooter
    }
    
    /// 添加背景空视图
    /// - Parameter view: 空视图
    func addBackgroundEmpty(view: WZEmptyViewProtocol) {
        base.emptyView = view
        base.wzObservation = base.observe(\.contentSize, options: .new) { [self] scrollView, change in
            self.refreshFootState()
            
            if let tab = scrollView as? UITableView {
                tab.backgroundView = self.base.mj_totalDataCount() == 0 ? scrollView.emptyView?.originView() : nil
                return
            }
            
            if let coll = scrollView as? UICollectionView {
                coll.backgroundView = self.base.mj_totalDataCount() == 0 ? scrollView.emptyView?.originView() : nil
                return
            }
        }
        base.contentOffsetObservation = base.observe(\.contentOffset, options: .new) { [self] scrollView, change in
            if var feam = base.emptyView?.originView().frame, scrollView.contentOffset.y <= 0 {
                feam.origin.y = scrollView.contentOffset.y
                base.emptyView?.originView().frame = feam
            }
        }
    }
    
    /// footView 添加占位图
    /// - Parameter view: 空视图
    func addFootEmpty(view: WZEmptyViewProtocol){
        base.emptyView = view
        base.mj_header?.endRefreshingCompletionBlock = {
            if let tab = self.base as? UITableView {
                tab.tableFooterView = self.base.mj_totalDataCount() == 0 ? self.base.emptyView?.originView() : nil
            }
        }
        base.wzObservation = base.observe(\.contentSize, options: .new) { scrollView, change in
            self.refreshFootState()
        }
    }
    
    /// 更新底部状态
    func refreshFootState() {
        
        if let foot = base.mj_footer, foot.state == .idle {
            if  base.contentSize.height < base.bounds.height {
                if base.mj_footer?.isHidden == false {
                    bottomRefreshState(state: .hidden)
                }
            }else {
                if base.mj_footer?.isHidden == true && base.mj_header?.state == .idle {
                    bottomRefreshState(state: .normal)
                }
            }
        }
    }
}



// MAKR - 添加占位视图等刷新机制
public extension UIScrollView {
    
    private struct AssociatedKeys {
        static var emptyViewKey = 10
        static var observationKey = 11
        static var contentOffsetKey = 12
    }
    
    /// 空视图占位
    var emptyView: WZEmptyViewProtocol? {
         get {
             return (objc_getAssociatedObject(self, &AssociatedKeys.emptyViewKey) as? WZEmptyViewProtocol)
         }
         set(newValue) {
             objc_setAssociatedObject(self, &AssociatedKeys.emptyViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
         }
     }
     
     /// 监听属性
    var wzObservation: NSKeyValueObservation? {
         get {
             return (objc_getAssociatedObject(self, &AssociatedKeys.observationKey) as? NSKeyValueObservation)
         }
         set(newValue) {
             objc_setAssociatedObject(self, &AssociatedKeys.observationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
         }
     }
    
    /// 监听属性
   var contentOffsetObservation: NSKeyValueObservation? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.contentOffsetKey) as? NSKeyValueObservation)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.contentOffsetKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

// MARL - 结果回调
public enum EmptyViewResultType {
    case error(Error)
    case noData
}

// MARK - 空视图协议
public protocol WZEmptyViewProtocol {
    
    /// 更新状态
    func uploadState(_ result: EmptyViewResultType)
    
    /// 视图
    func originView() -> UIView
}
