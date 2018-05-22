/*
 * This is a controller class for vf page CommentGeneration 
 * @created 2016/07/27
 * @author Dreamwares (Vidula)
 */
public with sharing class CommentGenerationController {
    public Comment_Generation__c comment           { get; set; }
    public List<SelectOption> listProductFields    { get; set; }
    Map<String,String> mapFields                   { get; set; }
    
    //--Controller
    public CommentGenerationController(ApexPages.StandardController controller) {
        comment = new Comment_Generation__c ();
        comment = (Comment_Generation__c )controller.getRecord();
        if( comment.Id != null ){
            try{
                comment = [ SELECT Id, Name, Include__c, Trigger_Word_Phrase__c, Field_API_Name__c, Comment__c, Link__c, Condition__c 
                           FROM Comment_Generation__c  
                           WHERE ID =: comment.Id];
            }catch(Exception ex){
                System.debug('Exception ::'+ex);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Id.'));
            }
        }
        System.debug('Comment Record ::'+comment);
        fetchProductFields();
    }
    
    //--fetch product fields    
    void fetchProductFields(){
        listProductFields = new List<SelectOption>();
        mapFields = new Map<String,String>();
        
        SObjectType objToken = Schema.getGlobalDescribe().get('Product2');
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();
        for(String field: fields.keySet()) {
            SObjectField fieldToken = fields.get(field);
            DescribeFieldResult selectedField = fieldToken.getDescribe();
            
            if( selectedField.isAccessible()){
                listProductFields.add(new SelectOption(selectedField.getName(), selectedField.getLabel())); 
                mapFields.put(selectedField.getName(), selectedField.getLabel());       
            }
        }
        system.debug(listProductFields);
    }
    
    //--save Comment record
    public PageReference saveComment(){
        PageReference commentPage = saveAndRedirect(false);
        commentPage.setRedirect(true);
        return commentPage;
    }
    //-- execute on click of save and new button
    public PageReference saveAndNewComment(){
        PageReference editCommentPage = saveAndRedirect(true); 
        editCommentPage.setRedirect(true);
        return editCommentPage;
    }
    //--generic method called from save and save and new button action
    public PageReference saveAndRedirect( Boolean isSaveAndNew ){
        PageReference newPage;
        if(!mapFields.isEmpty()){
            if(mapFields.containsKey(comment.Field_API_Name__c)){
                comment.Field_Label__c = mapFields.get(comment.Field_API_Name__c);
            }
        }        
        try{
            upsert comment;
            if( isSaveAndNew){
                
                return new PageReference('/apex/CommentGeneration' );
            }else{
                return new PageReference('/'+comment.Id );
            }
        }catch( Exception ex){
            System.debug('Exception while upserting record::'+ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            return null;
        }
    }
}