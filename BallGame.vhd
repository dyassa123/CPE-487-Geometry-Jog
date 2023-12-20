LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY BallGame IS
    PORT (
        clk_in : IN STD_LOGIC; -- system clock
        VGA_red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- VGA outputs
        VGA_green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_hsync : OUT STD_LOGIC;
        VGA_vsync : OUT STD_LOGIC;
        btnc : IN STD_LOGIC; -- button to initiate jump
        btnu : In std_logic; -- reset button
        anode : out std_logic_vector ( 7 downto 0);
        seg : out std_logic_vector (6 downto 0));
 END BallGame;

ARCHITECTURE Behavioral OF BallGame IS
    SIGNAL pxl_clk : STD_LOGIC := '0'; -- 25 MHz clock to VGA sync module
    -- internal signals to connect modules
    SIGNAL S_red, S_green, S_blue : STD_LOGIC; --_VECTOR (3 DOWNTO 0);
    SIGNAL S_vsync : STD_LOGIC;
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL batpos : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    SIGNAL serial_clk, sample_clk : STD_LOGIC;
    SIGNAL adout : STD_LOGIC_VECTOR (11 DOWNTO 0);
    SIGNAL count : STD_LOGIC_VECTOR (9 DOWNTO 0); -- counter to generate ADC clocks
    signal display : std_logic_vector (15 downto 0);
    signal mpx : std_logic_vector (2 downto 0);
    signal cnt : std_logic_vector (20 downto 0);
    

    COMPONENT bat_n_ball IS
        PORT (
            clk : in std_logic;
            v_sync : IN STD_LOGIC;
            pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            red : OUT STD_LOGIC;
            green : OUT STD_LOGIC;
            blue : OUT STD_LOGIC;
            counter : out std_logic_vector;
            jump_sig : in std_logic;
            reset : in std_logic
        );
    END COMPONENT;
    COMPONENT vga_sync IS
        PORT (
            pixel_clk : IN STD_LOGIC;
            red_in    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_in  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_in   : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            red_out   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_out  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            hsync : OUT STD_LOGIC;
            vsync : OUT STD_LOGIC;
            pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT clk_wiz_0 is
        PORT (
            clk_in1  : in std_logic;
            clk_out1 : out std_logic
        );
    END COMPONENT;
    component leddecNew is 
        port (
        dig : in std_logic_vector (2 downto 0);
        data4 : in std_logic_vector (15 downto 0);
        anode_new : out std_logic_vector (7 downto 0);
        seg_new : out std_logic_vector (6 downto 0)
      );
    end component;
BEGIN
    -- Process to generate clock signals
    ckp : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(clk_in);
        count <= count + 1; -- counter to generate ADC timing signals
    END PROCESS;
    serial_clk <= NOT count(4); -- 1.5 MHz serial clock for ADC
    sample_clk <= count(9); -- sampling clock is low for 16 SCLKs
    mpx <= count(9 downto 7); -- multiplexer for display


    add_bb : bat_n_ball
    PORT MAP(--instantiate bat and ball component
        clk => clk_in,
        v_sync => S_vsync, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        jump_sig => btnc, 
        red => S_red, 
        green => S_green, 
        blue => S_blue,
        counter => display,
        reset => btnu
    );
    vga_driver : vga_sync
    PORT MAP(--instantiate vga_sync component
        pixel_clk => pxl_clk, 
        red_in => S_red & "000", 
        green_in => S_green & "000", 
        blue_in => S_blue & "000", 
        red_out => VGA_red, 
        green_out => VGA_green, 
        blue_out => VGA_blue, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync => VGA_hsync, 
        vsync => S_vsync
    );
    led : leddecNew
        port map(
            dig => mpx, data4 => display,
            anode_new => anode, seg_new => seg
            );
    
    VGA_vsync <= S_vsync; --connect output vsync
    clk_wiz_0_inst : clk_wiz_0
     port map (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
      );
     
END Behavioral;
