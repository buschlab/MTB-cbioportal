content_by_lua '
    local roleString = ngx.ctx.user_roles
    local usernameString = ngx.ctx.user_name
    if (usernameString == nil) then usernameString = "Unknown" end
    if (roleString == nil) then roleString = "" end
    local knownStudies = {}
    local manuallyKnownStudies = {"MTB"}
    local foundStudyRoles = {}
    local foundPatientRoles = {}
    local hasNoPermission = false
    if (roleString == "no_roles") then hasNoPermission = true end

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

    if (knownStudies == nil or #knownStudies == 0) then
        knownStudies = manuallyKnownStudies 
    end

    -- function to check whether a table contains a specific value
    local function has_value (table, val)
        for index, value in ipairs(table) do
            if value == val then
                return true
            end
        end
        return false
    end

    -- start checking whether a user role is a study-role or not
    for role in string.gmatch(roleString, "%\\"(%a+)%\\"") do
        if(has_value(knownStudies, role)) then
            table.insert(foundStudyRoles, role)            
        else
            table.insert(foundPatientRoles, role)
        end
    end

    -- starting to build up the html login file
    local studyRolesAsString = ""
    local patientRolesAsString = ""
    
    for i, role in ipairs(foundStudyRoles) do 
        studyRolesAsString = studyRolesAsString .. role
        if i ~= #foundStudyRoles then studyRolesAsString = studyRolesAsString .. ", " end
    end

    for i, role in ipairs(foundPatientRoles) do 
        patientRolesAsString = patientRolesAsString .. role
        if i ~= #foundPatientRoles then patientRolesAsString = patientRolesAsString .. ", " end
    end
    
    local studyRolesHtml = [[ <p>You have the permission to edit MTB-sessions in the following studies:</p><p><i> ]] .. studyRolesAsString .. [[ </i></p> ]]

    local patientRolesHtml = [[ <p>You have the permission to edit MTB-sessions for the following patients:</p><p><i> ]] .. patientRolesAsString .. [[ </i></p> ]]

    local noPermissionHtml = [[ <p>You have <i>no permission</i> to edit any MTB-session.</p><p></br> ]]

    local roleSectionHtml = ""
    if hasNoPermission == true then roleSectionHtml = noPermissionHtml 
    else
        if #foundStudyRoles >=1 then roleSectionHtml = roleSectionHtml .. studyRolesHtml .. "</br>" end
        if #foundPatientRoles >=1 then roleSectionHtml = roleSectionHtml .. patientRolesHtml .. "</br>" end
    end

    local loginPage = [[ 
        <!DOCTYPE html>
        <html>
            <head>
                <title>User Info</title>
            </head>
            <body>
                <h1>User Info</h1>
                </br>
                <p>You are logged in as: </p>
                <p><i id="user"> ]] .. usernameString .. [[ </i></p>
                </br> ]]
                 .. roleSectionHtml .. 
                [[ <p>If you do not have the permission you need, contact your local MTB administrator.</p>
                <p>You can close this tab now and continue in cBioPortal.</p>
                <p>Or you can <a href="/mtb/logout">logout here</a>.</p>
            </body>
        </html>
    ]]
    ngx.say(loginPage)
';
