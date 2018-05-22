/*
 * @description - Test class for functionality testing and code coverage of WebsiteUrlRewriter
 * @createdDate - 18-09-2015
 * @CreatedBy   - Dreamwares
 */
@isTest
public class WebsiteUrlRewriterTest {
	
    @testSetup
    public static void setuprecords(){
        //create and insert products
        List< Product2 > listProducts = new List< Product2 >();
        Product2 objProduct;
        for( integer i=0 ;i < 5 ; i++ ){
            objProduct = new Product2();
            objProduct.Name = 'Truck no. '+ i;
            objProduct.Stock_Number__c = 'STK#' + i;
            objProduct.Post_To_Website__c = True;
            objProduct.apparatusType__c = 'Used Pumper and Engines';
            // Removed on 11/14/2015 as Main Title now resides in Fire Truck
            //objProduct.Main_Title__c = 'brindlee fire truck';
            listProducts.add(objProduct);
        }
        insert listProducts;
    }
    
    @isTest
    public static void testUrlGeneration(){
        List< PageReference > listPageUrls, listNewPageRefs;
		listPageUrls = new List< PageReference >();
        PageReference pageRefTruckDetail;
        
        for( Product2 loopVarProduct : [Select Id FROM Product2] ){
            pageRefTruckDetail = new PageReference('/AvailableTruckDetailView?id='+loopVarProduct.Id);
            listPageUrls.add( pageRefTruckDetail );
        }
        
        WebsiteUrlRewriter objURLRewriter = new WebsiteUrlRewriter();
        listNewPageRefs =  objURLRewriter.generateUrlFor(listPageUrls);
        System.assertNotEquals(null, listNewPageRefs);
    }
    
    @isTest
    public static void testMapRequestedUrl(){
        Product2 objProduct = [SELECT Id, Stock_Number__c, VF_Main_Title__c FROM PRoduct2 LIMIT 1];
        PageReference actualPageUrl, pageRef;
        pageRef = new PageReference('/AvailableTruck/'+
                                                  	objProduct.Stock_Number__c + '/'+
                                                  	  objProduct.VF_Main_Title__c);
        WebsiteUrlRewriter objURLRewriter = new WebsiteUrlRewriter();
        actualPageUrl = objURLRewriter.mapRequestUrl( pageRef );
        
        System.assertEquals('/AvailableTruckDetailView?id='+objProduct.Id, actualPageUrl.getUrl() );
        
    }
    
    @isTest
    public static void testRedirectToSearchPage(){
        PageReference pageRef, actualPageUrl;
        
        pageRef = new PageReference('/AvailableTruck/09999/Available-Truck');
        WebsiteUrlRewriter objURLRewriter = new WebsiteUrlRewriter();
        actualPageUrl = objURLRewriter.mapRequestUrl( pageRef );
        
        System.assertEquals('/SearchResults?stockNo=09999', actualPageUrl.getUrl() );
               
    }
    
    @isTest
    public static void testAvailableTrucksPage(){
        Pagereference pageRef = new PageReference('/AvailableTrucks?category=Vocational-Trucks');
        WebsiteUrlRewriter objURLRewriter = new WebsiteUrlRewriter();
        List<Pagereference> listPageReference = objURLRewriter.generateUrlFor( new List< PageReference >{ pageRef } );
        
        PageReference newPage = objURLRewriter.mapRequestUrl( listPageReference[0] );
    }
    
    @istest
    public static void testURLHyphenation(){
        PageReference pageRef = Page.Selling_your_Used_Fire_Truck;
        WebsiteUrlRewriter objURLRewriter = new WebsiteUrlRewriter();
        List<Pagereference> listPageReference = objURLRewriter.generateUrlFor( new List< PageReference >{ pageRef } );
        System.assert(listPageReference[0].getURL().containsIgnoreCase('selling_your_used_fire_truck'));
        PageReference newPage = objURLRewriter.mapRequestUrl( listPageReference[0] );
    }
    
    @isTest
    public static void testAvailableLooseEquipment(){
        Product2 product = new Product2( Name='Test', Equipment_Price__c=1200, Loose_Equipment_Type__c='Rescue Tools',
                                         Equipment_Status__c='Active', Description='Test', RecordTypeId=Utilities.getProductRecordTypeId('Loose Equipment') );
        insert product;
        
        WebsiteUrlRewriter objURLRewriter = new WebsiteUrlRewriter();
        List<PageReference> listResult = objURLRewriter.generateUrlFor( new List<PageReference>{ new pageReference('/AvailableLooseEquipment?id='+product.Id) } );
        
        product = [ SELECT Equipment_Number__c FROM Product2 WHERE id=:product.Id ];
        
        PageReference looseQEquipmentDetPageRef = objURLRewriter.mapRequestUrl(new PageReference('/AvailableLooseEquipment/'+product.Equipment_Number__c+'/'));
        System.assertEquals('/AvailableLooseEquipment?id='+product.Id, looseQEquipmentDetPageRef.getUrl());
        
        objURLRewriter.mapRequestUrl(new PageReference('/AvailableLooseEquipment/null/')); // dummy product
        
        objURLRewriter.mapRequestUrl(new PageReference('/AvailableLooseEquipments/'));
        objURLRewriter.mapRequestUrl(new PageReference('/Buying-a-Used-Fire-Truck'));
    }
}