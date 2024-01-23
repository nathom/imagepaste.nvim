# imagepaste.nvim

> Not tested across platforms yet!

Paste images from your clipboard into the buffer.

Supported filetypes:

- [x] LaTeX
- [x] markdown


## Setup

With lazy.nvim:

```lua
return { "nathom/imagepaste.nvim" }
```

## Usage

The plugin only sets up one macro, `<leader>ip`, which does the following

- create a `resources` directory in project root
- Fetch the image from clipboard and write it to a file
- Format the image link correctly based on the filetype and write to buffer
