/*
 * @purpose: AutoCOmplete text box to be used on New Expense VF page
 * @Created Date: 21 December, 2016
 */
public class InputLookupController{
        
    @RemoteAction
    public static List<sObject> searchRecord(String searchTerm, 
                                             String objectName, 
                                             String objectFieldsForCriteria, 
                                             String fieldForOptionDisplay, 
                                             String fieldForOptionValue,
                                             String extendedCriteria) {
    
        System.debug(searchTerm);        
        List<sObject> lstSelectedRecords = new List<sObject>();
        
        if(String.isNotBlank(searchTerm) && String.isNotBlank(objectFieldsForCriteria)) {
            String strCriteria = '(';
            Integer fieldCount = 0;
            for(String strField : objectFieldsForCriteria.split(',')) {
                if((++fieldCount) > 1) strCriteria += ' OR ';
                strCriteria += strField +' LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
            }
            strCriteria += ')' + ((String.isBlank(extendedCriteria)) ? '' : (' AND '+extendedCriteria));
            lstSelectedRecords = Database.query('SELECT '+fieldForOptionValue+', '+fieldForOptionDisplay+' FROM ' + objectName + ' WHERE '+ strCriteria +' LIMIT 10');
        } else
            lstSelectedRecords = Database.query('SELECT '+fieldForOptionValue+', '+fieldForOptionDisplay+' FROM ' + objectName + ' ORDER LIMIT 10');
        
        return lstSelectedRecords;
    }
}