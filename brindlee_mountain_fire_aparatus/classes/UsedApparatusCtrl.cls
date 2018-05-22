/**
 * @created date : 16 Dec, 2015
 * @purpose      : To show used apparatus on the page. 
 */
public class UsedApparatusCtrl {
    
    //Setting standard set controller
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                try{
                    setCon = new ApexPages.StandardSetController(
                        Database.getQueryLocator([SELECT VF_Main_Title__c, Truck_Public_URL__c 
                                                  FROM Product2 
                                                  WHERE VF_Main_Title__c != NULL 
                                                  AND Post_To_Firerescue1_com__c = TRUE
                                                  LIMIT 50]));
                    setCon.setPagesize(10);                    
                }catch(Exception e){
                    system.debug('Exception while getting the Product records : ' + e.getMessage());
                }
            }
            return setCon;
        }
        set;
    }

    // Initialize setCon and return a list of records
    public List<Product2> getProducts() {
        return (List<Product2>) setCon.getRecords();
    }
    
}