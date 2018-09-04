#if os(iOS) || os(tvOS)
import UIKit

/// Protocol to allow mocking the table view operated on by DifferenceKit
public protocol TableView: class {
    var window: UIWindow? { get }

    func reloadData()

    func insertSections(_ sections: IndexSet, with animation: UITableViewRowAnimation)

    func deleteSections(_ sections: IndexSet, with animation: UITableViewRowAnimation)

    func reloadSections(_ sections: IndexSet, with animation: UITableViewRowAnimation)

    func moveSection(_ section: Int, toSection newSection: Int)

    func insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation)

    func deleteRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation)

    func reloadRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation)

    func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath)

    /// Method with slightly different signature compared to
    /// `UITableView.performBatchUpdates(_:completion):`, which has a default parameter for the
    /// completion param and therefore cannot satisfy a protocol-defined function with the same
    /// signature
    func performBatchUpdates(_ updates: (() -> Swift.Void))
}

extension UITableView: TableView {
    /// Uses `performBatchUpdates(_:completion:)` if possible and falls back to
    /// `beginUpdates`/`endUpdates`
    public func performBatchUpdates(_ updates: (() -> Swift.Void)) {
        if #available(iOS 11.0, tvOS 11.0, *) {
            performBatchUpdates(updates, completion: nil)
        } else {
            beginUpdates()
            updates()
            endUpdates()
        }
    }
}

public extension TableView {
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
    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        with animation: @autoclosure () -> UITableViewRowAnimation,
        interrupt: ((Changeset<C>) -> Bool)? = nil,
        setData: (C) -> Void
        ) {
        reload(
            using: stagedChangeset,
            deleteSectionsAnimation: animation,
            insertSectionsAnimation: animation,
            reloadSectionsAnimation: animation,
            deleteRowsAnimation: animation,
            insertRowsAnimation: animation,
            reloadRowsAnimation: animation,
            interrupt: interrupt,
            setData: setData
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
    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        deleteSectionsAnimation: @autoclosure () -> UITableViewRowAnimation,
        insertSectionsAnimation: @autoclosure () -> UITableViewRowAnimation,
        reloadSectionsAnimation: @autoclosure () -> UITableViewRowAnimation,
        deleteRowsAnimation: @autoclosure () -> UITableViewRowAnimation,
        insertRowsAnimation: @autoclosure () -> UITableViewRowAnimation,
        reloadRowsAnimation: @autoclosure () -> UITableViewRowAnimation,
        interrupt: ((Changeset<C>) -> Bool)? = nil,
        setData: (C) -> Void
        ) {
        if case .none = window, let data = stagedChangeset.last?.data {
            setData(data)
            return reloadData()
        }

        for changeset in stagedChangeset {
            if let interrupt = interrupt, interrupt(changeset), let data = stagedChangeset.last?.data {
                setData(data)
                return reloadData()
            }

            performBatchUpdates {
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
            }
        }
    }
}

/// Protocol to allow mocking the collection view operated on by DifferenceKit
public protocol CollectionView: class {
    var window: UIWindow? { get }

    func reloadData()

    func insertSections(_ sections: IndexSet)

    func deleteSections(_ sections: IndexSet)

    func reloadSections(_ sections: IndexSet)

    func moveSection(_ section: Int, toSection newSection: Int)

    func insertItems(at indexPaths: [IndexPath])

    func deleteItems(at indexPaths: [IndexPath])

    func reloadItems(at indexPaths: [IndexPath])

    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath)

    /// Method with slightly different signature compared to
    /// `UICollectionView.performBatchUpdates(_:completion):`, which has a default parameter for the
    /// completion param and therefore cannot satisfy a protocol-defined function with the same
    /// signature
    func performBatchUpdates(_ updates: (() -> Swift.Void))
}

extension UICollectionView: CollectionView {
    public func performBatchUpdates(_ updates: (() -> Void)) {
        performBatchUpdates(updates, completion: nil)
    }
}

public extension CollectionView {
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
    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        interrupt: ((Changeset<C>) -> Bool)? = nil,
        setData: (C) -> Void
        ) {
        if case .none = window, let data = stagedChangeset.last?.data {
            setData(data)
            return reloadData()
        }

        for changeset in stagedChangeset {
            if let interrupt = interrupt, interrupt(changeset), let data = stagedChangeset.last?.data {
                setData(data)
                return reloadData()
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
            })
        }
    }
}
#endif
