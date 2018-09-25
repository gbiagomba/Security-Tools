```


                    ___.-------.___
                _.-' ___.--;--.___ `-._
             .-' _.-'  /  .+.  \  `-._ `-.
           .' .-'      |-|-o-|-|      `-. `.
          (_ <O__      \  `+'  /      __O> _)
            `--._``-..__`._|_.'__..-''_.--'
                  ``--._________.--''
   ____  _____  ____    ____       _       _______
  |_   \|_   _||_   \  /   _|     / \     |_   __ \
    |   \ | |    |   \/   |      / _ \      | |__) |
    | |\ \| |    | |\  /| |     / ___ \     |  ___/
   _| |_\   |_  _| |_\/_| |_  _/ /   \ \_  _| |
|_____|\____||_____||_____||____| |____||_____|
```
# Nmap Scripts
I create this script to help automate host and port discovery during the recon phase of an assessment. 

## Usage
```
./desired_nmap_script.sh
```
Obviously you would substitute the "desired_nmap_script.sh" with the actual script version you want.

# Versions
There are two versions of the script, the lite an the heavy (aka full) version.
```

          :================:
         /||# nmap -A _   ||
        / ||              ||
       |  ||              ||
        \ ||              ||
          ==================
   ........... /      \.............
   :\        ############            \
   : ---------------------------------
   : |  *   |__________|| ::::::::::  |
   \ |      |          ||   .......   |
     --------------------------------- 8
```

## NmapScript_Lite
The lightweight version or lite script was designed to perform a "light" port knock scan of a target network. It achieves this by checking the top 200 most commonly used TCP/UDP ports using masscan. Then it performs various ICMP scans using nmap followed with a targeted scan. Using the ports it found during the initial massscan scan we performed earlier. Last step is to perform some firewall evation scanning.

## NmapScript_Full
The heavyweight version or full script was designed to perform a port knock scan of a target network. It checks all 65,535 TCP/UDP ports using masscan. Then it performs various ICMP scans using nmap followed with further targeted scans. Using the ports it found during the initial massscan scan we performed earlier. The additional targeted scan consists of TCP SYN/ACK, UDP, and firewall evation scanning. Lastly, the script will zip up the findings and email it to an email address you desire. 

# Conclusion
As a wise man once said: "With great power, comes great responsibility" - Uncle Ben
```
   (  )   /\   _                 (
    \ |  (  \ ( \.(               )                      _____
  \  \ \  `  `   ) \             (  ___                 / _   \
 (_`    \+   . x  ( .\            \/   \____-----------/ (o)   \_
- .-               \+  ;          (  O                           \____
(__                +- .( -'.- <.   \_____________  `              \  /
(_____            ._._: <_ - <- _- _  VVVVVVV VV V\                \/
  .    /./.+-  . .- /  +--  - .    (--_AAAAAAA__A_/                |
  (__ ' /x  / x _/ (                \______________//_              \_______
 , x / ( '  . / .  /                                  \___'          \     /
    /  /  _/ /    +                                       |           \   /
   '  (__/                                               /              \/
                                                       /                  \
NMAP IS A POWERFUL TOOL -- USE CAREFULLY AND RESPONSIBLY
```
