/**
 *  className  BrindleeMountainHeaderController 
 *  createdBy  Amol[Dreamwares]
 *  purpose    Display contact info of pages
 */
public class BrindleeMountainHeaderController {

    public CompanyContactInformation__c companyContactInfo{ 
        get{
            return CompanyContactInformation__c.getValues('BMFA Contact Information');
        }
        set; 
    }    
}