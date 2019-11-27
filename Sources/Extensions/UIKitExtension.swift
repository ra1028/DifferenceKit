#if os(iOS) || os(tvOS)
import UIKit

public extension UITableView {
    /// Applies multiple animated updates in stages using `StagedChangeset`.
    ///
    /// - Note: There are combination of changes that crash when applied simultaneously in `performBatchUpdates`.
    ///         Assumes that `StagedChangeset` has a minimum staged changesets to avoid it.
    ///         The data of the data-source needs to be updated synchronously before `performBatchUpdates` in every stages.
    ///
    /// - Parameters:
    ///   - stagedChangeset: A staged set of changes.
    ///   - animation: An option to animate the updates.
    ///   - interrupt: A closure that takes an changeset as its argument and returns `true` if the animated
    ///                updates should be stopped and performed reloadData. Default is nil.
    ///   - setData: A closure that takes the collection as a parameter.
    ///              The collection should be set to data-source of UITableView.
    ///   - completion: An optional closure that reports the completion of the reload.
    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        with animation: @autoclosure () -> RowAnimation,
        interrupt: ((Changeset<C>) -> Bool)? = nil,
        setData: (C) -> Void,
        completion: (() -> Void)? = nil
        ) {
        reload(
            using: stagedChangeset,
            deleteSectionsAnimation: animation(),
            insertSectionsAnimation: animation(),
            reloadSectionsAnimation: animation(),
            deleteRowsAnimation: animation(),
            insertRowsAnimation: animation(),
            reloadRowsAnimation: animation(),
            interrupt: interrupt,
            setData: setData,
            completion: completion
        )
    }

    /// Applies multiple animated updates in stages using `StagedChangeset`.
    ///
    /// - Note: There are combination of changes that crash when applied simultaneously in `performBatchUpdates`.
    ///         Assumes that `StagedChangeset` has a minimum staged changesets to avoid it.
    ///         The data of the data-source needs to be updated synchronously before `performBatchUpdates` in every stages.
    ///
    /// - Parameters:
    ///   - stagedChangeset: A staged set of changes.
    ///   - deleteSectionsAnimation: An option to animate the section deletion.
    ///   - insertSectionsAnimation: An option to animate the section insertion.
    ///   - reloadSectionsAnimation: An option to animate the section reload.
    ///   - deleteRowsAnimation: An option to animate the row deletion.
    ///   - insertRowsAnimation: An option to animate the row insertion.
    ///   - reloadRowsAnimation: An option to animate the row reload.
    ///   - interrupt: A closure that takes an changeset as its argument and returns `true` if the animated
    ///                updates should be stopped and performed reloadData. Default is nil.
    ///   - setData: A closure that takes the collection as a parameter.
    ///              The collection should be set to data-source of UITableView.
    ///   - completion: An optional closure that reports the completion of the reload.
    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        deleteSectionsAnimation: @autoclosure () -> RowAnimation,
        insertSectionsAnimation: @autoclosure () -> RowAnimation,
        reloadSectionsAnimation: @autoclosure () -> RowAnimation,
        deleteRowsAnimation: @autoclosure () -> RowAnimation,
        insertRowsAnimation: @autoclosure () -> RowAnimation,
        reloadRowsAnimation: @autoclosure () -> RowAnimation,
        interrupt: ((Changeset<C>) -> Bool)? = nil,
        setData: (C) -> Void,
        completion: (() -> Void)? = nil
        ) {
        if case .none = window, let data = stagedChangeset.last?.data {
            setData(data)
            return _reloadData(completion: completion)
        }

        let dispatchGroup = DispatchGroup()
        (0..<stagedChangeset.count).forEach { dispatchGroup.enter() }
        dispatchGroup.notify(queue: .main, execute: { completion?() })

        for changeset in stagedChangeset {
            if let interrupt = interrupt, interrupt(changeset), let data = stagedChangeset.last?.data {
                setData(data)
                return _reloadData(completion: { dispatchGroup.leave() })
            }

            _performBatchUpdates({
                setData(changeset.data)

                if !changeset.sectionDeleted.isEmpty {
                    deleteSections(IndexSet(changeset.sectionDeleted), with: deleteSectionsAnimation())
                }

                if !changeset.sectionInserted.isEmpty {
                    insertSections(IndexSet(changeset.sectionInserted), with: insertSectionsAnimation())
                }

                if !changeset.sectionUpdated.isEmpty {
                    reloadSections(IndexSet(changeset.sectionUpdated), with: reloadSectionsAnimation())
                }

                for (source, target) in changeset.sectionMoved {
                    moveSection(source, toSection: target)
                }

                if !changeset.elementDeleted.isEmpty {
                    deleteRows(at: changeset.elementDeleted.map { IndexPath(row: $0.element, section: $0.section) }, with: deleteRowsAnimation())
                }

                if !changeset.elementInserted.isEmpty {
                    insertRows(at: changeset.elementInserted.map { IndexPath(row: $0.element, section: $0.section) }, with: insertRowsAnimation())
                }

                if !changeset.elementUpdated.isEmpty {
                    reloadRows(at: changeset.elementUpdated.map { IndexPath(row: $0.element, section: $0.section) }, with: reloadRowsAnimation())
                }

                for (source, target) in changeset.elementMoved {
                    moveRow(at: IndexPath(row: source.element, section: source.section), to: IndexPath(row: target.element, section: target.section))
                }
            }, completion: { dispatchGroup.leave() })
        }
    }

    private func _performBatchUpdates(_ updates: () -> Void, completion: (() -> Void)? = nil) {
        if #available(iOS 11.0, tvOS 11.0, *) {
            performBatchUpdates(updates) { _ in completion?() }
        }
        else {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            beginUpdates()
            updates()
            endUpdates()
            CATransaction.commit()
        }
    }

    private func _reloadData(completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        reloadData()
        CATransaction.commit()
    }
}

public extension UICollectionView {
    /// Applies multiple animated updates in stages using `StagedChangeset`.
    ///
    /// - Note: There are combination of changes that crash when applied simultaneously in `performBatchUpdates`.
    ///         Assumes that `StagedChangeset` has a minimum staged changesets to avoid it.
    ///         The data of the data-source needs to be updated synchronously before `performBatchUpdates` in every stages.
    ///
    /// - Parameters:
    ///   - stagedChangeset: A staged set of changes.
    ///   - interrupt: A closure that takes an changeset as its argument and returns `true` if the animated
    ///                updates should be stopped and performed reloadData. Default is nil.
    ///   - setData: A closure that takes the collection as a parameter.
    ///              The collection should be set to data-source of UICollectionView.
    ///   - completion: An optional closure that reports the completion of the reload.
    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        interrupt: ((Changeset<C>) -> Bool)? = nil,
        setData: (C) -> Void,
        completion: (() -> Void)? = nil
        ) {
        if case .none = window, let data = stagedChangeset.last?.data {
            setData(data)
            return _reloadData(completion: completion)
        }

        let dispatchGroup = DispatchGroup()
        (0..<stagedChangeset.count).forEach { dispatchGroup.enter() }
        dispatchGroup.notify(queue: .main, execute: { completion?() })

        for changeset in stagedChangeset {
            if let interrupt = interrupt, interrupt(changeset), let data = stagedChangeset.last?.data {
                setData(data)
                return _reloadData(completion: { dispatchGroup.leave() })
            }

            performBatchUpdates({
                setData(changeset.data)

                if !changeset.sectionDeleted.isEmpty {
                    deleteSections(IndexSet(changeset.sectionDeleted))
                }

                if !changeset.sectionInserted.isEmpty {
                    insertSections(IndexSet(changeset.sectionInserted))
                }

                if !changeset.sectionUpdated.isEmpty {
                    reloadSections(IndexSet(changeset.sectionUpdated))
                }

                for (source, target) in changeset.sectionMoved {
                    moveSection(source, toSection: target)
                }

                if !changeset.elementDeleted.isEmpty {
                    deleteItems(at: changeset.elementDeleted.map { IndexPath(item: $0.element, section: $0.section) })
                }

                if !changeset.elementInserted.isEmpty {
                    insertItems(at: changeset.elementInserted.map { IndexPath(item: $0.element, section: $0.section) })
                }

                if !changeset.elementUpdated.isEmpty {
                    reloadItems(at: changeset.elementUpdated.map { IndexPath(item: $0.element, section: $0.section) })
                }

                for (source, target) in changeset.elementMoved {
                    moveItem(at: IndexPath(item: source.element, section: source.section), to: IndexPath(item: target.element, section: target.section))
                }
            }, completion: { _ in dispatchGroup.leave() })
        }
    }

    private func _reloadData(completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        reloadData()
        CATransaction.commit()
    }
}
#endif
