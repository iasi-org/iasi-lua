local Filesystem = {}
function Filesystem.ensure_directory(path) pandoc.system.make_directory(path, true) end
function Filesystem.exists(path) local f=io.open(path,"rb"); if f==nil then return false end; f:close(); return true end
function Filesystem.read(path) local f,m=io.open(path,"rb"); if f==nil then error("No se pudo leer "..path..": "..tostring(m)) end; local c=f:read("*a"); f:close(); return c end
function Filesystem.write(path, contents) Filesystem.ensure_directory(pandoc.path.directory(path)); local f,m=io.open(path,"wb"); if f==nil then error("No se pudo escribir "..path..": "..tostring(m)) end; f:write(contents); f:close() end
function Filesystem.clean_directory(path) Filesystem.ensure_directory(path); for _,e in ipairs(pandoc.system.list_directory(path)) do local t=pandoc.path.join({path,e}); local ok,m=os.remove(t); if not ok then error("No se pudo eliminar "..t..": "..tostring(m)) end end end
return Filesystem
