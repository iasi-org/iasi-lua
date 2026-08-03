local Compiler = {}
local function trim(v) return (v:gsub("/+$","")) end
local function hex(v) return (v:gsub(".",function(c) return string.format("%02x",string.byte(c)) end)) end
local function styles(v) if v==nil then return {} end; if type(v)=="table" then return v end; return {tostring(v)} end
local function read(path) local f,m=io.open(path,"rb"); if f==nil then error("No se pudo leer el estilo PlantUML "..tostring(path)..": "..tostring(m)) end; local c=f:read("*a"); f:close(); return c end
local function inject(source,style) if style=="" then return source end; local _,e=source:find("@startuml[^\r\n]*"); if e==nil then return style.."\n"..source end; return source:sub(1,e).."\n"..style.."\n"..source:sub(e+1) end
function Compiler.prepare(source,config) local s=styles(config.styles); if #s==0 then return source end; local f={}; for _,p in ipairs(s) do table.insert(f,read(tostring(p))) end; return inject(source,table.concat(f,"\n")) end
function Compiler.mime_type(config) if tostring(config.format)=="svg" then return "image/svg+xml" end; error("Formato PlantUML no soportado: "..tostring(config.format)) end
function Compiler.compile(source,config)
  local format=tostring(config.format); if format~="svg" then error('Formato PlantUML no soportado: '..format..'. Use "svg".') end
  local url=trim(tostring(config.server)).."/"..format.."/~h"..hex(source)
  local ok,mime,contents=pcall(pandoc.mediabag.fetch,url)
  if not ok then error("No se pudo obtener el diagrama PlantUML.\nURL: "..url.."\nDetalle: "..tostring(mime)) end
  if contents==nil or contents=="" then error("PlantUML devolvio una respuesta vacia: "..url) end
  return mime or Compiler.mime_type(config),contents
end
return Compiler
