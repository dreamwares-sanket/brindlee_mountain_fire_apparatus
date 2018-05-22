/*
    Name : TestTime_Tracking_Controller
    Class Name : Time_Tracking_Controller
    Date : 
    Author : 
    Description : 
*/
@isTest
public class TestTime_Tracking_Controller{
    
    // Tesing Method
    @isTest 
    private static void startTestCheckDefault(){
        Time_Tracking_Controller timeObj = new Time_Tracking_Controller();
        timeObj.startTaskProcess(); 
        timeObj.cancelTask();
        timeObj.stopTaskNext();
        timeObj.checkEmpId();
        timeObj.showWeeklyTime();
    }
    // Testing for Internal Task 
    @isTest 
    private static void testInternalTask(){
        // insert Employee testing data
        Employee__c employee = new Employee__c();
        employee.name = 'Test Employee';
        employee.IsActive__c = true;
        employee.Email__c = 'Employee@hotmail.com';
        insert employee;
        
        Time_Tracking_Controller timeObj = new Time_Tracking_Controller();
        timeObj.startTaskProcess(); 
        timeObj.selectedEmp = employee.id;
        timeObj.internalTaskStatus = 'Lunch';
        timeObj.isInternal = true;
        timeObj.startTask();
        // Check The task is Internal
        System.assertEquals(timeObj.isInternal, true);
        timeObj.showWeeklyTime();
    }
    // Testing for Project task
    @isTest 
    private static void projectTask(){
        //insert employee tesing data
        Employee__c employee = new Employee__c();
        employee.name = 'Test Employee';
        employee.IsActive__c = true;
        employee.Email__c = 'Employee@hotmail.com';
        insert employee;
        
             
        // insert project testing data 
        AcctSeed__Project__c project = new AcctSeed__Project__c();
        project.recordtypeid = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        project.name = 'Test Project';
        project.AcctSeed__Status__c = 'Active';
        project.AcctSeed__Template_Project__c = False;
        project.AcctSeed__Revenue_Recognition_Method__c = 'Fixed Price in Period Invoiced';
        insert project;
        
        Time_Tracking_Controller timeObj = new Time_Tracking_Controller();
        
        timeObj.isInternal = false;
        timeObj.startTask();
        
        timeObj.selectedEmp = '';
        timeObj.selectedTask = '';
        timeObj.isInternal = true;
        timeObj.internalTaskStatus = '';
        timeObj.startTask();
        
        // insert GL Account testing data
        AcctSeed__GL_Account__c glAccount = new AcctSeed__GL_Account__c();
        glAccount.AcctSeed__Type__c = 'Expense';
        glAccount.name = 'Testing Gl Account';
        glAccount.AcctSeed__Active__c = true;
        insert glAccount;
        
        timeObj.selectedProject = project.id; 
        // insert project task testing data
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(AcctSeed__Project__c = Project.id);
        task.AcctSeed__Labor_GL_Account__c = glAccount.id;
        task.name = 'Test task';
        task.Description__c = 'Tesing Description for task';
        task.AcctSeed__Status__c = 'Active';
        insert task; 
        
        timeObj.fetchTask();
        timeObj.selectedEmp = employee.id;
        timeObj.getTaskDesciption();
        timeObj.selectedTask = task.id;
        timeObj.getTaskDesciption();
        timeObj.startTask();
        
        // Stop task Testing 
        
        // insert task time entry for internal task
        Task_Time_Entry__c taskTimeEntry = new Task_Time_Entry__c();
        taskTimeEntry.Employee__c = employee.id;
        taskTimeEntry.Internal_Task__c = 'Break';  
        taskTimeEntry.Start_Time__c = dateTime.Now()-5000;
        taskTimeEntry.Status__c = 'In Progress';
        insert taskTimeEntry;   
        
        timeObj.stopTaskProcess();
        timeObj.stopTaskNext();
        timeObj.stoptask();
        
        
        taskTimeEntry.Notes__c = 'Testing note';
        update taskTimeEntry;
        timeObj.stopTaskProcess();
        timeObj.stopTaskNext();
        timeObj.stoptask();
        
        // Check for Task Note is filled when user stop task
        System.assertEquals(taskTimeEntry.Notes__c, 'Testing note');
        
        task.AcctSeed__Status__c = ' ';
        update task; 
        timeObj.stoptask();
        
        
    }
      

@isTest 
    private static void projectTask2(){
        //insert employee tesing data
        Employee__c employee = new Employee__c();
        employee.name = 'Test Employee';
        employee.IsActive__c = true;
        employee.Email__c = 'Employee@hotmail.com';
        insert employee;
        
             
        // insert project testing data 
        AcctSeed__Project__c project = new AcctSeed__Project__c();
        project.recordtypeid = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        project.name = 'Test Project';
        project.AcctSeed__Status__c = 'Active';
        project.AcctSeed__Template_Project__c = False;
        project.AcctSeed__Revenue_Recognition_Method__c = 'Fixed Price in Period Invoiced';
        insert project;
        
        Time_Tracking_Controller timeObj = new Time_Tracking_Controller();
        
        timeObj.isInternal = false;
        timeObj.startTask();
        
        timeObj.selectedEmp = '';
        timeObj.selectedTask = '';
        timeObj.isInternal = true;
        timeObj.internalTaskStatus = '';
        timeObj.startTask();
        
        // insert GL Account testing data
        AcctSeed__GL_Account__c glAccount = new AcctSeed__GL_Account__c();
        glAccount.AcctSeed__Type__c = 'Expense';
        glAccount.name = 'Testing Gl Account';
        glAccount.AcctSeed__Active__c = true;
        insert glAccount;
        
        timeObj.selectedProject = project.id; 
        // insert project task testing data
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(AcctSeed__Project__c = Project.id);
        task.AcctSeed__Labor_GL_Account__c = glAccount.id;
        task.name = 'Test task';
        task.Description__c = 'Tesing Description for task';
        task.AcctSeed__Status__c = 'Active';
        insert task; 
        
        timeObj.fetchTask();
        timeObj.selectedEmp = employee.id;
        timeObj.getTaskDesciption();
        timeObj.selectedTask = task.id;
        timeObj.getTaskDesciption();
        timeObj.startTask();
        
        // Stop task Testing 
        
        
        timeObj.stopTaskProcess();
        timeObj.stopTaskNext();
        timeObj.stoptask();
        
        // insert task time entry for project task
        Task_Time_Entry__c taskTimeEntry2 = new Task_Time_Entry__c();
        taskTimeEntry2.Employee__c = employee.id;
        taskTimeEntry2.Project_Task__c = task.id; 
        taskTimeEntry2.Start_Time__c = dateTime.Now();
        taskTimeEntry2.Status__c = 'In Progress';
        insert taskTimeEntry2;
        timeObj.stopTaskProcess();
        timeObj.stopTaskNext();
        timeObj.stoptask();
        
        
        timeObj.empTask = task;
        timeObj.tte = taskTimeEntry2;
        timeObj.stoptask();
        
        task.AcctSeed__Status__c = ' ';
        update task; 
        timeObj.stoptask();
        
        taskTimeEntry2.Stop_Task_Reason__c = 'testing';
        update taskTimeEntry2;
        timeObj.timeTrackingRecordContainer = taskTimeEntry2;
        timeObj.stopTaskNext();
       
    }     
}