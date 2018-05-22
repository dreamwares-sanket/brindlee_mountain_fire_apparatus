/*
        Name            :    CreateProjectTaskhelper
        Author          :    
        Date            :    
        Description     :    
*/
public class CreateProjectTaskhelper{
    public Static boolean StopCreateProjectTask = false;
    public static void Opp(Set<Id> oppIds, Set<Id> ProIds){
        Map<Id,List<Contract_Item__c>> oppMap = new Map<Id,List<Contract_Item__c>>();
        Map<String,String> MapOppToPro = new Map<String,String>();
        List<AcctSeed__Project__c> listProject = new List<AcctSeed__Project__c>();
        for(Opportunity  op: [select id,(select id,Name,Description__c,Opportunity__c from Contract_Items__r) from Opportunity  where id IN: oppIds]){
            oppMap.put(op.id,op.Contract_Items__r);
        }
       
        for(AcctSeed__Project__c Ap:[select id,Name,AcctSeed__Opportunity__c,Sync__c from AcctSeed__Project__c where id in: ProIds]){
            if(Ap.Sync__c == false){
                MapOppToPro.put(Ap.AcctSeed__Opportunity__c,Ap.Id);
                Ap.Sync__c = true;
                listProject.add(Ap);
            }
        }
        
        Map<String,String> ProTaskMap = new Map<String,String>();
        for(AcctSeed__Project_Task__c task:[select id,Contract_Item__c,AcctSeed__Project__c from AcctSeed__Project_Task__c where AcctSeed__Project__c in: ProIds ]){
            ProTaskMap.put(task.Contract_Item__c,task.AcctSeed__Project__c);
        }
         
        List<AcctSeed__Project_Task__c> lstProTasks = new List<AcctSeed__Project_Task__c>();
        for(Contract_Item__c conItem :[select id,Name,Description__c,Opportunity__c from Contract_Item__c where Opportunity__c in: MapOppToPro.keySet()]){
            if(ProTaskMap.containsKey(conItem.id)){ 
                if(ProTaskMap.get(conItem.id)!= MapOppToPro.get(conItem.Opportunity__c)){
                    AcctSeed__Project_Task__c pt = new AcctSeed__Project_Task__c();
                    pt.AcctSeed__Project__c = MapOppToPro.get(conItem.Opportunity__c);
                    pt.Name = conItem.Name;
                    pt.Description__c = conItem.Description__c;
                    pt.Contract_Item__c = conItem.id;
                    lstProTasks.add(pt);
                    System.debug('----- in the loop');
                }
            }else{
                 AcctSeed__Project_Task__c pt = new AcctSeed__Project_Task__c();
                pt.AcctSeed__Project__c = MapOppToPro.get(conItem.Opportunity__c);
                pt.Name = conItem.Name;
                pt.Description__c = conItem.Description__c;
                pt.Contract_Item__c = conItem.id;
                lstProTasks.add(pt);
                System.debug('----- in the loop else');
            }
        }
        CreateProjectTaskhelper.StopCreateProjectTask = true;
        insert lstProTasks;
        System.debug('--------Pro Task'+lstProTasks.size()+'    =>'+ lstProTasks);
        CreateProjectTaskhelper.StopCreateProjectTask = false;
        
        if(listProject.size()>0)
            update listProject;
            
    }
}