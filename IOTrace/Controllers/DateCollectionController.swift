//
//  DateCollectionController.swift
//  IOTrace
//
//  Created by Jagni Bezerra on 09/12/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import GoogleMaps

class DateCollectionController: UICollectionViewController {
    var dates = [DateAggregator]()
    var delegate : DateControllerDelegate?
    var isReady = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isReady = true
    }
    func reloadDates(newDates: [DateAggregator]?){
        if isReady{
        DispatchQueue.main.async {
            
            self.collectionView.performBatchUpdates({
                if self.dates.count == 0 {
                    var indexes = [IndexPath]()
                    for i in 0..<newDates!.count{
                        self.dates.append(newDates![i])
                        indexes.append(IndexPath(item: i, section: 0))
                    }
                    self.collectionView.insertItems(at: indexes)
                }
                else if newDates!.count == self.dates.count {
                    self.dates[self.dates.count - 1] = newDates!.last!
                    self.collectionView.reloadItems(at: [IndexPath(item: self.dates.count - 1, section: 0)])
                } else {
                    
                    self.dates.append(newDates!.last!)
                    self.collectionView.insertItems(at: [IndexPath(item: self.dates.count-1, section: 0)])
                    
                    var indexes = [IndexPath]()
                    for i in 0..<newDates!.count-1{
                        indexes.append(IndexPath(item: i, section: 0))
                    }
                    self.collectionView.reloadItems(at: indexes)

                }
            }, completion: nil)
        }
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let initialPinchPoint = CGPoint(x: self.collectionView!.center.x + self.collectionView!.contentOffset.x, y: self.collectionView!.center.y + self.collectionView!.contentOffset.y)
        self.delegate?.didChangeIndex(self.collectionView!.indexPathForItem(at: initialPinchPoint)!)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "date", for: indexPath) as! DateCell
        let aggregator = dates[indexPath.item]
        cell.dateLabel.text = aggregator.date
        cell.locationImage.image = GMSMarker.markerImage(with: markerColor)
        cell.luminanceLabel.text = "\(aggregator.luminances.count)"
        
        if indexPath.item < dates.count - 1{
            cell.checkImage.alpha = 1
        }
        
            var count = 0
            for interval in aggregator.intervals{
                count += interval.locations.count
            }
            cell.locationLabel.text = "\(count)"
        
        return cell
    }
    
}

public class DateCell: UICollectionViewCell {
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var luminanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}

