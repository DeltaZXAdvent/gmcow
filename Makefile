# Potential bugs:
# - In clip, newline sequence is not converted from "\n" to "\r\n"
# - Intermediates not set right
ows = base.ow stat.ow persp.ow spin.ow ease.ow menu.ow misc.ow bot.ow menu.ow.cfg draw.ow parkour.ow
intermediates = gmc.txt gmc.m4 menu.ow.cfg misc.ow cmdmisc.owo gmc.setting bot.ow
# the clip program is from windows
clip : gmc.setting
	cat gmc.setting | iconv -f UTF-8 -t GBK | clip
gmc.setting : setting.txt gmc.txt
	cat setting.txt gmc.txt > gmc.setting
gmc.txt : gmc.m4
	m4 config.m4 gmc.m4 > gmc.txt
gmc.m4 : $(ows) owc.awk
	./owc.awk > gmc.m4 $(ows)
menu.ow.cfg : menu.awk menu.in
	./menu.awk menu.in > menu.ow.cfg
misc.ow : misc.owo cmdmisc.owo
	cat misc.owo cmdmisc.owo > misc.ow
cmdmisc.owo : cmdmisc.awk cmdmisc.in
	./cmdmisc.awk cmdmisc.in > cmdmisc.owo
bot.ow : bottype.in bot.owo
	cat bot.owo <(echo) <(./bottype.awk bottype.in) > bot.ow
clean :
	rm -f $(intermediates)
