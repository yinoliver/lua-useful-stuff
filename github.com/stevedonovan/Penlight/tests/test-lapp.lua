
local test = require 'pl.test'
local lapp = require 'pl.lapp'
local utils = require 'pl.utils'
local tablex = require 'pl.tablex'

local k = 1
function check (spec,args,match)
    local args = lapp(spec,args)
    for k,v in pairs(args) do
        if type(v) == 'userdata' then args[k]:close(); args[k] = '<file>' end
    end
    test.asserteq(args,match,nil,1)
end

-- force Lapp to throw an error, rather than just calling os.exit()
lapp.show_usage_error = 'throw'

function check_error(spec,args,msg)
    arg = args
    local ok,err = pcall(lapp,spec)
    test.assertmatch(err,msg)
end

local parmtest = [[
Testing 'array' parameter handling
    -o,--output... (string)
    -v...
]]


check (parmtest,{'-o','one'},{output={'one'},v={false}})
check (parmtest,{'-o','one','-v'},{output={'one'},v={true}})
check (parmtest,{'-o','one','-vv'},{output={'one'},v={true,true}})
check (parmtest,{'-o','one','-o','two'},{output={'one','two'},v={false}})


local simple = [[
Various flags and option types
    -p          A simple optional flag, defaults to false
    -q,--quiet  A simple flag with long name
    -o  (string)  A required option with argument
    <input> (default stdin)  Optional input file parameter...
]]

check(simple,
    {'-o','in'},
    {quiet=false,p=false,o='in',input='<file>'})

check(simple,
    {'-o','help','-q','test-lapp.lua'},
    {quiet=true,p=false,o='help',input='<file>',input_name='test-lapp.lua'})

local longs = [[
    --open (string)
]]

check(longs,{'--open','folder'},{open='folder'})

local extras1 = [[
    <files...> (string) A bunch of files
]]

check(extras1,{'one','two'},{files={'one','two'}})

-- any extra parameters go into the array part of the result
local extras2 = [[
    <file> (string) A file
]]

check(extras2,{'one','two'},{file='one','two'})

local extended = [[
    --foo (string default 1)
    -s,--speed (slow|medium|fast default medium)
    -n (1..10 default 1)
    -p print
    -v verbose
]]


check(extended,{},{foo='1',speed='medium',n=1,p=false,v=false})
check(extended,{'-pv'},{foo='1',speed='medium',n=1,p=true,v=true})
check(extended,{'--foo','2','-s','fast'},{foo='2',speed='fast',n=1,p=false,v=false})
check(extended,{'--foo=2','-s=fast','-n2'},{foo='2',speed='fast',n=2,p=false,v=false})

check_error(extended,{'--speed','massive'},"value 'massive' not in slow|medium|fast")

check_error(extended,{'-n','x'},"unable to convert to number: x")

check_error(extended,{'-n','12'},"n out of range")

local with_dashes = [[
  --first-dash  dash
  --second-dash dash also
]]

check(with_dashes,{'--first-dash'},{first_dash=true,second_dash=false})

-- optional parameters don't have to be set
local optional = [[
  -p (optional string)
]]

check(optional,{'-p', 'test'},{p='test'})
check(optional,{},{})

-- boolean flags may have a true default...
local false_flag = [[
    -g group results
    -f (default true) force result
]]

check (false_flag,{},{f=true,g=false})

check (false_flag,{'-g','-f'},{f=false,g=true})

local addtype = [[
  -l (intlist) List of items
]]

-- defining a custom type
lapp.add_type('intlist',
              function(x)
                 return tablex.imap(tonumber, utils.split(x, '%s*,%s*'))
              end,
              function(x)
                 for _,v in ipairs(x) do
                    lapp.assert(math.ceil(v) == v,'not an integer!')
                 end
              end)

check(addtype,{'-l', '1,2,3'},{l={1,2,3}})

check_error(addtype,{'-l', '1.5,2,3'},"not an integer!")

