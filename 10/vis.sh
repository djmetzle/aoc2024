convert -delay 20 img-00.png $(fd .png) img-10.png $(fd .png | tac) -loop 0 animate.gif
