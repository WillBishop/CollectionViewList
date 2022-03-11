//
//  ViewController.swift
//  CollectionViewList
//
//  Created by Will Bishop on 11/3/2022.
//

import UIKit

enum Section: Hashable {
	case info
	case image
}

enum Row: Hashable {
	case name
	case description
	case image(image: UIImage)
}

class DiffableDataSource: UICollectionViewDiffableDataSource<Section, Row> {
	
}

class ViewController: UIViewController {
	
	private let collectionView: UICollectionView = {
		let layoutConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
		let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfiguration)
		return UICollectionView(frame: .zero, collectionViewLayout: listLayout)
	}()
	private var dataSource: DiffableDataSource!
	
	override func viewDidLoad() {
		self.configureCollectionView()
		self.setupViews()
		self.view.backgroundColor = .systemBackground
	}
	
	func configureCollectionView() {
		let textRegistration = UICollectionView.CellRegistration<TextInputCell, Row> { (cell, indexPath, item) in
			cell.item = item
		}
		let imageRegistration = UICollectionView.CellRegistration<ImageCell, Row> { (cell, indexPath, item) in
			cell.item = item
		}
		self.dataSource = DiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
			switch itemIdentifier {
			case .name, .description:
				return collectionView.dequeueConfiguredReusableCell(using: textRegistration, for: indexPath, item: itemIdentifier)
			case .image:
				return collectionView.dequeueConfiguredReusableCell(using: imageRegistration, for: indexPath, item: itemIdentifier)
			default:
				fatalError()
			}
		})
		self.collectionView.dataSource = self.dataSource
		var snapshot = self.dataSource.snapshot()
		snapshot.appendSections([.info])
		snapshot.appendItems([.name, .description], toSection: .info)
		snapshot.appendSections([.image])
		snapshot.appendItems([.image(image: UIImage(named: "displayImage")!)], toSection: .image)
		self.dataSource.apply(snapshot, animatingDifferences: false)
	}
	
	func setupViews() {
		self.view.addSubview(collectionView)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
		])
	}
}

class TextInputCell: UICollectionViewListCell {
	
	var item: Row?
	
	override func updateConfiguration(using state: UICellConfigurationState) {
		var newConfiguration = TextInputConfiguration().updated(for: state)
		guard let item = item else {
			return
		}
		switch item {
		case .name:
			newConfiguration.placeholder = "Name"
		case .description:
			newConfiguration.placeholder = "Description"
		default:
			newConfiguration.placeholder = nil
		}
		contentConfiguration = newConfiguration
	}
	
}

struct TextInputConfiguration: UIContentConfiguration, Hashable {
	
	var placeholder: String?
	
	func makeContentView() -> UIView & UIContentView {
		return TextInputView(configuration: self)
	}
	
	func updated(for state: UIConfigurationState) -> TextInputConfiguration {
		return self
	}
}

class TextInputView: UIView, UIContentView {
	
	private var currentConfiguration: TextInputConfiguration!
	var configuration: UIContentConfiguration {
		get { currentConfiguration }
		set {
			guard let configuration = newValue as? TextInputConfiguration else {
				return
			}
			self.apply(configuration: configuration)
			
		}
	}
	
	var textField = UITextField()
	
	init(configuration: TextInputConfiguration) {
		super.init(frame: .zero)
		self.setupViews()
		self.apply(configuration: configuration)
	}
	
	func setupViews() {
		self.addSubview(textField)
		textField.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			textField.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			textField.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
			textField.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
			textField.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func apply(configuration: TextInputConfiguration) {
		guard currentConfiguration != configuration else {
			return
		}
		
		// Replace current configuration with new configuration
		currentConfiguration = configuration
		self.textField.placeholder = configuration.placeholder
	}
}

class ImageCell: UICollectionViewListCell {
	
	var item: Row?
	
	override func updateConfiguration(using state: UICellConfigurationState) {
		var newConfiguration = ImageCellConfiguration().updated(for: state)
		guard let item = item else {
			return
		}
		switch item {
		case .image(let image):
			newConfiguration.image = image
		default:
			newConfiguration.image = nil
		}
		contentConfiguration = newConfiguration
	}
	
}

struct ImageCellConfiguration: UIContentConfiguration, Hashable {
	
	var image: UIImage?

	func makeContentView() -> UIView & UIContentView {
		return ImageCellView(configuration: self)
	}
	
	func updated(for state: UIConfigurationState) -> ImageCellConfiguration {
		return self
	}
}

class ImageCellView: UIView, UIContentView {
	
	private var currentConfiguration: ImageCellConfiguration!
	var configuration: UIContentConfiguration {
		get { currentConfiguration }
		set {
			guard let configuration = newValue as? ImageCellConfiguration else {
				return
			}
			self.apply(configuration: configuration)
			
		}
	}
	
	var display = UIImageView()
	
	init(configuration: ImageCellConfiguration) {
		super.init(frame: .zero)
		self.setupViews()
		self.apply(configuration: configuration)
	}
	
	func setupViews() {
		self.addSubview(display)
		display.translatesAutoresizingMaskIntoConstraints = false
		display.contentMode = .scaleAspectFill
		NSLayoutConstraint.activate([
			display.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			display.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
			display.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
			display.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
			display.heightAnchor.constraint(equalToConstant: 200)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func apply(configuration: ImageCellConfiguration) {
		guard currentConfiguration != configuration else {
			return
		}
		
		// Replace current configuration with new configuration
		currentConfiguration = configuration
		self.display.image = configuration.image
	}
}
