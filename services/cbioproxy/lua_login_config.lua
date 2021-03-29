content_by_lua '
    local knownStudies = {"MTB"}
    local roleString = ngx.ctx.user_roles
    local usernameString = ngx.ctx.user_name
    if (usernameString == nil) then usernameString = "Unknown" end
    if (roleString == nil) then roleString = "" end
    local foundStudyRoles = {}
    local foundPatientRoles = {}
    local hasNoPermission = false
    if (roleString == "no_roles") then hasNoPermission = true end

    local function has_value (table, val)
        for index, value in ipairs(table) do
            if value == val then
                return true
            end
        end
        return false
    end


    for role in string.gmatch(roleString, "%\\"(%a+)%\\"") do
        if(has_value(knownStudies, role)) then
            table.insert(foundStudyRoles, role)            
        else
            table.insert(foundPatientRoles, role)
        end
    end
    
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
