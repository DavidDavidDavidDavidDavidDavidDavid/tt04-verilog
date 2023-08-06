set ::env(DESIGN_NAME) tt_um_dcb277_ALU
set ::env(VERILOG_FILES) "\
    $::env(DESIGN_DIR)/tt_um_dcb277_ALU.v"

# Project area: 1x1 tiles
set ::env(DIE_AREA) "0 0 168.36 111.52"
set ::env(FP_DEF_TEMPLATE) "$::env(DESIGN_DIR)/../tt/def/tt_block_1x1.def"
