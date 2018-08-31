#!/bin/bash

test_true_color_24_bit() {
  awk -v term_cols="${width:-$(tput cols || echo 80)}" 'BEGIN{
      s="/\\";
      for (colnum = 0; colnum<term_cols; colnum++) {
          r = 255-(colnum*255/term_cols);
          g = (colnum*510/term_cols);
          b = (colnum*255/term_cols);
          if (g>255) g = 510-g;
          printf "\033[48;2;%d;%d;%dm", r,g,b;
          printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
          printf "%s\033[0m", substr(s,colnum%2+1,1);
      }
      printf "\n";
  }'
}

test_true_color_24_bit

#256 support ..................  ok|fail
#trucolor 24 bit support ......  ok
#
#color outputs...:w


plain ascii
ansi escape codes     (16 colour codes with bold/italic and background)
256 colour pallette   (216 colours + 16 ansi + 24 gray) (colors are 24 bit)
24 bit true colour    ("888" colours aka 16 million)
