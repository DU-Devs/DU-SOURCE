/*

Updates
May 13th 2008
	Added List and RemoveItem procs



Usage

New(compare)
compare - The function which will be used to compare items being added to
the newly made queue.

IsEmpty()
This function returns true if the queue is empty and false otherwise.

Enqueue(d)
d - This item being put on the queue.
Puts the passed in parameter on the queue

Dequeue()
Returns the item on the queue which is smallest based on the passed
in comparision function passed in during creation of the queue.

Remove(i)
i - Index of the item to be removed.
Removes an item from the queue at index i.  Note this index is not
related to the sorted order but the item at the index i within the
internal list used by the queue.

List()
Returns a list version of the queue leaving the queue in tact.

RemoveItem(i)
i - The item to be removed
Finds the item i and removes it if it is found otherwise the queue
remains unchanged.

The comparision function should take two parameters.  The parameters
are the two items being compared.  This function should return a negative
number if the first item is less than the second, 0 if the items have
an equal weight for the sorting, and positive if the first item is
larger than the second.

*/
PriorityQueue
	var
		L[]
		cmp
	New(compare)
		L = new()
		cmp = compare
	proc
		IsEmpty()
			return !L.len
		Enqueue(d)
			var/i
			var/j
			L.Add(d)
			i = L.len
			j = i>>1
			while(i > 1 &&  call(cmp)(L[j],L[i]) > 0)
				L.Swap(i,j)
				i = j
				j >>= 1

		Dequeue()
			ASSERT(L.len)
			. = L[1]
			Remove(1)

		Remove(i)
			ASSERT(i <= L.len)
			L.Swap(i,L.len)
			L.Cut(L.len)
			if(i < L.len)
				_Fix(i)
		_Fix(i)
			var/child = i + i
			var/item = L[i]
			while(child <= L.len)
				if(child + 1 <= L.len && call(cmp)(L[child],L[child + 1]) > 0)
					child++
				if(call(cmp)(item,L[child]) > 0)
					L[i] = L[child]
					i = child
				else
					break
				child = i + i
			L[i] = item
		List()
			var/ret[] = new()
			var/copy = L.Copy()
			while(!IsEmpty())
				ret.Add(Dequeue())
			L = copy
			return ret
		RemoveItem(i)
			var/ind = L.Find(i)
			if(ind)
				Remove(ind)