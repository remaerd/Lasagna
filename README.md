# Lasagna

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/remaerd/lasagna)
[![Version](https://img.shields.io/github/release/remaerd/lasagna.svg)](https://github.com/remaerd/lasagna/releases)
[![License](https://img.shields.io/pypi/l/Django.svg)](https://github.com/remaerd/lasagna/blob/master/LICENSE)

Lasagna is a Swift Framework which help you implement Card Stack UICollectionView works similar as UITableView. Different from similar Objective-C Framework, Lasagna is carefully written to works well.

![Demo](https://i.imgur.com/dIVnPhO.gif)

### Carthage

Please intall [Carthage](https://github.com/cartage) then insert the following code into your `Cartfile`.

```
	github "remaerd/Keys"
```

＃＃＃ Example

```swift
		let layout = CardCollectionViewLayout()
    layout.edgeInsets = UIEdgeInsets(top: 40, left: 0, bottom: 40, right: 0)
    layout.cardSize = CGSize(width: 320, height: 480)
    let cardView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
    cardView.registerClass(CardCell.self, forCellWithReuseIdentifier: "Cell")
    cardView.backgroundColor = UIColor.whiteColor()
    cardView.dataSource = self
    cardView.delegate = self
    self.view.addSubview(cardView)
```
