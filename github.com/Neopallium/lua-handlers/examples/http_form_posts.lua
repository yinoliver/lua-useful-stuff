-- Copyright (c) 2010-2011 by Robert G. Jakabosky <bobby@neoawareness.com>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

local httpclient = require'handler.http.client'
local form = require'handler.http.form'
local file = require'handler.http.file'
local ev = require'ev'
local loop = ev.Loop.default
local tremove = table.remove

local client = httpclient.new(loop,{
	user_agent = "HTTPClient tester"
})

local function on_response(req, resp)
	print('---- start response headers: status code =' .. resp.status_code)
	for k,v in pairs(resp.headers) do
		print(k .. ": " .. v)
	end
	print('---- end response headers')
end

local function on_data(req, resp, data)
	print('---- start response body')
	io.write(data)
	print('---- end response body')
end

local function on_finished(req, resp)
	print('====================== Finished POST request =================')
	loop:unloop()
end

local post_data = form.new{
first_name = "tester",
last_name = "smith",
RequestMethod="RemoveSessions",
SceneID="51985476-fc16-4d25-aadd-be67a2e0f980",
}

local req = client:request{
	method = 'POST',
	host = 'localhost',
	path = '/',
	body = post_data,
	on_response = on_response,
	on_data = on_data,
	on_finished = on_finished,
}

loop:loop()

