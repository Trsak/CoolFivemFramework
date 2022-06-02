Vector3 = {}

Vector3Meta = {
  __call = function(self,x,y,z) return setmetatable( { x = x or 0, y = y or 0, z = z or 0 }, Vector3Return ); end,
}

setmetatable(Vector3,Vector3Meta)

local sqrt = math.sqrt
Vector3Return = {
  __add       = function(self,other) print(self,other) return Vector3( self.x+other.x, self.y+other.y, self.z+other.z ); end,
  __sub       = function(self,other) return Vector3( self.x-other.x, self.y-other.y, self.z-other.z ); end,
  __div       = function(self,other) return Vector3( self.x/other.x, self.y/other.y, self.z/other.z ); end,
  __mul       = function(self,other) return Vector3( self.x*other.x, self.y*other.y, self.z*other.z ); end,
  __mod       = function(self,other) return Vector3( self.x%other.x, self.y%other.y, self.z%other.z ); end,
  __pow       = function(self,other) return Vector3( self.x^other.x, self.y^other.y, self.z^other.z ); end,
  __dist      = function(self,other) return sqrt( (self.x-other.x)*(self.x-other.x) + (self.y-other.y)*(self.y-other.y) + (self.z-other.z)*(self.z-other.z) ) end,
  __distance  = function(self,other) return sqrt( (self.x-other.x)*(self.x-other.x) + (self.y-other.y)*(self.y-other.y) + (self.z-other.z)*(self.z-other.z) ) end,
  __dir       = function(self,other) for kt,t in pairs({self,other}) do for k,v in pairs(t) do if v == 0 then t[kt][k] = 0.000001 ; end; end; end; return Vector3(sqrt(self.x*other.x),sqrt(self.y*other.y),sqrt(self.z*other.z)) end,
  __direction = function(self,other) for kt,t in pairs({self,other}) do for k,v in pairs(t) do if v == 0 then t[kt][k] = 0.000001 ; end; end; end; return Vector3(sqrt(self.x*other.x),sqrt(self.y*other.y),sqrt(self.z*other.z)) end,
  __tostring  = function(self) return string.format( "Vector3(%s,%s,%s)", self.x,self.y,self.z ); end,
}

Vector3.zero    = Vector3(  0.0,  0.0,  0.0 )
Vector3.back    = Vector3( -1.0,  0.0,  0.0 )
Vector3.forward = Vector3(  1.0,  0.0,  0.0 )
Vector3.left    = Vector3(  0.0, -1.0,  0.0 )
Vector3.right   = Vector3(  0.0,  1.0,  0.0 )
Vector3.down    = Vector3(  0.0,  0.0, -1.0 )
Vector3.up      = Vector3(  0.0,  0.0,  1.0 )
