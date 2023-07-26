-- Get the list of open project file paths in Reaper

function get_open_projects()
  local projects = {}
  local project_count = reaper.CountProjects(0)
  for i = 0, project_count - 1 do
    local project = reaper.EnumProjects(i, "")
    if project then
      local _, project_path = reaper.GetProjectName(0, project, "")
      if project_path ~= "" then
        table.insert(projects, project_path)
      end
    end
  end
  return projects
end

local projects = get_open_projects()

-- Write the list of open projects to a temporary file
local file = io.open("open_projects.txt", "w")
for _, path in ipairs(projects) do
  file:write(path .. "\n")
end
file:close()
