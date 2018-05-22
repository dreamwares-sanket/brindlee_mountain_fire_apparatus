/*
    
*/
public with sharing class ViewAllActivityController{
    private String id;
    private String objectType;
    public List<ActivityHistory> activityHistories{get;set;}
    public SummaryModal summary{get;set;}
    public ViewAllActivityController(){
        activityHistories = new List<ActivityHistory>();
        summary = new SummaryModal();
        id = ApexPages.currentPage().getParameters().get('id');
        objectType = ApexPages.currentPage().getParameters().get('object');
        
        if(id != null && (id.trim().length() == 15 || id.trim().length() == 18) &&
            objectType != null && objectType.trim().length()>0)
        {
             fetchActivityHistories();   
        }
    }
    private void fetchActivityHistories(){
        if(objectType.trim().equalsIgnoreCase('Account') == true){
            loadAccountSummary();
        }
        else if(objectType.trim().equalsIgnoreCase('Contact') == true){
            loadContactSummary();
        }
    }
    private void loadAccountSummary(){
        for(Account acc: [select id,Name,
                                (Select Id, AccountId, WhoId, WhatId, Subject, IsTask, ActivityDate, OwnerId, Status, 
                                ActivityType, Description, CreatedDate, CreatedById, LastModifiedDate, Who.Name, Owner.Name 
                                From ActivityHistories order by ActivityDate DESC, LastModifiedDate DESC limit 499) 
                            from Account where id=:id])
        {
            summary.accountName = acc.Name;
            summary.accountId = acc.id;
            if(acc.ActivityHistories != null && acc.ActivityHistories.size()>0)
                activityHistories = acc.ActivityHistories;
        }    
    }
    private void loadContactSummary(){
        for(Contact con : [select id,Name,AccountId,Account.Name,
                                (Select Id, AccountId, WhoId, WhatId, Subject, IsTask, ActivityDate, OwnerId, Status, 
                                ActivityType, Description, CreatedDate, CreatedById, LastModifiedDate, Who.Name, Owner.Name 
                                From ActivityHistories order by ActivityDate DESC, LastModifiedDate DESC limit 499) 
                            from Contact where id=:id])
        {
            summary.accountName = con.AccountId != null ? con.Account.Name : null;
            summary.accountId = con.AccountId != null ? con.AccountId : null;
            summary.name = con.Name;
            summary.contactId = con.id;
            if(con.ActivityHistories != null && con.ActivityHistories.size()>0)
                activityHistories = con.ActivityHistories;
        }  
    }
    public class SummaryModal{
        public String accountName{get;set;}
        public String accountId{get;set;}
        public String contactFirstName{get;set;}
        public String contactLastName{get;set;}
        public String name{get;set;}
        public String contactId{get;set;}
    }
}