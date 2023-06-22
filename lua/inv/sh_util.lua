function SaveFile(filePath, table)
  local fileJson = util.TableToJSON(table)
  file.Write(filePath, fileJson)
end

function LoadFile(filePath)
  if (!file.Exists(filePath, "DATA")) then return {} end
  local fileJson = file.Read(filePath, "DATA")
  local fileTable = util.JSONToTable(fileJson)
  return fileTable
end

function SendCompressedTableCl(networkStr, sendTo, table)
  local data = util.Compress(util.TableToJSON(table))
  net.Start(networkStr)
    net.WriteData(data)
  net.Send(sendTo)
end

function AddToTable(tbl, val)
  table.insert(tbl, val)
end

function RemoveByValue(tbl, val)
  table.RemoveByValue(tbl, val)
end

function HasValue(tbl, val)
  return table.HasValue(tbl, val)
end

function ParseAddArgs(tbl, args)
  if (#args < 1) then return end
  local str = args[1]
  if (!isstring(str)) then return end

  if (#args == 2) then
    local times = tonumber(args[2])
    if (!isnumber(times) || times == 0) then return end

    for i = 1, times do
        AddToTable(tbl, str)
    end
  else
    AddToTable(tbl, str)
  end
end

function ParseRemoveArgs(tbl, args)
  if (#args < 1) then return end
  local str = args[1]
  if (!isstring(str)) then return end

  if (#args == 2) then
    local times = tonumber(args[2])
    if (!isnumber(times) || times == 0) then return end

    for i = 1, times do
        RemoveByValue(tbl, str)
    end
  else
    RemoveByValue(tbl, str)
  end
end
