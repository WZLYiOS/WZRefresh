//
//  ViewController.swift
//  WZRefresh
//
//  Created by ppqx on 03/17/2020.
//  Copyright (c) 2020 ppqx. All rights reserved.
//

import UIKit
import WZRefresh
import SnapKit
class ViewController: UIViewController {

    var wzObservation: NSKeyValueObservation?
    /// 列表
    fileprivate lazy var tableView: UITableView = {
        $0.separatorStyle = .none
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = 80
        $0.backgroundColor = UIColor.clear
        $0.tableFooterView = UIView()
        $0.dataSource = self
        $0.delegate = self
        $0.register(WZTableViewCell.self, forCellReuseIdentifier: "WZTableViewCell")
        $0.wz.pullToRefresh(target: self, refreshingAction: #selector(pullToRefresh))
        $0.wz.loadMoreFooter(target: self, refreshingAction: #selector(loadMoreReFresh))
        $0.wz.addBackgroundEmpty(view: RefreshEmptyView())
        return $0
    }(UITableView())
    
    fileprivate var dataArray: [Int] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    
    /// 背景
    private lazy var bgView: UIView = {
        $0.backgroundColor = UIColor(red: 1, green: 0.93, blue: 0.92, alpha: 1)
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
        $0.frame = CGRect(x: 8, y: 93, width: view.bounds.size.width-16, height: 0)
        return $0
    }(UIView())
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.white
        view.addSubview(bgView)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
//        wzObservation = tableView.observe(\.contentSize, options: .new) { [self] scrollView, change in
//            var xxx = self.bgView.frame
//            xxx.size.height = scrollView.contentSize.height
//            self.bgView.frame = xxx
//        }
        loadMoreReFresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func pullToRefresh(){
        tableView.wz.endRefreshing()
    }
    
    @objc func loadMoreReFresh() {
        debugPrint("当前位置：\(tableView.mj_offsetY) 内容高度：\(tableView.mj_contentH) 距离：\(tableView.mj_contentH-tableView.mj_offsetY)")
        let deadline = DispatchTime.now() + .seconds(3)
        DispatchQueue.global().asyncAfter(deadline: deadline) {
            DispatchQueue.main.async {
//                self.dataArray.append(contentsOf: [1,2,3,4,5,6,7,8,8,8,8,6])
                self.tableView.reloadData()
                self.tableView.wz.headerEndRefreshing()
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WZTableViewCell = tableView.dequeueReusableCell(withIdentifier: "WZTableViewCell", for: indexPath) as! WZTableViewCell
        cell.textLabel?.text = "\(dataArray[indexPath.row])"
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = UIColor.black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataArray.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .right)
    }
}
 

class WZTableViewCell: UITableViewCell {
    
    /// 背景
    private lazy var bgView: UIView = {
        $0.layer.cornerRadius = 18
        $0.layer.masksToBounds = true
        $0.backgroundColor = UIColor.orange
        return $0
    }(UIView())
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        configView()
        configViewLocation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 添加视图
    func configView() {
        contentView.addSubview(bgView)
    }
    
    /// 视图位置
    func configViewLocation() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(5)
            make.height.equalTo(120)
            make.bottom.lessThanOrEqualTo(-5).priority(.low)
        }
    }
}
