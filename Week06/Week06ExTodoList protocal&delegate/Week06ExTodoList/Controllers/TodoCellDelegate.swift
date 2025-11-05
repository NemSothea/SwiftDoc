//
//  TodoCellDelegate.swift
//  Week06ExTodoList
//
//  Created by sothea007 on 5/11/25.
//


import Foundation

protocol TodoCellDelegate: AnyObject {
    func todoCellDidToggleStatus(_ cell: TodoCell, for todo: TodoItem)
}
