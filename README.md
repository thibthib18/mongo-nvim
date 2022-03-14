# 🌿 mongo-nvim 🌿
MongoDB Integration in Neovim.

**Browse MongoDB from Neovim! 🔎**

![mongonvim_compressed](https://user-images.githubusercontent.com/37300147/136668005-94f82166-20d3-484e-8868-4c1446a85689.gif)

## 🤩 Features
- Browse MongoDB databases with Telescope
- Browse a Mongo database's collections with Telescope
- Browse a collection's documents with Telescope
- Edit a picked document from Neovim

## 🦒 Requirements

- Nvim >= 0.5
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [lua-mongo](https://github.com/neoxic/lua-mongo)

Note: instructions to install `lua-mongo` [here](#installing-lua-mongo).

## 🏠 Installation

With your plugin manager of choice:

vim-plug:
```vim
Plug 'thibthib18/mongo-nvim'
```
Packer:
```lua
use { 'thibthib18/mongo-nvim', rocks = {'lua-mongo'}, config=function()
  require 'mongo-nvim'.setup({})
}
```

## ⚙️  Setup

In Lua:
```lua
require 'mongo-nvim'.setup {
  -- connection string to your mongodb
  connection_string = "mongodb://127.0.0.1:27017",
  -- key to use for previewing/picking documents
  -- either a string or custom table of string or functions
  list_document_key = "_id"
  -- delete selected document in document_picker
  delete_document_mapping = nil -- "<c-d>"
}
```

In Vim, simply enclose it in a lua block:
```vim
lua << EOF
require 'mongo-nvim'.setup {
  -- connection string to your mongodb
  connection_string = "mongodb://127.0.0.1:27017",
  -- key to use for previewing/picking documents
  -- either a string or custom table of string or functions
  list_document_key = "_id"
  -- delete selected document in document_picker
  delete_document_mapping = nil -- "<c-d>"
}
EOF
```
Note: instructions to install `lua-mongo` [here](#installing-lua-mongo).

## ⚙️  Config

```vim
" List available databases
nnoremap <leader>dbl <cmd>lua require('mongo-nvim.telescope.pickers').database_picker()<cr>
" List collections in database (arg: database name)
nnoremap <leader>dbcl <cmd>lua require('mongo-nvim.telescope.pickers').collection_picker('examples')<cr>
" List documents in a database's collection (arg: database name, collection name)
nnoremap <leader>dbdl <cmd>lua require('mongo-nvim.telescope.pickers').document_picker('examples', 'movies')<cr>
```

The demo GIF above was made with the database from [MongoDB Getting started page] (https://docs.mongodb.com/manual/tutorial/getting-started/).

### `list_document_key`

`list_document_key` is used by the `collection_picker` preview and `document_picker` to filter documents based on this key. For this movies collection, setting `list_document_key` to `"title"` thus lets you select the movie documents by their title. If not set, `_id` will be used as it is present for every document.

Two types of values are accepted for `list_document_key`: string or table.

For a simple/homogeneous database or usage, where all documents will share a common field, setting `list_document_key` to this field's name will do.

To handle a more heterogenous structure, it is preferrable to set `list_document_key` as a table of the form:

```lua
  list_document_key = {
    database1 = {
      collection1 = "someFieldName", -- string to be used as key
      collection2 = function(document) -- function taking a document table, returns a string
        return document.value1
      end
    }
    database2 = {
      ...
    }
  }
```

If `list_document_key[databaseName][collectionName]` is a string, the document will be represented by the value at this key.

If `list_document_key[databaseName][collectionName]` is a function taking a document parameter, the document will be represented by the return value of this function.

In any other case, the `_id` will be used.

Example: We have a `persons` database, containing 2 collections: `students` and `employees`. For the `students`, we'd like to see their field `name`. For `employees`, we'd like to use both their `department` and `role`. To achieve this, use the following `list_document_key`:

```lua
  list_document_key = {
    persons = {
      students = "name",
      employees = function(document)
        return document.department .. " " .. document.role
      end,
  }
```

## Installing lua-mongo
First, make sure you have `luarocks` installed, or install via your package manager, e.g. for Ubuntu:

```sudo apt install luarocks```


### Install Mongo C driver
Lua-mongo depends on Mongo C driver and LibBSON. The latter is part of Mongo C driver, so we only need to install the former.

From package manager (couldn't get this to work nicely on Ubuntu 18.04, fall back to install from source):
[official instructions](http://mongoc.org/libmongoc/current/installing.html#install-libmongoc-with-a-package-manager)

From source:

```shell
git clone https://github.com/mongodb/mongo-c-driver.git
cd mongo-c-driver
python build/calc_release_version.py > VERSION_CURRENT
mkdir cmake-build
cd cmake-build
cmake -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF ..
make
sudo make install
```

Note: On Ubuntu 18.04, `libzstd` and `libssl` might be missing, install them with:

```shell
sudo apt install libzstd-dev libssl-dev
```

We're now ready to install lua-mongo:

```sudo luarocks install lua-mongo```

## Roadmap

- [x] Delete document
- [ ] Refresh document (if possible on update)
