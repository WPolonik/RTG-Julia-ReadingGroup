# Parallel Processing walkthrough

A leisurely stroll through some parallel processing features in Julia.

## SSH on compute servers

To prepare for this walk we need to setup ssh logon to the stats department servers. Some decent tutorials for this are:
- (Linux/MacOS) https://debian-administration.org/article/530/SSH_with_authentication_key_instead_of_password
- (Windows https://www.howtogeek.com/336775/how-to-enable-and-use-windows-10s-built-in-ssh-commands/) Note: I haven't verified the last one, let me know if it's good or not.

The gist of this process is:

1.	Make a ssh key on your machine/computer
2. 	Copy your (public) key over to the server
3.	Login for the first time, use your password
4.	You now have password-less ssh access!

This process can be setup to login from your computer to a compute server, but it also can be setup from compute server to compute server.

## References
-	https://github.com/crstnbr/JuliaWorkshop19