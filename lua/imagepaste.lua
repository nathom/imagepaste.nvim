local M = {}
local syntax = nil
local image_path = nil
local resources_folder = nil

local function vim_error(msg)
    vim.cmd("echohl Error")
    vim.cmd('echomsg "' .. msg .. '"')
    vim.cmd("echohl None")
end
local image_syntax = {
    md = { "![](", ")" },
    tex = { [[\includegraphics[width=\linewidth]{]], "}" },
}

function M.paste_image()
    local path = vim.api.nvim_buf_get_name(0)
    local ext = path:match("%S%.(%w+)$")
    syntax = image_syntax[ext]

    if not syntax then
        if ext == nil then
            ext = "empty"
        end
        print("ImagePaste not available for " .. tostring(ext) .. " files")
        return
    end

    local folder = path:match("(.+)/")
    resources_folder = path:match("(.+)%.") .. "_resources"
    os.execute("mkdir '" .. resources_folder .. "' 2> /dev/null")
    image_path = random_string(32) .. ".jpg"
    local command = "pngpaste " .. "'" .. image_path .. "'"

    vim.fn.jobstart(command, {
        cwd = resources_folder,
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
    local formatted_link = syntax[1]
        .. resources_folder:match(".+/(.+)")
        .. "/"
        .. image_path
        .. syntax[2]
    local prev_reg = vim.fn.getreg("z")
    vim.fn.setreg("z", formatted_link)
    vim.cmd([[normal! "zp]])
    -- vim.cmd("put z")
    vim.fn.setreg("z", prev_reg)
end

local function on_event(job_id, data, event)
    local error_msg = table.concat(data, "")
    vim_error(error_msg)
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
