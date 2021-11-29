local M = {}
local syntax = nil
local image_path = nil

local function vim_error(msg)
    vim.cmd("echohl Error")
    vim.cmd('echomsg "' .. msg .. '"')
    vim.cmd("echohl None")
end
local image_syntax = {
    md = { "![](", ")" },
}
function M.paste_image()
    local path = vim.fn.expand("%:p")
    local ext = path:match("%S%.(%w+)$")
    syntax = image_syntax[ext]

    if not syntax then
        error("invalid file extension")
    end

    local folder = vim.fn.expand("%:p:h")
    image_path = folder .. "/" .. random_string(16) .. ".jpg"
    local command = "pngpaste " .. '"' .. image_path .. '"'

    vim.fn.jobstart(command, {
        on_stderr = on_event,
        on_stdout = on_event,
        on_exit = put_text,
        stdout_buffered = true,
        stderr_buffered = true,
    })
end

function put_text(job_id, exit_code)
    -- print(exit_code)
    if exit_code ~= 0 then
        vim_error("No image on clipboard!")
        return
    end
    local formatted_link = syntax[1] .. image_path .. syntax[2]
    local prev_reg = vim.fn.getreg("z")
    vim.fn.setreg("z", formatted_link)
    vim.cmd("put z")
    vim.fn.setreg("z", prev_reg)
end

local function on_event(job_id, data, event)
    if event == "stdout" or event == "stderr" then
        local error_msg = table.concat(data, "")
        vim_error(error_msg)
    end
    -- for _, d in ipairs(data) do
    --     print(d)
    -- end
end

math.randomseed(os.time())
function random_string(length)
    local res = ""
    for i = 1, length do
        res = res .. string.char(math.random(97, 122))
    end
    return res
end

return M
