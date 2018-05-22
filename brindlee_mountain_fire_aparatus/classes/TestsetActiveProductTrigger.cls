@isTest
public class TestsetActiveProductTrigger{
    public static TestMethod void demo(){
        List<Product2> lstProduct2=new List<Product2>();
        for(integer i=1;i<=4;i++){
            Product2 pro=new Product2();
            pro.name='Test'+i;
            pro.Stock_Number__c='1235'+i;
            pro.Family='Trucks';
            lstProduct2.add(pro);
        }
        insert lstProduct2;  
              
        lstProduct2[0].IsActive=true;
        update lstProduct2; 
        
        lstProduct2[0].IsActive=false;
        update lstProduct2;  
        
        system.assertEquals(lstProduct2.size(),4);    
    }
}