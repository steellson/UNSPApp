//
//  CustomTransition.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 21.11.2023.
//

import UIKit

//MARK: - Impl


final class CustomTransition: NSObject {
    
    //MARK: Selections
    
    enum TransitionType {
        case present
        case dismiss
    }
    
    private var transitionType: TransitionType
    private let duration: TimeInterval
    private let statringPoint: CGPoint
    
    
    //MARK: Init
    
    init(
        transitionType: TransitionType,
        duration: TimeInterval,
        statringPoint: CGPoint
    ) {
        self.transitionType = transitionType
        self.duration = duration
        self.statringPoint = statringPoint
    }
    
    
    //MARK: Animations
    
    private func transitionAnimation(withTransitioningContext
                                     context: UIViewControllerContextTransitioning,
                                     viewToAnimate view: UIView,
                                     typeOfTransition type: TransitionType) {
        switch type {
        case .present:
            
            let center = view.center
            let bgColor = view.backgroundColor
            
            // Prepare to animation
            view.center = self.statringPoint
            view.backgroundColor = .clear
            view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            context.containerView.addSubview(view)
            
            // Process
            UIView.animate(
                withDuration: duration,
                delay: 0.1,
                options: [.curveEaseOut, .transitionCurlDown]
            ) {
                
                view.backgroundColor = bgColor
                view.center = center
                view.transform = CGAffineTransform.identity
                
            } completion: { finished in
                context.completeTransition(finished)
                print(R.Strings.animatedTransitionCompleted.rawValue)
            }
            
        case .dismiss:
            
            // Prepare to animation
            context.containerView.addSubview(view)

            // Process
            UIView.animate(withDuration: 0.2) {
                
                view.backgroundColor = .clear
                
                UIView.animate(
                    withDuration: self.duration,
                    delay: 0.1,
                    options: [.curveEaseIn, .transitionCurlUp]
                ) {
                    
                    view.center = self.statringPoint
                    view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    
                } completion: { finished in
                    view.removeFromSuperview()
                    context.completeTransition(finished)
                    print(R.Strings.animatedTransitionCompleted.rawValue)
                }
            }
        }
    }
}


//MARK: - Animated Transitioning

extension CustomTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch transitionType {
        case .present:
            guard let presentedView = transitionContext.view(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
            }
            transitionAnimation(
                withTransitioningContext: transitionContext,
                viewToAnimate: presentedView,
                typeOfTransition: .present
            )

        case .dismiss:
            guard let dismissedView = transitionContext.view(forKey: .from) else {
                transitionContext.completeTransition(false)
                return
            }
            transitionAnimation(
                withTransitioningContext: transitionContext,
                viewToAnimate: dismissedView,
                typeOfTransition: .dismiss
            )
        }
    }
}



