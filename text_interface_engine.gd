#MADE BY HENRIQUE ALVES
#ALL RIGHTS RESERVED BLABLABLA
#Its MIT licensed

# Intern initializations
extends Node2D # Extends from Node2D

const _ARRAY_CHARS = [" ","!","\"","#","$","%","&","'","(",")","*","+",",","-",".","/","0","1","2","3","4","5","6","7","8","9",":",";","<","=",">","?","@","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","[","\\","]","^","_","`","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","{","|","}","~"]

const STATE_WAITING = 0
const STATE_OUTPUT = 1
const STATE_INPUT = 2

onready var _buffer = [] # 0 = Debug; 1 = Text; 2 = Silence; 3 = Break; 4 = Input
onready var _label = Label.new() # The Label in which the text is going to be displayed
onready var _state = 0 # 0 = Waiting; 1 = Output; 2 = Input

onready var _output_delay = 0
onready var _output_delay_limit = 0
onready var _on_break = false
onready var _max_lines_reached = false
onready var _buff_beginning = true
onready var _turbo = false

onready var _blink_input_visible = false
onready var _blink_input_timer = 0
onready var _input_timer_limit = 1
onready var _input_index = 0

# =============================================== 
# Text display properties!
export(int) var MAX_LINES = 5 # Maximum number of lines in the label
export(int) var LINE_WIDTH = 200 # Number of characters per line
export(bool) var SCROLL_ON_MAX_LINES = true # If this is true, the text buffer update will stop after reaching the maximum number of lines; else, it will stop to wait for user input, and than clear the text.
export(bool) var BREAK_ON_MAX_LINES = true # If the text output pauses waiting for the user when reaching the maximum number of lines
export(bool) var AUTO_SKIP_WORDS = true # If words that dont fit the line only start to be printed on next line
export(bool) var LOG_SKIPPED_LINES = true # false = delete every line that is not showing on screen
export(bool) var SCROLL_SKIPPED_LINES = false # if the user will be able to scroll through the skipped lines; weird stuff can happen if this and BREAK_ON_MAX_LINE/LOG_SKIPPED_LINES
export(Font) var FONT
# Text input properties!
export(bool) var PRINT_INPUT = true # If the input is going to be printed
export(bool) var BLINKING_INPUT = true # If there is a _ blinking when input is appropriate
export(int) var INPUT_CHARACTERS_LIMIT = -1 # If -1, there'll be no limits in the number of characters
# ===============================================

func buff_debug(f, lab = false, arg0 = null): # For simple debug purposes; use with care
	_buffer.append([0, f, lab, arg0])

func buff_text(text, vel = 0): # The text for the output, and its printing velocity (per character)
	_buffer.append([1, text, vel])

func buff_silence(len): # A duration without output
	_buffer.append([2, len])

func buff_break(): # Stop output until the player hits enter
	_buffer.append([3])

func buff_input(): # 'Schedule' a change state to Input in the buffer
	_buffer.append([4])

func clear_text(): # Deletes ALL the text on the label
	_label.set_text("")

func clear_skipped_lines(): # Deletes only the 'hidden' lines, if LOG_SKIPPED_LINES is false
	if(LOG_SKIPPED_LINES == true):
		_clear_skipped_lines()

func add_newline(): # Add a new line to the label text
	_label_print("\n")

func get_text(): # Get current text on Label
	return _label.get_text()

func set_turbomode(s): # Print stuff in the maximum velocity and ignore breaks
	_turbo = s;

func set_font(str_path): # Changes the font of the text; weird stuff will happen if you use this function after text has been printed
	_label.add_font_override("font",load(str_path))

func set_state(i): # Changes the state of the Text Interface Engine
	emit_signal("state_change", i)
	_state = i
	if(i == 2): # Set input index to last character on the label
		_input_index = _label.get_text().length()

func set_buff_speed(v): # Changes the velocity of the text being printed
	if (_buffer[0][0] == 1):
		_buffer[0][2] = v

# ==============================================
# Reserved methods

# Override
func _ready():
	set_fixed_process(true)
	set_process_input(true)
	
	add_child(_label)
	if(FONT != null):
		_label.add_font_override("font", FONT)
	
	_label.set_size(Vector2(LINE_WIDTH,_label.get_line_height()*MAX_LINES))
	_label.set_autowrap(true)
	
	add_user_signal("input_enter") # When user finished an input
	add_user_signal("buff_end") # When there is no more outputs in _buffer
	add_user_signal("max_lines_reach") # When the maximum number of lines is reached
	add_user_signal("state_change") # When the state of the engine changes
	add_user_signal("enter_break") # When the engine stops on a break
	add_user_signal("resume_break") # When the engine resumes from a break

func _fixed_process(delta):
	if(_state == STATE_OUTPUT): # Output
		if(_buffer.size() == 0):
			set_state(STATE_WAITING)
			emit_signal("buff_end")
			return
		
		var o = _buffer[0] # Calling this var 'o' was one of my biggest mistakes during the development of this code. I'm sorry about this.
		
		if (o[0] == 0): # ---- It's a debug! ----
			if(o[2] == false):
				if(o[3] == null):
					print(self.call(o[1]))
				else:
					print(self.call(o[1],o[3]))
			else:
				if(o[3] == null):
					print(_label.call(o[1]))
				else:
					print(_label.call(o[1],o[3]))
			_buffer.pop_front()
		elif (o[0] == 1): # ---- It's a text! ----
			# -- Print Text --
			var ot = o[1] # Whole text to be printed
			
			if (_turbo): # In case of turbo, print everything on this buff
				o[2] = 0
			
			if(o[2] == 0): # If the velocity is 0, than just print everything
				while(o[1] != ""): # Not optimal (not really printing everything at the same time); but is the only way to work with line break
					if(AUTO_SKIP_WORDS and (o[1][0] == " " or _buff_beginning)):
						_skip_word()
					_label_print(o[1][0])
					_buff_beginning = false
					o[1] = o[1].right(1)
					if(_max_lines_reached == true):
						break
					
			else: # Else, print each character according to velocity
				_output_delay_limit = o[2]
				_output_delay += delta
				if(_output_delay > _output_delay_limit):
					if(AUTO_SKIP_WORDS and (o[1][0] == " " or _buff_beginning)):
						_skip_word()
					_label_print(ot[0])
					_buff_beginning = false
					_output_delay -= _output_delay_limit
					o[1] = o[1].right(1)
			# -- Popout Buff --
			if (o[1] == ""): # This buff finished, so pop it out of the array
				_buffer.pop_front()
				_buff_beginning = true
				_output_delay = 0
		elif (o[0] == 2): # ---- It's a silence! ----
			_output_delay_limit = o[1] # Length of the silence
			_output_delay += delta
			if(_output_delay > _output_delay_limit):
				_output_delay = 0
				_buffer.pop_front()
		elif (o[0] == 3): # ---- It's a break! ----
			if(_turbo): # Ignore this break
				_buffer.pop_front()
			elif(!_on_break):
				emit_signal("enter_break")
				_on_break = true
		elif (o[0] == 4): # ---- It's an Input! ----
			set_state(STATE_INPUT)
			_buffer.pop_front()
	elif(_state == STATE_INPUT):
		if BLINKING_INPUT:
			_blink_input_timer += delta
			if(_blink_input_timer > _input_timer_limit):
				_blink_input_timer -= _input_timer_limit
				_blink_input()
	
	pass

func _input(event):
	if(event.type == InputEvent.KEY and event.is_pressed() == true ):
		if(SCROLL_SKIPPED_LINES and event.scancode == KEY_UP or event.scancode == KEY_DOWN): # User is just scrolling the text
			if(event.scancode == KEY_UP):
				if(_label.get_lines_skipped() > 0):
					_label.set_lines_skipped(_label.get_lines_skipped()-1)
			else:
				if(_label.get_lines_skipped() < _label.get_line_count()-MAX_LINES):
					_label.set_lines_skipped(_label.get_lines_skipped()+1)
		elif(_state == 1 and _on_break): # If its on a break
			if(event.scancode == KEY_RETURN):
				emit_signal("resume_break")
				_buffer.pop_front() # Pop out break buff
				_on_break = false
		elif(_state == 2): # If its on the input state
			var input = _label.get_text().right(_input_index) # Get Input
			input = input.replace("\n","")
			
			if(BLINKING_INPUT): # Stop blinking line while inputing
				_blink_input(true) 
			if(event.scancode == KEY_BACKSPACE): # Delete last character
				_delete_last_character(true)
			elif(event.scancode == KEY_RETURN): # Finish input
				emit_signal("input_enter", input)
				if(!PRINT_INPUT): # Delete input
					var i = _label.get_text().length() - _input_index
					while(i > 0):
						_delete_last_character()
						i-=1
				set_state(STATE_OUTPUT)
			
			elif(event.unicode >= 32 and event.unicode <= 126): # Add character
				if(INPUT_CHARACTERS_LIMIT < 0 or input.length() < INPUT_CHARACTERS_LIMIT):
					_label_print(_ARRAY_CHARS[event.unicode-32])

# Private
func _clear_skipped_lines():
	var i = 0
	var n = 0
	while i < _label.get_lines_skipped():
		n = _label.get_text().findn("\n", n)+1
		i+=1
	_label.set_text(_label.get_text().right(n))
	_label.set_lines_skipped(0)

func _blink_input(reset = false):
	if(reset == true):
		if(_blink_input_visible):
			_delete_last_character()
		_blink_input_visible = false
		_blink_input_timer = 0
		return
	if(_blink_input_visible):
		_delete_last_character()
		_blink_input_visible = false
	else:
		_blink_input_visible = true
		_label_print("_")

func _delete_last_character(scrollup = false):
	var n = _label.get_line_count()
	_label.set_text(_label.get_text().left(_label.get_text().length()-1))
	if( scrollup and n > _label.get_line_count() and _label.get_lines_skipped() > 0 and _blink_input_visible == false):
		_label.set_lines_skipped(_label.get_lines_skipped()-1)

func _get_last_line():
	var i = _label.get_text().rfind("\n")
	if (i == -1):
		return _label.get_text()
	return _label.get_text().substr(i,_label.get_text().length()-i)

func _has_to_skip_word(word): # what an awful name
	var ret = false
	var n = _label.get_line_count()
	_label.set_text(_label.get_text() + word)
	if(_label.get_line_count() > n):
		ret = true
	_label.set_text(_label.get_text().left(_label.get_text().length()-word.length())) #omg
	return ret

func _skip_word():
	var ot = _buffer[0][1]
	
	# which comes first, a space or a new line (else, till the end)
	var f_space = ot.findn(" ",1)
	if f_space == -1:
		f_space = ot.length()
	var f_newline = ot.findn("\n",1)
	if f_newline == -1:
		f_newline = ot.length()
	var len = min(f_space, f_newline)
	if(_has_to_skip_word(ot.substr(0,len))):
		if(_buffer[0][1][0] == " "):
			_buffer[0][1][0] = "\n"
		else:
			_buffer[0][1] = _buffer[0][1].insert(0,"\n")

func _label_print(t): # Add text to the label
	var n = _label.get_line_count()
	_label.set_text(_label.get_text() + t)
	if(_label.get_line_count() > n): # If number of lines increased
		if(_label.get_line_count()-_label.get_lines_skipped() > MAX_LINES): # If it exceeds MAX_LINES
			# Check if it is a rogue blinking input
			if(_blink_input_visible == true):
				_blink_input(true)
				return
			
			emit_signal("max_lines_reach")
			if(_state == 1 and BREAK_ON_MAX_LINES and _max_lines_reached == false): # Add a break when maximum lines are reached
				_delete_last_character()
				_max_lines_reached = true
				_buffer[0][1] = t + _buffer[0][1]
				_buffer.push_front([3])
				return t
			
			if(_max_lines_reached): # Reset maximum lines break
				_max_lines_reached = false
			
			if(SCROLL_ON_MAX_LINES): # Scroll text, or clear everything
				_label.set_lines_skipped(_label.get_lines_skipped()+1)
			else:
				_label.set_lines_skipped(_label.get_lines_skipped()+MAX_LINES)
		
		if (t != "\n" and n > 0): # Add a line breaker, so the engine will be able to get each line
			_label.set_text(_label.get_text().insert( _label.get_text().length()-1,"\n"))
		
		if(LOG_SKIPPED_LINES == false): # Delete skipped lines
			_clear_skipped_lines()
	return t