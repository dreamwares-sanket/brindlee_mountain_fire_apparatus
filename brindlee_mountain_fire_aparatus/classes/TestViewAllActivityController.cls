/**/
@isTest
public class TestViewAllActivityController{
    public static TestMethod void demo(){
        /*insert account */
        Account acc = new Account(Name = 'test');
        insert acc;
        /*create test task record */
        Task task = new Task();
        task.WhatId = acc.Id;
        task.Subject = 'Email: apex test';
        task.ActivityDate = date.today();
        task.Status = 'Completed';
        insert task;
    
        /*putting query parameters */
        ApexPages.currentPage().getParameters().put('id',acc.id);
        ApexPages.currentPage().getParameters().put('object','Account');
        /*creating class object */
        ViewAllActivityController obj = new ViewAllActivityController();
        system.assert(obj.summary.accountId!=null,'No records found');
        
        /*insert contact */
        Contact con = new Contact(LastName='test',AccountId=acc.id);
        insert con;
        /*create test task record */
        task = new Task();
        task.WhatId = acc.Id;
        task.WhoId = con.Id;
        task.Subject = 'Email: apex test';
        task.ActivityDate = date.today();
        task.Status = 'Completed';
        insert task;
        
        /*putting query string parameters */
        ApexPages.currentPage().getParameters().put('id',con.id);
        ApexPages.currentPage().getParameters().put('object','Contact');
        /*reallocating memory to object */
        obj = new ViewAllActivityController();
        system.assert(obj.summary.contactId!=null,'No records found');
    }
}