LIBRARY	IEEE;
USE	IEEE.STD_LOGIC_1164.ALL;
USE	IEEE.STD_LOGIC_UNSIGNED.ALL;

entity memcont is
generic(
	AWIDTH		:integer	:=25;
	CAWIDTH		:integer	:=10;
	CLKMHZ		:integer 	:=120		--SDRAM clk MHz
);
port(
	-- SDRAM PORTS
	SDRAM_CKE     	: out std_logic;                 			-- SD-RAM Clock enable
	SDRAM_nCS    	: out std_logic;                        	-- SD-RAM Chip select
	SDRAM_nRAS   	: out std_logic;                        	-- SD-RAM Row/RAS
	SDRAM_nCAS   	: out std_logic;                        	-- SD-RAM /CAS
	SDRAM_nWE    	: out std_logic;                        	-- SD-RAM /WE
	SDRAM_DQMH    	: out std_logic;                        	-- SD-RAM DQMH
	SDRAM_DQML    	: out std_logic;                        	-- SD-RAM DQML
	SDRAM_BA     	: out std_logic_vector(1 downto 0);      	-- SD-RAM Bank select address
	SDRAM_A     	: out std_logic_vector(12 downto 0);    	-- SD-RAM Address
	SDRAM_DQ     	: inout std_logic_vector(15 downto 0);  	-- SD-RAM Data

	b_addr		:in std_logic_vector(awidth-1 downto 0);
	b_wdat		:in std_logic_vector(15 downto 0);
	b_rdat		:out std_logic_vector(15 downto 0);
	b_rd		:in std_logic;
	b_wr		:in std_logic_vector(1 downto 0);
	b_rmw		:in std_logic_vector(1 downto 0);
	b_rmwmsk	:in std_logic_vector(15 downto 0);
	b_ack		:out std_logic;

	b_csaddr	:in std_logic_vector(awidth-9 downto 0)	:=(others=>'0');
	b_cdaddr	:in std_logic_vector(awidth-9 downto 0)	:=(others=>'0');
	b_cpy		:in std_logic_vector(3 downto 0)	:=(others=>'0');
	b_cack		:out std_logic;
	
	g00_addr	:in std_logic_vector(awidth-1 downto 0);
	g00_rd		:in std_logic;
	g00_rdat	:out std_logic_vector(15 downto 0);
	g00_ack		:out std_logic;

	g01_addr	:in std_logic_vector(awidth-1 downto 0);
	g01_rd		:in std_logic;
	g01_rdat	:out std_logic_vector(15 downto 0);
	g01_ack		:out std_logic;

	g02_addr	:in std_logic_vector(awidth-1 downto 0);
	g02_rd		:in std_logic;
	g02_rdat	:out std_logic_vector(15 downto 0);
	g02_ack		:out std_logic;

	g03_addr	:in std_logic_vector(awidth-1 downto 0);
	g03_rd		:in std_logic;
	g03_rdat	:out std_logic_vector(15 downto 0);
	g03_ack		:out std_logic;

	g10_addr	:in std_logic_vector(awidth-1 downto 0);
	g10_rd		:in std_logic;
	g10_rdat	:out std_logic_vector(15 downto 0);
	g10_ack		:out std_logic;

	g11_addr	:in std_logic_vector(awidth-1 downto 0);
	g11_rd		:in std_logic;
	g11_rdat	:out std_logic_vector(15 downto 0);
	g11_ack		:out std_logic;

	g12_addr	:in std_logic_vector(awidth-1 downto 0);
	g12_rd		:in std_logic;
	g12_rdat	:out std_logic_vector(15 downto 0);
	g12_ack		:out std_logic;

	g13_addr	:in std_logic_vector(awidth-1 downto 0);
	g13_rd		:in std_logic;
	g13_rdat	:out std_logic_vector(15 downto 0);
	g13_ack		:out std_logic;

	t0_addr		:in std_logic_vector(awidth-3 downto 0);
	t0_rd		:in std_logic;
	t0_rdat0	:out std_logic_vector(15 downto 0);
	t0_rdat1	:out std_logic_vector(15 downto 0);
	t0_rdat2	:out std_logic_vector(15 downto 0);
	t0_rdat3	:out std_logic_vector(15 downto 0);
	t0_ack		:out std_logic;
	
	t1_addr		:in std_logic_vector(awidth-3 downto 0);
	t1_rd		:in std_logic;
	t1_rdat0	:out std_logic_vector(15 downto 0);
	t1_rdat1	:out std_logic_vector(15 downto 0);
	t1_rdat2	:out std_logic_vector(15 downto 0);
	t1_rdat3	:out std_logic_vector(15 downto 0);
	t1_ack		:out std_logic;

	g0_caddr	:in std_logic_vector(awidth-1 downto 7);
	g0_clear	:in std_logic;
	
	g1_caddr	:in std_logic_vector(awidth-1 downto 7);
	g1_clear	:in std_logic;

	g2_caddr	:in std_logic_vector(awidth-1 downto 7);
	g2_clear	:in std_logic;

	g3_caddr	:in std_logic_vector(awidth-1 downto 7);
	g3_clear	:in std_logic;
	
	initdone	:out std_logic;
	
	sclk	:in std_logic;
	vclk	:in std_logic;
	rclk	:in std_logic;
	rstn	:in std_logic
);
end memcont;

architecture rtl of memcont is
signal	ram_inidone	:std_logic;
signal	cache_inidone:std_logic;
signal	b_rd_m		:std_logic;
signal	b_wr_m		:std_logic_vector(1 downto 0);
signal 	ramaddrh	:std_logic_vector(awidth-9 downto 0);
signal	rambgnaddr	:std_logic_vector(7 downto 0);
signal	ramendaddr	:std_logic_vector(7 downto 0);
signal	ramaddrrc	:std_logic_vector(7 downto 0);
signal	ramaddrwc	:std_logic_vector(7 downto 0);
signal	ramrd		:std_logic;
signal	ramwr		:std_logic;
signal	ramrefrsh	:std_logic;
signal	rambusy		:std_logic;
signal	ramde		:std_logic;
signal	ramrdat		:std_logic_vector(15 downto 0);
signal	ramwdat		:std_logic_vector(15 downto 0);
signal	ramwe		:std_logic_vector(1 downto 0);

component cachecont
generic(
	awidth	:integer	:=22
);
port(
	b_addr	:in std_logic_vector(awidth-1 downto 0);
	b_wdat	:in std_logic_vector(15 downto 0);
	b_rdat	:out std_logic_vector(15 downto 0);
	b_rd	:in std_logic;
	b_wr	:in std_logic_vector(1 downto 0);
	b_rmw	:in std_logic_vector(1 downto 0);
	b_rmwmsk:in std_logic_vector(15 downto 0);
	b_ack	:out std_logic;

	b_csaddr:in std_logic_vector(awidth-9 downto 0)	:=(others=>'0');
	b_cdaddr:in std_logic_vector(awidth-9 downto 0)	:=(others=>'0');
	b_cpy	:in std_logic_vector(3 downto 0)	:=(others=>'0');
	b_cack	:out std_logic;

	g00_addr:in std_logic_vector(awidth-1 downto 0);
	g00_rd	:in std_logic;
	g00_rdat:out std_logic_vector(15 downto 0);
	g00_ack	:out std_logic;

	g01_addr:in std_logic_vector(awidth-1 downto 0);
	g01_rd	:in std_logic;
	g01_rdat:out std_logic_vector(15 downto 0);
	g01_ack	:out std_logic;

	g02_addr:in std_logic_vector(awidth-1 downto 0);
	g02_rd	:in std_logic;
	g02_rdat:out std_logic_vector(15 downto 0);
	g02_ack	:out std_logic;

	g03_addr:in std_logic_vector(awidth-1 downto 0);
	g03_rd	:in std_logic;
	g03_rdat:out std_logic_vector(15 downto 0);
	g03_ack	:out std_logic;

	g10_addr:in std_logic_vector(awidth-1 downto 0);
	g10_rd	:in std_logic;
	g10_rdat:out std_logic_vector(15 downto 0);
	g10_ack	:out std_logic;

	g11_addr:in std_logic_vector(awidth-1 downto 0);
	g11_rd	:in std_logic;
	g11_rdat:out std_logic_vector(15 downto 0);
	g11_ack	:out std_logic;

	g12_addr:in std_logic_vector(awidth-1 downto 0);
	g12_rd	:in std_logic;
	g12_rdat:out std_logic_vector(15 downto 0);
	g12_ack	:out std_logic;

	g13_addr:in std_logic_vector(awidth-1 downto 0);
	g13_rd	:in std_logic;
	g13_rdat:out std_logic_vector(15 downto 0);
	g13_ack	:out std_logic;

	t0_addr	:in std_logic_vector(awidth-3 downto 0);
	t0_rd	:in std_logic;
	t0_rdat0:out std_logic_vector(15 downto 0);
	t0_rdat1:out std_logic_vector(15 downto 0);
	t0_rdat2:out std_logic_vector(15 downto 0);
	t0_rdat3:out std_logic_vector(15 downto 0);
	t0_ack	:out std_logic;
	
	t1_addr	:in std_logic_vector(awidth-3 downto 0);
	t1_rd	:in std_logic;
	t1_rdat0:out std_logic_vector(15 downto 0);
	t1_rdat1:out std_logic_vector(15 downto 0);
	t1_rdat2:out std_logic_vector(15 downto 0);
	t1_rdat3:out std_logic_vector(15 downto 0);
	t1_ack	:out std_logic;

	g0_caddr	:in std_logic_vector(awidth-1 downto 7);
	g0_clear	:in std_logic;
	
	g1_caddr	:in std_logic_vector(awidth-1 downto 7);
	g1_clear	:in std_logic;

	g2_caddr	:in std_logic_vector(awidth-1 downto 7);
	g2_clear	:in std_logic;

	g3_caddr	:in std_logic_vector(awidth-1 downto 7);
	g3_clear	:in std_logic;
	
	ramaddrh	:out std_logic_vector(awidth-9 downto 0);
	rambgnaddr	:out std_logic_vector(7 downto 0);
	ramendaddr	:out std_logic_vector(7 downto 0);
	ramaddrrc	:in std_logic_vector(7 downto 0);
	ramaddrwc	:in std_logic_vector(7 downto 0);
	ramrd		:out std_logic;
	ramwr		:out std_logic;
	ramrefrsh	:out std_logic;
	rambusy		:in std_logic;
	ramde		:in std_logic;
	ramrdat		:in std_logic_vector(15 downto 0);
	ramwdat		:out std_logic_vector(15 downto 0);
	ramwe		:out std_logic_vector(1 downto 0);
	
	ini_end	:out std_logic;
	sclk	:in std_logic;
	vclk	:in std_logic;
	rclk	:in std_logic;
	rstn	:in std_logic
);
end component;

begin
	RAMC	: work.SDRAMC
	generic map(
		AWIDTH		=>AWIDTH,
		CAWIDTH		=>CAWIDTH,
		LAWIDTH		=>8,
		CLKMHZ		=>CLKMHZ
	) port map(
		SDRAM_CKE	=>SDRAM_CKE,
		SDRAM_nCS	=>SDRAM_nCS,
		SDRAM_nRAS	=>SDRAM_nRAS,
		SDRAM_nCAS	=>SDRAM_nCAS,
		SDRAM_nWE	=>SDRAM_nWE,
		SDRAM_DQMH	=>SDRAM_DQMH,
		SDRAM_DQML	=>SDRAM_DQML,
		SDRAM_BA		=>SDRAM_BA,
		SDRAM_A		=>SDRAM_A,
		SDRAM_DQ		=>SDRAM_DQ,
		
		addr_high	=>ramaddrh,
		bgnaddr		=>rambgnaddr,
		endaddr		=>ramendaddr,
		addr_rc		=>ramaddrrc,
		addr_wc		=>ramaddrwc,
		rddat		=>ramrdat,
		wrdat		=>ramwdat,
		de			=>ramde,
		we			=>ramwe,
		rd			=>ramrd,
		wr			=>ramwr,
		refrsh		=>ramrefrsh,
		busy		=>rambusy,
		
		initdone	=>ram_inidone,
		clk			=>rclk,
		rstn		=>rstn
	);
	
	b_rd_m	<='0' when cache_inidone='0' else b_rd;
	b_wr_m	<="00" when cache_inidone='0' else b_wr;

	CACHEC	:cachecont generic map(AWIDTH) port map(
		b_addr	=>b_addr,
		b_wdat	=>b_wdat,
		b_rdat	=>b_rdat,
		b_rd	=>b_rd_m,
		b_wr	=>b_wr_m,
		b_rmw	=>b_rmw,
		b_rmwmsk=>b_rmwmsk,
		b_ack	=>b_ack,

		b_csaddr=>b_csaddr,
		b_cdaddr=>b_cdaddr,
		b_cpy	=>b_cpy,
		b_cack	=>b_cack,
		
		g00_addr	=>g00_addr,
		g00_rd		=>g00_rd,
		g00_rdat	=>g00_rdat,
		g00_ack		=>g00_ack,

		g01_addr	=>g01_addr,
		g01_rd		=>g01_rd,
		g01_rdat	=>g01_rdat,
		g01_ack		=>g01_ack,

		g02_addr	=>g02_addr,
		g02_rd		=>g02_rd,
		g02_rdat	=>g02_rdat,
		g02_ack		=>g02_ack,

		g03_addr	=>g03_addr,
		g03_rd		=>g03_rd,
		g03_rdat	=>g03_rdat,
		g03_ack		=>g03_ack,

		g10_addr	=>g10_addr,
		g10_rd		=>g10_rd,
		g10_rdat	=>g10_rdat,
		g10_ack		=>g10_ack,

		g11_addr	=>g11_addr,
		g11_rd		=>g11_rd,
		g11_rdat	=>g11_rdat,
		g11_ack		=>g11_ack,

		g12_addr	=>g12_addr,
		g12_rd		=>g12_rd,
		g12_rdat	=>g12_rdat,
		g12_ack		=>g12_ack,

		g13_addr	=>g13_addr,
		g13_rd		=>g13_rd,
		g13_rdat	=>g13_rdat,
		g13_ack		=>g13_ack,

		t0_addr		=>t0_addr,
		t0_rd		=>t0_rd,
		t0_rdat0	=>t0_rdat0,
		t0_rdat1	=>t0_rdat1,
		t0_rdat2	=>t0_rdat2,
		t0_rdat3	=>t0_rdat3,
		t0_ack		=>t0_ack,
		
		t1_addr		=>t1_addr,
		t1_rd		=>t1_rd,
		t1_rdat0	=>t1_rdat0,
		t1_rdat1	=>t1_rdat1,
		t1_rdat2	=>t1_rdat2,
		t1_rdat3	=>t1_rdat3,
		t1_ack		=>t1_ack,

		g0_caddr	=>g0_caddr,
		g0_clear	=>g0_clear,
		
		g1_caddr	=>g1_caddr,
		g1_clear	=>g1_clear,

		g2_caddr	=>g2_caddr,
		g2_clear	=>g2_clear,

		g3_caddr	=>g3_caddr,
		g3_clear	=>g3_clear,
		
		ramaddrh	=>ramaddrh,
		rambgnaddr	=>rambgnaddr,
		ramendaddr	=>ramendaddr,
		ramaddrrc	=>ramaddrrc,
		ramaddrwc	=>ramaddrwc,
		ramrd		=>ramrd,
		ramwr		=>ramwr,
		ramrefrsh	=>ramrefrsh,
		rambusy		=>rambusy,
		ramde		=>ramde,
		ramrdat		=>ramrdat,
		ramwdat		=>ramwdat,
		ramwe		=>ramwe,
		
		ini_end	=>cache_inidone,
		sclk	=>sclk,
		vclk	=>vclk,
		rclk	=>rclk,
		rstn	=>rstn
	);
	
	initdone<=ram_inidone and cache_inidone;
	
end rtl;
