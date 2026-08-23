return {
  {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },

    version = '1.*', --force v1 while v2 is in heavy dev

    --@module 'blink.cmp'
    --@type blink.cmp.Config
    opts = {
      keymap = { preset = 'super-tab' }, --tab to accept suggestion
      appearance = { nerd_font_variant = 'mono' }
    }
  }
}
