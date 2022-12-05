# _hw.tcl file for dnn_accel_system
package require -exact qsys 14.0

# module properties
set_module_property NAME {dnn_accel_system_export}
set_module_property DISPLAY_NAME {dnn_accel_system_export_display}

# default module properties
set_module_property VERSION {1.0}
set_module_property GROUP {default group}
set_module_property DESCRIPTION {default description}
set_module_property AUTHOR {author}

set_module_property COMPOSITION_CALLBACK compose
set_module_property opaque_address_map false

proc compose { } {
    # Instances and instance parameters
    # (disabled instances are intentionally culled)
    add_instance clk_0 clock_source 19.1
    set_instance_parameter_value clk_0 {clockFrequency} {50000000.0}
    set_instance_parameter_value clk_0 {clockFrequencyKnown} {1}
    set_instance_parameter_value clk_0 {resetSynchronousEdges} {NONE}

    add_instance dnn_accel_system altera_nios2_gen2 19.1
    set_instance_parameter_value dnn_accel_system {bht_ramBlockType} {Automatic}
    set_instance_parameter_value dnn_accel_system {breakOffset} {32}
    set_instance_parameter_value dnn_accel_system {breakSlave} {None}
    set_instance_parameter_value dnn_accel_system {cdx_enabled} {0}
    set_instance_parameter_value dnn_accel_system {cpuArchRev} {1}
    set_instance_parameter_value dnn_accel_system {cpuID} {0}
    set_instance_parameter_value dnn_accel_system {cpuReset} {0}
    set_instance_parameter_value dnn_accel_system {data_master_high_performance_paddr_base} {0}
    set_instance_parameter_value dnn_accel_system {data_master_high_performance_paddr_size} {0.0}
    set_instance_parameter_value dnn_accel_system {data_master_paddr_base} {0}
    set_instance_parameter_value dnn_accel_system {data_master_paddr_size} {0.0}
    set_instance_parameter_value dnn_accel_system {dcache_bursts} {false}
    set_instance_parameter_value dnn_accel_system {dcache_numTCDM} {0}
    set_instance_parameter_value dnn_accel_system {dcache_ramBlockType} {Automatic}
    set_instance_parameter_value dnn_accel_system {dcache_size} {2048}
    set_instance_parameter_value dnn_accel_system {dcache_tagramBlockType} {Automatic}
    set_instance_parameter_value dnn_accel_system {dcache_victim_buf_impl} {ram}
    set_instance_parameter_value dnn_accel_system {debug_OCIOnchipTrace} {_128}
    set_instance_parameter_value dnn_accel_system {debug_assignJtagInstanceID} {0}
    set_instance_parameter_value dnn_accel_system {debug_datatrigger} {0}
    set_instance_parameter_value dnn_accel_system {debug_debugReqSignals} {0}
    set_instance_parameter_value dnn_accel_system {debug_enabled} {1}
    set_instance_parameter_value dnn_accel_system {debug_hwbreakpoint} {0}
    set_instance_parameter_value dnn_accel_system {debug_jtagInstanceID} {0}
    set_instance_parameter_value dnn_accel_system {debug_traceStorage} {onchip_trace}
    set_instance_parameter_value dnn_accel_system {debug_traceType} {none}
    set_instance_parameter_value dnn_accel_system {debug_triggerArming} {1}
    set_instance_parameter_value dnn_accel_system {dividerType} {no_div}
    set_instance_parameter_value dnn_accel_system {exceptionOffset} {32}
    set_instance_parameter_value dnn_accel_system {exceptionSlave} {onchip_memory2_0.s1}
    set_instance_parameter_value dnn_accel_system {fa_cache_line} {2}
    set_instance_parameter_value dnn_accel_system {fa_cache_linesize} {0}
    set_instance_parameter_value dnn_accel_system {flash_instruction_master_paddr_base} {0}
    set_instance_parameter_value dnn_accel_system {flash_instruction_master_paddr_size} {0.0}
    set_instance_parameter_value dnn_accel_system {icache_burstType} {None}
    set_instance_parameter_value dnn_accel_system {icache_numTCIM} {0}
    set_instance_parameter_value dnn_accel_system {icache_ramBlockType} {Automatic}
    set_instance_parameter_value dnn_accel_system {icache_size} {4096}
    set_instance_parameter_value dnn_accel_system {icache_tagramBlockType} {Automatic}
    set_instance_parameter_value dnn_accel_system {impl} {Tiny}
    set_instance_parameter_value dnn_accel_system {instruction_master_high_performance_paddr_base} {0}
    set_instance_parameter_value dnn_accel_system {instruction_master_high_performance_paddr_size} {0.0}
    set_instance_parameter_value dnn_accel_system {instruction_master_paddr_base} {0}
    set_instance_parameter_value dnn_accel_system {instruction_master_paddr_size} {0.0}
    set_instance_parameter_value dnn_accel_system {io_regionbase} {0}
    set_instance_parameter_value dnn_accel_system {io_regionsize} {0}
    set_instance_parameter_value dnn_accel_system {master_addr_map} {0}
    set_instance_parameter_value dnn_accel_system {mmu_TLBMissExcOffset} {0}
    set_instance_parameter_value dnn_accel_system {mmu_TLBMissExcSlave} {None}
    set_instance_parameter_value dnn_accel_system {mmu_autoAssignTlbPtrSz} {1}
    set_instance_parameter_value dnn_accel_system {mmu_enabled} {0}
    set_instance_parameter_value dnn_accel_system {mmu_processIDNumBits} {8}
    set_instance_parameter_value dnn_accel_system {mmu_ramBlockType} {Automatic}
    set_instance_parameter_value dnn_accel_system {mmu_tlbNumWays} {16}
    set_instance_parameter_value dnn_accel_system {mmu_tlbPtrSz} {7}
    set_instance_parameter_value dnn_accel_system {mmu_udtlbNumEntries} {6}
    set_instance_parameter_value dnn_accel_system {mmu_uitlbNumEntries} {4}
    set_instance_parameter_value dnn_accel_system {mpu_enabled} {0}
    set_instance_parameter_value dnn_accel_system {mpu_minDataRegionSize} {12}
    set_instance_parameter_value dnn_accel_system {mpu_minInstRegionSize} {12}
    set_instance_parameter_value dnn_accel_system {mpu_numOfDataRegion} {8}
    set_instance_parameter_value dnn_accel_system {mpu_numOfInstRegion} {8}
    set_instance_parameter_value dnn_accel_system {mpu_useLimit} {0}
    set_instance_parameter_value dnn_accel_system {mpx_enabled} {0}
    set_instance_parameter_value dnn_accel_system {mul_32_impl} {2}
    set_instance_parameter_value dnn_accel_system {mul_64_impl} {0}
    set_instance_parameter_value dnn_accel_system {mul_shift_choice} {0}
    set_instance_parameter_value dnn_accel_system {ocimem_ramBlockType} {Automatic}
    set_instance_parameter_value dnn_accel_system {ocimem_ramInit} {0}
    set_instance_parameter_value dnn_accel_system {regfile_ramBlockType} {Automatic}
    set_instance_parameter_value dnn_accel_system {register_file_por} {0}
    set_instance_parameter_value dnn_accel_system {resetOffset} {0}
    set_instance_parameter_value dnn_accel_system {resetSlave} {onchip_memory2_0.s1}
    set_instance_parameter_value dnn_accel_system {resetrequest_enabled} {1}
    set_instance_parameter_value dnn_accel_system {setting_HBreakTest} {0}
    set_instance_parameter_value dnn_accel_system {setting_HDLSimCachesCleared} {1}
    set_instance_parameter_value dnn_accel_system {setting_activateMonitors} {1}
    set_instance_parameter_value dnn_accel_system {setting_activateTestEndChecker} {0}
    set_instance_parameter_value dnn_accel_system {setting_activateTrace} {0}
    set_instance_parameter_value dnn_accel_system {setting_allow_break_inst} {0}
    set_instance_parameter_value dnn_accel_system {setting_alwaysEncrypt} {1}
    set_instance_parameter_value dnn_accel_system {setting_asic_add_scan_mode_input} {0}
    set_instance_parameter_value dnn_accel_system {setting_asic_enabled} {0}
    set_instance_parameter_value dnn_accel_system {setting_asic_synopsys_translate_on_off} {0}
    set_instance_parameter_value dnn_accel_system {setting_asic_third_party_synthesis} {0}
    set_instance_parameter_value dnn_accel_system {setting_avalonDebugPortPresent} {0}
    set_instance_parameter_value dnn_accel_system {setting_bhtPtrSz} {8}
    set_instance_parameter_value dnn_accel_system {setting_bigEndian} {0}
    set_instance_parameter_value dnn_accel_system {setting_branchpredictiontype} {Dynamic}
    set_instance_parameter_value dnn_accel_system {setting_breakslaveoveride} {0}
    set_instance_parameter_value dnn_accel_system {setting_clearXBitsLDNonBypass} {1}
    set_instance_parameter_value dnn_accel_system {setting_dc_ecc_present} {1}
    set_instance_parameter_value dnn_accel_system {setting_disable_tmr_inj} {0}
    set_instance_parameter_value dnn_accel_system {setting_disableocitrace} {0}
    set_instance_parameter_value dnn_accel_system {setting_dtcm_ecc_present} {1}
    set_instance_parameter_value dnn_accel_system {setting_ecc_present} {0}
    set_instance_parameter_value dnn_accel_system {setting_ecc_sim_test_ports} {0}
    set_instance_parameter_value dnn_accel_system {setting_exportHostDebugPort} {0}
    set_instance_parameter_value dnn_accel_system {setting_exportPCB} {0}
    set_instance_parameter_value dnn_accel_system {setting_export_large_RAMs} {0}
    set_instance_parameter_value dnn_accel_system {setting_exportdebuginfo} {0}
    set_instance_parameter_value dnn_accel_system {setting_exportvectors} {0}
    set_instance_parameter_value dnn_accel_system {setting_fast_register_read} {0}
    set_instance_parameter_value dnn_accel_system {setting_ic_ecc_present} {1}
    set_instance_parameter_value dnn_accel_system {setting_interruptControllerType} {Internal}
    set_instance_parameter_value dnn_accel_system {setting_itcm_ecc_present} {1}
    set_instance_parameter_value dnn_accel_system {setting_mmu_ecc_present} {1}
    set_instance_parameter_value dnn_accel_system {setting_oci_export_jtag_signals} {0}
    set_instance_parameter_value dnn_accel_system {setting_oci_version} {1}
    set_instance_parameter_value dnn_accel_system {setting_preciseIllegalMemAccessException} {0}
    set_instance_parameter_value dnn_accel_system {setting_removeRAMinit} {0}
    set_instance_parameter_value dnn_accel_system {setting_rf_ecc_present} {1}
    set_instance_parameter_value dnn_accel_system {setting_shadowRegisterSets} {0}
    set_instance_parameter_value dnn_accel_system {setting_showInternalSettings} {0}
    set_instance_parameter_value dnn_accel_system {setting_showUnpublishedSettings} {0}
    set_instance_parameter_value dnn_accel_system {setting_support31bitdcachebypass} {1}
    set_instance_parameter_value dnn_accel_system {setting_tmr_output_disable} {0}
    set_instance_parameter_value dnn_accel_system {setting_usedesignware} {0}
    set_instance_parameter_value dnn_accel_system {shift_rot_impl} {1}
    set_instance_parameter_value dnn_accel_system {tightly_coupled_data_master_0_paddr_base} {0}
    set_instance_parameter_value dnn_accel_system {tightly_coupled_data_master_0_paddr_size} {0.0}
    set_instance_parameter_value dnn_accel_system {tightly_coupled_data_master_1_paddr_base} {0}
    set_instance_parameter_value dnn_accel_system {tightly_coupled_data_master_1_paddr_size} {0.0}
    set_instance_parameter_value dnn_accel_system {tightly_coupled_data_master_2_paddr_base} {0}
    set_instance_parameter_value dnn_accel_system {tightly_coupled_data_master_2_paddr_size} {0.0}
    set_instance_parameter_value dnn_accel_system {tightly_coupled_data_master_3_paddr_base} {0}
    set_instance_parameter_value dnn_accel_system {tightly_coupled_data_master_3_paddr_size} {0.0}
    set_instance_parameter_value dnn_accel_system {tightly_coupled_instruction_master_0_paddr_base} {0}
    set_instance_parameter_value dnn_accel_system {tightly_coupled_instruction_master_0_paddr_size} {0.0}
    set_instance_parameter_value dnn_accel_system {tightly_coupled_instruction_master_1_paddr_base} {0}
    set_instance_parameter_value dnn_accel_system {tightly_coupled_instruction_master_1_paddr_size} {0.0}
    set_instance_parameter_value dnn_accel_system {tightly_coupled_instruction_master_2_paddr_base} {0}
    set_instance_parameter_value dnn_accel_system {tightly_coupled_instruction_master_2_paddr_size} {0.0}
    set_instance_parameter_value dnn_accel_system {tightly_coupled_instruction_master_3_paddr_base} {0}
    set_instance_parameter_value dnn_accel_system {tightly_coupled_instruction_master_3_paddr_size} {0.0}
    set_instance_parameter_value dnn_accel_system {tmr_enabled} {0}
    set_instance_parameter_value dnn_accel_system {tracefilename} {}
    set_instance_parameter_value dnn_accel_system {userDefinedSettings} {}

    add_instance dot_accelerator_0 dot_accelerator 1.0

    add_instance jtag_uart_0 altera_avalon_jtag_uart 19.1
    set_instance_parameter_value jtag_uart_0 {allowMultipleConnections} {0}
    set_instance_parameter_value jtag_uart_0 {hubInstanceID} {0}
    set_instance_parameter_value jtag_uart_0 {readBufferDepth} {64}
    set_instance_parameter_value jtag_uart_0 {readIRQThreshold} {8}
    set_instance_parameter_value jtag_uart_0 {simInputCharacterStream} {}
    set_instance_parameter_value jtag_uart_0 {simInteractiveOptions} {NO_INTERACTIVE_WINDOWS}
    set_instance_parameter_value jtag_uart_0 {useRegistersForReadBuffer} {0}
    set_instance_parameter_value jtag_uart_0 {useRegistersForWriteBuffer} {0}
    set_instance_parameter_value jtag_uart_0 {useRelativePathForSimFile} {0}
    set_instance_parameter_value jtag_uart_0 {writeBufferDepth} {64}
    set_instance_parameter_value jtag_uart_0 {writeIRQThreshold} {8}

    add_instance onchip_memory2_0 altera_avalon_onchip_memory2 19.1
    set_instance_parameter_value onchip_memory2_0 {allowInSystemMemoryContentEditor} {0}
    set_instance_parameter_value onchip_memory2_0 {blockType} {AUTO}
    set_instance_parameter_value onchip_memory2_0 {copyInitFile} {0}
    set_instance_parameter_value onchip_memory2_0 {dataWidth} {32}
    set_instance_parameter_value onchip_memory2_0 {dataWidth2} {32}
    set_instance_parameter_value onchip_memory2_0 {dualPort} {0}
    set_instance_parameter_value onchip_memory2_0 {ecc_enabled} {0}
    set_instance_parameter_value onchip_memory2_0 {enPRInitMode} {0}
    set_instance_parameter_value onchip_memory2_0 {enableDiffWidth} {0}
    set_instance_parameter_value onchip_memory2_0 {initMemContent} {1}
    set_instance_parameter_value onchip_memory2_0 {initializationFileName} {onchip_mem.hex}
    set_instance_parameter_value onchip_memory2_0 {instanceID} {NONE}
    set_instance_parameter_value onchip_memory2_0 {memorySize} {32768.0}
    set_instance_parameter_value onchip_memory2_0 {readDuringWriteMode} {DONT_CARE}
    set_instance_parameter_value onchip_memory2_0 {resetrequest_enabled} {1}
    set_instance_parameter_value onchip_memory2_0 {simAllowMRAMContentsFile} {0}
    set_instance_parameter_value onchip_memory2_0 {simMemInitOnlyFilename} {0}
    set_instance_parameter_value onchip_memory2_0 {singleClockOperation} {0}
    set_instance_parameter_value onchip_memory2_0 {slave1Latency} {1}
    set_instance_parameter_value onchip_memory2_0 {slave2Latency} {1}
    set_instance_parameter_value onchip_memory2_0 {useNonDefaultInitFile} {0}
    set_instance_parameter_value onchip_memory2_0 {useShallowMemBlocks} {0}
    set_instance_parameter_value onchip_memory2_0 {writable} {1}

    add_instance pio_0 altera_avalon_pio 19.1
    set_instance_parameter_value pio_0 {bitClearingEdgeCapReg} {0}
    set_instance_parameter_value pio_0 {bitModifyingOutReg} {0}
    set_instance_parameter_value pio_0 {captureEdge} {0}
    set_instance_parameter_value pio_0 {direction} {Output}
    set_instance_parameter_value pio_0 {edgeType} {RISING}
    set_instance_parameter_value pio_0 {generateIRQ} {0}
    set_instance_parameter_value pio_0 {irqType} {LEVEL}
    set_instance_parameter_value pio_0 {resetValue} {127.0}
    set_instance_parameter_value pio_0 {simDoTestBenchWiring} {0}
    set_instance_parameter_value pio_0 {simDrivenValue} {0.0}
    set_instance_parameter_value pio_0 {width} {7}

    add_instance pll_0 altera_pll 19.1
    set_instance_parameter_value pll_0 {debug_print_output} {0}
    set_instance_parameter_value pll_0 {debug_use_rbc_taf_method} {0}
    set_instance_parameter_value pll_0 {gui_active_clk} {0}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency0} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency1} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency10} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency11} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency12} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency13} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency14} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency15} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency16} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency17} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency2} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency3} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency4} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency5} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency6} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency7} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency8} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency9} {0 MHz}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift0} {0}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift1} {0}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift10} {0}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift11} {0}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift12} {0}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift13} {0}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift14} {0}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift15} {0}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift16} {0}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift17} {0}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift2} {0}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift3} {0}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift4} {0}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift5} {0}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift6} {0}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift7} {0}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift8} {0}
    set_instance_parameter_value pll_0 {gui_actual_phase_shift9} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter0} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter1} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter10} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter11} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter12} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter13} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter14} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter15} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter16} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter17} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter2} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter3} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter4} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter5} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter6} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter7} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter8} {0}
    set_instance_parameter_value pll_0 {gui_cascade_counter9} {0}
    set_instance_parameter_value pll_0 {gui_cascade_outclk_index} {0}
    set_instance_parameter_value pll_0 {gui_channel_spacing} {0.0}
    set_instance_parameter_value pll_0 {gui_clk_bad} {0}
    set_instance_parameter_value pll_0 {gui_device_speed_grade} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c0} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c1} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c10} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c11} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c12} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c13} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c14} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c15} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c16} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c17} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c2} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c3} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c4} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c5} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c6} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c7} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c8} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_c9} {1}
    set_instance_parameter_value pll_0 {gui_divide_factor_n} {1}
    set_instance_parameter_value pll_0 {gui_dps_cntr} {C0}
    set_instance_parameter_value pll_0 {gui_dps_dir} {Positive}
    set_instance_parameter_value pll_0 {gui_dps_num} {1}
    set_instance_parameter_value pll_0 {gui_dsm_out_sel} {1st_order}
    set_instance_parameter_value pll_0 {gui_duty_cycle0} {50}
    set_instance_parameter_value pll_0 {gui_duty_cycle1} {50}
    set_instance_parameter_value pll_0 {gui_duty_cycle10} {50}
    set_instance_parameter_value pll_0 {gui_duty_cycle11} {50}
    set_instance_parameter_value pll_0 {gui_duty_cycle12} {50}
    set_instance_parameter_value pll_0 {gui_duty_cycle13} {50}
    set_instance_parameter_value pll_0 {gui_duty_cycle14} {50}
    set_instance_parameter_value pll_0 {gui_duty_cycle15} {50}
    set_instance_parameter_value pll_0 {gui_duty_cycle16} {50}
    set_instance_parameter_value pll_0 {gui_duty_cycle17} {50}
    set_instance_parameter_value pll_0 {gui_duty_cycle2} {50}
    set_instance_parameter_value pll_0 {gui_duty_cycle3} {50}
    set_instance_parameter_value pll_0 {gui_duty_cycle4} {50}
    set_instance_parameter_value pll_0 {gui_duty_cycle5} {50}
    set_instance_parameter_value pll_0 {gui_duty_cycle6} {50}
    set_instance_parameter_value pll_0 {gui_duty_cycle7} {50}
    set_instance_parameter_value pll_0 {gui_duty_cycle8} {50}
    set_instance_parameter_value pll_0 {gui_duty_cycle9} {50}
    set_instance_parameter_value pll_0 {gui_en_adv_params} {0}
    set_instance_parameter_value pll_0 {gui_en_dps_ports} {0}
    set_instance_parameter_value pll_0 {gui_en_phout_ports} {0}
    set_instance_parameter_value pll_0 {gui_en_reconf} {0}
    set_instance_parameter_value pll_0 {gui_enable_cascade_in} {0}
    set_instance_parameter_value pll_0 {gui_enable_cascade_out} {0}
    set_instance_parameter_value pll_0 {gui_enable_mif_dps} {0}
    set_instance_parameter_value pll_0 {gui_feedback_clock} {Global Clock}
    set_instance_parameter_value pll_0 {gui_frac_multiply_factor} {1.0}
    set_instance_parameter_value pll_0 {gui_fractional_cout} {32}
    set_instance_parameter_value pll_0 {gui_mif_generate} {0}
    set_instance_parameter_value pll_0 {gui_multiply_factor} {1}
    set_instance_parameter_value pll_0 {gui_number_of_clocks} {2}
    set_instance_parameter_value pll_0 {gui_operation_mode} {direct}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency0} {50.0}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency1} {50.0}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency10} {100.0}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency11} {100.0}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency12} {100.0}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency13} {100.0}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency14} {100.0}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency15} {100.0}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency16} {100.0}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency17} {100.0}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency2} {100.0}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency3} {100.0}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency4} {100.0}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency5} {100.0}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency6} {100.0}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency7} {100.0}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency8} {100.0}
    set_instance_parameter_value pll_0 {gui_output_clock_frequency9} {100.0}
    set_instance_parameter_value pll_0 {gui_phase_shift0} {0}
    set_instance_parameter_value pll_0 {gui_phase_shift1} {-3000}
    set_instance_parameter_value pll_0 {gui_phase_shift10} {0}
    set_instance_parameter_value pll_0 {gui_phase_shift11} {0}
    set_instance_parameter_value pll_0 {gui_phase_shift12} {0}
    set_instance_parameter_value pll_0 {gui_phase_shift13} {0}
    set_instance_parameter_value pll_0 {gui_phase_shift14} {0}
    set_instance_parameter_value pll_0 {gui_phase_shift15} {0}
    set_instance_parameter_value pll_0 {gui_phase_shift16} {0}
    set_instance_parameter_value pll_0 {gui_phase_shift17} {0}
    set_instance_parameter_value pll_0 {gui_phase_shift2} {0}
    set_instance_parameter_value pll_0 {gui_phase_shift3} {0}
    set_instance_parameter_value pll_0 {gui_phase_shift4} {0}
    set_instance_parameter_value pll_0 {gui_phase_shift5} {0}
    set_instance_parameter_value pll_0 {gui_phase_shift6} {0}
    set_instance_parameter_value pll_0 {gui_phase_shift7} {0}
    set_instance_parameter_value pll_0 {gui_phase_shift8} {0}
    set_instance_parameter_value pll_0 {gui_phase_shift9} {0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg0} {0.0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg1} {0.0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg10} {0.0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg11} {0.0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg12} {0.0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg13} {0.0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg14} {0.0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg15} {0.0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg16} {0.0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg17} {0.0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg2} {0.0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg3} {0.0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg4} {0.0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg5} {0.0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg6} {0.0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg7} {0.0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg8} {0.0}
    set_instance_parameter_value pll_0 {gui_phase_shift_deg9} {0.0}
    set_instance_parameter_value pll_0 {gui_phout_division} {1}
    set_instance_parameter_value pll_0 {gui_pll_auto_reset} {Off}
    set_instance_parameter_value pll_0 {gui_pll_bandwidth_preset} {Auto}
    set_instance_parameter_value pll_0 {gui_pll_cascading_mode} {Create an adjpllin signal to connect with an upstream PLL}
    set_instance_parameter_value pll_0 {gui_pll_mode} {Integer-N PLL}
    set_instance_parameter_value pll_0 {gui_ps_units0} {ps}
    set_instance_parameter_value pll_0 {gui_ps_units1} {ps}
    set_instance_parameter_value pll_0 {gui_ps_units10} {ps}
    set_instance_parameter_value pll_0 {gui_ps_units11} {ps}
    set_instance_parameter_value pll_0 {gui_ps_units12} {ps}
    set_instance_parameter_value pll_0 {gui_ps_units13} {ps}
    set_instance_parameter_value pll_0 {gui_ps_units14} {ps}
    set_instance_parameter_value pll_0 {gui_ps_units15} {ps}
    set_instance_parameter_value pll_0 {gui_ps_units16} {ps}
    set_instance_parameter_value pll_0 {gui_ps_units17} {ps}
    set_instance_parameter_value pll_0 {gui_ps_units2} {ps}
    set_instance_parameter_value pll_0 {gui_ps_units3} {ps}
    set_instance_parameter_value pll_0 {gui_ps_units4} {ps}
    set_instance_parameter_value pll_0 {gui_ps_units5} {ps}
    set_instance_parameter_value pll_0 {gui_ps_units6} {ps}
    set_instance_parameter_value pll_0 {gui_ps_units7} {ps}
    set_instance_parameter_value pll_0 {gui_ps_units8} {ps}
    set_instance_parameter_value pll_0 {gui_ps_units9} {ps}
    set_instance_parameter_value pll_0 {gui_refclk1_frequency} {100.0}
    set_instance_parameter_value pll_0 {gui_refclk_switch} {0}
    set_instance_parameter_value pll_0 {gui_reference_clock_frequency} {50.0}
    set_instance_parameter_value pll_0 {gui_switchover_delay} {0}
    set_instance_parameter_value pll_0 {gui_switchover_mode} {Automatic Switchover}
    set_instance_parameter_value pll_0 {gui_use_locked} {1}

    add_instance sdram_controller altera_avalon_new_sdram_controller 19.1
    set_instance_parameter_value sdram_controller {TAC} {5.4}
    set_instance_parameter_value sdram_controller {TMRD} {3.0}
    set_instance_parameter_value sdram_controller {TRCD} {15.0}
    set_instance_parameter_value sdram_controller {TRFC} {70.0}
    set_instance_parameter_value sdram_controller {TRP} {15.0}
    set_instance_parameter_value sdram_controller {TWR} {14.0}
    set_instance_parameter_value sdram_controller {casLatency} {3}
    set_instance_parameter_value sdram_controller {columnWidth} {10}
    set_instance_parameter_value sdram_controller {dataWidth} {16}
    set_instance_parameter_value sdram_controller {generateSimulationModel} {1}
    set_instance_parameter_value sdram_controller {initNOPDelay} {0.0}
    set_instance_parameter_value sdram_controller {initRefreshCommands} {2}
    set_instance_parameter_value sdram_controller {masteredTristateBridgeSlave} {0}
    set_instance_parameter_value sdram_controller {model} {single_Micron_MT48LC4M32B2_7_chip}
    set_instance_parameter_value sdram_controller {numberOfBanks} {4}
    set_instance_parameter_value sdram_controller {numberOfChipSelects} {1}
    set_instance_parameter_value sdram_controller {pinsSharedViaTriState} {0}
    set_instance_parameter_value sdram_controller {powerUpDelay} {100.0}
    set_instance_parameter_value sdram_controller {refreshPeriod} {7.8125}
    set_instance_parameter_value sdram_controller {registerDataIn} {1}
    set_instance_parameter_value sdram_controller {rowWidth} {13}

    add_instance vga_avalon vga_avalon 1.0

    add_instance word_copy_interface_0 word_copy_interface 1.0

    # connections and connection parameters
    add_connection clk_0.clk pll_0.refclk clock

    add_connection clk_0.clk_reset dnn_accel_system.reset reset

    add_connection clk_0.clk_reset dot_accelerator_0.reset_sink reset

    add_connection clk_0.clk_reset jtag_uart_0.reset reset

    add_connection clk_0.clk_reset onchip_memory2_0.reset1 reset

    add_connection clk_0.clk_reset pio_0.reset reset

    add_connection clk_0.clk_reset pll_0.reset reset

    add_connection clk_0.clk_reset sdram_controller.reset reset

    add_connection clk_0.clk_reset vga_avalon.reset reset

    add_connection clk_0.clk_reset word_copy_interface_0.reset_sink reset

    add_connection dnn_accel_system.data_master dnn_accel_system.debug_mem_slave avalon
    set_connection_parameter_value dnn_accel_system.data_master/dnn_accel_system.debug_mem_slave arbitrationPriority {1}
    set_connection_parameter_value dnn_accel_system.data_master/dnn_accel_system.debug_mem_slave baseAddress {0x0800}
    set_connection_parameter_value dnn_accel_system.data_master/dnn_accel_system.debug_mem_slave defaultConnection {0}

    add_connection dnn_accel_system.data_master dot_accelerator_0.slave avalon
    set_connection_parameter_value dnn_accel_system.data_master/dot_accelerator_0.slave arbitrationPriority {1}
    set_connection_parameter_value dnn_accel_system.data_master/dot_accelerator_0.slave baseAddress {0x1100}
    set_connection_parameter_value dnn_accel_system.data_master/dot_accelerator_0.slave defaultConnection {0}

    add_connection dnn_accel_system.data_master jtag_uart_0.avalon_jtag_slave avalon
    set_connection_parameter_value dnn_accel_system.data_master/jtag_uart_0.avalon_jtag_slave arbitrationPriority {1}
    set_connection_parameter_value dnn_accel_system.data_master/jtag_uart_0.avalon_jtag_slave baseAddress {0x1000}
    set_connection_parameter_value dnn_accel_system.data_master/jtag_uart_0.avalon_jtag_slave defaultConnection {0}

    add_connection dnn_accel_system.data_master onchip_memory2_0.s1 avalon
    set_connection_parameter_value dnn_accel_system.data_master/onchip_memory2_0.s1 arbitrationPriority {1}
    set_connection_parameter_value dnn_accel_system.data_master/onchip_memory2_0.s1 baseAddress {0x00010000}
    set_connection_parameter_value dnn_accel_system.data_master/onchip_memory2_0.s1 defaultConnection {0}

    add_connection dnn_accel_system.data_master pio_0.s1 avalon
    set_connection_parameter_value dnn_accel_system.data_master/pio_0.s1 arbitrationPriority {1}
    set_connection_parameter_value dnn_accel_system.data_master/pio_0.s1 baseAddress {0x1010}
    set_connection_parameter_value dnn_accel_system.data_master/pio_0.s1 defaultConnection {0}

    add_connection dnn_accel_system.data_master sdram_controller.s1 avalon
    set_connection_parameter_value dnn_accel_system.data_master/sdram_controller.s1 arbitrationPriority {1}
    set_connection_parameter_value dnn_accel_system.data_master/sdram_controller.s1 baseAddress {0x08000000}
    set_connection_parameter_value dnn_accel_system.data_master/sdram_controller.s1 defaultConnection {0}

    add_connection dnn_accel_system.data_master vga_avalon.avalon_slave_0 avalon
    set_connection_parameter_value dnn_accel_system.data_master/vga_avalon.avalon_slave_0 arbitrationPriority {1}
    set_connection_parameter_value dnn_accel_system.data_master/vga_avalon.avalon_slave_0 baseAddress {0x4000}
    set_connection_parameter_value dnn_accel_system.data_master/vga_avalon.avalon_slave_0 defaultConnection {0}

    add_connection dnn_accel_system.data_master word_copy_interface_0.slave avalon
    set_connection_parameter_value dnn_accel_system.data_master/word_copy_interface_0.slave arbitrationPriority {1}
    set_connection_parameter_value dnn_accel_system.data_master/word_copy_interface_0.slave baseAddress {0x1040}
    set_connection_parameter_value dnn_accel_system.data_master/word_copy_interface_0.slave defaultConnection {0}

    add_connection dnn_accel_system.debug_reset_request dnn_accel_system.reset reset

    add_connection dnn_accel_system.debug_reset_request dot_accelerator_0.reset_sink reset

    add_connection dnn_accel_system.debug_reset_request jtag_uart_0.reset reset

    add_connection dnn_accel_system.debug_reset_request onchip_memory2_0.reset1 reset

    add_connection dnn_accel_system.debug_reset_request pio_0.reset reset

    add_connection dnn_accel_system.debug_reset_request sdram_controller.reset reset

    add_connection dnn_accel_system.debug_reset_request word_copy_interface_0.reset_sink reset

    add_connection dnn_accel_system.instruction_master dnn_accel_system.debug_mem_slave avalon
    set_connection_parameter_value dnn_accel_system.instruction_master/dnn_accel_system.debug_mem_slave arbitrationPriority {1}
    set_connection_parameter_value dnn_accel_system.instruction_master/dnn_accel_system.debug_mem_slave baseAddress {0x0800}
    set_connection_parameter_value dnn_accel_system.instruction_master/dnn_accel_system.debug_mem_slave defaultConnection {0}

    add_connection dnn_accel_system.instruction_master onchip_memory2_0.s1 avalon
    set_connection_parameter_value dnn_accel_system.instruction_master/onchip_memory2_0.s1 arbitrationPriority {1}
    set_connection_parameter_value dnn_accel_system.instruction_master/onchip_memory2_0.s1 baseAddress {0x00010000}
    set_connection_parameter_value dnn_accel_system.instruction_master/onchip_memory2_0.s1 defaultConnection {0}

    add_connection dnn_accel_system.irq jtag_uart_0.irq interrupt
    set_connection_parameter_value dnn_accel_system.irq/jtag_uart_0.irq irqNumber {5}

    add_connection dot_accelerator_0.avalon_master sdram_controller.s1 avalon
    set_connection_parameter_value dot_accelerator_0.avalon_master/sdram_controller.s1 arbitrationPriority {1}
    set_connection_parameter_value dot_accelerator_0.avalon_master/sdram_controller.s1 baseAddress {0x08000000}
    set_connection_parameter_value dot_accelerator_0.avalon_master/sdram_controller.s1 defaultConnection {0}

    add_connection pll_0.outclk0 dnn_accel_system.clk clock

    add_connection pll_0.outclk0 dot_accelerator_0.clock clock

    add_connection pll_0.outclk0 jtag_uart_0.clk clock

    add_connection pll_0.outclk0 onchip_memory2_0.clk1 clock

    add_connection pll_0.outclk0 pio_0.clk clock

    add_connection pll_0.outclk0 sdram_controller.clk clock

    add_connection pll_0.outclk0 vga_avalon.clock clock

    add_connection pll_0.outclk0 word_copy_interface_0.clock clock

    add_connection word_copy_interface_0.avalon_master sdram_controller.s1 avalon
    set_connection_parameter_value word_copy_interface_0.avalon_master/sdram_controller.s1 arbitrationPriority {1}
    set_connection_parameter_value word_copy_interface_0.avalon_master/sdram_controller.s1 baseAddress {0x08000000}
    set_connection_parameter_value word_copy_interface_0.avalon_master/sdram_controller.s1 defaultConnection {0}

    # exported interfaces
    add_interface clk clock sink
    set_interface_property clk EXPORT_OF clk_0.clk_in
    add_interface hex conduit end
    set_interface_property hex EXPORT_OF pio_0.external_connection
    add_interface pll_locked conduit end
    set_interface_property pll_locked EXPORT_OF pll_0.locked
    add_interface reset reset sink
    set_interface_property reset EXPORT_OF clk_0.clk_in_reset
    add_interface sdram conduit end
    set_interface_property sdram EXPORT_OF sdram_controller.wire
    add_interface sdram_clk clock source
    set_interface_property sdram_clk EXPORT_OF pll_0.outclk1
    add_interface vga conduit end
    set_interface_property vga EXPORT_OF vga_avalon.conduit_end

    # interconnect requirements
    set_interconnect_requirement {$system} {qsys_mm.clockCrossingAdapter} {HANDSHAKE}
    set_interconnect_requirement {$system} {qsys_mm.enableEccProtection} {FALSE}
    set_interconnect_requirement {$system} {qsys_mm.insertDefaultSlave} {FALSE}
    set_interconnect_requirement {$system} {qsys_mm.maxAdditionalLatency} {1}
}
