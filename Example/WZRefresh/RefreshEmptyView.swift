//
//  RefreshEmptyView.swift
//  Created by CocoaPods on 2024/3/7
//  Description <#文件描述#>
//  PD <#产品文档地址#>
//  Design <#设计文档地址#>
//  Copyright © 2024. All rights reserved.
//  @author qiuqixiang(739140860@qq.com)   
//

import UIKit
import WZRefresh

class RefreshEmptyView: UIView, WZEmptyViewProtocol {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
        configViewLocation()
        backgroundColor = UIColor.yellow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// 添加视图
    private func configView() {
        
    }
    
    /// 视图位置
    private func configViewLocation() {
        
    }
    
    func uploadState(_ error: EmptyViewResultType) {
        debugPrint("23131")
    }
    
    func originView() -> UIView {
        return self
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
