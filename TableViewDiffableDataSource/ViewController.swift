//
//  ViewController.swift
//  TableViewDiffableDataSource
//
//  Created by master on 2019/12/30.
//  Copyright © 2019 ksb. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    enum Section: String, CaseIterable {
        case friends
        case family
        case coworkers
    }

    struct Contact: Hashable {
        var name: String
        var email: String
    }

    struct ContactList {
        var friends: [Contact]
        var family: [Contact]
        var coworkers: [Contact]
    }

    //private let tableView = UITableView()
    @IBOutlet weak var tableView: UITableView!
    
    private let cellReuseIdentifier = "cell"
    private lazy var dataSource = makeDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // 기본
//        tableView.register(UITableViewCell.self,
//                           forCellReuseIdentifier: cellReuseIdentifier
//        )
        
        // Custom Cell Class, xib 만들어서 register
        tableView.register(Custom_Cell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        loadData()
    }

    
    /// cell Provider 클로저로 dequeueReusableCell 구성 가능
    func makeDataSource() -> UITableViewDiffableDataSource<Section, Contact> {
        let reuseIdentifier = cellReuseIdentifier
        
        return UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: {  tableView, indexPath, contact in

                // tableView(_:cellForRowAtIndexPath:) 대신 아래 클로저 사용
                var cell = tableView.dequeueReusableCell(
                    withIdentifier: reuseIdentifier,
                    for: indexPath
                )
                
                // cell의 DetailTextLabel까지 보이기 위해 stlye 바꿔줌
                cell = UITableViewCell.init(style: .value1, reuseIdentifier: reuseIdentifier)
                
                //cell 구성 내용
                cell.textLabel?.text = contact.name
                cell.detailTextLabel?.text = contact.email
                return cell
            }
        )
    }
    
    func update(with list: ContactList, animate: Bool = true) {
        // NSDiffableDataSourceSnapshot : 데이터의 현재 상태를 표현함. tableview reloading 데이터 관리
        var snapshot = NSDiffableDataSourceSnapshot<Section, Contact>()
        // 각 섹션을 추가
        snapshot.appendSections(Section.allCases)
//         allCases로 섹션을 추가하지 않고 각각 섹션으로 추가할 경우, 모든 섹션이 추가되지 않으면 에러
//         Section의 순서가 의미가 있다면 아래와같이 각각 추가. 위에서부터 추가됨
//        snapshot.appendSections([.family])
//        snapshot.appendSections([.coworkers])
//        snapshot.appendSections([.friends])

        // 섹션에 데이터 추가
        snapshot.appendItems(list.friends, toSection: .friends)
        snapshot.appendItems(list.family, toSection: .family)
        snapshot.appendItems(list.coworkers, toSection: .coworkers)
        
        // datasource에 snapshot 붙임
        dataSource.apply(snapshot, animatingDifferences: animate)
        
    }

    func loadData() {
        let friends = [
            Contact(name: "Bob", email: "Bob@gmail.com"),
            Contact(name: "Tom", email: "Tom@myspace.com")
        ]

        let family = [
            Contact(name: "Mom", email: "mom@aol.com"),
            Contact(name: "Dad", email: "dad@aol.com")
        ]

        let coworkers = [
            Contact(name: "Mason", email: "tim@something.com"),
            Contact(name: "Tim", email: "mason@something.com")
        ]

        let contactList = ContactList(friends: friends, family: family, coworkers: coworkers)
        update(with: contactList, animate: true)
    }
}

extension ViewController : UITableViewDelegate {
    /// Cell 클릭했을 때
    /// - Parameters:
    ///   - tableView:
    ///   - indexPath:
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        let alert = UIAlertController(title: item.name, message: item.email, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        let deleteAction = UIAlertAction(title: "지우기", style: .destructive) { (action) in
            /*
             이미 붙인 snapshot이 있는 상태에서, 아이템이나 섹션을 추가하거나 삭제할 때에는
             datasource의 현재 snapshot을 가져와서 처리를 한다음, 다시 datasource에 apply 해주어야 한다.
             */
            var currentSnapshot = self.dataSource.snapshot()
            currentSnapshot.deleteItems([Contact.init(name: item.name, email: item.email)])
            self.dataSource.apply(currentSnapshot)
        }
        
        alert.addAction(confirmAction)
        alert.addAction(deleteAction)
        
        self.present(alert, animated: false)
    }
    
    
    /// Section 구분
    /// - Parameters:
    ///   - tableView:
    ///   - section:
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionLabel = UILabel()
        sectionLabel.text = dataSource.snapshot().sectionIdentifiers[section].rawValue.capitalized
        sectionLabel.textColor = UIColor.blue
        sectionLabel.font = UIFont.boldSystemFont(ofSize: 25)
        sectionLabel.textAlignment = .right
        
        return sectionLabel
    }
}


