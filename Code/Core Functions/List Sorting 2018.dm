proc
	SortListOfObjectsAlphabetically(list/l)
		var/list/names = new
		for(var/atom/o in l) names += o.name
		names = mergesort(names)
		var/list/new_list = new
		for(var/n in names)
			for(var/atom/o in l)
				if(o.name == n)
					new_list += o
					break
		return new_list

proc
    bubblesort(list/L, sort=0)
        for(var/i=L.len, i>=1, i--)
            for(var/j=1, j<=i-1, j++)
                if(L[j] > L[j+1])
                    L.Swap(j, j+1)
        return ((sort)?(descending(L)):(L))

    quicksort(list/L, sort=0)
        var
            list/less = new
            list/pivots = new
            list/greater = new
        if(L.len <= 1) return L
        var
            n = L.Find(pick(L))
            pivot = L[n]
        for(var/i=1, i<=L.len, i++)
            if(i!=n)
                if(L[i]<pivot) less += L[i]
                else if(L[i]>=pivot) greater += L[i]
        pivots += pivot
        L = quicksort(less) + pivots + quicksort(greater)
        return ((sort)?(descending(L)):(L))

 	//somehow sorts lists of strings alphabetically too, but also numbers somehow
    mergesort(list/L, sort=0)
        var
            list/left = new
            list/right = new
        if(L.len <= 1) return L
        var/mid = round(L.len / 2, 1)
        for(var/x=1, x<=mid, x++) left += L[x]
        for(var/x=mid+1, x<=L.len, x++) right += L[x]
        left = mergesort(left)
        right = mergesort(right)
        L = merge(left, right)
        return ((sort)?(descending(L)):(L))

    merge(list/L, list/R)
        var/list/result = new
        while(L.len > 0 && R.len > 0)
            if(L[1] <= R[1])
                result += L[1]
                L.Cut(1, 2)
            else
                result += R[1]
                R.Cut(1, 2)
        if(L.len>0) result += L
        if(R.len>0) result += R
        return result

    selectionsort(list/L, sort=0)
        var/min, temp
        for(var/i=1,i<=L.len-1,i++)
            min=i
            for(var/j=i+1,j<=L.len,j++) if(L[j]<L[min]) min=j
            temp=L[i]
            L[i]=L[min]
            L[min]=temp
        return ((sort)?(descending(L)):(L))

    insertionsort(list/L, sort=0)
        var/index, j
        for(var/i=2, i<=L.len, i++)
            index=L[i]
            j=i
            while((j>1)&&(L[j-1]>index))
                L[j]=L[j-1]
                j=j-1
            L[j]=index
        return ((sort)?(descending(L)):(L))

    descending(list/L)
        var/list/R=new
        for(var/i=L.len,i>=1,i--) R+=L[i]
        return R