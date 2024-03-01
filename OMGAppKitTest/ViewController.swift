//
//  ViewController.swift
//  OMGAppKitTest
//
//  Created by Sergio Veliz on 29.02.2024.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HorizontalTableViewCell.self, forCellReuseIdentifier: "HorizontalCell")
        view.addSubview(tableView)
        return tableView
    }()
    
    var verticalData: [[Int]] = []
    var timers: [Timer] = []
    let scalePress = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateRandomData()
        startTimers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func generateRandomData() {
        let numberOfItems = Int.random(in: 100...200)
        for _ in 0..<numberOfItems {
            let innerArrayCount = Int.random(in: 10...20)
            let innerArray = (0..<innerArrayCount).map { _ in
                return Int.random(in: 1...100)
            }
            verticalData.append(innerArray)
        }
    }
    
    func startTimers() {
        for _ in 0..<verticalData.count {
            let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                self.updateRandomNumber()
            }
            timers.append(timer)
        }
    }
    
    func updateRandomNumber() {
        guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
        for indexPath in indexPaths {
            let section = indexPath.section
            if let collectionView = (tableView.cellForRow(at: indexPath) as? HorizontalTableViewCell)?.collectionView {
                collectionView.visibleCells.forEach { cell in
                    if let indexPath = collectionView.indexPath(for: cell) {
                        let randomNumber = Int.random(in: 1...100)
                        verticalData[section][indexPath.item] = randomNumber
                        if let label = cell.contentView.subviews.first as? UILabel {
                            label.text = "\(randomNumber)"
                        }
                    }
                }
            }
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return verticalData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HorizontalCell", for: indexPath) as! HorizontalTableViewCell
        cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)
        return cell
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return verticalData[collectionView.tag].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SquareNumberCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        cell.layer.cornerRadius = 15
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.purple.cgColor
        cell.backgroundColor = .black
        
        let label = UILabel(frame: cell.bounds)
        label.textAlignment = .center
        label.text = "\(verticalData[collectionView.tag][indexPath.item])"
        label.textColor = UIColor.white
        cell.contentView.addSubview(label)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didTapLongPress))
        longPressRecognizer.minimumPressDuration = 0.05
        longPressRecognizer.cancelsTouchesInView = false
        cell.addGestureRecognizer(longPressRecognizer)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
}

extension ViewController {
    @objc func didTapLongPress(sender: UILongPressGestureRecognizer) {
        guard let cell = sender.view as? UICollectionViewCell else { return }
        
        switch sender.state {
        case .began:
            animate(cell, to: scalePress)
            cell.backgroundColor = .gray
        case .changed:
            if cell.transform != scalePress {
                animate(cell, to: scalePress)
                cell.backgroundColor = .gray
            }
        case .ended, .cancelled:
            animate(cell, to: .identity)
            cell.backgroundColor = .black
        default:
            break
        }
    }
    
    private func animate(_ cell: UICollectionViewCell, to transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 3,
                       options: [.curveEaseInOut],
                       animations: {
            cell.transform = transform
        }, completion: nil)
    }
}
