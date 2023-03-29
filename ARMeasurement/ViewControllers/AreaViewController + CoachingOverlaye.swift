//
//  AreaViewController + CoachingOverlayer.swift
//  MeasureDemo
//
//  Created by Bhavik on 15/03/23.
//

import Foundation
import ARKit

extension AreaViewController: ARCoachingOverlayViewDelegate {

    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        //upperControlsView.isHidden = true
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        //upperControlsView.isHidden = false
    }

    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        //restartExperience()
    }

    func setupCoachingOverlay() {

        coachingOverlay.session = sceneView.session
        coachingOverlay.delegate = self
        
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        sceneView.addSubview(coachingOverlay)
        
        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
            ])
        
        setActivatesAutomatically()
        setGoal()
    }
    func setActivatesAutomatically() {
        coachingOverlay.activatesAutomatically = true
    }
    func setGoal() {
        coachingOverlay.goal = .anyPlane
    }
}
