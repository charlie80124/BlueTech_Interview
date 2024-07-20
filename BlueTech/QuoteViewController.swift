//
//  ViewController.swift
//  BlueTech
//
//  Created by Lan on 2024/7/20.
//

import UIKit
import RxSwift
import RxCocoa

class QuoteViewController: UIViewController {
    private let viewModel = QuoteViewModel()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(QuoteCell.self, forCellReuseIdentifier: "QuoteCell")
        return tv
    }()
    
    private let priceTextField: UITextField = {
        let tf = UITextField()
        let lb = UILabel()
        lb.text = "Price:"
        tf.leftView = lb
        tf.leftViewMode = .always
        return tf
    }()
    
    private let amountTextField: UITextField = {
        let tf = UITextField()
        let lb = UILabel()
        lb.text = "Amount:"
        tf.leftView = lb
        tf.leftViewMode = .always

        return tf
    }()
    
    private let totalTextField: UITextField = {
        let tf = UITextField()
        let lb = UILabel()
        lb.text = "Total:"
        tf.leftView = lb
        tf.leftViewMode = .always
        return tf
    }()
    
    private let orderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Order", for: .normal)
        return button
    }()
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        // 添加並佈局 UI 元素
    }
    
    private func setupBindings() {
        viewModel.sortedItems
            .bind(to: tableView.rx.items(cellIdentifier: "QuoteCell", cellType: QuoteCell.self)) { _, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(QuoteItem.self)
            .subscribe(onNext: { [weak self] item in
                self?.viewModel.selectedPrice.accept(item.price)
                self?.viewModel.selectedAmount.accept(item.volume)
            })
            .disposed(by: disposeBag)
        
        priceTextField.rx.text.orEmpty
            .compactMap { Decimal(string:$0) }
            .bind(to: viewModel.inputPrice)
            .disposed(by: disposeBag)
        
        amountTextField.rx.text.orEmpty
            .compactMap { Decimal(string:$0) }
            .bind(to: viewModel.inputAmount)
            .disposed(by: disposeBag)
        
        totalTextField.rx.text.orEmpty
            .compactMap { Decimal(string:$0) }
            .bind(to: viewModel.total)
            .disposed(by: disposeBag)

        
        orderButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showOrderConfirmation()
            })
            .disposed(by: disposeBag)
    }
    
    private func showOrderConfirmation() {
        // 實現訂單確認彈窗邏輯
    }
}
