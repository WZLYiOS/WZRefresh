//
//  ViewController.swift
//  WZRefresh
//
//  Created by ppqx on 03/17/2020.
//  Copyright (c) 2020 ppqx. All rights reserved.
//

import UIKit
import WZRefresh

class ViewController: UIViewController {

    /// 列表
    fileprivate lazy var tableView: UITableView = {
        $0.separatorStyle = .none
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = 80
        $0.tableFooterView = UIView()
        $0.dataSource = self
        $0.delegate = self
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        $0.wz.addBackgroundEmpty(view: self.xxxx)
        $0.wz.pullToRefresh(target: self, refreshingAction: #selector(pullToRefresh))
        
        return $0
    }(UITableView())
    
    fileprivate var dataArray: [String] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private lazy var xxxx: UIView = {
        $0.backgroundColor = UIColor.orange
        return $0
    }(UIView())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.wz.beginRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func pullToRefresh(){
        tableView.wz.endRefreshing()
        dataArray = ["",""]
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.backgroundColor = UIColor.red
        return cell
    }
}
 

