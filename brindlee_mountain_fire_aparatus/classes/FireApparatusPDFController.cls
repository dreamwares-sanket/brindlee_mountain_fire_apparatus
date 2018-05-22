/*************************************************************************************************
     @Developer : Dreamwares 
     @Purpose : TO Create PDF View of Fire Apparatus 
     @Date  : 13 May, 2016
**************************************************************************************************/
public with sharing class FireApparatusPDFController {

    public List< Product2 > listAllProducts {get; set;}    //List of product records
    
    /** Aerials */
    /**
    public static Map<String, String> apparatusTypeMap = new Map<String, String>{
        'test1'=>'Towers and Platforms',
        'test2'=>'Used Aerials, Ladder Trucks and Quints',
        'test3'=>'Used Aerials, Ladder Trucks and Quints, Towers and Platforms'
    };
    */
    
    /** Ambulance & Command */
    /**
    public static Map<String, String> apparatusTypeMap = new Map<String, String>{
        'test1'=>'Ambulances and Transport Units',
        'test2'=>'Ambulances and Transport Units, Command Units',
        'test3'=>'Ambulances and Transport Units, Command Units, Loose and Miscellaneous Equipment',
        'test4'=>'Ambulances and Transport Units, Used Brush Trucks, Quick Attacks & Minis',
        'test5'=>'Ambulances and Transport Units, Used Brush Trucks, Quick Attacks & Minis, Vocational Trucks',
        'test6'=>'Command Units',
        'test7'=>'Used Rescue Trucks and Squads, Ambulances and Transport Units',
        'test8'=>'Used Rescue Trucks and Squads, Command Units'
    };
    */
    
    /** Brush, Mini, & Wildland */
    /**
    public static Map<String, String> apparatusTypeMap = new Map<String, String>{
        'test1'=>'Rescue Pumpers and Engines, Used Brush Trucks, Quick Attacks & Minis',
        'test2'=>'Used Brush Trucks, Quick Attacks & Minis'
    };
    */
    
    /** Engines */
    /**
    public static Map<String, String> apparatusTypeMap = new Map<String, String>{
        'test1'=>'Rescue Pumpers and Engines',
        'test2'=>'Used Pumpers and Engines',
        'test3'=>'Rescue Pumpers and Engines, Used Rescue Trucks and Squads',
        'test4'=>'Used Pumpers and Engines, Rescue Pumpers and Engines',
        'test5'=>'Used Pumpers and Engines, Rescue Pumpers and Engines, Used Rescue Trucks and Squads',
        'test6'=>'Used Pumpers and Engines, Rescue Pumpers and Engines, Used Rescue Trucks and Squads, Used Brush Trucks, Quick Attacks & Minis'
    };
    */   
    
    /** Other */
    
    public static Map<String, String> apparatusTypeMap = new Map<String, String>{
        'test1'=>'Command Units, Vocational Trucks',
        'test2'=>'European Style Units',
        'test3'=>'European Style Units, Pacific Rim Style Fire Apparatus',
        'test4'=>'Pacific Rim Style Fire Apparatus',
        'test5'=>'Rescue Pumpers and Engines, European Style Units',
        'test6'=>'Rescue Pumpers and Engines, Vocational Trucks',
        'test7'=>'Used Aerials, Ladder Trucks and Quints, Used ARFF and Airport Crash Trucks',
        'test8'=>'Used ARFF and Airport Crash Trucks',
        'test9'=>'Used ARFF and Airport Crash Trucks, European Style Units',
        'test10'=>'Used Brush Trucks, Quick Attacks & Minis, Loose and Miscellaneous Equipment',
        'test11'=>'Used Brush Trucks, Quick Attacks & Minis, Used ARFF and Airport Crash Trucks',
        'test12'=>'Used Brush Trucks, Quick Attacks & Minis, Used Tankers and Tenders',
        'test13'=>'Used Pumpers and Engines, Loose and Miscellaneous Equipment',
        'test14'=>'Used Pumpers and Engines, Rescue Pumpers and Engines, European Style Units',
        'test15'=>'Used Pumpers and Engines, Used Aerials, Ladder Trucks and Quints',
        'test16'=>'Used Pumpers and Engines, Used ARFF and Airport Crash Trucks',
        'test17'=>'Used Pumpers and Engines, Used Brush Trucks, Quick Attacks & Minis',
        'test18'=>'Used Pumpers and Engines, Used Brush Trucks, Quick Attacks & Minis, Used Tankers and Tenders',
        'test19'=>'Used Pumpers and Engines, Used Rescue Trucks and Squads, Ambulances and Transport Units',
        'test20'=>'Used Pumpers and Engines, Used Rescue Trucks and Squads, Used Brush Trucks, Quick Attacks & Minis',
        'test21'=>'Used Pumpers and Engines, Vocational Trucks',
        'test22'=>'Used Rescue Trucks and Squads, Ambulances and Transport Units, Command Units',
        'test23'=>'Used Rescue Trucks and Squads, Loose and Miscellaneous Equipment',
        'test24'=>'Used Rescue Trucks and Squads, Used Brush Trucks, Quick Attacks & Minis',
        'test25'=>'Used Rescue Trucks and Squads, Vocational Trucks',
        'test26'=>'Vocational Trucks',
        'test27'=>'Vocational Trucks, Demo and Refurb Units',
        'test28'=>'Vocational Trucks, Loose and Miscellaneous Equipment'
    };
      
    
    /** Rescues */
    /**
    public static Map<String, String> apparatusTypeMap = new Map<String, String>{
        'test1'=>'Used Rescue Trucks and Squads'
    };
    */
    
    /** Tankers */
    /**
    public static Map<String, String> apparatusTypeMap = new Map<String, String>{
        'test1'=>'Rescue Pumpers and Engines, Used Tankers and Tenders',
        'test2'=>'Used Pumpers and Engines, Used Tankers and Tenders',
        'test3'=>'Used Pumpers and Engines, Used Tankers and Tenders, Demo and Refurb Units',
        'test4'=>'Used Tankers and Tenders',
        'test5'=>'Used Tankers and Tenders, Demo and Refurb Units'
    };
       */
    
    
    
    // Constructor 
    public FireApparatusPDFController(){    
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
                           'WHERE Include_in_Newspaper_PDF_Layout__c = True '+
                           ( apparatusType.equals('All') ? getAllApparatusTypeMappings()+' ' : ' AND Apparatus_Type_Reports__c = \''+ apparatusTypeMap.get(apparatusType) +'\' ')+
                           'ORDER BY FT_Year_of_Truck__c DESC '+ 
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
    
    public static string getAllApparatusTypeMappings() {
        String criteria = 'AND (';
        for(String appType : apparatusTypeMap.keySet()) {
            criteria += ' Apparatus_Type_Reports__c = \'' +apparatusTypeMap.get(appType)+ '\' OR';
        }
        criteria = criteria.removeEnd('OR')+ ')';
        return criteria;
    }
}