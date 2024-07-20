//
//  QuoteCell.swift
//  BlueTech
//
//  Created by Charlie on 2024/7/20.
//

import Foundation
import UIKit

class QuoteCell: UITableViewCell {
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let volumeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        let priceTap = UITapGestureRecognizer(target: self, action: #selector(priceTapped))
        priceLabel.addGestureRecognizer(priceTap)
        priceLabel.isUserInteractionEnabled = true
        
        let volumeTap = UITapGestureRecognizer(target: self, action: #selector(volumeTapped))
        volumeLabel.addGestureRecognizer(volumeTap)
        volumeLabel.isUserInteractionEnabled = true 
        setupUI()
    }
    
    var onPriceTapped: (()->Void)?
    var onVolumeTapped: (()->Void)?
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [timeLabel, priceLabel, volumeLabel])
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.spacing = 8
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with item: QuoteItem) {
        timeLabel.text = item.time
        priceLabel.text = item.price.formattedString
        volumeLabel.text = item.volume.formattedString
    }
    
    
    @objc func priceTapped() {
        onPriceTapped?()
    }
    
    @objc func volumeTapped() {
        onVolumeTapped?()
    }
}
