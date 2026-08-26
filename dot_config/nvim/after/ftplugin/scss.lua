-- unlike css.vim, scss's stock ftplugin doesn't treat "-" as part of a
-- word, even though hyphenated names ($primary-color, .btn-primary) are
-- idiomatic scss
vim.opt_local.iskeyword:append("-")
