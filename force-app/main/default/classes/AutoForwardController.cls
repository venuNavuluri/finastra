public class AutoForwardController {
    public PageReference ForwardOn(){
        //if(ApexPages.currentPage().getParameters().get('CF00NR0000000XiCd_lkid') != null){
         if(ApexPages.currentPage().getParameters().get('CF00N200000029p5q_lkid') != null){

            PageReference p = Page.New_Account_Supported;
            //p.getParameters().put('CF00NR0000000XiCd_lkid', ApexPages.currentPage().getParameters().get('CF00NR0000000XiCd_lkid'));
            p.getParameters().put('CF00N200000029p5q_lkid', ApexPages.currentPage().getParameters().get('CF00N200000029p5q_lkid'));
            return p;
        }else{
            return null;
        }
    }

}