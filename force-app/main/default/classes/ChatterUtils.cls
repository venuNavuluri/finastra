public class ChatterUtils
{
	public class chatterFeedItem 
	{
		public Id parentId;
		public String feedType;
		public String feedTitle;
		public String feedBody;
		public String feedURL;
	}
	
    public static void postFeedItems(List<chatterFeedItem> fiPosts)
	{
		String defaultPostType = 'TextPost';
		List<FeedItem> fItems = new List<FeedItem>();
		for(chatterFeedItem post : fiPosts)
		{
			if(post.parentId != null && 
			   post.feedBody != '' && post.feedBody != null && 
			   post.feedType != '' && post.feedType != null &&
			   !(post.feedType == 'LinkPost' && (post.feedURL == '' || post.feedURL == null))){
				FeedItem fItem = new FeedItem();
				if(post.feedType == 'LinkPost'){
					fItem.Type = post.feedType;
					fItem.ParentId = post.parentId;
					fItem.Title = post.feedTitle;
					fItem.Body = post.feedBody;
					fItem.LinkUrl = post.feedURL;
				}else if(post.feedType == 'TextPost'){
					fItem.Type = post.feedType;
					fItem.ParentId = post.parentId;
					fItem.Title = post.feedTitle;
					fItem.Body = post.feedBody;
				}else{
					system.debug('Unknown feedType - ' + post.feedType + ' - requested.  Defaulting to TextPost.');
					fItem.Type = defaultPostType;
					fItem.ParentId = post.parentId;
					fItem.Body = post.feedBody;
				}
				fItems.add(fItem);
			}
		}
		try{
			insert fItems;
		}catch(Exception e){
			system.debug('CommonFunctions.postFeedItems EXCEPTION - '+e);
		}
	}
	    
	public static chatterFeedItem createChatterPost(Id oppId, Boolean success, Integer successOLICnt, Integer successBSICnt)
	{
		chatterFeedItem cfi = new chatterFeedItem();
		String resultMsg = '';
		if (success) {
			resultMsg = Label.PPOPPLINE_ChatterFeed_Success.replace('xxxx', string.valueOf(successOLICnt)); 
			resultMsg = resultMsg.replace('yyyy', string.valueOf(successBSICnt)); 
		}
		else{
			resultMsg = Label.PPOPPLINE_ChatterFeed_Failure;
		}
		cfi.feedType = 'TextPost';
		cfi.parentId = oppId;
		cfi.feedBody = resultMsg;
		return cfi;
	}

	public static chatterFeedItem createOpportunityChatterPost(Id oppId, string msg)
	{
		chatterFeedItem cfi = new chatterFeedItem();
		cfi.feedType = 'TextPost';
		cfi.parentId = oppId;
		cfi.feedBody = msg;
		return cfi;
	}
	
	public static chatterFeedItem createOpportunityChatterPost(Id oppId, Boolean success, Integer successPLICnt)
	{
		String resultMsg = '';
		if (success) {
			resultMsg = Label.PPOPPLINE_ChatterFeed_Success.replace('xxxx', string.valueOf(successPLICnt)); 
		}
		else{
			resultMsg = Label.PPOPPLINE_ChatterFeed_Failure;
		}
		return createOpportunityChatterPost(oppId, resultMsg);
	}

	public static void PostOpportunityMessage(Id oppId, Boolean success, Integer successPLICnt)
	{
		postFeedItems(new List<chatterFeedItem>{ChatterUtils.createOpportunityChatterPost(oppId, success, successPLICnt)});
	}

	public static void PostOpportunityMessage(Id oppId, string msg)
	{
		postFeedItems(new List<chatterFeedItem>{ChatterUtils.createOpportunityChatterPost(oppId, msg)});
	}

}