public  virtual class Response{
    
    /**
    *@Description   : Wrapper for Response
    */
    public Boolean Success;
    public Object Data;
    public String Message;
    public Object Errors;
    List<String> errorsStr;

    
     public Response(Boolean Success , Object Data , String Message){
        this.Success = Success;
        this.Data = Data;
        this.Message = Message;

    }
    public Response(Boolean Success , Object Data , String Message , Object Errors){
        this(Success , Data , Message);
        this.Errors = Errors;
    }
    
    public Response(Object data, String message, Boolean success, List<String> errors){
        this.data = data;
        this.message = message;
        this.success = success;
        this.errorsStr = errors;
    }
}