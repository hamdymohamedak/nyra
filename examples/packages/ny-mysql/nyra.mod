module ny-mysql

version 0.1.0

link mysqlclient
link-arg -I/opt/homebrew/include
link-arg -L/opt/homebrew/lib
link-source rt/mysql.c
