--[[ 
Core of LUA Object Instancing 
 class.lua: see http://lua-users.org/wiki/SimpleLuaClasses 
 Compatible with Lua 5.1 (not 5.0).
 --]]
function class(base, ctor)
  local c = {}     -- a new class instance
  if not ctor and type(base) == 'function' then
      ctor = base
      base = nil
  elseif type(base) == 'table' then
   -- our new class is a shallow copy of the base class!
      for i,v in pairs(base) do
          c[i] = v
      end
      c._base = base
  end
  -- the class will be the metatable for all its objects,
  -- and they will look up their methods in it.
  c.__index = c

  -- expose a ctor which can be called by <classname>(<args>)
  local mt = {}
  mt.__call = function(class_tbl,...)
    local obj = {}
    setmetatable(obj,c)
    if ctor then
       ctor(obj,...)
    else
    -- make sure that any stuff from the base class is initialized!
       if base and base.init then
         base.init(obj,...)
       end
    end
    return obj
  end
  c.init = ctor
  c.is_a = function(self,klass)
      local m = getmetatable(self)
      while m do
         if m == klass then return true end
         m = m._base
      end
      return false
    end
  setmetatable(c,mt)
  return c
end


--[[
=======================================================================
================  VECTORS  functions  =================================
=======================================================================
--]]

--[[
Vector creation.
myVec = vec3()
--]]
vec3 = class(function(vec,x,y,z)
	if not z then z=0 end
	if not y then y=0 end
	if not x then x=0 end
    vec:set(x,y,z)
 end)

--[[
Vector accessor - Get/Set
--]]
function vec3.set(vec, x, y, z)
	if type(x) == 'table' and getmetatable(x) == vec3 then
		local po = x;
		x = po.x;
		y = po.y;
		z = po.z;
	end
	vec.x = x;
	vec.y = y;
	vec.z = z;
end

function vec3.get(v)
  return v.x, v.y, v.z;
end
function vec3.get_x(v)
  return v.x;
end
function vec3.get_y(v)
  return v.y;
end
function vec3.get_z(v)
  return v.z;
end

--[[
Vector equality.
v1 == v2 ?
--]]
function vec3.__eq(v1, v2)
  return (v1.x==v2.x) and (v1.y==v2.y) and (v1.z==v2.z);
end

function VEC3_IsEqual(v1, v2)
  return v1==v2;
end

--[[
Vector addition.
vec3 addition is '+','-'
--]]
function vec3.__add(v1, v2)
  return vec3(v1.x+v2.x, v1.y+v2.y, v1.z+v2.z)
end

function vec3.__sub(v1, v2)
  return vec3(v1.x-v2.x, v1.y-v2.y, v1.z-v2.z)
end

function vec3.add(v1, v2)
  return v1+v2;
end

function vec3.sub(v1, v2)
  return v1-v2;
end

--[[
unitary minus  (e.g in the expression f(-p))
Negate.
--]]
function vec3.__unm(v)
  return vec3(-v.x, -v.y, -v.z)
end

function vec3.neg(v)
	v.x = -v.x;
	v.y = -v.y;
	v.z = -v.z;
end

--[[
scalar and component-wise multiplication is '*'
--]]
function vec3.__mul(v, s)
	if type(s) == 'table' then
		return vec3( s.x*v.x, s.y*v.y, s.z*v.z );
	else
		return vec3( s*v.x, s*v.y, s*v.z );
	end
end

function vec3.mul(v, s)
	if type(s) == 'table' then
		v.x = s.x*v.x;
		v.y = s.y*v.y;
		v.z = s.z*v.z;
	else
		v.x = s*v.x;
		v.y = s*v.y;
		v.z = s*v.z;
	end
end

--[[
DOT product.
--]]
function vec3.dot(v1, v2)
   return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z
end

--[[
CROSS product.
--]]
function vec3.cross(v1, v2)
	return vec3(v1.y*v2.z - v1.z*v2.y,
	            v1.z*v2.x - v1.x*v2.z,
			    v1.x*v2.y - v1.y*v2.x)
end

function vec3.cross_v2(v1, v2)
	local x = v1.y*v2.z - v1.z*v2.y
	local y = v1.z*v2.x - v1.x*v2.z
	local z = v1.x*v2.y - v1.y*v2.x
	v1.x = x
	v1.y = y
	v1.z = z
end

--[[
Vector norm or length or magnitude.
--]]
function vec3.square_len(v)
	return v.x*v.x + v.y*v.y + v.z*v.z
end

function vec3.len(v)
	return math.sqrt(v:square_len())
end

--[[
Vector normalization.
--]]
function vec3.normalize(v)
	local norm = v:len();
	local multiplier;
	if( norm > 0 ) then
		multiplier = 1.0/norm;
	else
		multiplier = 0.00001;
	end
		
	v.x = v.x * multiplier;
	v.y = v.y * multiplier;
	v.z = v.z * multiplier;
end

--[[
Is null vector ?
--]]
function vec3.is_null(v)
	return (v.x==0 and v.y==0 and v.z==0);
end

--[[
Distance between vectors
--]]
function vec3.square_distance(v1, v2)
	local dx = v1.x-v2.x;
	local dy = v1.y-v2.y;
	local dz = v1.z-v2.z;
	return dx*dx + dy*dy + dz*dz;
end

function vec3:distance(v1, v2)
	return math.sqrt(v1:square_distance(v2));
end

--[[
Linear Interpolation
--]]
function vec3.lerp(a, b, t)
	return vec3( a.x + (b.x - a.x)*t, 
	             a.y + (b.y - a.y)*t, 
				 a.z + (b.z - a.z)*t );
end

function VEC3_Lerp(a, b, t)
	return vec3( a.x + (b.x - a.x)*t, 
	             a.y + (b.y - a.y)*t, 
				 a.z + (b.z - a.z)*t );
end

function vec3.to_string(v)	
	return string.format('%f,%f,%f', v.x, v.y, v.z);
end

function vec3.dump(v, name) 
	gh_utils.trace(ID, string.format("%s = (%f %f %f)",name, v.x, v.y, v.z))
end


--[[
=======================================================================
=========================  MATH MODULE   ==============================
=======================================================================
--]]

local M = module("mod_math", package.seeall)


--[[
Math constants
--]]
M._PI = math.pi
M._EPSILON = 0.000001
M._PI_OVER_180 = math.pi/180
M._180_OVER_PI = 180/math.pi

function M.init_random()
  -- http://lua-users.org/wiki/MathLibraryTutorial
  -- improve seeding on these platforms by throwing away the high part of time, 
  -- then reversing the digits so the least significant part makes the biggest change
  -- NOTE this should not be considered a replacement for using a stronger random function
  -- ~ferrix
  -- math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))

	math.randomseed(os.time()) -- seed and pop
end

function M.random(a, b)
	if (a > b) then
		local c = b
		b = a
		a = c
	end
	local delta = b-a
	return (a + math.random()*delta)
end

function M.rad2deg( radian )
	return radian * _180_OVER_PI
end

function M.deg2rad( degree )
	return degree * _PI_OVER_180
end

function M.lerp( a, b, t)
	return (a + (b - a)*t)
end

function M.max(a, b)
	if (a > b) then
		return a;
	end
	return b;
end

function M.min(a, b)
	if (a < b) then
		return a;
	end
	return b;
end

function M.clamp( n, _min, _max)
	if (n > _max) then 
		n = _max; 
	end
	if (n < _min) then 
		n = _min; 
	end
	return n;
end

function M.interpolate(actual, goal, speed)
	local delta = goal - actual
	if (math.abs(delta) < _EPSILON) then
		return goal
	end
	return (actual + delta * min(speed, 1.0))
end

function M.new_vec3()
	local v = vec3();
  return v
end


return M
