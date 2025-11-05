//
//  TodoCell.swift
//  Week05ExTodoList
//
//  Created by sothea007 on 5/11/25.
//


import UIKit

class TodoCell: UITableViewCell {
    
    // MARK: - UI Components
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let completedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle")
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Add subviews
        contentView.addSubview(completedImageView)
        contentView.addSubview(titleLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Checkmark icon
            completedImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            completedImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            completedImageView.widthAnchor.constraint(equalToConstant: 24),
            completedImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Title label
            titleLabel.leadingAnchor.constraint(equalTo: completedImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(with todo: TodoItem) {
        titleLabel.text = todo.title
        
        if todo.isCompleted {
            completedImageView.image = UIImage(systemName: "checkmark.circle.fill")
            completedImageView.tintColor = .systemGreen
            titleLabel.textColor = .systemGray
            titleLabel.attributedText = todo.title.strikeThrough()
        } else {
            completedImageView.image = UIImage(systemName: "circle")
            completedImageView.tintColor = .systemGray
            titleLabel.textColor = .label
            titleLabel.attributedText = NSAttributedString(string: todo.title)
        }
    }
}

// Helper extension for strike-through text
extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(
            .strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSRange(location: 0, length: attributeString.length)
        )
        return attributeString
    }
}