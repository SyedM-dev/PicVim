local M = {}

local stdout = vim.loop.new_tty(1, false)
if not stdout then
  error "failed to open stdout"
end

local uv = vim.uv
if not uv then
  uv = vim.loop
end

local Image = {}
Image.__index = Image

function Image:new(filepath)
  local obj = setmetatable({}, self)
  obj.filepath_o = filepath
  obj.filepath = filepath
  obj.properties = {}
  obj.properties.zoom = 0.9
  obj.properties.o_x = 0
  obj.properties.o_y = 0
  obj.properties.rotation = 0
  return obj
end

function Image:draw(x, y, w, h)
  self.properties.w = w
  self.properties.h = h
  self:pngify()
  self:rescale()
  local file = io.open(self.filepath, "rb")
  if not file then
    print "Error: Could not open file."
    return
  end
  local data = file:read "*all"
  file:close()
  local encoded_data = vim.base64.encode(data):gsub("%/", "/")
  local pos = 1
  local chunk_size = 4096
  stdout:write "\27_Ga=d\27\\"
  stdout:write("\27[" .. x + 2 .. ";" .. y + 4 .. "H")
  while pos <= #encoded_data do
    local chunk = encoded_data:sub(pos, pos + chunk_size - 1)
    pos = pos + chunk_size
    local m = (pos <= #encoded_data) and "1" or "0"
    local cmd
    cmd = "\27_Ga=T,r=" .. h .. ",c=" .. w .. ",C=1,f=100,m=" .. m .. ";" .. chunk .. "\27\\"
    stdout:write(cmd)
    uv.sleep(1)
  end
  stdout:write "\x1b[H"
  vim.cmd "redraw"
end

function Image:unload()
  stdout:write "\27_Ga=d\27\\"
end

function Image:rescale()
  local w, h = self.properties.w, self.properties.h
  local o_x, o_y = self.properties.o_x, self.properties.o_y
  local rotation = self.properties.rotation
  local temp_file = "/tmp/gg_1.png"
  if vim.fn.filereadable(temp_file) == 1 then
    vim.fn.delete(temp_file)
  end
  local crop_offset_x = o_x >= 0 and "+" .. o_x or tostring(o_x)
  local crop_offset_y = o_y >= 0 and "+" .. o_y or tostring(o_y)
  local gravity = "center"
  if o_x > 0 and o_y > 0 then
    gravity = "northwest"
  elseif o_x < 0 and o_y > 0 then
    gravity = "northeast"
  elseif o_x > 0 and o_y < 0 then
    gravity = "southwest"
  elseif o_x < 0 and o_y < 0 then
    gravity = "southeast"
  elseif o_x > 0 then
    gravity = "west"
  elseif o_x < 0 then
    gravity = "east"
  elseif o_y > 0 then
    gravity = "north"
  elseif o_y < 0 then
    gravity = "south"
  end
  local r_w, r_h = w * self.properties.zoom * 10, h * self.properties.zoom * 23
  local cmd = string.format(
    "magick %s -resize %dx%d -background none -rotate %d -gravity center -background none -extent %dx%d -gravity center -crop %dx%d%s%s +repage -gravity %s -background none -extent %dx%d %s",
    self.filepath,
    r_w,
    r_h,
    rotation,
    w * 10,
    h * 23,
    w * 10,
    h * 23,
    crop_offset_x,
    crop_offset_y,
    gravity,
    w * 10,
    h * 23,
    temp_file
  )
  local result = vim.fn.system(cmd)
  if vim.v.shell_error == 0 then
    self.filepath = temp_file
  else
    vim.api.nvim_err_writeln("Error converting image: " .. result)
    self.filepath = ""
  end
end

function Image:pngify()
  local temp_file = "/tmp/gg.png"
  if vim.fn.filereadable(temp_file) == 1 then
    vim.fn.delete(temp_file)
  end
  local file_type = vim.fn.fnamemodify(self.filepath_o, ":e")
  local cmd
  if file_type == "png" then
    self.filepath = self.filepath_o
    return
  end
  if file_type == "gif" then
    cmd = string.format("magick %s[0] %s", self.filepath_o, temp_file)
  else
    cmd = string.format("magick %s %s", self.filepath_o, temp_file)
  end
  local result = vim.fn.system(cmd)
  if vim.v.shell_error == 0 then
    self.filepath = temp_file
  else
    vim.api.nvim_err_writeln("Error converting image: " .. result)
    self.filepath = ""
  end
end

function M.setup()
  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.png,*.jpg,*.jpeg,*.gif,*.bmp",
    callback = function()
      if not vim.b.img then
        vim.b.img = Image:new(vim.fn.expand "%:p")
      end
      local redrawing = false
      vim.cmd "setlocal buftype=nofile"
      vim.cmd "setlocal nonumber"
      vim.cmd "setlocal norelativenumber"
      vim.cmd "setlocal modifiable"
      local buf = vim.api.nvim_get_current_buf()
      local function redraw()
        if redrawing then
          return
        end
        redrawing = true
        vim.defer_fn(function()
          if not vim.b.img then
            vim.b.img = Image:new(vim.fn.expand "%:p")
          end
          local image = vim.b.img
          if image then
            setmetatable(image, Image)
          end
          local win_id = vim.api.nvim_get_current_win()
          local cursor = vim.api.nvim_win_get_position(win_id)
          local x, y = cursor[1], cursor[2]
          local win = vim.api.nvim_get_current_win()
          local window_height = vim.api.nvim_win_get_height(win)
          local window_width = vim.api.nvim_win_get_width(win)
          image:draw(x, y, window_width - 6, window_height - 1)
          vim.b.img = image
          redrawing = false
        end, 5)
      end
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
      vim.cmd "setlocal nomodifiable"
      vim.keymap.set("n", "=", function()
        if redrawing then
          return
        end
        local image = vim.b.img
        if image.properties.zoom < 1 then
          image.properties.zoom = math.min(image.properties.zoom + 0.2, 1)
          vim.b.img = image
          redraw()
        end
      end, { buffer = buf, noremap = true, silent = true })
      vim.keymap.set("n", "-", function()
        if redrawing then
          return
        end
        local image = vim.b.img
        if image.properties.zoom > 0.1 then
          image.properties.zoom = math.max(image.properties.zoom - 0.2, 0.1)
          vim.b.img = image
          redraw()
        end
      end, { buffer = buf, noremap = true, silent = true })
      local win = vim.api.nvim_get_current_win()
      local window_height = vim.api.nvim_win_get_height(win)
      local window_width = vim.api.nvim_win_get_width(win)
      local MAX_OFFSET_X = (window_width * 10) - 150
      local MIN_OFFSET_X = (-window_width * 10) + 150
      local MAX_OFFSET_Y = (window_height * 23) - 150
      local MIN_OFFSET_Y = (-window_height * 23) + 150
      vim.keymap.set("n", "<Left>", function()
        if redrawing then
          return
        end
        local image = vim.b.img
        if image.properties.o_x < MAX_OFFSET_X then
          image.properties.o_x = math.min(image.properties.o_x + 30, MAX_OFFSET_X)
          vim.b.img = image
          redraw()
        end
      end, { buffer = buf, noremap = true, silent = true })
      vim.keymap.set("n", "<Right>", function()
        if redrawing then
          return
        end
        local image = vim.b.img
        if image.properties.o_x > MIN_OFFSET_X then
          image.properties.o_x = math.max(image.properties.o_x - 30, MIN_OFFSET_X)
          vim.b.img = image
          redraw()
        end
      end, { buffer = buf, noremap = true, silent = true })
      vim.keymap.set("n", "<Down>", function()
        if redrawing then
          return
        end
        local image = vim.b.img
        if image.properties.o_y > MIN_OFFSET_Y then
          image.properties.o_y = math.max(image.properties.o_y - 30, MIN_OFFSET_Y)
          vim.b.img = image
          redraw()
        end
      end, { buffer = buf, noremap = true, silent = true })
      vim.keymap.set("n", "<Up>", function()
        if redrawing then
          return
        end
        local image = vim.b.img
        if image.properties.o_y < MAX_OFFSET_Y then
          image.properties.o_y = math.min(image.properties.o_y + 30, MAX_OFFSET_Y)
          vim.b.img = image
          redraw()
        end
      end, { buffer = buf, noremap = true, silent = true })
      vim.keymap.set("n", "t", function()
        if redrawing then
          return
        end
        local image = vim.b.img
        image.properties.rotation = (image.properties.rotation + 30) % 360
        vim.b.img = image
        redraw()
      end, { buffer = buf, noremap = true, silent = true })
      vim.keymap.set("n", "T", function()
        if redrawing then
          return
        end
        local image = vim.b.img
        image.properties.rotation = (image.properties.rotation - 30) % 360
        vim.b.img = image
        redraw()
      end, { buffer = buf, noremap = true, silent = true })
      vim.keymap.set("n", "o", function()
        if redrawing then
          return
        end
        local image = vim.b.img
        image.properties.o_x = 0
        image.properties.o_y = 0
        image.properties.rotation = 0
        vim.b.img = image
        redraw()
      end, { buffer = buf, noremap = true, silent = true })
      vim.keymap.set("n", "r", function()
        redraw()
      end, { buffer = buf, noremap = true, silent = true })
      vim.b.no_git_diff = true
      redraw()
    end,
  })
  vim.api.nvim_create_autocmd("VimResized", {
    pattern = "*.png,*.jpg,*.jpeg,*.gif,*.bmp",
    callback = function()
      if not vim.b.img then
        vim.b.img = Image:new(vim.fn.expand "%:p")
      end
      local image = vim.b.img
      if image then
        setmetatable(image, Image)
      end
      local win_id = vim.api.nvim_get_current_win()
      local cursor = vim.api.nvim_win_get_position(win_id)
      local x, y = cursor[1], cursor[2]
      local win = vim.api.nvim_get_current_win()
      local window_height = vim.api.nvim_win_get_height(win)
      local window_width = vim.api.nvim_win_get_width(win)
      image:draw(x, y, window_width - 6, window_height - 1)
      vim.b.img = image
    end,
  })
  vim.api.nvim_create_autocmd("BufLeave", {
    pattern = "*",
    callback = function()
      local image = vim.b.img
      if image then
        setmetatable(image, Image)
      end
      if image and image.unload then
        image:unload()
      end
    end,
  })
end

return M
