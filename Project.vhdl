library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity project_reti_logiche is
port (
i_clk : in std_logic;
i_rst : in std_logic;
i_start : in std_logic;
i_data : in std_logic_vector(7 downto 0);
o_address : out std_logic_vector(15 downto 0);
o_done : out std_logic;
o_en : out std_logic;
o_we : out std_logic;
o_data : out std_logic_vector (7 downto 0)
);
end project_reti_logiche;



architecture Behavioral of project_reti_logiche is

    type state_type is (WAIT_START, CHECK, PRIMO, WRITE_OUT1,WRITE_OUT2,DONE,S0, S1, S2, S3);
    signal next_state, current_state, ultimostato: state_type;
    
     --Segnali di aggiornamento uscite componente
       signal o_done_next, o_en_next, o_we_next : std_logic := '0';
       signal o_data_next1 : std_logic_vector(15 downto 0) := "0000000000000000";
       signal o_data_next : std_logic_vector(7 downto 0) := "00000000";
       signal o_address_next : std_logic_vector(15 downto 0) := "0000001111101000";
       signal i_dataletta,i_dataletta1 : std_logic_vector(7 downto 0) := "00000000";
       signal write_ok,write_ok_next: std_logic :='0';
       signal write_en: std_logic :='0';
       
       --Segnali per l' indirizzo da tradurre (indirizzo memoria 8)
       -- signal p1, p1_next : std_logic :='0';
       -- signal p2, p2_next : std_logic :='0';
      
        
       
       
       --Segnali per l' indirizzo che voglio leggere
       signal addr_read, addr_read_next : std_logic_vector(15 downto 0) := "0000000000000000";
    

begin

  state_reg: process(i_clk,i_rst)
  begin
  
    if i_rst='1' then
     
      o_done <= '0';
      o_en <= '0';
      o_we <= '0';
      o_data <= "00000000";
      o_address <= "0000001111101000";
      --p1 <= '0';
      --p2 <= '0';
      addr_read <= "0000000000000000";
      current_state <= WAIT_START;
      
      
    elsif (i_clk'event and i_clk = '1') then
      current_state <= next_state;
      o_done <= o_done_next;
      o_en <= o_en_next;
      o_we <= o_we_next;
      o_data <= o_data_next;
      write_en<= o_we_next;
      o_address <=o_address_next;
      write_ok<=write_ok_next;
      
      --p1 <= p1_next;
      --p2 <= p2_next;
      addr_read <= addr_read_next;
      i_dataletta <= i_data;
      
      
      
    end if;
    end process;
    
delta: process(current_state, i_data,i_start,addr_read)
 variable i : integer;
 --variable c : integer range 0 to 255;
begin
  
   --Valori di default ad ogni ciclo di clock
   o_done_next <= '0';
   o_en_next <= '0';
   o_we_next <= '0';
   --o_data_next <= "00000000";
   --o_address_next <= "0000000000000000";
   next_state <= current_state;
   
   case current_state is
   
   when WAIT_START =>
        if(i_start = '1') then
              next_state <= PRIMO;
        else 
            if(i_start ='0') then
            next_state <=WAIT_START;
        end if;
        end if;
                   
                   
     --Stato in cui chiedo l'indirizzo alla memoria
    when PRIMO =>
        -- c:=0;
         o_en_next <= '1';
         i_dataletta1 <= i_data;
         ultimostato<=S0;
         next_state <= CHECK;
    
    --Stato im cui chiedo alla memoria il prossimo indirizzo di working zone   
    
     
    --when REQUEST_ADDRESS =>
        --  o_en_next <= '1';
          
         -- p1_next <= i_dataletta(0);
          
          --i_dataletta <= i_dataletta + i_dataletta;
         -- addr_read_next <= addr_read - "0001";
         -- o_address_next <= addr_read - "0001";
       --   next_state <= s0;
     when CHECK =>
               o_en_next <= '1'; -- forse non serve
               o_we_next <= '0';
               o_address_next <=std_logic_vector(unsigned(o_address_next)+8);
               o_we_next<='0';
              -- c:=c+1;
               i_dataletta <= i_data;
               i:=0;
               next_state <= ultimostato; 
    
    --Stato in cui controllo se devo tradurre l'indirizzo o andare avanti a chiedere gli indirizzi di working zone
    when S0 =>
        if(i_dataletta(i)= '0' and i <8 ) then 
              
              o_data_next1 <= "00" & o_data_next1(13 downto 0) ;
              i :=i+1;
              ultimostato <= S0;
              next_state <= S0;
        else
             if(i_dataletta(i)= '1' and i <8) then 
                 
                 o_data_next1 <=  "11" & o_data_next1(13 downto 0) ;
                 i :=i+1;
                 ultimostato <= S0;
                 next_state <= S2;
        else     
                 next_state <= WRITE_OUT1;
                 --next_state<=WRITE_OUT;
             --else
               --   if(addr_read="1111") then
                 --    next_state<=WRITE_OUT;
             --     else
             --        next_state <= REQUEST_ADDRESS;
             --                end if;
                        end if;
                      end if;
     
     when S1 =>
             if(i_dataletta(i)= '0' and i <8) then
             
                 o_data_next1 <= "11" & o_data_next1(13 downto 0) ;
                 i :=i+1;
                 ultimostato <= S1;
                 next_state <= S0;
             else
                 if(i_dataletta(i)= '1' and i <8) then
                 o_data_next1 <="00" & o_data_next1(13 downto 0) ;
                 i :=i+1;
                 ultimostato <= S1;
                 next_state <= S2;
             else
                 next_state <= WRITE_OUT1;
             end if;               
         end if;
         
     when S2 =>
              if(i_dataletta(i)= '0' and i <8) then
                 
                 o_data_next1 <= "10" & o_data_next1(13 downto 0) ;
                 i :=i+1;
                 ultimostato <= S2;
                 next_state <= S1;
             else
                if(i_dataletta(i)= '1' and i <8) then
                
                 o_data_next1 <="01" & o_data_next1(13 downto 0) ;
                 i :=i+1;
                 ultimostato <= S2;
                 next_state <= S3;
            else  
                 next_state <= WRITE_OUT1;
             end if;
          end if;
          
     when S3 =>
              if(i_dataletta(i)= '0' and i <8) then
                  
                  o_data_next1 <="01" & o_data_next1(13 downto 0) ;
                   i :=i+1;
                   ultimostato <= S3;
                  next_state <= S0;
              else
                  if(i_dataletta(i)= '1' and i <8) then
                  
                  o_data_next1 <="10" & o_data_next1(13 downto 0) ;
                   i :=i+1;
                   ultimostato <= S3;
                  next_state <= S0;
              else 
                  next_state <= WRITE_OUT1;
              end if;
           end if;   
     --Stato in cui scrivo sulla memoria l'indirizzo tradotto o non tradotto a seconda del caso
     when WRITE_OUT1=>
           if(write_ok='0') then 
              next_state<=WRITE_OUT1;
              if(write_en='0') then
                   
              
            
                   o_en_next<='1';
                   o_we_next<='1';
                   
                   o_data_next <= o_data_next1(15 downto 8);
                  -- o_data<=o_data_next;
                   
                   --o_data_next <= o_data_next1(7 downto 0);
                   --o_data<=o_data_next;
                   --o_address_next <=std_logic_vector(unsigned(o_address_next)+1);
                   
              else write_ok_next<='1';
              end if;        
          else next_state<=WRITE_OUT2;
          
         end if; 
           
    when WRITE_OUT2=>
                      
                          o_en_next<='1';
                          o_we_next<='1';
                          
                          o_data_next <= o_data_next1(7 downto 0);
                         -- o_data<=o_data_next;
                          o_address_next <=std_logic_vector(unsigned(o_address_next)+8);
                          --o_data_next <= o_data_next1(7 downto 0);
                          --o_data<=o_data_next;
                          --o_address_next <=std_logic_vector(unsigned(o_address_next)+1);
                          if(to_integer(unsigned(i_dataletta1))=to_integer( unsigned(o_address_next - "0000001111101000"))/8) then
                          
                          next_state<=DONE;
                          
                          else 
                              next_state<=CHECK;
                          end if;
                      
          -- o_address_next <= "1001";
        --if(translate = false) then
        --      o_data_next<="0" & addr_transl;
        --else
          --    o_data_next(7) <= '1';
          --    o_data_next(6 downto 4) <= addr_read(2 downto 0) + "001";
      --  case diff is
         --     when "00" => o_data_next(3 downto 0) <= "0001";
          --    when "01" => o_data_next(3 downto 0) <= "0010";
          --    when "10" => o_data_next(3 downto 0) <= "0100";
          --    when others => o_data_next(3 downto 0) <= "1000";
      --  end case;
      --  end if;            
         
      --Stato in cui aspetto che la memoria abbassi il segnale di start
     
     when DONE=> 
           o_done_next<='1';
           
         
             --addr_transl_next <= "0000000";
             --addr_read_next <= "1000";
             --diff_next<="0000000";
             -- translate_next <= false;
            next_state<=WAIT_START;
            
          
     
     
         
       end case;
end process;

end Behavioral;
