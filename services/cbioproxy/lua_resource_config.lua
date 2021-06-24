access_by_lua '

    local knownStudies = {}

-- curl /api/studies and extract all studies if available
    local userSessionId = ngx.var.cookie_JSESSIONID
    local cookie = ""
    if(userSessionId ~= nil) then
        cookie = "\\"JSESSIONID=" .. userSessionId .. "\\""
    end
    local command = [[ curl --cookie ]] .. cookie .. [[ "http://cbioportal:8080/api/studies" ]]
    print(command)
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()

    if(result ~= nil) then
        local i = 1
        for study in string.gmatch(result, "\\"studyId\\":\\"[^\\"]*\\"") do
            study = study:gsub("%\\"studyId\\":\\"", "")
            study = study:gsub("%\\"", "")
            knownStudies[i] = study
            i = i + 1
        end
    end

    local function has_value (tab, val)
        for index, value in ipairs(tab) do
            if value == val then
                return true
            end
        end
    
        return false
    end

    if not has_value(knownStudies, ngx.var.study) then
      ngx.status = 403
      ngx.say(err)
      ngx.exit(ngx.HTTP_FORBIDDEN)
    end

    return

';
