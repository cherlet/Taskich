import UIKit

class MenuTagsView: UITableView {
    var tags = [Tag]()
    
    var returnEditedTag: ((UUID) -> Void)?
    var returnDeletedTag: ((UUID) -> Void)?
    
    init() {
        super.init(frame: .zero, style: .plain)
        self.dataSource = self
        self.delegate = self
        self.separatorStyle = .none
        updateData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        self.register(TagCell.self, forCellReuseIdentifier: "TagCell")
    }
    
    func updateData() {
        tags = StorageManager.shared.fetchTags()
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
}

extension MenuTagsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell", for: indexPath) as? TagCell else { fatalError() }
        
        let tag = tags[indexPath.row]
        
        cell.configure(tag: tag)
        
        cell.onEditButton = {
            self.returnEditedTag?(tag.id)
            cell.configureEditingTools(isEditingMode: false)
        }
        
        cell.onDeleteButton = {
            self.returnDeletedTag?(tag.id)
            cell.configureEditingTools(isEditingMode: false)
        }
        
        return cell
    }
}

extension MenuTagsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TagCell {
            
            if cell.isEditingMode {
                cell.configureEditingTools(isEditingMode: false)
            } else {
                cell.configureEditingTools(isEditingMode: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TagCell {
            cell.configureEditingTools(isEditingMode: false)
        }
    }
}
