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
    var detailed = false
    var delegate : DateControllerDelegate?
    
    func reloadDates(newDates: [DateAggregator]?, detailed: Bool){
        DispatchQueue.main.async {
            self.dates = newDates ?? [DateAggregator]()
            self.detailed = detailed
            self.collectionView?.reloadSections([0])
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
        
        if (detailed){
            var count = 0
            for interval in aggregator.intervals{
                count += interval.locations.count
            }
            cell.locationLabel.text = "\(count)"
        } else {
            cell.locationLabel.text = "\(aggregator.intervals.count)"
        }
        return cell
    }
    
}

public class DateCell: UICollectionViewCell {
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var luminanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}

