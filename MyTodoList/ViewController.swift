//
//  ViewController.swift
//  MyTodoList
//
//  Created by 木村友哉 on 2016/06/19.
//  Copyright © 2016年 tomoya kimura. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var todoList = [MyTodo]()
    
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //読み込み処理を追加
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let todoListData = userDefaults.objectForKey("todoList") as? NSData {
            if let storedTodoList = NSKeyedUnarchiver.unarchiveObjectWithData(todoListData) as? [MyTodo] {
                todoList.appendContentsOf(storedTodoList)
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapAddButton(sender: AnyObject) {
        //アラートダイアログ生成
        let alertController = UIAlertController(title: "TODO追加", message: "TODOを入力してください", preferredStyle: UIAlertControllerStyle.Alert)
        
        //テキストエリア追加
        alertController.addTextFieldWithConfigurationHandler(nil)
        
//        let userDefaults = NSUserDefaults.standardUserDefaults()
//        userDefaults.setObject(data, forKey: "todoList")
        
        //OKボタンを追加
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            (action:UIAlertAction) -> Void in
            
            //OKボタンが押された時の処理
            if let textField = alertController.textFields?.first {
                
                //テーブルに行が追加されたことをテーブルに通知
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Right)
                
                //TODOの配列に入力した値を挿入。先頭に挿入する
                let myTodo = MyTodo()
                myTodo.todoTitle = textField.text
                self.todoList.insert(myTodo, atIndex: 0)

                
                //保存処理を追加
                //NSData型にシリアライズする
                let data :NSData = NSKeyedArchiver.archivedDataWithRootObject(self.todoList)
                
                //NSUserDefaultsに保存
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setObject(data, forKey: "todoList")
                userDefaults.synchronize()
            }
            
        }
        //OKボタンを追加
        alertController.addAction(okAction)
        
        //CANCELボタンがタップされた時の処理
        let cancelAction = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.Cancel, handler: nil)
        
        //CANCELボタンを追加
        alertController.addAction(cancelAction)
        
        //アラートダイアログを表示
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    //テーブルの行ごとのセルを返却する
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //storyboardで指定したtodoCell識別子を利用して再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCellWithIdentifier("todoCell", forIndexPath: indexPath)
        
        //行番号にあったToDoのタイトルの取得
        let todo = todoList[indexPath.row]
        //セルのラベルにToDoのタイトルをセット
        cell.textLabel!.text = todo.todoTitle
        
        if todo.todoDone {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //ToDoの配列の長さを返却する
        return todoList.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let todo = todoList[indexPath.row]
        if todo.todoDone {
            //完了済みの場合は未完に変更
            todo.todoDone = false
        } else {
            //未完の場合は完了済みに変更
            todo.todoDone = true
        }
        //セルの状態を変更
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        
        //データ保存
        //NSData型にシリアライズする
        let data :NSData = NSKeyedArchiver.archivedDataWithRootObject(todoList)
        
        //NSUserDefaultsに保存
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(data, forKey: "todoList")
        userDefaults.synchronize()
    }
    
    //セルが編集可能かどうかの判定処理
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //削除処理かどうか
        if editingStyle == .Delete {
            //ToDoリストから削除
            todoList.removeAtIndex(indexPath.row)
            
            //セルを削除
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            //データ保存
            //NSData型にシリアライズする
            let data :NSData = NSKeyedArchiver.archivedDataWithRootObject(todoList)
            
            //NSUserDefaultsnに保存
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(data, forKey: "todoList")
            userDefaults.synchronize()
        }
    }
    
    
    


}

class MyTodo: NSObject, NSCoding {
    //Todoのタイトル
    var todoTitle :String?
    
    //Todoを完了したかどうかを表すフラグ
    var todoDone :Bool = false
    
    //コンストラクタ
    override init(){
        
    }
    
    //NSCodingプロトコルに宣言されているデシリアライズ処理。デコード処理とも呼ばれる
    required init?(coder aDecoder: NSCoder) {
        todoTitle = aDecoder.decodeObjectForKey("todoTitle") as? String
        todoDone = aDecoder.decodeBoolForKey("todoDone")
    }
    
    //NSCodingプロトコルに宣言されているシリアライズ処理。エンコード処理とも呼ばれる
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(todoTitle, forKey: "todoTitle")
        aCoder.encodeBool(todoDone, forKey: "todoDone")
    }
}

