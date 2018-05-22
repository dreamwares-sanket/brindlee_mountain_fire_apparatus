public class dealerTrucksPDFController {
    
    private Dealer_FTF_Account__c dealerAcc;
    private List<String> productIdList;
    public List<Product2> truckList {
        get {
            if( truckList == null ) {
                if( productIdList.isEmpty() ) {
                    truckList = new List<Product2>();
                } else {
                    truckList = (List<Product2>) Database.query( constructQuery() );
                }                
            }
            return truckList;
        }
        set;
    }
    
    public dealerTrucksPDFController() {
        try {
            String accountId = Apexpages.Currentpage().getParameters().get('id');
            dealerAcc = [SELECT Id, Dealer_Truck_Details__c, 
                                (SELECT Truck__c FROM Dealer_FTF_Trucks__r) 
                         FROM Dealer_FTF_Account__c 
                         WHERE Id = :accountId];            
            productIdList = new List<String>();
            for( Dealer_FTF_Truck__c FTF_Truck : dealerAcc.Dealer_FTF_Trucks__r ) {
                productIdList.add( FTF_Truck.Truck__c );
            }
            if( String.isNotEmpty(dealerAcc.Dealer_Truck_Details__c) ) {
                productIdList.addAll( dealerAcc.Dealer_Truck_Details__c.split(',') );
            }
        } catch(Exception exp) {
            System.debug('Exception while fetch Dealer Account : ' + exp.getMessage());
        }
    }
    
    private string constructQuery() {
        String query = 'SELECT Id{0} FROM Product2 WHERE Id IN :productIdList';
        String otherFields = '';
        for(Schema.FieldSetMember field : this.getFields()) {
            otherFields += ', '+ field.getFieldPath();
        }
        query = String.format(query, new List<String>{otherFields});
        return query;
    }
    
    private List<Schema.FieldSetMember> getFields() {
        return SObjectType.Product2.FieldSets.Dealer_Notifier_Truck_Fields.getFields();
    }


}