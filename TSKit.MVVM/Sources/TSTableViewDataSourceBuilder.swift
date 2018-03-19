/// TSTOOLS: This would be great stuff.
/**
 Dependencies:
  TSLog
  TSCollectionsViewEx
  IdentifiableView,
  Configurable,
  Stylable
 */
/**
 1. Utilize tableView's common dataSource, delegate methods.
 2. Add support for empty content
 3. Add support for pull to refresh
 4. Add support for bottom pull to refresh (this one needs custom view/cell)
 */
/*
 Goal:
 

 */
import UIKit

typealias TableViewSectionsProvider = (section : Int) -> Any
typealias TableViewContentProvider = (section : Int, row : Int) -> Any

private enum SectionViewRow : Int {
    case Header = -1
    case Footer = -2
}

enum TableViewManagerError : ErrorType {
    case MissingDataProvider
    case MissingContentDataProvider
}

class TableViewManager : NSObject {
    
    private let log : Log = try! Injector.inject(Log.self, with: TableViewManager.self)
    
    private let tableView : UITableView
    private let registeredViews : [String : TableViewElement.Type]
    private var cachedTypes : [NSIndexPath : TableViewElement.Type] = [:]
    private let dataProvider : TableViewDataProvider

    class func manage(tableView : UITableView) -> TableViewManagerBuilder {
        return SimpleTableViewManagerBuilder(tableView: tableView)
    }
    
    init(tableView : UITableView,
         registeredViews : [String : TableViewElement.Type],
         dataProvider : TableViewDataProvider) {
        self.tableView = tableView
        self.registeredViews = registeredViews
        self.dataProvider = dataProvider
    }
}

struct TableViewDataProvider {
    var headers : TableViewSectionsProvider?
    var footers : TableViewSectionsProvider?
    var content : TableViewContentProvider?
}

protocol TableViewManagerBuilder {
    func consume() -> TableViewDataProviderBuilder
    func registerContentCell<T where T : UITableViewCell, T : TableViewElement, T : Configurable>(cell : T.Type) -> ReusableViewBuilder
    func registerHeaderView<T where T : UITableViewHeaderFooterView, T : TableViewElement, T : Configurable>(view : T.Type) -> ReusableViewBuilder
    func registerFooterView<T where T : UITableViewHeaderFooterView, T : TableViewElement, T : Configurable>(view : T.Type) -> ReusableViewBuilder
    func build() throws -> TableViewManager
}

protocol ReusableViewBuilder {
    func forDataSource(dataSource : Any.Type) -> TableViewManagerBuilder
}

protocol TableViewDataProviderBuilder {
    func content(closure : TableViewContentProvider) -> Self
    func headers(closure : TableViewSectionsProvider) -> Self
    func footers(closure : TableViewSectionsProvider) -> Self
    func build() throws -> TableViewManagerBuilder
}

extension TableViewManager : UITableViewDataSource, UITableViewDelegate {
    
    private func typeForRowAtIndexPath(indexPath : NSIndexPath) -> Any.Type? {
        if let type = self.cachedTypes[indexPath] {
            return type
        } else if let itemType = self.dataProvider.content?(section: indexPath.section, row: indexPath.row).dynamicType,
                    cellType = self.registeredViews["\(itemType)"] {
            self.cachedTypes[indexPath] = cellType
            return itemType
        } else {
            return nil
        }
    }
    
    private func typeForHeaderInSection(section : Int) -> Any.Type? {
        let indexPath = NSIndexPath(forRow: SectionViewRow.Header.rawValue, inSection: section)
        if let type = self.cachedTypes[indexPath] {
            return type
        } else if let itemType = self.dataProvider.headers?(section: section).dynamicType,
            headerType = self.registeredViews["\(itemType)"] {
            self.cachedTypes[indexPath] = headerType
            return headerType
        } else {
            return nil
        }
    }
    
    private func typeForFooterInSection(section : Int) -> Any.Type? {
        let indexPath = NSIndexPath(forRow: SectionViewRow.Footer.rawValue, inSection: section)
        if let type = self.cachedTypes[indexPath] {
            return type
        } else if let itemType = self.dataProvider.footers?(section: section).dynamicType,
            footerType = self.registeredViews["\(itemType)"] {
            self.cachedTypes[indexPath] = footerType
            return footerType
        } else {
            return nil
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let type = self.typeForRowAtIndexPath(indexPath) as? UITableViewCell.Type else {
            return 0.001
        }
        return type.height
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cellType = self.typeForRowAtIndexPath(indexPath) as? UITableViewCell.Type else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCellOfType(cellType)
        
        if let content = self.dataProvider.content?(section: indexPath.section, row: indexPath.row) {
            cell.configure(with: content)
            cell.style(with: content)
        } else {
            self.log.warning("Content for '\(cellType)' at indexPath \(indexPath) wasn't provided.")
        }
        
        
        return cell
    }
}