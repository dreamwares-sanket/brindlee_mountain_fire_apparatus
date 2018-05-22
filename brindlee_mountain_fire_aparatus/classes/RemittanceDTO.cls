/**
 * @Purpose      : Wrapper class for RemittanceDTO
 * @Author       : Dreamwares 
 * @Created Date : 02/05/2018
 */ 
public class RemittanceDTO {
    public AcctSeed__Account_Payable__c accountPayable  {get;  set;}
    public Integer amount {get;  set;}
    
    //Constructor
    public RemittanceDTO(){
    	this.accountPayable = new AcctSeed__Account_Payable__c();    
    }

}