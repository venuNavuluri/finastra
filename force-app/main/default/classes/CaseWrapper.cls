public class CaseWrapper {
	public Boolean Selected{get; set;}
	public Case internalCase{get; set;}

	public CaseWrapper(Case wrapCase){
		internalCase = wrapCase;
	}

    // AC 9/4/09 Test Methods moved to separate class
}