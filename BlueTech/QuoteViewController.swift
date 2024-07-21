//
//  ViewController.swift
//  BlueTech
//
//  Created by Charlie on 2024/7/20.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class QuoteViewController: UIViewController, UITextFieldDelegate {
    private let viewModel = QuoteViewModel()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(QuoteCell.self, forCellReuseIdentifier: "QuoteCell")
        return tv
    }()
    
    private lazy var  priceTextField: UITextField = {
        let tf = UITextField()
        let lb = UILabel()
        lb.text = "Price: "
        tf.leftView = lb
        tf.leftViewMode = .always
        tf.keyboardType = .decimalPad
        tf.delegate = self
        return tf
    }()
    
    private lazy var amountTextField: UITextField = {
        let tf = UITextField()
        let lb = UILabel()
        lb.text = "Amount: "
        tf.leftView = lb
        tf.leftViewMode = .always
        tf.keyboardType = .decimalPad
        tf.delegate = self
        return tf
    }()
    
    private let totalTextField: UITextField = {
        let tf = UITextField()
        let lb = UILabel()
        lb.text = "Total: "
        tf.leftView = lb
        tf.leftViewMode = .always
        tf.keyboardType = .decimalPad
        tf.isUserInteractionEnabled = false
        return tf
    }()
    
    private let orderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Order", for: .normal)
        button.backgroundColor = .cyan
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 22
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private let disposeBag = DisposeBag()

    
    private let timeSortButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Time ▼", for: .normal)
        return button
    }()

    private let priceSortButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Price", for: .normal)
        return button
    }()

    private let volumeSortButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Volume", for: .normal)
        return button
    }()

    
    private lazy var sortButtonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [timeSortButton, priceSortButton, volumeSortButton])
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        
        view.backgroundColor = .white
        
        [tableView, sortButtonsStack, priceTextField, amountTextField, totalTextField, orderButton].forEach { view.addSubview($0) }
        
        sortButtonsStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(sortButtonsStack.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
        
        priceTextField.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
        
        amountTextField.snp.makeConstraints { make in
            make.top.equalTo(priceTextField.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
        
        totalTextField.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
        
        orderButton.snp.makeConstraints { make in
            make.top.equalTo(totalTextField.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
        }

    }
    
    private func setupBindings() {
        
        timeSortButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.updateSortButton(self?.timeSortButton, type: .time)
            })
            .disposed(by: disposeBag)

        priceSortButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.updateSortButton(self?.priceSortButton, type: .price)
            })
            .disposed(by: disposeBag)

        volumeSortButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.updateSortButton(self?.volumeSortButton, type: .volume)
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(viewModel.sortType, viewModel.sortDirection)
            .subscribe(onNext: { [weak self] sortType, direction in
                self?.updateButtonTitles(sortType, direction)
            })
            .disposed(by: disposeBag)


        viewModel.sortedItems
            .bind(to: tableView.rx.items(cellIdentifier: "QuoteCell", cellType: QuoteCell.self)) { _, item, cell in
                cell.configure(with: item)
                
                cell.onPriceTapped = { [weak self] in
                    self?.viewModel.inputPrice.accept(item.price)
                }
                
                cell.onVolumeTapped = { [weak self] in
                    self?.viewModel.inputAmount.accept(item.volume)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.total
            .map{ $0 != nil ?  $0?.formattedString : "" }
            .bind(to: totalTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.inputPrice
            .compactMap { $0?.formattedString }
            .bind(to: priceTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.inputAmount
            .compactMap { $0?.formattedString }
            .bind(to: amountTextField.rx.text)
            .disposed(by: disposeBag)
        

        priceTextField.rx.controlEvent([.editingDidEnd])
            .subscribe(onNext: { [weak self] in
                if let price = self?.priceTextField.text, !price.isEmpty {
                    let value = Decimal(string:price)
                    self?.viewModel.inputPrice.accept(value)
                }else{
                    self?.viewModel.inputPrice.accept(nil)
                }
            })
            .disposed(by: disposeBag)
        
        
        amountTextField.rx.controlEvent([.editingDidEnd])
            .subscribe(onNext: { [weak self] in
                if let amount = self?.amountTextField.text, !amount.isEmpty {
                    let value = Decimal(string:amount)
                    self?.viewModel.inputAmount.accept(value)
                }else{
                    self?.viewModel.inputAmount.accept(nil)
                }
            })
            .disposed(by: disposeBag)
        
        orderButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showOrderConfirmation()
            })
            .disposed(by: disposeBag)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let range = Range(range, in:text) {
            var updateString = text.replacingCharacters(in: range, with: string)
            
            //法國鍵盤 => "." = ","
            updateString = updateString.replacingOccurrences(of: ",", with: ".")
            let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
            let characterSet = CharacterSet(charactersIn: updateString)
            if !allowedCharacters.isSuperset(of: characterSet) {
                return false
            }
            let decimalCount = updateString.components(separatedBy: ".").count-1
            if decimalCount > 1 {
                return false
            }
            
            return true
        }
        return false
    }
    
    
    private func showOrderConfirmation() {
        
        guard let priceValue = viewModel.inputPrice.value,
              let totalValue = viewModel.total.value,
              let amountValue = viewModel.inputAmount.value
        else { return }
        
        let price = priceValue.formattedString
        let total = totalValue.formattedString
        let amount = amountValue.formattedString
        
        let alertVC = UIAlertController(title: nil, message: 
            """
            Total:\(String(describing: total))
            Price:\(String(describing: price))
            Amount:\(String(describing: amount))
            """, preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
            self.clearInputs()
        }))
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertVC, animated: true)
    }
    
    private func clearInputs() {
        priceTextField.text = nil
        amountTextField.text = nil
        viewModel.inputPrice.accept(nil)
        viewModel.inputAmount.accept(nil)
    }
    
    private func updateSortButton(_ button: UIButton?,  type: SortType) {
        viewModel.changeSortType(type)
    }

    private func updateButtonTitles(_ currentSortType: SortType, _ direction: SortDirection) {
        let upArrow = " ▲"
        let downArrow = " ▼"
        
        timeSortButton.setTitle("Time" + (currentSortType == .time ? (direction == .ascending ? upArrow : downArrow) : ""), for: .normal)
        priceSortButton.setTitle("Price" + (currentSortType == .price ? (direction == .ascending ? upArrow : downArrow) : ""), for: .normal)
        volumeSortButton.setTitle("Volume" + (currentSortType == .volume ? (direction == .ascending ? upArrow : downArrow) : ""), for: .normal)
    }
}
