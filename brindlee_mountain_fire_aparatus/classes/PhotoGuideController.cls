/**
    @Purpose :- Fetches images from custom Setting  

*/

public class PhotoGuideController{

    public List<RescuePictures__c> listOfRescuePictures{get;set;}
    public List<PumperPictures__c> listOfPumperPictures{get;set;}
    public List<AerialPictures__c> listOfAerialPictures{get;set;}

    /*
        Constructor
    */
    public PhotoGuideController(){
    
        listOfRescuePictures = new List<RescuePictures__c>();
        listOfPumperPictures = new List<PumperPictures__c>();
        listOfAerialPictures = new List<AerialPictures__c>();
        
        //fetches Rescue Images
        try{
            listOfRescuePictures = [ SELECT Id, Name, Image_URL__c, Image_Description__c 
                                     FROM RescuePictures__c 
                                     ORDER BY Display_Order__c ASC 
                                   ];
        }
        catch( Exception e ){
            System.debug('Exception Occured while fetching Rescue pictures'+e.getMessage());
        }
        
        //fetches Pumper Images
        try{
            listOfPumperPictures = [ SELECT Id, Name, Image_URL__c, Image_Description__c 
                                     FROM PumperPictures__c 
                                     ORDER BY Display_Order__c ASC 
                                   ];
        }
        catch( Exception e ){
            System.debug('Exception Occured while fetching Pumper pictures'+e.getMessage());
        }
        
        //fetches Aerial Images
        try{
            listOfAerialPictures = [ SELECT Id, Image_URL__c, Image_Description__c, Name 
                                     FROM AerialPictures__c
                                     ORDER BY Display_Order__c ASC 
                                   ];
        }
        catch( Exception e ){
            System.debug('Exception Occured while fetching Aerial pictures'+e.getMessage());
        }
    }
}