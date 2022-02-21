import UIKit

class NoteListTableViewCell: UITableViewCell {
    private var titleLabel: UILabel = {
       var label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private var dateLabel: UILabel = {
        var label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
         return label
     }()
    
    private var previewLabel: UILabel = {
        var label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption2)
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .systemGray
         return label
     }()
    
    private lazy var textHorizontalStackView: UIStackView = {
       var stackView = UIStackView(arrangedSubviews: [dateLabel, previewLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 5
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var textVerticalStackView: UIStackView = {
        var stackView = UIStackView(arrangedSubviews: [titleLabel, textHorizontalStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textVerticalStackView)
        setUpLayout() 
    }
    
    func updateLabel(title: String, lastModified: Date, preview: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy. MM. dd"
        let dateConvertedToTimeInterval = lastModified.timeIntervalSince1970
        let formattedDate = Date(timeIntervalSince1970: dateConvertedToTimeInterval)

        titleLabel.text = title
        if title.isEmpty {
            titleLabel.text = "제목을 입력하세요"
        }
        dateLabel.text = dateFormatter.string(from: formattedDate)
        previewLabel.text = preview
    }
    
    private func setUpLayout() {
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5)
        ])
        
        NSLayoutConstraint.activate([
            textVerticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            textVerticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            textVerticalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            textVerticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7)
        ])
    }
}
