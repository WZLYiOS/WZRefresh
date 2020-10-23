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
import WZNamespaceWrappable

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


/// MARK - 默认底部自动刷新
public class WZDefaultRefreshAutoFooter: WZRefresh {
    
    public lazy var refreshView: MJRefreshComponent = {
        let temElement = MJRefreshAutoStateFooter()
        temElement.setTitle("没有更多数据", for: MJRefreshState.noMoreData)
        temElement.triggerAutomaticallyRefreshPercent = -UIScreen.main.bounds.height/2.0/44.0
        return temElement
    }()
}

// MARK: - UIScrollView + 刷新的扩展
public extension WZTypeWrapperProtocol where WrappedType: UIScrollView {
    
    /// 开始刷新
    func beginRefreshing() {
        wrappedValue.mj_header?.beginRefreshing()
    }
    
    /// 停止刷新
    func endRefreshing() {
        
        /// 头部停止刷新
        if let header = wrappedValue.mj_header, header.isRefreshing == true {
            header.endRefreshing()
        }
    
        if let foot = wrappedValue.mj_footer, foot.isRefreshing == true {
            foot.endRefreshing()
        }
    }
     
    /// 移除顶部刷新控件
    func removeHeadRefreshing() {
        wrappedValue.mj_header = nil
    }
    
    /// 刷新顶部视图状态
    /// - Parameter state: 顶部视图状态
   func headRefreshState(state: WZHeadRefreshState) {
       switch state {
        case .hidden:
            wrappedValue.mj_header?.isHidden = true
        case .normal:
            wrappedValue.mj_header?.isHidden = false
        }
    }
    
    /// 底部刷新状态
    /// - Parameter state: 状态
    func bottomRefreshState(state: WZBottomRefreshState) {
        switch state {
        case .hidden:
            wrappedValue.mj_footer?.isHidden = true
        case .noMoreData:
            wrappedValue.mj_footer?.isHidden = false
            wrappedValue.mj_footer?.endRefreshingWithNoMoreData()
        case .normal:
            wrappedValue.mj_footer?.isHidden = false
            wrappedValue.mj_footer?.resetNoMoreData()
        }
    }
    
    
    /// 下拉刷新
    /// - Parameter header: 头部刷新
    /// - Parameter handler: handler description
    func pullToRefresh(target: Any, refreshingAction action: Selector) {
        
        let header = WZDefaultRefreshHeader()
        header.refreshingTarget(target, refreshingAction: action)
        wrappedValue.mj_header = (header.refreshView as! MJRefreshHeader)
    }
    
    /// 下拉刷新
    /// - Parameter handler: handler description
    func pullToRefresh(handler: @escaping () -> Void) {
        
        let header = WZDefaultRefreshHeader()
        wrappedValue.mj_header = (header.refreshView as! MJRefreshHeader)
        header.refreshingBlock(handler: handler)
    }
    

    /// 加载更多
    /// - Parameter target: target description
    /// - Parameter action: action description
    func loadMoreFooter(target: Any, refreshingAction action: Selector) {
        
        let footer = WZDefaultRefreshAutoFooter()
        footer.refreshingTarget(target, refreshingAction: action)
        wrappedValue.mj_footer = (footer.refreshView as! MJRefreshFooter)
    }
    
    /// 加载更多
    /// - Parameter handler: handler description
    func loadMoreFooter(handler: @escaping () -> Void) {
        
        let footer = WZDefaultRefreshAutoFooter()
        wrappedValue.mj_footer = (footer.refreshView as! MJRefreshFooter)
        footer.refreshingBlock(handler: handler)
    }
    
    /// 添加背景空视图
    /// - Parameter view: 空视图
    func addBackgroundEmpty(view: UIView) {
        wrappedValue.wzEmptyView = view
        wrappedValue.wzObservation = wrappedValue.observe(\.contentSize, options: .new) { [self] scrollView, change in
            self.refreshFootState()
            if let tab = scrollView as? UITableView {
                tab.backgroundView = self.wrappedValue.mj_totalDataCount() == 0 ? scrollView.wzEmptyView : nil
                return
            }
            
            if let coll = scrollView as? UICollectionView {
                coll.backgroundView = self.wrappedValue.mj_totalDataCount() == 0 ? scrollView.wzEmptyView : nil
                return
            }
        }
    }
    
    /// footView 添加占位图
    /// - Parameter view: 空视图
    func addFootEmpty(view: UIView){
        wrappedValue.wzEmptyView = view
        wrappedValue.mj_header?.endRefreshingCompletionBlock = {
            if let tab = self.wrappedValue as? UITableView {
                tab.tableFooterView = self.wrappedValue.mj_totalDataCount() == 0 ? self.wrappedValue.wzEmptyView : nil
            }
        }
        wrappedValue.wzObservation = wrappedValue.observe(\.contentSize, options: .new) { scrollView, change in
            self.refreshFootState()
        }
    }
    
    /// 下拉刷新 针对tableview 和 collectionview  背景view自动添加空视图 将要废弃
    /// - Parameter header: 头部刷新
    /// - Parameter handler: handler description
    func refreshHeaderBackgroundView(target: Any, refreshingAction action: Selector) {
        
        let header = WZDefaultRefreshHeader()
        header.refreshingTarget(target, refreshingAction: action)
        wrappedValue.mj_header = (header.refreshView as! MJRefreshHeader)
      
        wrappedValue.wzObservation = wrappedValue.observe(\.contentSize, options: .new) { [self] scrollView, change in

            self.refreshFootState()
            
            if let tab = scrollView as? UITableView {
                tab.backgroundView = self.wrappedValue.mj_totalDataCount() == 0 ? scrollView.wzEmptyView : nil
                return
            }
            
            if let coll = scrollView as? UICollectionView {
                coll.backgroundView = self.wrappedValue.mj_totalDataCount() == 0 ? scrollView.wzEmptyView : nil
                return
            }
        }
    }
    
    /// 下拉刷新 针对tableview 和 collectionview  FootView自动添加空视图
    /// - Parameter header: 头部刷新
    /// - Parameter handler: handler description
     func refreshHeaderTableFooterView(target: Any, refreshingAction action: Selector) {
    
        let header = WZDefaultRefreshHeader()
        header.refreshingTarget(target, refreshingAction: action)
        wrappedValue.mj_header = (header.refreshView as! MJRefreshHeader)
        wrappedValue.mj_header?.endRefreshingCompletionBlock = {
            if let tab = self.wrappedValue as? UITableView {
                tab.tableFooterView = self.wrappedValue.mj_totalDataCount() == 0 ? self.wrappedValue.wzEmptyView : nil
            }
        }
        wrappedValue.wzObservation = wrappedValue.observe(\.contentSize, options: .new) { scrollView, change in
            self.refreshFootState()
        }
    }
    
    /// 更新底部状态
    func refreshFootState() {
        
        if let foot = wrappedValue.mj_footer, foot.state == .idle {
            if  wrappedValue.contentSize.height < wrappedValue.bounds.height {
                if wrappedValue.mj_footer?.isHidden == false {
                    bottomRefreshState(state: .hidden)
                }
            }else {
                if wrappedValue.mj_footer?.isHidden == true && wrappedValue.mj_header?.state == .idle {
                    bottomRefreshState(state: .normal)
                }
            }
        }
    }
}

private struct AssociatedKeys {
    static var emptyViewKey: String = "com.wzly.refresh.emptyView"
    static var observationKey: String = "com.wzly.refresh.observation"
}

// MAKR - 添加占位视图等刷新机制
public extension UIScrollView {
    
    /// 空视图占位
    var wzEmptyView: UIView? {
         get {
             return (objc_getAssociatedObject(self, &AssociatedKeys.emptyViewKey) as? UIView)
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
}
