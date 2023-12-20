LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.all;

ENTITY bat_n_ball IS
    PORT (
        clk : in std_logic;
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        jump_sig : IN STD_LOGIC; -- player jump
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC;
        counter : out std_logic_vector(15 downto 0); -- sends score to display
        reset : in std_logic -- resets game
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS
    constant cols : integer := 800; -- number of columns on screen
    CONSTANT player_size : INTEGER := 12; -- player size in pixels
    CONSTANT big_size : INTEGER := 12; -- large obstacle size in pixels
    CONSTANT med_size : INTEGER := 8; -- medium obstacle size in pixels
    CONSTANT sml_size : INTEGER := 4; -- small obstacle size in pixels
    constant ground_w : integer := 800; -- width of ground
    constant ground_h : integer := 3; -- height of ground
    signal ground_on : std_logic := '1'; -- ground is always drawn
    SIGNAL player_on : STD_LOGIC; -- indicates whether player is at current pixel position
    SIGNAL big_on : STD_LOGIC; -- indicates whether big obstacle is at current pixel position
    SIGNAL med_on : STD_LOGIC; -- indicates whether med obstacle is at current pixel position
    SIGNAL sml_on : STD_LOGIC; -- indicates whether small obstacle is at current pixel position
    SIGNAL game_on : STD_LOGIC := '1'; -- indicates whether ball is in play
    -- initial position of all objects
    signal big_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(cols, 11);
    signal big_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(420, 11);
    signal med_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(cols, 11);
    signal med_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(442, 11);
    signal sml_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(cols, 11);
    signal sml_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(340, 11);
    SIGNAL player_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    SIGNAL player_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(438, 11);
    signal ground_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(450, 11);
    signal ground_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(450, 11);
    -- initial speed of all objects  
    constant big_speed : integer := 65;
    constant med_speed : integer := 55;
    constant sml_speed : integer := 60;
    signal player_speed : integer := 30;
    constant time_factor : integer := 6250;
    -- random number generators
    constant rand_width : integer := 5;
    signal rand_num : integer := 0;
    -- game logic signals
    signal is_jumping : std_logic := '0';
    signal score : std_logic_vector (15 downto 0);
    signal restart : std_logic := '0';
    signal end_game : std_logic := '0';
BEGIN
    red <= NOT ground_on AND NOT sml_on; -- color setup for magenta player, black ground, red obstacles, and blue bonus
    green <= NOT big_on AND NOT med_on AND NOT sml_on AND NOT ground_on AND NOT player_on;
    blue <= NOT big_on AND NOT med_on AND NOT ground_on;
    
    
        -- Process to draw round playe
        -- Draws player by sset player_on if current pixel address is covered by player position
    
    playerdraw : PROCESS (player_x, player_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF pixel_col <= player_x THEN -- vx = |ball_x - pixel_col|
            vx := player_x - pixel_col;
        ELSE
            vx := pixel_col - player_x;
        END IF;
        IF pixel_row <= player_y THEN -- vy = |ball_y - pixel_row|
            vy := player_y - pixel_row;
        ELSE
            vy := pixel_row - player_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (player_size * player_size) THEN -- test if radial distance < bsize
            player_on <= game_on;
        ELSE
            player_on <= '0';
        END IF;
    END PROCESS;
    
        -- Draws the large obstacle
    
    big_obstacle : process (big_x, big_y, pixel_row, pixel_col) is 
    begin
            IF (pixel_col >= big_x - big_size) AND
               (pixel_col <= big_x + big_size) AND
               (pixel_row >= big_y - big_size) AND
               (pixel_row <= big_y + big_size) THEN
                    big_on <= '1';
            ELSE
                big_on <= '0';
            END IF;
    end process;
    
        -- Draws the small obstacle
    
    med_obstacle : process (med_x, med_y, pixel_row, pixel_col) is 
    begin
            IF (pixel_col >= med_x - med_size) AND
               (pixel_col <= med_x + med_size) AND
               (pixel_row >= med_y - med_size) AND
               (pixel_row <= med_y + med_size) THEN
                    med_on <= '1';
            ELSE
                med_on <= '0';
            END IF;
    end process;

        -- Draws the small obstacle

    sml_obstacle : process (sml_x, sml_y, pixel_row, pixel_col) is 
    begin
            IF (pixel_col >= sml_x - sml_size) AND
               (pixel_col <= sml_x + sml_size) AND
               (pixel_row >= sml_y - sml_size) AND
               (pixel_row <= sml_y + sml_size) THEN
                    sml_on <= '1';
            ELSE
                sml_on <= '0';
            END IF;
    end process;
    
        -- Draws the gorund
        
    ground_draw : PROCESS (ground_x, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); 
    BEGIN
        IF ((pixel_col >= ground_x - ground_w) OR (ground_x <= ground_w)) AND
         pixel_col <= ground_x + ground_w AND
             pixel_row >= ground_y - ground_h AND
             pixel_row <= ground_y + ground_h THEN
                ground_on <= '1';
        ELSE
            ground_on <= '0';
        END IF;
    END PROCESS;
    
    game_logic : PROCESS (clk, restart)
        variable endGame : std_logic := '0';
        variable player_count : integer := 0;
        variable big_count : integer := 0;
        variable med_count : integer := 0;
        variable sml_count : integer := 0;
        variable rand_temp : std_logic_vector(RAND_WIDTH - 1 downto 0):=(RAND_WIDTH - 1 => '1',others => '0');
		variable temp : std_logic := '0';
	begin
		if clk'event and clk = '1' then

			-- Generate random number
			temp := rand_temp(RAND_WIDTH - 1) xor rand_temp(RAND_WIDTH - 2);
			rand_temp(RAND_WIDTH - 1 downto 1) := rand_temp(RAND_WIDTH - 2 downto 0);
			rand_temp(0) := temp;
		    rand_num <= conv_integer(rand_temp);
            
            -- Start jump
            IF jump_sig = '1' AND is_jumping = '0' THEN
                is_jumping <= '1';
            END IF;
    
            -- Jumping logic
            if player_count >= time_factor * player_speed then
                IF is_jumping = '1' THEN
                    if (player_y > 335) then 
                        player_y <= player_y - 1;
                    else 
                        is_jumping <= '0';
                    end if;
                    player_count := 0;
                else 
                    if (player_y < 438) then 
                        player_y <= player_y + 1;
                    end if;
                    player_count := 0;
                END IF;
            end if;
            player_count := player_count + 1;
        
            -- Collision detection, ends game
        
        IF ((player_x + player_size/2) >= (big_x - big_size) AND
             (player_x - player_size/2) <= (big_x + big_size) AND
             (player_y + player_size/2) >= (big_y - big_size) AND
             (player_y - player_size/2) <= (big_y + big_size)) OR 
             ((player_x + player_size/2) >= (med_x - med_size) AND
             (player_x - player_size/2) <= (med_x + med_size) AND
             (player_y + player_size/2) >= (med_y - med_size) AND
             (player_y - player_size/2) <= (med_y + med_size))
             THEN
                end_game <= '1';
        END IF;
        
            -- Player score increase, increments on hit with blue bonus object
        
        IF ((player_x + player_size/2) >= (sml_x - sml_size) AND
             (player_x - player_size/2) <= (sml_x + sml_size) AND
             (player_y + player_size/2) >= (sml_y - sml_size) AND
             (player_y - player_size/2) <= (sml_y + sml_size)) then
             score <= score + 500;
             counter <= score;
             sml_x <= conv_std_logic_vector(cols + cols, 11);
        end if;
        
            -- End game 
        
        if (end_game = '1') then 
            player_x <= conv_std_logic_vector(400, 11);
            player_y <= conv_std_logic_vector(438, 11);
            end_game <= '0';
            restart <= '1';
        end if;
        
            -- Reset game
         
        if reset = '1' then
            restart <= '1';
        end if;
        
        if (restart = '1') then 
            big_x <= conv_std_logic_vector(cols, 11);
            med_x <= conv_std_logic_vector(COLS + (COLS/2), 11);
            sml_x <= conv_std_logic_vector(cols + cols, 11);
            score <= "0000000000000000";
            restart <= '0';
        end if;
        
                -- Large object movement
        if (endGame = '0') and (big_count >= time_factor * big_speed) then
		      if (big_x <= 0) then
			         big_x <= conv_std_logic_vector(COLS + rand_num, 11);
			  else
					 big_x <= big_x - 1;
			  end if;
			  big_count := 0;
		end if;
	    big_count := big_count + 1;


				-- Medium object movement
		if (endGame = '0') and (med_count >= time_factor * med_speed) then
			   if med_x <= 0 then
				      med_x <= conv_std_logic_vector(COLS + (COLS/2) + rand_num, 11);
			   else
					  med_x <= med_x - 1;
			   end if;
			   med_count := 0;
		end if;
		med_count := med_count + 1;


				-- Small object movement
		if (endGame = '0') and (sml_count >= time_factor * sml_speed) then
			   if sml_x <= 0 then
					   sml_x <= conv_std_logic_vector(COLS + cols, 11);
			   else
					   sml_x <= sml_x - 1;
			   end if;
			   sml_count := 0;
		end if;
		sml_count := sml_count + 1;
    end if;
    END PROCESS;
    counter <= score;
END Behavioral;
