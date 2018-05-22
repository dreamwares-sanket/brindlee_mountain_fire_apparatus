/*
Name : Time_Tracking_Controller
Date : 3/2/2015
Author : 
Description : 
*/
public class Time_Tracking_Controller{
       
    public Map<String, AcctSeed__Project_Task__c> taskMap{get; set;}
    
    public List<SelectOption> selectEmployee{get;set;}
    public List<SelectOption> selectProject{get;set;}
    public List<SelectOption> selectTask{get;set;} 
    
    public String selectedEmp{get;set;}
    public Double totalSpendDuration{get; set;}
    public String selectedProject{get;set;}
    public String selectedTask{get;set;}
    public String taskDuration {get;set;}
    public String taskIds{get;set;}
    
    public Task_Time_Entry__c tte {get;set;}
    public AcctSeed__Project_Task__c empTask {get;set;}
    
    public String taskDescription {get;set;}
    public Boolean isInternal{get;set;}
    public Boolean isStartOfDay{get;set;}
    public Boolean isEndOfDay{get;set;}
    public String internalTaskStatus {get;set;}
    
    public List<SelectOption> intenalTask{get;set;}
    // Added : 6 Oct 2015
    public string taskLastTimeNote {get;set;}
    public string taskUnallocatedParts {get;set;}
    Map< Id, employee__c> mapEmployeeWeeklyHours;    //--added on 5th Apriil 2016 to show weeklytime when user selected
    
    public Employee__c selectedEmployee{get;set;}
    public Decimal selectedEmpHourlyHours{get;set;}
    public Task_Time_Entry__c timeTrackingRecordContainer {get;set;}
    
    
    // Constructor
    public Time_Tracking_Controller(){    
        totalSpendDuration = 0;    
        selectProject = new List<selectOption>();
        selectEmployee = new List<selectOption>();
        selectTask = new List<selectOption>();
        taskMap = new Map<String, AcctSeed__Project_Task__c>();
        taskIds = '';
        Set<Id> userIds = new Set<Id>();     
        timeTrackingRecordContainer = new Task_Time_Entry__c ();
        
        isStartOfDay = false;
        isEndOfDay = false;
        
        for(Task_Time_Entry__c tteObj : [SELECT id,Employee__c ,Project_Task__c FROM Task_Time_Entry__c WHERE status__c = 'In Progress']){
            userIds.add(tteObj.Employee__c);
        }
        // John Burdett - 4/10/2015 - added order by clause
        //-- 
        mapEmployeeWeeklyHours = new Map< Id, employee__c>();
        for(employee__c e : [select id,name, Task_Time_Entry_Hours_This_Week__c, Remaing_Hours_This_Week__c, Round_Off_Remaining_Hours_This_Week__c, Round_Off_Task_Time_Entry_This_Week__c  from employee__c WHERE IsActive__c = true AND id NOT IN :userIds ORDER BY Name ASC]){
            SelectEmployee.add(new SelectOption(e.id,e.name));
            mapEmployeeWeeklyHours.put(e.Id, e  );
            
        }
        system.debug('SelectEmployee::\n'+SelectEmployee);
        system.debug('mapEmployeeWeeklyHours::\n'+mapEmployeeWeeklyHours);
        // Filling Project List 
        // John Burdett - 4/10/2015 - only show projects that are active and not templates
        //for(AcctSeed__Project__c p : [select id,name from AcctSeed__Project__c]){
        for(AcctSeed__Project__c p : [select id,name from AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' AND AcctSeed__Template_Project__c = False ORDER BY Name ASC]){
            SelectProject.add(new SelectOption(p.id,p.name));
        }         
        // fetch internal task dynamically 
        intenalTask = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Task_Time_Entry__c.Internal_Task__c.getDescribe();
        List<Schema.PicklistEntry> internalTaskValues = fieldResult.getPicklistValues();   
        
        for(Schema.PicklistEntry f : internalTaskValues)
        {
            intenalTask.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
    } 
    // Function to fetch the Tasks calling from page
    public void fetchTask(){        
        Set<Id> taskAssignedIds = new Set<ID>();
        for(Task_Time_Entry__c tteObj : [SELECT id,Project_Task__c FROM Task_Time_Entry__c WHERE status__c = 'In Progress' AND Employee__c = :selectedEmp ])
            taskAssignedIds.add(tteObj.Project_Task__c); 
        
        selectTask.clear();
        taskMap.clear();
        taskIds = '';
        
        // John Burdett - 3/10/2014 - allow for all active tasks to show up; regardless if someone else is logging time against it
        //for(AcctSeed__Project_Task__c taskObj :[ SELECT id ,name FROM AcctSeed__Project_Task__c Where AcctSeed__Project__c = :selectedProject AND AcctSeed__Status__c = 'Active' AND id NOT IN :taskAssignedIds ]){
        //selectTask.add(new SelectOption(taskObj.id, taskObj.name));
        //}
        // John Burdett - 4/10/2015 - added order by clause       
        for(AcctSeed__Project_Task__c taskObj :[ SELECT id, name, AcctSeed__Budgeted_Hours__c, Total_Time_Logged_Hours__c FROM AcctSeed__Project_Task__c Where AcctSeed__Project__c = :selectedProject AND AcctSeed__Status__c = 'Active' ORDER BY Name ASC]){
            selectTask.add(new SelectOption(taskObj.id, taskObj.name));
            taskMap.put(taskObj.id, taskObj);
            taskIds = String.isNotBlank(taskIds) ? ','+taskObj.id : taskObj.id;
        }
        taskDescription = '';
        taskLastTimeNote = '';
        taskUnallocatedParts = '';
    }  
    // fetch stop task data
    public void fetchStopTaskData(){
        Set<Id> userIds = new Set<Id>();
        Set<Id> taskAssignedIds = new Set<ID>();
        for(Task_Time_Entry__c tteObj : [SELECT id,Employee__c ,Project_Task__c FROM Task_Time_Entry__c WHERE status__c = 'In Progress' ]){
            taskAssignedIds.add(tteObj.Project_Task__c);
            userIds.add(tteObj.Employee__c);
        }
        SelectEmployee.clear();
        System.debug('taskAssignedIds:::\n'+taskAssignedIds);
        System.debug('userIds:::\n'+userIds);
        mapEmployeeWeeklyHours = new Map< Id, employee__c>();
        for(employee__c e : [select id,name, Task_Time_Entry_Hours_This_Week__c , Remaing_Hours_This_Week__c, Round_Off_Remaining_Hours_This_Week__c, Round_Off_Task_Time_Entry_This_Week__c  from employee__c WHERE IsActive__c = true AND id IN :userIds ORDER BY Name ASC]){
            SelectEmployee.add(new SelectOption(e.id,e.name));
            mapEmployeeWeeklyHours.put(e.Id, e  );         
        }
        System.debug('SelectEmployee:::\n'+SelectEmployee);
        System.debug('mapEmployeeWeeklyHours:::\n'+mapEmployeeWeeklyHours);
        
        selectTask.clear();
        //taskMap.clear();
        taskMap = new Map<String, AcctSeed__Project_Task__c>();
        taskIds = '';
        
        for(AcctSeed__Project_Task__c taskObj :[SELECT id ,name, AcctSeed__Budgeted_Hours__c, Total_Time_Logged_Hours__c FROM AcctSeed__Project_Task__c Where AcctSeed__Project__c = :selectedProject AND AcctSeed__Status__c = 'Active' AND id IN :taskAssignedIds ORDER BY Name ASC]){
            selectTask.add(new SelectOption(taskObj.id, taskObj.name));
            taskMap.put(taskObj.id, taskObj);
            taskIds = String.isNotBlank(taskIds) ? ','+taskObj.id : taskObj.id;
        }
    }
    //Start Task Process
    public PageReference startTaskProcess(){
        return new pagereference('/apex/TimeTrackingStartTask');
    }
    
    //Stop Task Process
    public PageReference stopTaskProcess(){
        fetchStopTaskData();
        return new pageReference('/apex/TimeTrackingStopTask');
    }    
    
    //Start Task
    public PageReference startTask(){
        boolean selectEmpStatus = selectedEmp == null || selectedEmp.trim().length() == 0;
        boolean selectedTaskStaus = selectedTask == null || selectedTask.trim().length() == 0;
        boolean selectedProjectSatus = selectedProject == null || selectedProject.trim().length() == 0;
        boolean internalTask = string.isEmpty(internalTaskStatus);
        if(isInternal == false){
            if(selectEmpStatus || selectedTaskStaus || selectedProjectSatus){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'All Fields are required !'); 
                ApexPages.addMessage(myMsg);
                return null;    
            }
        }
        if((isInternal && selectEmpStatus) || (isInternal && internalTask)){
            if(selectEmpStatus){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Employee is required !'); 
                ApexPages.addMessage(myMsg);       
            }
            if(internalTask){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Internal Task is required !'); 
                ApexPages.addMessage(myMsg);
            }
            return null;
        }
        try{
            Task_Time_Entry__c taskentire = new Task_Time_Entry__c();
            taskentire.Employee__c = selectedEmp;
            taskentire.Start_Time__c = DateTime.Now();
            taskentire.Status__c = 'In Progress';
            
            if(isInternal){
                taskentire.Internal_Task__c = internalTaskStatus;
            }else{
                taskentire.Project_Task__c = selectedTask;
            }
            
            if(isStartOfDay){
                taskentire.Start_of_Day__c = true;
            }                        
            system.debug('$$$$$$ taskentire data ==> '+taskentire);
            insert taskentire;
            return new PageReference('/apex/TimeTrackingIndex').setRedirect(true);
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            System.debug('Exception ::::'+e.getStackTraceString());

            return null;
        }  
    }
    
    // Stop Task
    public PageReference stopTaskNext(){  
        if(selectedEmp == null || selectedEmp.trim().length() == 0 ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Select an Emplopyee'); 
            ApexPages.addMessage(myMsg);
            return null;    
        }
        if( timeTrackingRecordContainer.Stop_Task_Reason__c == '' || timeTrackingRecordContainer.Stop_Task_Reason__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Select stop task reason'); 
            ApexPages.addMessage(myMsg);
            return null;  
        }
        empTask = new  AcctSeed__Project_Task__c();
        tte = [SELECT id,Project_Task__c,Notes__c,Is_Internal_Task__c,Internal_Task__c,Project_Task__r.name,Project_Task__r.id, 
               Project_Task__r.AcctSeed__Project__r.name,Start_Time__c FROM Task_Time_Entry__c WHERE Employee__c = :selectedEmp AND 
               status__c = 'In Progress' LIMIT 1][0];  
        
        //--upsert case reason -- Date 04/08/2016
                
        tte.Stop_Task_Reason__c = timeTrackingRecordContainer.Stop_Task_Reason__c;
        if(isEndOfDay){
            tte.End_of_Day__c = true;
        }
        //timeTrackingRecordContainer.Id = tte.Id;
        upsert tte;
        
        if(tte.Is_Internal_Task__c == false){
            empTask = [select id,AcctSeed__Status__c from AcctSeed__Project_Task__c where id =: tte.Project_Task__c LIMIT 1][0];
        }  
        
        Datetime startime = tte.Start_Time__c;
        Datetime endtime = Datetime.now();
        Long Difference = endtime.getTime() -startime.getTime();
        taskDuration = getDurations(Difference/1000);
        
        return new PageReference('/apex/TimeTrackingStopTaskDetail');
    }
    public pagereference checkEmpId(){
        if(selectedEmp == null || selectedEmp.trim().length() == 0 ){
            return new pagereference('/apex/TimeTrackingIndex').setRedirect(true);
        }
        return null;
    }
    // Confirm Stop Task
    public PageReference  stoptask(){   
        
        
        if( tte != null ){
            boolean isNotesBlank = String.isBlank(tte.Notes__c);
            boolean isStatusBlank = String.isBlank(empTask.AcctSeed__Status__c) ;
            
            if((isStatusBlank && tte.Is_Internal_Task__c == false ) || (isNotesBlank && tte.Is_Internal_Task__c == false)){
                if(isNotesBlank){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Task Note is required !'); 
                    ApexPages.addMessage(myMsg);
                }     
                if(isStatusBlank){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Task Status is required !'); 
                    ApexPages.addMessage(myMsg);
                }
                return null;   
            }//else if(tte.Is_Internal_Task__c == true && isNotesBlank){
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Task Note is required !'); 
            //ApexPages.addMessage(myMsg);
            //return null;
            //}
            
            // John Burdett - 3/10/2014 - Don't mark task as completed as more people can log time against it.       
            // task.AcctSeed__Status__c = 'Completed';             
            try{    
                tte.status__c = 'Completed';
                tte.Stop_Time__c = DateTime.Now(); 
                if(isEndOfDay){
                    tte.End_of_Day__c = true;
                }  
                System.debug('tte::'+tte);
                
                update tte;      
                if(tte.Is_Internal_Task__c == false)    
                    update empTask;
                
                return new PageReference('/apex/TimeTrackingIndex').setRedirect(true); 
            }catch(exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
                System.debug('Exception ::::'+e.getStackTraceString());
                return null;
            }  
        } else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You can not update task note'));
            return null;
        }
    }
    // Cancel Task Page
    public PageReference cancelTask(){
        return new pagereference('/apex/TimeTrackingIndex').setRedirect(true);
    }
    //Durattion
    private String getDurations(Long seconds){
        String duration = '';
        if(seconds/(3600*24) > 0)
            duration += seconds/(3600*24) + ' Days ';
        if(math.mod((seconds/3600),24) >= 0)
            duration += math.mod((seconds/3600),24) + ' Hours ';
        duration += math.mod((seconds/60),60) + ' Minutes ';
        duration += math.mod(seconds,24) + ' Seconds ';
        return duration;
    }
    // fetch project task description calling from page
    public void getTaskDesciption(){
        if(String.isNotEmpty(selectedTask)){
            // Updated 6 Oct 2015 
            // Commented query below and used new query with new fields.            
            // taskDescription = [SELECT Description__c FROM AcctSeed__Project_Task__c WHERE id =: selectedTask].Description__c;
            
            // Added new fields in query : Last_Time_Entry_Note__c, Unallocated_Parts__c
            AcctSeed__Project_Task__c aspt = [SELECT Description__c, Last_Time_Entry_Note__c, Unallocated_Parts__c FROM AcctSeed__Project_Task__c WHERE id =: selectedTask];
            taskDescription = aspt.Description__c;
            taskLastTimeNote = aspt.Last_Time_Entry_Note__c; 
            taskUnallocatedParts = aspt.Unallocated_Parts__c;
        }else{
            taskDescription = null;
            taskLastTimeNote = null;
            taskUnallocatedParts = null;
        } 
    }
    
    //--
    public PageReference showWeeklyTime() {
        system.debug('selectedEmp ::'+selectedEmp);
        if( String.isNotEmpty(selectedEmp)){
        
            getCurrentEmployeeDuration();
            if(mapEmployeeWeeklyHours != null && mapEmployeeWeeklyHours.containsKey(selectedEmp)){
                selectedEmployee = mapEmployeeWeeklyHours.get(selectedEmp);                               
            }else{
                selectedEmployee = new Employee__c();
            }
        }else{
            selectedEmployee = new Employee__c();
        }
        return null;
    }
    
    private void getCurrentEmployeeDuration(){
    
        totalSpendDuration = 0;
        try{
            Task_Time_Entry__c timeEntry = [SELECT id, Start_Time__c 
                                            FROM Task_Time_Entry__c 
                                            WHERE Employee__c = :selectedEmp AND 
                                            status__c = 'In Progress' LIMIT 1];
            
            Datetime startime = timeEntry.Start_Time__c;
            Datetime endtime = DateTime.Now();                              
            Long currentDurationInSeconds = endtime.getTime() - startime.getTime(); 
            currentDurationInSeconds = currentDurationInSeconds/1000;
            Double day = 0;
            Double hrs = 0;
            Double totalDutation = 0.0;
            Integer minutes = 0;
            Long remainingTime = currentDurationInSeconds; 
            
            //days     
            if(currentDurationInSeconds /(3600*24) > 0){
                day = currentDurationInSeconds /(3600*24);
                hrs = day*24;
                remainingTime = math.mod((currentDurationInSeconds),3600*24);
            }
            //hrs
            if(math.mod((remainingTime /3600),24) >= 0){
                
                hrs = hrs + math.mod((remainingTime /3600),24);
                remainingTime = remainingTime -  math.mod((remainingTime /3600),24);
            }
            //minutes
            minutes = (Integer)math.mod((remainingTime /60),60);
            String strMinutes;
            if(String.valueOf(minutes).length() == 1){
                strMinutes = '00.0'+minutes; 
            }else{
                strMinutes = '00.'+minutes; 
            }
                        
            totalSpendDuration = hrs + Double.valueOf(strMinutes);
            
        }catch(Exception exp){
            System.debug('Exception :::'+exp.getMessage());
        }          
    }
}