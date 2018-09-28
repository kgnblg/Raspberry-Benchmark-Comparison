--
-- http://web.cs.wpi.edu/~cs4536/c12/programs/sorting.lua
--

-- lib_dir = gh_utils.get_scripting_libs_dir() 		
-- dofile(lib_dir .. "lua/sorting_init.lua")
-- dofile("sorting_init.lua") 


--[[

Suppose that 

1.  tab is a table, and 
2.  fn is a function that can be applied to 
    the value in each key,value pair stored 
    in the table.  

Then 

        iterate_through_table(fn, tab)

returns a new table 
with exactly the same keys as tab, 
but in place of each value v, 
it has fn(v) instead.  

No side effects on tab.  

--]]

function iterate_through_table(fn, tab)
   local result = {} 
   for k,v in pairs(tab) do 
      result[k] = fn(v)
   end
   return result 
end

--[[

Suppose that fn2 is a function of two arguments, and tab1 and tab2 are
two tables.  Then iterate_through_two_tables will construct a table
which has an entry for key k iff tab1[k] and tab2[k] are well
defined.  

The resulting table r has r[k] equal to fn(tab1[k], tab2[k]).  

--]]

function iterate_through_two_tables(fn, tab1, tab2)
   local result = {} 
   for k,v in pairs(tab1) do 
      if tab2[k] ~= nil         -- check if non-nil 
      then 
         result[k] = fn(v,tab2[k])
      end 
   end
   return result 
end


--[[

The identity function returns any 
argument v unchanged. 

--]]

function identity(v) 
   return v 
end  

--[[

If tab is a table, then copy_table(tab) 
returns a copy of it.

That is, another table with exactly the 
same key,value pairs.  

--]]

function copy_table(tab) 
   return iterate_through_table(identity, tab)
end 
   
--[[

If  a is an array, then fold(fn, seed, a) 
"folds" the two-argument function fn through a.

That means, it returns the value: 

        fn(a[#a], (fn(a[#a-1], ... 
                      fn(a[2],fn(a[1],seed)))))

Writing this another way, let 

v_0 = seed 
v_1 = fn(a[1], v_0)
v_2 = fn(a[2], v_1)

...

v_n = fn(a[n], v[n-1])

Then fold(fn, seed, a) = v_#a

--]]

function fold (fn,seed,a) 
   local result = seed 
   for i = 1, #a do 
      result = fn(a[i], result) 
   end 
   return result 
end 

--[[

If tab is a table, then print_table
prints each key,value pair in tab 
on a separate line, separated by 
a comma and two spaces.    

--]] 

function print_table(tab) 
   for k,v in pairs(tab) do 
      print(k, ",  ", v)
   end 
end 

-- print out the entries of the array a 
-- in order.  (An *array* is a table with 
-- a sequence 1 ... n as the keys.) 

function print_array (a) 
   io.write("{")
   for i = 1, #a-1 do 
      io.write(a[i], ", ") 
   end
   if a[#a] ~= nil 
   then io.write(a[#a], "}\n")
   else io.write("}\n") 
   end 
end

-- generate an array of length len where 
-- each entry is an integer between 1 and 
-- max_entry, chosen randomly. 

function random_int_array (len, max_entry) 
   local result = {} 

   math.randomseed(os.time())   -- initialize random number gen
   local ignore = math.random(max_entry) -- discard first value 

   for i = 1, len do 
      result[i] = math.random(max_entry) -- take random number up to max_entry
   end 
   return result
end 

-- generate an increasing array {1,2,3,...,n}

function increasing_int_array(len) 
   local result = {} 

   for i = 1, len do 
      result[i]=i
   end
   return result 
end 

-- and generate a decreasing array {n, ..., 3,2,1}

function decreasing_int_array(len) 
   local result = {} 

   for i = 1, len do 
      result[i]=(len-i)+1
   end
   return result 
end 


--[[ 

Suppose that tab is a table, 
and tab, regarded as a function, 
is injective.  That means that if 
k_1, v_1 and k_2, v_2 are key,value 
pairs in tab, and k_1 and k_2 are 
different keys, then v_1 and v_2 are 
different values.  

Then invert(tab) returns a table that,
regarded as a function, is the inverse 
of tab.  Namely, its keys are the values 
in tab, and associated with each is the 
key under which it was found in tab.  

--]] 

function invert(tab) 
   local result = {} 

   for k,v in pairs(tab) do 
      result[v] = k 
   end; 
   return result 
end 

-- utility to raise an error 
-- on an array that is *not* properly sorted
-- between start and finish.  

-- s is a string to use as an error message 
-- to inform the user 
-- about the source of the error.  

function assert_sorted (a,start,finish,s) 
   local last = a[start] 

   for i = start+1, finish do 
      assert((last <= a[i]), 
             string.format("%s: value %d at %d\n", s, a[i], i)) 
      last = a[i]
   end
end 

-- construct an array of the differences between the entries in the
-- given array, assumed to be an array of numbers.  

-- Since each entry in the new array requires using two in the given
-- one, the new one is one shorter.  

-- This is kind of like taking a derivative.  

function derive (a) 
   local result = {} 
   for i = 1, #a-1 do 
      result[i] = a[i+1] - a[i] 
   end 
   return result 
end 

-- sum the values in a numerical array

function sum (a) 
   return fold(function (x,y) return (x+y) end, 
               0,a)
end 

-- write a dot on standard output.  
-- Useful to keep track of progress 
-- as some program youre debugging is running.  

function write_dot() 
   io.write("."); io.flush()
end 


-- construct an array where each entry a[i] is 
-- the ratio a1[i]/a2[i], where a1 and a2 are 
-- the two arguments to the function 

function array_ratios(a1,a2) 
   return iterate_through_two_tables(
      function (x,y) return x/y end,
      a1,a2)
end

--[[

factory to make objects with 
one field called count and
three methods:

1.  incr which increments the count 
    and returns true 

2.  reset which rests the count to 0 
    (and returns true) 

3.  reveal which returns the count value. 

If the factory returns an object obj of this kind, 
as in 

    obj = make_collector() 

you can call its methods in the form 

    obj.incr(), obj.reset(), obj.reveal() 

--]]

function make_collector () 
   local count = 0 

   local function increment () 
      count = count + 1 
      return true
   end 

   local function reset () 
      count = 0 
      return true
   end

   local function reveal () 
      return count 
   end 

   local function increment_reveal () 
      count = count + 1 
      return count
   end 

   return { inc = increment, 
            reset = reset, 
            reveal = reveal, 
            inc_reveal = increment_reveal
         } 
end 

-- associate the strings "true" and "false" with the booleans

function string_of_boolean (b) 
   if b then return "true" else return "false" end 
end 

-- print out any (:-) data structure.  Data structures 
-- can be read in again unchanged as long as they 
-- contain no function values.  


function serialize (o)
   if type(o) == "number" then
      io.write(o)
   elseif type(o) == "string" then
      io.write(string.format("%q", o))
   elseif type(o) == "function" then 
      io.write(string.format("fn value"))
   elseif type(o) == "boolean" then 
      io.write(string_of_boolean(o))
   elseif type(o) == "nil" then 
      io.write("nil")
   elseif type(o) == "table" then
      io.write("{\n")
      for k,v in pairs(o) do
         if type(k) == "string" 
         then io.write("  ", k, " = ") 
         else 
            io.write("  ["); serialize(k); io.write("] = ")
         end 
         serialize(v)
         io.write(",\n")
      end
      io.write("}\n")
   else
      error("cannot serialize a " .. type(o))
   end
end

-- execute a command in the OS, and then 
-- return a string containing the output it generated.  
-- Omit final newline.  

function string_of_command (command)
   local f = os.tmpname () 
   os.execute(string.format("%s > %s", command, f))
   local fh = assert(io.open(f,"r"))
   return string.sub(fh:read("*a"),1,-2)
end 

-- Use string_of_command to produce an 
-- *iterator* to use in for loops, 
-- yielding one iteration for each file 
-- matching the pattern.    

function matching_files (pattern) 
   local s = string_of_command(string.format("ls %s", pattern))
   return string.gmatch(s, "[^%s]+")
end 

-- a Lua version of the unix basename 
-- command, plus option to attach a new extension.  

function basename(filename, ext, alt_ext) 
   local alt_ext = (alt_ext or "")
   local bn = string_of_command(string.format("basename %s %s", filename, ext))
   return (bn .. alt_ext)
end 




--[[    

*** BUBBLE SORT command ***

When applied to a given array { 4, 3, 5, ...}, it repeatedly bubbles
out-of-order elements toward their correct positions, ending when
there are no more out-of-order pairs.

--]]


function bubble_sort (given) 
   local a = copy_table(given)  -- make a copy to leave given unchanged 
   
   local a_length = #a          -- Lua notation for array length is # 

   local still_active = true    -- flag to decide when to stop 
   local tmp = 0                -- temporary slot for interchanging 

   while still_active do 
      still_active = false 
      for i = 1, a_length-1 do 
         if a[i+1]<a[i]         -- Is this pair out of order? 
         then 
            tmp = a[i]          -- Hold onto a[i]
            a[i] = a[i+1]       -- Plug in smaller value 
            a[i+1] = tmp        -- and larger value

            still_active = true -- Needed work.  Dont stop! 
         end
      end 
   end
   return a
end 

--[[    

*** INSERTION SORT command ***
in_place_insertion_sort 

Its the same *algorithm* as copying_insertion_sort, 
only implemented without the copying.  

Does this make a big difference?  How big?  

--]]

      

function in_place_insertion_sort(a)
   for i = 2, #a do             -- the target for each step will be a[i]
      local entry = a[i] 
      for j = i-1, 0, -1 do 
         -- the sorted part at any time 
         -- is a[1] .. a[i-1].
         -- we want to insert the target in the right spot,
         -- and slide the part above that up.  
         if j == 0 or entry >= a[j]
         then 
            a[j+1] = entry 
            break 
         else 
            a[j+1] = a[j]
         end 
      end 
   end 
end 

--[[
***   MERGE SORT  ***

Heres an implementation of merge sort, 
organized as three functions.

The first merges two already sorted arrays.  

The second copies any array into two arrays 
that are half as long.  

The third does the wishful thinking, namely 
it applies itself recursively to the two halves 
of its argument, and merges the results for the 
two halves to build the full array.  

--]] 

--[[ 

Merge: 

Assume that a1 and a2 are sorted arrays.

Return an array r containing their joint 
content, globally sorted.  

That is, make sure the entries in 
a1 are in the right spots versus the
entries in a2.  

--]]

function merge (a1, a2) 
   local result = {} 
   local a1_len = #(a1) ; local a2_len = #(a2)
   local i1 = 1 ;         local i2 = 1

   for j = 1, a1_len+a2_len do 
      if i2 > a2_len            -- used up a2? 
         or 
         (i1 <= a1_len          -- a1 still available 
          and a1[i1] <= a2[i2]) -- and value is small
      then
         result[j] = a1[i1]     -- plug it in
         i1 = i1+1              -- and increment index
      else                      
         result[j] = a2[i2]     -- must use a2 next 
         i2 = i2+1
      end
   end 
   if demo_merge then print_array(result) end 
   return result 
end 

-- set this demo_merge flag to true to cause merge to 
-- print its result *every* time it is called.  
-- This causes a *lot* of output on big runs.  

demo_merge = false 



-- given an array, return *two* arrays, 
-- each containing half the original entries 

function split_array (a) 
   local r1 = {} 
   local r2 = {} 
   local a_len = #a 
   local mid = math.floor( a_len / 2)

   -- first half goes into r1

   for i = 1, mid do 
      r1[i] = a[i]              -- copy to r1
   end 

   for i = mid+1, a_len do 
      r2[i-mid] = a[i]          -- copy to r2, 
      -- but remember to slide the a entries over! 
   end 

   return r1,r2                 -- this works: it returns them both 
end 

-- merge_sort(a) 
-- splits the array a unless it is of length 0,1
-- and recursively merge_sorts each half
-- then it uses merge to combine the sorted halves.

-- This version does a good bit of copying.

function merge_sort (a) 
   if #a <= 1 then return a     -- too small to be unsorted 
   else 
      local a1, a2 = 
         split_array(a)         -- construct the two subproblems 

      return
      merge(                    -- merge the results 
         merge_sort(a1),        -- of solving them both 
         merge_sort(a2))        -- recursively
   end 
end 

--[[

Partition reorders a between left and right 
and returns a position i such that:

1.  Every value <= a[i] appears earlier than position i;

2.  Every value > a[i] appears later than position i.  

The value a[i] at the end will be the value at a[right] when the fn
was called.  This is called the *pivot*.  

--]]


function partition(a,left,right) 
   local pivot = a[right]       -- the value to divide "small" from "large"
   local i = left               -- the start of the large 
   for j = left, right-1 do 
      if a[j] <= pivot          -- a[j] is small 
      then 
         a[i],a[j]              -- swap the small value a[j] 
            = a[j],a[i]         -- with a[i], the first entry  
         i = i+1                -- not already known to be small
      end 
   end 
   a[i],a[right] = a[right],a[i] -- put the pivot at the boundary 
   return i
end 

function quicksort(a,left,right)
   if left < right
   then 
      q = partition(a,left,right)
      quicksort(a,left,q-1)
      quicksort(a,q+1,right)
   end 
end 

function qs(a) 
   quicksort(a,1,#a)
end 


function timing_test_harness (fn_to_test, test_arrays) 
   local result = {} 
   for i = 1, #test_arrays do 
      local start = os.clock() 
      fn_to_test(test_arrays[i]) 
      local finish = os.clock() 
      result[i] = finish-start 
      io.write(".") ; io.flush() 
   end 
   io.write("\n") ; io.flush() 
   return result 
end 

function make_test_vector (length, start, multiplier) 
   local result = {} 
   for i = 1, length do 
      result[i] = random_int_array(start+(i*multiplier), 1000000)
   end 
   return result
end 



--[[ partition instrumentation 

      print("i=", i, "j=", j)
      print_array(a)
      io.read() 

   print_array(a)

--]]

function partition_instr(a,left,right) 
   local pivot = a[right]       -- the value to divide "small" from "large"
   local i = left               -- the start of the large 
   for j = left, right-1 do 
      if a[j] <= pivot          -- a[j] is small 
      then 
         a[i],a[j]              -- swap the small value a[j] 
            = a[j],a[i]         -- with a[i], the first entry  
         i = i+1                -- not already known to be small
      end 
      print("i=", i, "j=", j)
      print_array(a)
      io.read() 
   end 
   a[i],a[right] = a[right],a[i] -- put the pivot at the boundary 
   print_array(a)
   return i
end 


--[[ 

Some examples

--]] 

--[[
a={7,6,5,4,3,2,1}

b={20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1} 

c={1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

d={1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 11, 13, 14, 15, 16, 17, 18, 19, 20}

e=random_int_array (7, 75)

f=random_int_array (20, 75)

g=random_int_array (200, 1000)

h=random_int_array (2000, 10000)

i=random_int_array (10000, 100000)

j=random_int_array (20000, 100000)


-- merge_sort(j)

qs_eg = {61, 29, 91, 70, 31, 25, 2, 63, 83, 24, 65, 51}
--]]
