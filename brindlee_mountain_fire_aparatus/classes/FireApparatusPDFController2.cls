/*************************************************************************************************
     @Developer : Dreamwares 
     @Purpose : TO Create PDF View of Fire Apparatus 
     @Date  : 13 May, 2016
**************************************************************************************************/
public with sharing class FireApparatusPDFController2 {

    public List< Product2 > listAllProducts {get; set;}    //List of product records
    public static Map<String, String> apparatusTypeMap = new Map<String, String>{
        'test1'=>'Towers and Platforms',
        'test2'=>'Used Aerials, Ladder Trucks and Quints',
        'test3'=>'Used Aerials, Ladder Trucks and Quints, Towers and Platforms'
    };
    
    
    // Constructor 
    public FireApparatusPDFController2 (){    
       this.listAllProducts =  getProductDetails();
    }
    
    /**
        @Purpose : To get Prodct records 
    */
    Public static List< Product2 > getProductDetails(){
        String apparatusType = '';
        String limitSOQL = '', offSetSOQL = '';
        try {
            apparatusType = apexpages.currentpage().getparameters().get('ApparatusType');
            apparatusType = ((apparatusType == NULL || String.isBlank(apparatusType)) ? 'All' : apparatusType);
            apparatusType = EncodingUtil.urlDecode(apparatusType,'UTF-8');
            limitSOQL = apexpages.currentpage().getparameters().get('Limit');
            limitSOQL = ( (limitSOQL == null) || String.isBlank(limitSOQL) ? '64' : limitSOQL);
            offSetSOQL = apexpages.currentpage().getparameters().get('Offset');
            offSetSOQL = ( (offSetSOQL == null) || String.isBlank(offSetSOQL) ? '0' : offSetSOQL);
        } catch(Exception exp) {
            System.debug('Exception while getparameters() : ' + exp.getMessage());
        }
        
        List<Product2> listofProducts = new  List<Product2>();
        try{
            String query = 'SELECT Id, VF_Main_Title__c,Stock_Number__c, VF_Additional_Pricing_Text__c,'+
                           '       Description, VF_Sort_By_Budget_Range__c,VF_Website_Price__c,FT_Year_of_Truck__c,'+
                           '       (SELECT Id, Amazon_S3_Image_URL__c '+
                           '        FROM Cloud_Documents__r '+
                           '        WHERE Main_Thumbnail__c = TRUE AND'+ 
                           '        Show_Online__c = TRUE LIMIT 1) '+
                           'FROM Product2 '+
                           'WHERE Include_in_Newspaper_PDF_Layout__c = True AND '+
                           '      Post_to_Website__c = True '+
                           ( apparatusType.equals('All') ? '' : ' AND Apparatus_Type_Reports__c = \''+ apparatusTypeMap.get(apparatusType) +'\' ')+
                           'ORDER BY FT_Year_of_Truck__c '+ 
                           'LIMIT '+ limitSOQL +' '+
                           'OFFSET '+ offSetSOQL;
            system.debug('query : ' + query);
            listofProducts = Database.query(query);
        } catch(Exception e) {
            System.debug('The following exception has occurred  ' + e.getMessage() +
                         'At line number :' + e.getLineNumber() + ' Error ' + e.getStackTraceString()); 
        }             
        return listofProducts;
    }
}