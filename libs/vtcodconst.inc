const
  { TCOD_chars_t: custom characters that libtcod can draw }
  { single walls }
  TCOD_CHAR_VLINE = #179;
  TCOD_CHAR_HLINE = #196;
  TCOD_CHAR_NE = #191;
  TCOD_CHAR_NW = #218;
  TCOD_CHAR_SE = #217;
  TCOD_CHAR_SW = #192;
  { arrows }
  TCOD_CHAR_ARROW_E = #26;

  { Defined in TCOD_colctrl_t enum. }
  TCOD_COLCTRL_NUMBER: TCOD_colctrl_t = TCOD_COLCTRL_5;

  { TCOD_key_status_t flags can be combined when passed to TCOD_console_check_for_keypress. }
  TCOD_KEY_PRESSED = 1;
  TCOD_KEY_RELEASED = 2;
