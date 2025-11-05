//
//  UserTableViewCell.swift
//  Week03ExviewDidLoad
//
//  Created by sothea007 on 3/11/25.
//
import UIKit

class UserTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let companyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset all labels
        nameLabel.text = nil
        usernameLabel.text = nil
        emailLabel.text = nil
        phoneLabel.text = nil
        addressLabel.text = nil
        companyLabel.text = nil
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(usernameLabel)
        containerView.addSubview(emailLabel)
        containerView.addSubview(phoneLabel)
        containerView.addSubview(addressLabel)
        containerView.addSubview(companyLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container constraints
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Name label
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Username label
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            usernameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Email label
            emailLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            emailLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Phone label
            phoneLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 4),
            phoneLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            phoneLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Address label
            addressLabel.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 4),
            addressLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Company label
            companyLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 4),
            companyLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            companyLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            companyLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    func configure(with user: User) {
        nameLabel.text = user.name
        usernameLabel.text = "@\(user.username)"
        emailLabel.text = "📧 \(user.email)"
        phoneLabel.text = "📞 \(user.phone)"
        addressLabel.text = "📍 \(user.address.formattedAddress)"
        companyLabel.text = "🏢 \(user.company.name)"
    }
}
