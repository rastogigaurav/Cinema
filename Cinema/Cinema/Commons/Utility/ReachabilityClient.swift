//
//  ReachabilityClient.swift
//  Cinema
//
//  Created by g.b.rastogi on 08/07/2021.
//

import Foundation
import RxSwift
import Reachability

public class ReachabilityClient {

    /** Subscribe for updates to confirm if the user is on Wifi. */
    public var connectionStatus: Observable<Reachability.Connection> {
        return connectionEstablishedSubject.asObservable().distinctUntilChanged()
    }

    /** Ping this method to get the current connectivity status. Wifi / Cellular / Disconnected */
    public func currentConnectionStatus() -> Reachability.Connection {
        if reachability == nil {
            startNotifier()
        }
        return reachability?.connection ?? .unavailable
    }

    private var connectionEstablishedSubject: BehaviorSubject<Reachability.Connection> = .init(value: .unavailable)
    private var reachability: Reachability? = try? Reachability(hostname: "google.com")

    public init() {
        setUpReachability()
        startNotifier()
    }

    // MARK: - Private implementation
    // **In normal situations, there is no need to call startNotifier*/
    public func startNotifier() {
        if reachability == nil {
            setUpReachability()
        }

        do {
            try reachability?.startNotifier()
        } catch {}
    }

    /** In ALL cases, call stopNotifier when removing the viewController holding this class. */
    public func stopNotifier() {
        reachability?.stopNotifier()
        reachability = nil
    }

    // Push connection status to observers.
    private func updateRx(with reachability: Reachability) {
        connectionEstablishedSubject.onNext(reachability.connection)
    }

    private func setUpReachability() {
        if reachability == nil {
            reachability = try? Reachability(hostname: "google.com")
        }

        addClosures()
    }

    private func addClosures() {
        reachability?.whenReachable = { reachability in
            self.updateRx(with: reachability)
        }
        reachability?.whenUnreachable = { reachability in
            self.updateRx(with: reachability)
        }
    }
}

