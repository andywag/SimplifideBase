---------------------------------------------------------------------------------------------
-- © Copyright 2010, Xilinx, Inc. All rights reserved.
-- This file contains confidential and proprietary information of Xilinx, Inc. and is
-- protected under U.S. and international copyright and other intellectual property laws.
---------------------------------------------------------------------------------------------
--
-- Disclaimer:
--		This disclaimer is not a license and does not grant any rights to the materials
--		distributed herewith. Except as otherwise provided in a valid license issued to you
--		by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE MATERIALS
--		ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL
--		WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED
--		TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR
--		PURPOSE; and (2) Xilinx shall not be liable (whether in contract or tort, including
--		negligence, or under any other theory of liability) for any loss or damage of any
--		kind or nature related to, arising under or in connection with these materials,
--		including for any direct, or any indirect, special, incidental, or consequential
--		loss or damage (including loss of data, profits, goodwill, or any type of loss or
--		damage suffered as a result of any action brought by a third party) even if such
--		damage or loss was reasonably foreseeable or Xilinx had been advised of the
--		possibility of the same.
--
-- CRITICAL APPLICATIONS
--		Xilinx products are not designed or intended to be fail-safe, or for use in any
--		application requiring fail-safe performance, such as life-support or safety devices
--		or systems, Class III medical devices, nuclear facilities, applications related to
--		the deployment of airbags, or any other applications that could lead to death,
--		personal injury, or severe property or environmental damage (individually and
--		collectively, "Critical Applications"). Customer assumes the sole risk and
--		liability of any use of Xilinx products in Critical Applications, subject only to
--		applicable laws and regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES. 
--
--		Contact:    e-mail  hotline@xilinx.com        phone   + 1 800 255 7778
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 
--  \   \        Filename:              CntTwoBit_Testbench.vhd
--  /   /        Date Last Modified:    27 April, 2010
-- /___/   /\    Date Created:  		21 April, 2009 
-- \   \  /  \
--  \___\/\___\
-- 
-- Device:		Virtex-6
-- Entity Name: CntTwoBit_Testbench
-- Purpose: 	Test Bench for design.
-- Tools:
-- Limitations: TESTBENCH
--                       DON'T USE THIS FILE FOR COMPILATION NOR INTEGRATION.
--
-- Revision History:
--	Rev. 23 Apr 2010 
--		Name change of the file. From "LsbCntTwoBit" into "CntTwoBit".
--	Rev, 27 Apr 2010
--		Tested with the latest version of Modelsim SE_6.6
-----------------------------------------------------------------------------------------------
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_UNSIGNED.all;
use STD.textio.all;
library UNISIM;
use UNISIM.all;
--
entity CntTwoBit_Testbench is
     -- generic / port / local declatations
end entity CntTwoBit_Testbench;
--
architecture CntTwoBit_Testbench_struct of CntTwoBit_Testbench is
-----------------------------------------------------------------------------------------------
-- Component Instantiation
-----------------------------------------------------------------------------------------------
component CntTwoBit
    generic (C_CascdPos : integer); 
	port(
		CntClk		: in std_logic;
		CntRst		: in std_logic;
		CntEna		: in std_logic;
		CntCmbIn	: in std_logic_vector(1 downto 0);
		CntCmbTcIn  : in std_logic_vector(1 downto 0);
		CntOut		: out std_logic_vector(1 downto 0);
		CntCmbTc	: out std_logic;	
		CntTc		: out std_logic
	);
end component;
--
component CntTwoBit_Tester
    generic (C_CascdPos : integer); 
	port(
		CntClk		: out std_logic;
		CntRst		: out std_logic;
		CntEna		: out std_logic;
		CntCmbIn	: out std_logic_vector(1 downto 0);
		CntCmbTcIn  : out std_logic_vector(1 downto 0);
		CntOut		: in std_logic_vector(1 downto 0);
		CntCmbTc	: in std_logic;	
		CntTc		: in std_logic
	);
end component;
-----------------------------------------------------------------------------------------------
-- Signal Declarations
-----------------------------------------------------------------------------------------------
constant Sim_C_CascdPos : integer := 0;
--
signal Sim_CntClk	    : std_logic;
signal Sim_CntRst	    : std_logic;
signal Sim_CntEna	    : std_logic;
signal Sim_CntCmbIn 	: std_logic_vector(1 downto 0);
signal Sim_CntCmbTcIn 	: std_logic_vector(1 downto 0);
signal Sim_CntOut	    : std_logic_vector(1 downto 0);
signal Sim_CntCmbTc		: std_logic;
signal Sim_CntTc	    : std_logic;
-----------------------------------------------------------------------------------------------
--
begin
Uut : CntTwoBit
	generic map (C_CascdPos => Sim_C_CascdPos)
	port map (
		CntClk		=> Sim_CntClk,
		CntRst		=> Sim_CntRst,
		CntEna		=> Sim_CntEna,
		CntCmbIn 	=> Sim_CntCmbIn,
		CntCmbTcIn	=> Sim_CntCmbTcIn,
		CntOut		=> Sim_CntOut,
		CntCmbTc	=> Sim_CntCmbTc,		
		CntTc		=> Sim_CntTc
	);
Dtu : CntTwoBit_Tester
	generic map (C_CascdPos => Sim_C_CascdPos)
	port map (
		CntClk		=> Sim_CntClk,
		CntRst		=> Sim_CntRst,
		CntEna		=> Sim_CntEna,
		CntCmbIn 	=> Sim_CntCmbIn,
		CntCmbTcIn	=> Sim_CntCmbTcIn,
		CntOut		=> Sim_CntOut,
		CntCmbTc	=> Sim_CntCmbTc,		
		CntTc		=> Sim_CntTc
	);
--
-----------------------------------------------------------------------------------------------
end architecture CntTwoBit_Testbench_struct;
--