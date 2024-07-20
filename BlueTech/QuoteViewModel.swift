//
//  QuoteViewModel.swift
//  BlueTech
//
//  Created by Charlie on 2024/7/20.
//

import RxSwift
import RxCocoa

enum SortType {
    case time
    case price
    case volume
}

enum SortDirection {
    case ascending
    case descending
}


class QuoteViewModel {
    let items = BehaviorRelay<[QuoteItem]>(value: [])
    let sortedItems = BehaviorRelay<[QuoteItem]>(value: [])
    let sortType = BehaviorRelay<SortType>(value: .time)
    let sortDirection = BehaviorRelay<SortDirection>(value: .descending)

    let inputPrice = BehaviorRelay<Decimal?>(value: nil)
    let inputAmount = BehaviorRelay<Decimal?>(value: nil)
    
    let total = BehaviorRelay<Decimal?>(value: nil)
    
    private let disposeBag = DisposeBag()
    
    init() {
        setupBindings()
        startGeneratingQuotes()
    }
    
    func changeSortType(_ type: SortType) {
        if type == sortType.value {
            sortDirection.accept(sortDirection.value == .ascending ? .descending : .ascending)
        } else {
            sortType.accept(type)
            sortDirection.accept(.descending)
        }
    }

    
    private func setupBindings() {
        Observable.combineLatest(items, sortType, sortDirection)
            .map { items, sortType, direction in
                switch sortType {
                case .time:
                    if direction == .ascending {
                        return items.sorted { $0.date > $1.date }
                    }else{
                        return items.sorted { $0.date < $1.date }
                    }
                case .price:
                    if direction == .ascending {
                        return items.sorted { $0.price > $1.price }
                    }else{
                        return items.sorted { $0.price < $1.price }
                    }

                case .volume:
                    if direction == .ascending {
                        return items.sorted { $0.volume > $1.volume }
                    }else{
                        return items.sorted { $0.volume < $1.volume }
                    }
                }
            }
            .bind(to: sortedItems)
            .disposed(by: disposeBag)
                
        Observable.combineLatest(inputPrice, inputAmount)
            .map { inputPrice, inputAmount in
                guard let price = inputPrice, let amount = inputAmount else { return nil }
                return price * amount
            }
            .bind(to: total)
            .disposed(by: disposeBag)
    }
    
    private func startGeneratingQuotes() {
        Observable<Int>.interval(.seconds(2), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                let date = Date()
                let newQuote = QuoteItem(
                    time: DateFormatter.quoteTimeFormatter.string(from:date),
                    price: Decimal(string: String(format: "%.4f", Double.random(in: 0.0000...100000.0000)))!,
                    volume: Decimal(string: String(format: "%.4f", Double.random(in: 0.0000...100000.0000)))!,
                    date: date
                )
                self?.items.accept((self?.items.value)! + [newQuote])
            })
            .disposed(by: disposeBag)
    }
}


