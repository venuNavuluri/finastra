public abstract class Sortable implements Comparable {
	public abstract string GetSortName();
	public Integer compareTo(Object compareTo) {
		if (GetSortName() == ((Sortable)compareTo).GetSortName()) { return 0; }
		else if (GetSortName() > ((Sortable)compareTo).GetSortName()) { return 1; }
		else { return -1; }
	}
}