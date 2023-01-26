// This library handles a lot of common mathematical functions, such as interpolation,
// as well as providing some constant values for commonly used numbers such as Pi.

var/global/math/Math = new
var/global/math/int/MathI = new

math/int
	HandleOutput(x)
		return round(x)

math
	var/const
		E = 2.718281828
		PI = 3.141592653
		HYPOT = 1.414213562

	proc
		// Take the output from the procs and handle it in some way-- for overriding in subclasses.
		HandleOutput(x)
			return x

		// Linear Interpolation between two points.  Where `a` is the starting point, `b` is the end point, and `t` is a number from 0 to 1 (inclusive)
		// indicating how far between the two points the new value is.
		Lerp(a, b, t)
			return HandleOutput(a+(b-a)*t)

		//Cosine Interpolation between two points.  Where `a` is the starting point, `b` is the end point, and `t` is a number from 0 to 1 (inclusive)
		//indicating how far between the two points the new value is.
		Cerp(a, b, t)
			var/f = (1-cos(t*PI)) * 0.5
			return HandleOutput(a*(1-f)+b*f)

		//Bias function to provide a y coord on a 2D grid, based on X.  If bias is 0, y = x.  Closer to 1 bias gets the lower value y gets relative to x.
		Bias(x, bias)
			var/k = Pow(1-bias, 3)
			var/denominator = (x * k - x + 1)
			if(denominator == 0) return 0
			return HandleOutput((x * k) / denominator)

		//Sigmoid function which compresses any real number x into the range of 0 to 1.
		Sigmoid(x)
			return Inverse(1 + Exp(-x))

		//This exponential falloff function returns 1 at x = 0.  The output decreases at rate of r as x decreases.  (r defaults to 0.01)
		Falloff(x, r = 0.01)
			return Exp(-r * x)

		//Raise E to the nth power
		Exp(n)
			return HandleOutput(E**n)

		//Raise x to the y power.  Default of y is 2
		Pow(x, y=2)
			return HandleOutput(x**y)
		
		Hypot(a, b)
			if(!b) return a * HYPOT
			return Sqrt(Pow(a) + Pow(b))

		Sin(x)
			return HandleOutput(sin(x))

		Arcsin(x)
			return HandleOutput(arcsin(x))

		Cos(x)
			return HandleOutput(cos(x))

		Arccos(x)
			return HandleOutput(arccos(x))

		Tan(x)
			return HandleOutput(tan(x))

		Arctan(x, y)
			return HandleOutput(y ? arctan(x,y) : arctan(x))

		//Make num equal to the closest value of either a or b if not between them (inclusive)
		Clamp(num, a, b)
			return HandleOutput(clamp(num, a, b))

		Min(a, b)
			return HandleOutput(min(a, b))

		Max(a, b)
			return HandleOutput(max(a, b))

		Abs(x)
			return HandleOutput(abs(x))
		
		//Checks if a number is even or odd.  Returns true if no remainder, thus even.  Returns false if there is a remainder, thus making it odd.
		IsEven(x)
			return x % 2 == 0

		Prob(x)
			return prob(x)

		Rand(a, b)
			if(a)
				if(b)
					return HandleOutput(rand(a, b))
				return HandleOutput(rand(Max(0, a), Min(0, a)))
			return HandleOutput(rand())

		Seed(x)
			rand_seed(x)

		//Round x down to the nearest multiple of 1
		Floor(x)
			return HandleOutput(round(x))

		//Round x down to the nearest multiple of N
		FloorN(x, N)
			return HandleOutput((round((x)/(N)) * (N)))

		//Round x up to the nearest multiple of 1
		Ceil(x)
			return HandleOutput((-round(-(x))))

		//Round x up to the nearest multiple of N
		CeilN(x, N)
			return HandleOutput((-round(-(x)/(N)) * (N)))

		Round(x, y)
			return HandleOutput(round(x, y))

		Sqrt(x)
			return HandleOutput(sqrt(x))

		//Natural log of x (base E)
		Log(x)
			return HandleOutput(log(x))

		//Logarithm of x (base 10)
		Log10(x)
			return HandleOutput(log(10, x))

		//Mean average of all numbers passed as arguments
		Mean()
			if(!args || !args?.len) return 0
			var/total = 0, n = args?.len
			for(var/x in args)
				if(!isnum(x)) continue
				total += x
			return HandleOutput(total / n)

		//Mode average of all numbers passed as arguments
		Mode()
			var/list/keys = list()
			for(var/x in args)
				if(keys[x]) keys[x]++
				else keys[x] = 1
			var/num
			for(var/x in keys)
				if(!num) num = x
				else if(keys[num] < keys[x]) num = x
			return HandleOutput(num)

		//Factorial of n.  r is cutoff.  Set to 0 for full factorial.
		Factorial(n, r=0)
			if(n in list(0, 1, 2)) return n
			switch(r)
				if(0) r = n
				if(1) return n
				if(2) return n * (n - 1)
			var/result = n
			for(var/c in 1 to (r-1))
				result *= (n - c)
			return HandleOutput(result)
		
		Delta(a1, a2)
			return HandleOutput(a2 - a1)
		
		Line(slope, x, y_intercept = 0)
			return HandleOutput(slope * x + y_intercept)
		
		Slope(x1, y1, x2, y2)
			var/deltaX = Delta(x1, x2)
			var/deltaY = Delta(y1, y2)
			return HandleOutput(deltaY / deltaX)
		
		//Provided a percentage, returns the represented value in range min-max.
		ValueFromPercentInRange(min, max, percent)
			return HandleOutput((percent * (max - min) / 100) + min)
		
		//Provided a value in range min-max, returns the representing percentage.
		PercentFromValueInRange(min, max, value)
			return HandleOutput(((value - min) * 100) / (max - min))
		
		Inverse(n)
			return HandleOutput(1 / n)
		
		InRange(val, min, max, inclusive = 1)
			if(inclusive)
				return min <= val && max >= val
			return min < val && max > val
		
		PlotLine(x1, y1, x2, y2)
			if(Abs(Delta(y1, y2)) < Abs(Delta(x1, x2)))
				if(x1 > x2)
					return PlotLineLow(x2, y2, x1, y1)
				else
					return PlotLineLow(x1, y1, x2, y2)
			else
				if(y1 > y2)
					return PlotLineHigh(x2, y2, x1, y1)
				else
					return PlotLineHigh(x1, y1, x2, y2)
		
		PlotLineLow(x1, y1, x2, y2)
			var/list/plots = list()
			var/dx = Delta(x1, x2), dy = Delta(y1, y2), yi = 1
			if(dy < 0)
				yi = -1
				dy = -dy
			var/diff = (2 * dy) - dx, y = y1

			for(var/x in x1 to x2)
				plots.Add(new/simple_vector(x, y))
				if(diff > 0)
					y += yi
					diff += (2 * (dy - dx))
				else
					diff += 2 * dy
			return plots
		
		PlotLineHigh(x1, y1, x2, y2)
			var/list/plots = list()
			var/dx = Delta(x1, x2), dy = Delta(y1, y2), xi = 1
			if(dx < 0)
				xi = -1
				dx = -dx
			var/diff = (2 * dx) - dy, x = x1
			for(var/y in y1 to y2)
				plots.Add(new/simple_vector(x, y))
				if(diff > 0)
					x += xi
					diff += (2 * (dx - dy))
				else
					diff += 2 * dx
			return plots

simple_vector
	var
		x
		y
		z
	
	New(_x = 1, _y = 1, _z = 1)
		x = _x
		y = _y
		z = _z