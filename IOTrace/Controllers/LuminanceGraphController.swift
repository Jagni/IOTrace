//
//  LuminanceGraphController.swift
//  IOTrace
//
//  Created by Jagni Bezerra on 10/12/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import UIKit
import ScrollableGraphView

class LuminanceGraphController: UIViewController, ScrollableGraphViewDataSource {
    var luminances = [LuminanceEvent]()
    var shouldUpdate = true
    var numberOfPlots = 1
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet var graphView: ScrollableGraphView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.graphView.dataSource = self
    }
    
    var setup = true
    
    func setLuminances(luminances: [LuminanceEvent]?){
        var uniqueLuminances : [LuminanceEvent] = luminances ?? []
        var i = 0
        while i < uniqueLuminances.count-2{
            var isEqual = true
            while isEqual {
                if i < uniqueLuminances.count-2 {
                if uniqueLuminances[i] == uniqueLuminances[i+1]{
                    uniqueLuminances.remove(at: i+1)
                } else {
                    isEqual = false
                }
                } else {
                    isEqual = false
                }
            }
            i += 1
        }
        self.luminances = uniqueLuminances
        self.graphView.dataSource = nil
        self.updateAvaliations()
    }
    
    func scrollTo(_ location : LocationEvent) {
        
        if let index = luminances.firstIndex(where: { (luminance) -> Bool in
            luminance.date >= location.date
        }) {
            let point = graphView.dataPointSpacing * CGFloat(index) - (self.graphView.bounds.width/2)
            self.graphView.setContentOffset(CGPoint(x: point, y: 0), animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.shouldUpdate = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.shouldUpdate = true
    }
    
    func numberOfPoints() -> Int {
        return luminances.count
    }
    
    func label(atIndex pointIndex: Int) -> String {
        let luminance = luminances[pointIndex]
        return luminance.timeString
    }
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        let luminance = luminances[pointIndex]
        return luminance.lux
    }
    
    func configureGraphView() {
        
        // Setup the reference lines.
        let referenceLines = ReferenceLines()
        referenceLines.referenceLineNumberOfDecimalPlaces = 1
        referenceLines.referenceLineLabelFont = UIFont.systemFont(ofSize: 14)
        referenceLines.referenceLineColor = UIColor(white: 0, alpha: 0.25)
        referenceLines.referenceLineThickness = 0.25
        referenceLines.referenceLineLabelColor = textColor
        referenceLines.includeMinMax = true
        referenceLines.dataPointLabelColor = textColor
        referenceLines.dataPointLabelsSparsity = 1
        referenceLines.referenceLineUnits = "lx"
        
        // Setup the graph
        graphView.backgroundFillColor = UIColor.clear
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = true
        graphView.dataPointSpacing = 48
        graphView.shouldRangeAlwaysStartAtZero = true
        
        
        
        // Add everything to the graph.
        graphView.addReferenceLines(referenceLines: referenceLines)
        
                let linePlot = LinePlot(identifier: "line")
                linePlot.lineWidth = 2
                linePlot.lineColor = luxColor
                linePlot.lineStyle = .smooth
                linePlot.shouldFill = true
                linePlot.fillType = .gradient
                linePlot.fillGradientStartColor = luxColor.withAlphaComponent(0)
                linePlot.fillGradientEndColor = luxColor.withAlphaComponent(0.25)
                linePlot.adaptAnimationType = .easeOut
                graphView.addPlot(plot: linePlot)
                
                let dotPlot = DotPlot(identifier: "dot")
                dotPlot.dataPointFillColor = luxColor
                let size = 3
                dotPlot.dataPointSize = CGFloat(size)
                dotPlot.dataPointType = .circle
                graphView.addPlot(plot: dotPlot)
        
        
    }
    
    func updateAvaliations() {
        if shouldUpdate {
            self.replaceGraphView()
        }
    }
    
    func replaceGraphView() {
        let newGraph = ScrollableGraphView()
        let view = self.graphView.superview
        
        self.graphView.removeFromSuperview()
        view?.addSubview(newGraph)
        self.graphView = newGraph
        self.graphView.translatesAutoresizingMaskIntoConstraints = false
        self.addGraphConstraints(0)
        self.configureGraphView()
        self.graphView.dataSource = self
        //self.updateEmpty()
    }
    
    func addGraphConstraints(_ constant : CGFloat) {
        let view = self.graphView.superview
        self.view.addConstraints([
            NSLayoutConstraint(item: self.graphView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: graphView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.graphView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: self.graphView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -30)
            ])
        
    }
    
    func updateEmpty() {
        UIView.animate(withDuration: 0.25, animations: {
            if self.luminances.isEmpty {
                self.emptyView.alpha = 1
                self.graphView.alpha = 0
            } else {
                self.emptyView.alpha = 0
                self.graphView.alpha = 1
            }
        })
    }
}
