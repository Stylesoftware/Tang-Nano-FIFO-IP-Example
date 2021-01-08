# Tang-Nano-FIFO-IP-Example
Exploring the timing for the FIFO IP from Gowin, setup for the Tang Nano.

# The problem
A number of cycles need to be observed after read or write is enabled and before the actual data is presented or consumed, and before read or write is then disabled again.

# How it works
Use a stateful sequence to figure out when to trigger fifo_write_enable, fifo_read_enable and when to turn them off.  
This code saves 3 bytes to the FIFO and independently waits for fifo_empty to be turned off to then start reading those 3 bytes.
If successful, each byte turns on one of the three LED's on the Tang Nano (It may look light-cyan, but all three RGB LED's are on).

# Setup
In the GOWIN FPGA Designer, start a new project.<br>
Add the FIFO IP by clicking on the Tools Menu / IP Core Generator.<br>
Untick Almost Full and Almost Empty.<br>
Tick Output Registers Selected.<br>
Set Read and Write Depth to 16.<br>
Set Read and Write Width to 8.<br>
Click OK, then Add to your project when asked.<br>
Add the two files in this GIT (TOP.v and constrains.cst) to your FPGA project.<br>

# To Do
Write a state-machine module/wrapper not using fifo_empty, but employing the read_data_num to realize the number of bytes to read, and/or offload when Almost Full is reached.

# Literature
Search for the "Gowin FIFO User guide".
