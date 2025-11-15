local clip_setup = require("clipboard-image").setup
local paste_img = require("clipboard-image.paste").paste_img

describe("this plugin", function()
  it("should paste correctly with the default setup", function()
    -- Copy image to clipboard
    print(vim.fn.system { './test/copy-img2clipboard.sh', 'test/expected.png' })

    -- Idk why but test start at line 0. So I move it to line 1 with this
    vim.cmd [[norm o]]

    clip_setup { default = { img_name = "image" }}
    paste_img()

    local current_line = vim.fn.getline('.')
    assert.are.equal("img/image.png", current_line)
  end)

  it("should respect img_dir_relative_to_buffer setting", function()
    -- Copy image to clipboard
    print(vim.fn.system { './test/copy-img2clipboard.sh', 'test/expected.png' })

    -- Create a test file in a subdirectory
    vim.cmd [[enew]]
    local test_file = vim.fn.tempname() .. "/subdir/test.md"
    vim.fn.mkdir(vim.fn.fnamemodify(test_file, ":h"), "p")
    vim.cmd("edit " .. test_file)
    vim.cmd [[norm o]]

    clip_setup { 
      default = { 
        img_name = "image",
        img_dir = "assets",
        img_dir_txt = "assets",
        img_dir_relative_to_buffer = true
      }
    }
    paste_img()

    local current_line = vim.fn.getline('.')
    assert.are.equal("![](assets/image.png)", current_line)
    
    -- Verify the directory was created relative to buffer
    local expected_dir = vim.fn.fnamemodify(test_file, ":h") .. "/assets"
    assert.are.equal(1, vim.fn.isdirectory(expected_dir))
  end)

  it("should allow file-level override of img_dir_relative_to_buffer", function()
    -- Copy image to clipboard
    print(vim.fn.system { './test/copy-img2clipboard.sh', 'test/expected.png' })

    vim.cmd [[enew]]
    local test_file = vim.fn.tempname() .. "/override/test.md"
    vim.fn.mkdir(vim.fn.fnamemodify(test_file, ":h"), "p")
    vim.cmd("edit " .. test_file)
    vim.cmd [[norm o]]

    clip_setup { 
      default = { 
        img_name = "image",
        img_dir = "global",
        img_dir_relative_to_buffer = false
      }
    }
    
    -- Override at paste time
    paste_img({ 
      img_dir = "local",
      img_dir_txt = "local",
      img_dir_relative_to_buffer = true
    })

    local current_line = vim.fn.getline('.')
    assert.are.equal("![](local/image.png)", current_line)
    
    -- Verify the directory was created relative to buffer
    local expected_dir = vim.fn.fnamemodify(test_file, ":h") .. "/local"
    assert.are.equal(1, vim.fn.isdirectory(expected_dir))
  end)
end)
