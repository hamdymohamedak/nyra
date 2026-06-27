module ny-redis

version 0.1.0

link hiredis
link-arg -I/opt/homebrew/include
link-arg -L/opt/homebrew/lib
link-source rt/hiredis_shim.c
