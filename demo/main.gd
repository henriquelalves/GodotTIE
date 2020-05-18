extends Control

onready var tie = get_node("panel/text_interface_engine")

func select_demo(i):
	tie.reset()
	if(i == 1):
		# "A Beautiful Song"
		# by Henrique Alves
		tie.set_color(Color(1,1,1))
		# Buff text: "Text", duration (in seconds) of each letter
		tie.buff_text("This is a song, ", 0.1)
		tie.buff_text("lalala\n", 0.2)
		# Buff silence: Duration of the silence (in seconds)
		tie.buff_silence(1)
		tie.buff_text("It is so beautiful, ", 0.1)
		tie.buff_text("lalala\n", 0.2)
		tie.buff_silence(1)
		tie.buff_text("I love this song, ", 0.1)
		tie.buff_text("lalala\n", 0.2)
		tie.buff_silence(1)
		tie.buff_text("But now I'll ", 0.1) # WAIT FOR THE DROP
		tie.buff_text("DROP", 0.02) # ?????
		tie.buff_silence(0.4)
		tie.buff_text(" THE BASS\n", 0.02) # !!!!!
		tie.buff_silence(0.4)
		tie.buff_text("TVUVTUVUTUVU WOODBODBOWBDODBO TUUVUTVU WODWVDOOWDV WODOWVOOWDVOWVD DUBDUBDUBUDUDB OWVDOWVWDOWVDOWVDOWVDWVDOWVDOWVODV", 0.04) # I firmly believe this particular verse is my Magna Opus.
	elif(i == 2):
		tie.set_color(Color(1,1,0.3))
		# If velocity is 0, than whole text is printed 
		tie.buff_text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras semper finibus sapien, ut fringilla nulla vehicula ac. In hac habitasse platea dictumst. Nulla lobortis tempus sem vel lobortis. Mauris facilisis mollis nunc, vitae aliquet dui dictum id. Nullam ultricies facilisis interdum. Ut id semper eros, in lobortis diam. Nam consequat, dolor pharetra imperdiet finibus, lacus turpis tincidunt velit, ut fringilla ligula orci et justo. Praesent sagittis lectus eu metus faucibus aliquam. Donec sollicitudin porttitor massa a mollis. Nulla eleifend orci lacus, et tristique dui viverra eu. Sed nec mollis ligula. Quisque eu tellus libero. Nulla id hendrerit mauris.",0)
	elif(i == 3):
		tie.set_color(Color(0.3,1,1))
		# Schedule an Input in the buffer, after all
		# the text before it is displayed
		tie.buff_text("Hey there!! What's your name?\n", 0.01)
		tie.buff_input()
	tie.set_state(tie.STATE_OUTPUT)

func _ready():
	# Add the demos in the list
	get_node("demos_list").set_focus_mode(0)
	get_node("demos_list").add_item("No demo")
	get_node("demos_list").add_item("DEMO_Music")
	get_node("demos_list").add_item("DEMO_Ipsum")
	get_node("demos_list").add_item("DEMO_Input")
	
	# Connect every signal to check them using the "print()" method
	tie.connect("input_enter", self, "_on_input_enter")
	tie.connect("buff_end", self, "_on_buff_end")
	tie.connect("state_change", self, "_on_state_change")
	tie.connect("enter_break", self, "_on_enter_break")
	tie.connect("resume_break", self, "_on_resume_break")
	tie.connect("tag_buff", self, "_on_tag_buff")
	pass

func _on_demos_list_item_selected( ID ):
	select_demo(ID)

func _on_input_enter(s):
	print("Input Enter ",s)
	
	tie.add_newline()
	tie.buff_text("Oooh, so your name is " + s + "? What a beautiful name!", 0.01)
	pass

func _on_buff_end():
	print("Buff End")
	pass

func _on_state_change(i):
	print("New state: ", i)
	pass

func _on_enter_break():
	print("Enter Break")
	pass

func _on_resume_break():
	print("Resume Break")
	pass

func _on_tag_buff(s):
	print("Tag Buff ",s)
	pass
