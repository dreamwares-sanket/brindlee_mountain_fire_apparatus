/**************************************************************************************************************
         * @description - Controller class for VF page FireApparatusPDFController used for PDF creation                
         * @dateCreated - 14/05/2016
         * @createdBy   - Dreamwares
 ***************************************************************************************************************/
@isTest
public class FireApparatusPDFControllerTest {
    
    @testSetup
    public static void setupRecords(){
        Fire_Truck__c fireTruck = new Fire_Truck__c();
        fireTruck.Main_Title__c = 'new Truck';
        fireTruck.Year_of_Truck__c = 2013;
        fireTruck.Mileage__c = 8000;
        fireTruck.Pump_GPM__c = '1750';
        fireTruck.Fire_Body_Manufacturer__c = 'E-One';
        fireTruck.Chassis_Manufacturer__c = '3D';
        insert fireTruck;
        
        Account testAcc = new Account(name='test Account');
        insert testAcc;
        
        Account customerAcc = new Account(name='Customer Account');
        insert customerAcc;
        
        Contact testCon = new Contact();
        testCon.lastName = 'Test Contact';
        testCon.pi__url__c ='https://pi.pardot.com/prospect/read?id=13322';
        testCon.AccountId = testAcc.Id;
        insert testCon;
        
        List< Product2 > listProducts = new List<Product2>();
        Product2 product;
        for( integer i=0;i<10;i++ ){
            product = new Product2();
            product.Fire_Truck__c = fireTruck.Id;
            product.Seller_Contact__c = testCon.Id;
            product.Sold_to_Customer_Account__c = customerAcc.Id;
            if( i<5 ){  //set 1
                
                product.Website_Price__c = '$40,000';               
                product.apparatusType__c = 'Used ARFF and Airport Crash Trucks';
                product.Warranty_Terms__c = 'test';     // Warranty for trucks
                
            }
            else if( i>=5 ){    // set 2
                product.Website_Price__c = '$120,000';               
                product.apparatusType__c = 'Vocational Trucks';               
            }
            product.IsActive = True;
            product.Post_To_Website__c = True;
            product.Stock_Number__c = ''+i;
            product.Name = 'Truck no.'+i;
            product.status__c = 'Available';
            listProducts.add(product);
        }
        insert listProducts;
        //System.debug('listProducts1:'+listProducts);
        listProducts = new List<product2>([SELECT VF_Sort_By_Tank_Size__c FROM Product2]);
        //System.debug('listProducts2:'+listProducts);
        
        //List< Meta_Data_for_Categories__c > listMetaData = new List< Meta_Data_for_Categories__c >();
        Meta_Data_for_Categories__c objMetaData = new Meta_Data_for_Categories__c();
        objMetaData.Category__c = 'Used ARFF and Airport Crash Trucks';
        objMetaData.Description__c = 'Used ARFF and Airport Crash Trucks';
        objMetaData.Title__c = 'Used ARFF and Airport Crash Trucks';
        objMetaData.Name = '1';
        insert objMetaData;
    }
    
    @isTest
    public static void controllerTestFirstSet(){       
        FireApparatusPDFController trucksDetails = new FireApparatusPDFController();
    }
}