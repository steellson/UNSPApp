//
//  CustomTransition.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 21.11.2023.
//

import UIKit


final class CustomTransition: NSObject {
    
    //MARK: Type
    
    enum TransitionType {
        case present
        case dismiss
    }
    
    private var fromVC: UIViewController?
    private var toVC: UIViewController?
    
    private var transitionType: TransitionType
    private let duration: TimeInterval
    
    
    init(
        transitionType: TransitionType,
        duration: TimeInterval
    ) {
        self.transitionType = transitionType
        self.duration = duration
    }
    
    private func presentAnimation(
        withTransitioningContext context: UIViewControllerContextTransitioning,
        viewToAnimate view: UIView) {
        
            view.clipsToBounds = true
            view.transform = CGAffineTransform(scaleX: 0, y: 0)
            
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.1,
                options: [.curveEaseOut, .curveEaseIn]
            ) {
                print("suck")
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
                } completion: { _ in
                    context.completeTransition(true)
                }

    }
}


//MARK: - Animated Transitioning

extension CustomTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard 
//            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
        }
        
        switch transitionType {
        case .present: 
            presentAnimation(withTransitioningContext: transitionContext, viewToAnimate: toView)
        case .dismiss: 
            print("Need implement transition to detail")
        }
    }
}


//MARK: - Transitioning Delegate

extension CustomTransition: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, 
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            transitionType = .present
            fromVC = source
            toVC = presented
            return self
    }
    
    func animationController(forDismissed 
                             dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            transitionType = .dismiss
            toVC = fromVC
            fromVC = dismissed
            return self
    }
}
