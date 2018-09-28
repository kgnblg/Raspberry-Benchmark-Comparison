gx_quaternion = { }

--[[
Quaternions can be defined with an axis-angle notation
q = [x,y,z, angle]

- http://fr.wikipedia.org/wiki/Quaternions_et_rotation_dans_l%27espace
- http://fr.wikipedia.org/wiki/Blocage_de_cardan
- http://fr.wikipedia.org/wiki/Quaternion#Applications
--]]

--------------------------------------------------------------------------
function gx_quaternion.new(x, y, z, w)
  local q = {x=0, y=0, z=0, w=1 }
  q.x = x
  q.y = y
  q.z = z
  q.w = w
  return q
end

--------------------------------------------------------------------------
function gx_quaternion.set(q, x, y, z, w)
  q.x = x
  q.y = y
  q.z = z
  q.w = w
end

--------------------------------------------------------------------------
function gx_quaternion.get(q)
  return q.x, q.y, q.z, q.w
end

--------------------------------------------------------------------------
function gx_quaternion.from_angle_axis(ang, x, y, z)
	local r = ang * math.pi / 180
  local halfang = 0.5 * r
	local fsin = math.sin(halfang)
	return fsin*x , fsin*y , fsin*z, math.cos(halfang)
end

--------------------------------------------------------------------------
function gx_quaternion.identity()
	return 0,0,0,1
end

--------------------------------------------------------------------------
function gx_quaternion.normalise(q)
	local factor = 1.0 / math.sqrt(x*x + y*y + z*z + w*w)
	return x*factor,y*factor,z*factor,w*factor
end

--[[
function gx_quaternion.normalise(x, y, z, w)
	local factor = 1.0 / math.sqrt(x*x + y*y + z*z + w*w)
	return x*factor,y*factor,z*factor,w*factor
end
--]]

--------------------------------------------------------------------------
function gx_quaternion.mul(a, b)
  return gx_quaternion.mul_xyzw(a.x,a.y,a.z,a.w,b.x,b.y,b.z,b.w)
end

--------------------------------------------------------------------------
function gx_quaternion.mul_xyzw(ax,ay,az,aw, bx,by,bz,bw)
	return	aw * bx + ax * bw + ay * bz - az * by,
			    aw * by + ay * bw + az * bx - ax * bz,
			    aw * bz + az * bw + ax * by - ay * bx,
          aw * bw - ax * bx - ay * by - az * bz
end

--------------------------------------------------------------------------
function gx_quaternion.slerp(qa, qb, t)
  -- from: http://www.codea.io/talk/discussion/1873/extension-of-andrew-staceys-quaternion-library/p1

  local qm = gx_quaternion.new(0, 0, 0, 0)

  --    // Calculate angle between them.
  local cosHalfTheta = (qa.x * qb.x) + (qa.y * qb.y) + (qa.z * qb.z) + (qa.w * qb.w)

  --    // if qa=qb or qa=-qb then...
  if (math.abs(cosHalfTheta) >= 1.0) then
    qm.x = qa.x
    qm.y = qa.y
    qm.z = qa.z
    qm.w = qa.w
    return qm
  end

  --   // Calculate temporary values.
  local halfTheta = math.acos(cosHalfTheta)
  local sinHalfTheta = math.sqrt(1.0 - cosHalfTheta*cosHalfTheta)

  --    // if theta = 180 degrees then result is not fully defined
  --    // we could rotate around any axis normal to qa or qb
  if (math.abs(sinHalfTheta) < 0.001) then
        qm.x = (qa.x * 0.5 + qb.x * 0.5)
        qm.y = (qa.y * 0.5 + qb.y * 0.5)
        qm.z = (qa.z * 0.5 + qb.z * 0.5)
        qm.w = (qa.w * 0.5 + qb.w * 0.5)
        return qm
  end

  local ratioA = math.sin((1 - t) * halfTheta) / sinHalfTheta
  local ratioB = math.sin(t * halfTheta) / sinHalfTheta

  --    //calculate Quaternion.
  qm.x = (qa.x * ratioA + qb.x * ratioB)
  qm.y = (qa.y * ratioA + qb.y * ratioB)
  qm.z = (qa.z * ratioA + qb.z * ratioB)
  qm.w = (qa.w * ratioA + qb.w * ratioB)
  return qm
end


--------------------------------------------------------------------------
function gx_quaternion.rotate_point(q, point)


end





