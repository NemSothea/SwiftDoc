//
//  TodoItemCell.swift
//  Week06ExTodoList
//
//  Created by sothea007 on 5/11/25.
//
import UIKit

class TodoCell: UITableViewCell {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var statusButtonTapped: (() -> Void)?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(statusButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Status button
            statusButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            statusButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statusButton.widthAnchor.constraint(equalToConstant: 24),
            statusButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: statusButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Date label
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupActions() {
        statusButton.addTarget(self, action: #selector(statusButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func statusButtonTapped(_ sender: UIButton) {
        statusButtonTapped?()
    }
    
    // MARK: - Configuration (FIXED)
    func configure(with todo: TodoItem) {
        // Store the todo title
        let todoTitle = todo.title
        
        // Format date
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: todo.createdAt)
        
        // Update appearance with the title
        updateAppearance(for: todo, title: todoTitle)
    }
    
    private func updateAppearance(for todo: TodoItem, title: String) {
        if todo.isCompleted {
            // COMPLETED: Green checkmark, strikethrough, gray text
            statusButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            statusButton.tintColor = .systemGreen
            
            // Apply strikethrough for completed items
            let attributedString = NSAttributedString(
                string: title,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.systemGray,
                    .font: UIFont.systemFont(ofSize: 16, weight: .medium)
                ]
            )
            titleLabel.attributedText = attributedString
            containerView.backgroundColor = .systemGreen.withAlphaComponent(0.1)
        } else {
            // ACTIVE: Gray circle, normal text, no strikethrough
            statusButton.setImage(UIImage(systemName: "circle"), for: .normal)
            statusButton.tintColor = .systemGray
            
            // Use regular text for active items (NO strikethrough)
            titleLabel.attributedText = nil // Clear any attributes
            titleLabel.text = title // Set the text
            titleLabel.textColor = .label // Ensure correct color
            containerView.backgroundColor = .secondarySystemBackground
        }
    }
}
