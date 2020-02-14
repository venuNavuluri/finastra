public class CSP_Welcome_Controller{

    Id userid = Userinfo.getUserId();
    User u1 = [Select id, contactid, profileid from User where id =  :userid];  //'005200000018bNM' ]; 
    
    Contact cont = new Contact();
    
    public List<String> getRecords()
    {
        
    	System.debug('User id is' + userid);
    
    	List<String> lvalue = new List<String>();
    	try{
    		cont = [Select Account.Site, Account.Name, AccountId From Contact where Id = :u1.contactid];
    	}catch(Exception e){
    		//nothing
    	} 
    	system.debug('JRB........ Cont:'+cont);
    
    	if((!(cont.Account.name == null)) && (!(cont.Account.name == '')))
    	{
    		lvalue.add(cont.Account.name);
    	}
    
    	if((!(cont.Account.site == null)) && (!(cont.Account.site == '')))
    	{
    		lvalue.add(cont.Account.site);
    	}
    
    	return lvalue;
    }
    
    public pageReference profile()
    {
    	System.debug('profileidHello' + u1.profileid);
    	PageReference p1 = new PageReference('/_ui/core/portal/PortalUserMyProfilePage/d');
    	p1.setRedirect(true);
    	return p1;
    }
    
    public pageReference logout()
    {
    	PageReference p1 = new PageReference('/secur/logout.jsp');
    	p1.setRedirect(true);
    	return p1;
    }

    public PageReference Security() {
        //PageReference page = new PageReference('/?ec=302&startURL=%2Fservlet%2Fservlet.Integration%3Flid%3D01N200000009A8J%26ic%3D1');
        PageReference page = new PageReference(Label.Security_Statement_URL);
        page.setRedirect(true);
        return page;
    }
}