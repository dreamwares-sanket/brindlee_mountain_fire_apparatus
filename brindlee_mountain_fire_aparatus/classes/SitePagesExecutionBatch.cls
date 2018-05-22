public class SitePagesExecutionBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    public List<String> pageUrlList = new List<String>();
    public List<CompetitorSite__c> truckList = new List<CompetitorSite__c>();
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Id, Batch_Class__c, Active__c FROM CompetitorSite__c WHERE Active__c = true AND ID =\'a58290000003n1I\' LIMIT 5000';
        System.debug('query ::::'+query);
        return Database.getQueryLocator(query);
    } 
    
    public void execute(Database.BatchableContext bc, List<CompetitorSite__c> siteList){
        
        for(CompetitorSite__c site :siteList){
        
            Type t = Type.forName(site.Batch_Class__c);
            System.debug('ite instance :::::'+t);
            //Database.executeBatch(new t.newInstance();

            //Database.executeBatch(t.newInstance(site.Site__c, site.Id));
             //Database.executeBatch(new ExternalTruckDetailViewLinkBatch(pageUrlList, siteId));    
        }    
    }
    
    public void finish(Database.BatchableContext BC){
       
    }
}