/*
 *  @Name : OpportunityWrapper  
 *  @Purpose : wrapper class to store Opportunity related data 
 *  @Created Date : 
 *  @CreatedBy Dreamwares
 */
global class OpportunityWrapper implements Comparable {
    
    public Sobject sourceRecord{get; set;}
    public Decimal intPoints{get; set;}

    // This is the contructor method. When we create a new OpportunityWrapper object we pass a source that is set to Compare. 
    // set the initial points value to '0'
    public OpportunityWrapper(Sobject sourceRecord) {
        this.sourceRecord = sourceRecord;
        intPoints = 0;
    }  
    global Integer compareTo(Object compareTo) {

        OpportunityWrapper compareToEmp = (OpportunityWrapper)compareTo;

        if (intPoints == compareToEmp.intPoints) return 0;

        if (intPoints < compareToEmp.intPoints) return 1;

        return -1;       

    }
       
}