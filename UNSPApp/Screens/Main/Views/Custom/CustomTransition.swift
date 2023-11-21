//
//  CustomTransition.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 21.11.2023.
//

import UIKit

//MARK: - Impl

final class CustomTransition: NSObject {
    
    private let duration: TimeInterval = 1
    
}


//MARK: - Animated Transitioning

extension CustomTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        
        let bounds = containerView.bounds
        toView.frame = bounds.offsetBy(dx: 0, dy: bounds.height)
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: duration,
            delay: 0,
            options: .curveEaseInOut
        ) {
            toView.frame = bounds
        } completion: { position in
            let finished = !transitionContext.transitionWasCancelled
            transitionContext.completeTransition(finished)
        }
    }
}

//MARK: - Transitioning Delegate

extension CustomTransition: UIViewControllerTransitioningDelegate {
    
}
