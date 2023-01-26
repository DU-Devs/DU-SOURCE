
var/Vector/Vector = new

Vector
	var/vector/zero = new(0, 0, 0)
	var/vector/north = new(0, 1, 0)
	var/vector/south = new(0, -1, 0)
	var/vector/east = new(1, 0, 0)
	var/vector/west = new(-1, 0, 0)
	var/vector/up = new(0, 0, 1)
	var/vector/down = new(0, 0, -1)

proc/dir2vector(dir)
	return new/vector(
		((dir & EAST) > 0) - ((dir & WEST) > 0),
		((dir & NORTH) > 0) - ((dir & SOUTH) > 0),
		((dir & UP) > 0) - ((dir & DOWN) > 0))

vector
	var/_x
	var/_y
	var/_z

	proc/X()
		return _x

	proc/Y()
		return _y

	proc/Z()
		return _z

	proc/With(x = _x, y = _y, z = _z)
		return new/vector(x, y, z)

	proc/Text(figures = 6)
		return text("vector([], [], [])",
			num2text(X(), figures),
			num2text(Y(), figures),
			num2text(Z(), figures))

	proc/operator~=(vector/vector)
		return \
			X() == vector.X() && \
			Y() == vector.Y() && \
			Z() == vector.Z()

	proc/operator+(vector/vector)
		return new/vector(
			X() + vector.X(),
			Y() + vector.Y(),
			Z() + vector.Z())

	proc/operator-()
		if(length(args) > 0)
			return Subtract(args[1])
		else
			return Negate()

	proc/operator*(arg)
		if(isnum(arg))
			return Scale(arg)
		if(istype(arg, /vector))
			return Multiply(arg)
		if(istype(arg, /matrix))
			return Transform(arg)
		CRASH("Undefined")

	proc/operator/(arg)
		if(isnum(arg))
			return Scale(1 / arg)
		if(istype(arg, /vector))
			return Divide(arg)
		if(istype(arg, /matrix))
			return Transform(~arg)
		CRASH("Undefined")

	proc/Subtract(vector/vector)
		return new/vector(
			X() - vector.X(),
			Y() - vector.Y(),
			Z() - vector.Z())

	proc/Negate()
		return new/vector(-X(), -Y(), -Z())

	proc/Scale(scalar)
		return new/vector(
			X() * scalar,
			Y() * scalar,
			Z() * scalar)

	proc/Multiply(vector/vector)
		return new/vector(
			X() * vector.X(),
			Y() * vector.Y(),
			Z() * vector.Z())

	proc/Transform(matrix/matrix)
		return new/vector(
			X() * matrix.a + Y() * matrix.b + matrix.c,
			X() * matrix.d + Y() * matrix.e + matrix.f,
			Z())

	proc/Divide(vector/vector)
		return new/vector(
			X() / vector.X(),
			Y() / vector.Y(),
			Z() / vector.Z())

	proc/Dot(vector/vector)
		return \
			X() * vector.X() + \
			Y() * vector.Y() + \
			Z() * vector.Z()

	proc/Cross(vector/vector)
		return new/vector(
			Y() * vector.Z() - Z() * vector.Y(),
			Z() * vector.X() - X() * vector.Z(),
			CrossZ(vector))

	proc/CrossZ(vector/vector)
		return X() * vector.Y() - Y() * vector.X()

	proc/LengthSquared()
		return Dot(src)

	proc/Length()
		return sqrt(LengthSquared())

	proc/Direction()
		return src / Length()

	proc/HasDirection()
		return src ~! Vector.zero

	proc/DirectionOrZero()
		return HasDirection() ? Direction() : src

	proc/HasLength()
		return HasDirection()

	proc/Rotation(vector/from = Vector.north)
		var/vector/to_direction = Direction()
		var/vector/from_direction = from.Direction()
		var/cos = to_direction.Dot(from_direction)
		var/sin = to_direction.CrossZ(from_direction)
		return matrix(cos, sin, 0, -sin, cos, 0)

	proc/Turn(clockwise_degrees)
		return src * matrix(clockwise_degrees, MATRIX_ROTATE)

	proc/WithLength(length)
		return src * (length / Length())

	proc/WithLengthOrZero(length)
		return HasLength() ? WithLength(length) : src

	proc/ClampLength(upper)
		return DirectionOrZero() * min(Length(), upper)

	proc/ToDir()
		var/exact = ToExactDir()
		if(exact & (exact - 1))
			var/abs_x = abs(X())
			var/abs_y = abs(Y())
			if(abs_x >= abs_y * 2)
				return exact & (EAST | WEST)
			if(abs_y >= abs_x * 2)
				return exact & (NORTH | SOUTH)
		return exact

	proc/ToCardinalDir()
		var/exact = ToExactDir()
		if(exact & (exact - 1))
			var/abs_x = abs(X())
			var/abs_y = abs(Y())
			if(abs_x >= abs_y)
				return exact & (EAST | WEST)
			if(abs_y >= abs_x)
				return exact & (NORTH | SOUTH)
		return exact

	proc/ToExactDir()
		return \
			(X() == 0 ? 0 : X() > 0 ? EAST : WEST) | \
			(Y() == 0 ? 0 : Y() > 0 ? NORTH : SOUTH) | \
			(Z() == 0 ? 0 : Z() > 0 ? UP : DOWN)

	proc/Clamp(vector/lower, vector/upper)
		return new/vector(
			clamp(X(), lower.X(), upper.X()), 
			clamp(Y(), lower.Y(), upper.Y()), 
			clamp(Z(), lower.Z(), upper.Z()))

	proc/DegreesTo(vector/other)
		return -DegreesFrom(other)

	proc/DegreesFrom(vector/other)
		var/vector/direction = Direction()
		var/vector/other_direction = other.Direction()
		var/cos = direction.Dot(other_direction)
		var/sin = direction.CrossZ(other_direction)
		return arctan(cos, sin)

	New(x = 0, y = 0, z = 0)
		..()
		_x = x
		_y = y
		_z = z
