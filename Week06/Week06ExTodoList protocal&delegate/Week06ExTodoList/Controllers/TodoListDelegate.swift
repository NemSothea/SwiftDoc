//
//  TodoListDelegate.swift
//  Week06ExTodoList
//
//  Created by sothea007 on 5/11/25.
//
import Foundation

protocol TodoListDelegate: AnyObject {
    func todoListDidUpdate(_ todoList: TodoListManaging)
    func todoList(_ todoList: TodoListManaging, didEncounterError error: TodoError)
}
