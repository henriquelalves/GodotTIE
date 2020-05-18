#MADE BY HENRIQUE ALVES
#LICENSE STUFF BLABLABLA
#(MIT License)

# Intern initializations
extends ReferenceRect # Extends from ReferenceFrame


const STATE_WAITING = 0
const STATE_OUTPUT = 1
const STATE_INPUT = 2

const BUFF_DEBUG = 0
const BUFF_TEXT = 1
const BUFF_SILENCE = 2
const BUFF_BREAK = 3
const BUFF_INPUT = 4
const BUFF_CLEAR = 5

onready var _buffer = [] # 0 = Debug; 1 = Text; 2 = Silence; 3 = Break; 4 = Input
onready var _label = Label.new() # The Label in which the text is going to be displayed
onready var _state = 0 # 0 = Waiting; 1 = Output; 2 = Input

onready var _output_delay = 0
onready var _output_delay_limit = 0
onready var _on_break = false
onready var _max_lines_reached = false
onready var _buff_beginning = true
onready var _turbo = false
onready var _max_lines = 0
onready var _break_key = KEY_ENTER

onready var _blink_input_visible = false
onready var _blink_input_timer = 0
onready var _input_timer_limit = 1
onready var _input_index = 0

# =============================================== 
# Text display properties!
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
# Signals!
signal input_enter(input) # When user finished an input
signal buff_end() # When there is no more outputs in _buffer
signal state_change(state) # When the state of the engine changes
signal enter_break() # When the engine stops on a break
signal resume_break() # When the engine resumes from a break
signal tag_buff(tag) # When the _buffer reaches a buff which is tagged
signal buff_cleared() # When the buffer's been cleared of text
# ===============================================

func buff_debug(f, lab = false, arg0 = null, push_front = false): # For simple debug purposes; use with care
	var b = {"buff_type":BUFF_DEBUG,"debug_function":f,"debug_label":lab,"debug_arg":arg0}
	if(! push_front):
		_buffer.append(b)
	else:
		_buffer.push_front(b)

func buff_text(text, vel = 0, tag = "", push_front = false): # The text for the output, and its printing velocity (per character)
	var b = {"buff_type":BUFF_TEXT, "buff_text":text, "buff_vel":vel, "buff_tag":tag}
	if !push_front:
		_buffer.append(b)
	else:
		_buffer.push_front(b)

func buff_silence(length, tag = "", push_front = false): # A duration without output
	var b = {"buff_type":BUFF_SILENCE, "buff_length":length, "buff_tag":tag}
	if !push_front:
		_buffer.append(b)
	else:
		_buffer.push_front(b)

func buff_break(tag = "", push_front = false): # Stop output until the player hits enter
	var b = {"buff_type":BUFF_BREAK, "buff_tag":tag}
	if !push_front:
		_buffer.append(b)
	else:
		_buffer.push_front(b)

func buff_input(tag = "", push_front = false): # 'Schedule' a change state to Input in the buffer
	var b = {"buff_type":BUFF_INPUT, "buff_tag":tag}
	if !push_front:
		_buffer.append(b)
	else:
		_buffer.push_front(b)
		
func buff_clear(tag = "", push_front = false): # Clear the text buffer when this buffer command is run.
	var b = {"buff_type":BUFF_CLEAR, "buff_tag":tag}
	if !push_front:
		_buffer.append(b)
	else:
		_buffer.push_front(b)

func clear_text(): # Deletes ALL the text on the label
	_label.set_lines_skipped(0)
	_label.set_text("")

func clear_buffer(): # Clears all buffs in _buffer
	_on_break = false
	set_state(STATE_WAITING)
	_buffer.clear()
	
	_output_delay = 0
	_output_delay_limit = 0
	_buff_beginning = true
	_turbo = false
	_max_lines_reached = false

func reset(): # Reset TIE to its initial 100% cleared state
	clear_text()
	clear_buffer()

func clear_skipped_lines(): # Deletes only the 'hidden' lines, if LOG_SKIPPED_LINES is false
	if(LOG_SKIPPED_LINES == true):
		_clear_skipped_lines()

func add_newline(): # Add a new line to the label text
	_label_print("\n")

func get_text(): # Get current text on Label
	return _label.get_text()

func set_turbomode(s): # Print stuff in the maximum velocity and ignore breaks
	_turbo = s;

# Careful when changing fonts on-the-fly! It might break the text if there is something
# already printed!
func set_font_bypath(str_path): # Changes the font of the text; weird stuff will happen if you use this function after text has been printed
	_label.add_font_override("font",load(str_path))
	_max_lines = floor(get_size().y/(_label.get_line_height()+_label.get_constant("line_spacing")))

func set_font_byresource(font): # Changes font of the text (uses the resource)
	_label.add_font_override("font", font)
	_max_lines = floor(get_size().y/(_label.get_line_height()+_label.get_constant("line_spacing")))

func set_color(c): # Changes the color of the text
	_label.add_color_override("font_color", c)

func set_state(i): # Changes the state of the Text Interface Engine
	emit_signal("state_change", int(i))
	if _state == STATE_INPUT:
		_blink_input(true)
	_state = i
	if(i == 2): # Set input index to last character on the label
		_input_index = _label.get_text().length()

func set_break_key_by_scancode(i): # Set a new key to resume breaks (uses scancode!)
	_break_key = i

func set_buff_speed(v): # Changes the velocity of the text being printed
	if (_buffer[0]["buff_type"] == BUFF_TEXT):
		_buffer[0]["buff_vel"] = v

# ==============================================
# Reserved methods

# Override
func _ready():
	set_physics_process(true)
	set_process_input(true)
	
	add_child(_label)
	
	# Setting font of the text
	if(FONT != null):
		_label.add_font_override("font", FONT)
	
	# Setting size of the frame
	_max_lines = floor(get_size().y/(_label.get_line_height()+_label.get_constant("line_spacing")))
	_label.set_size(Vector2(get_size().x,get_size().y))
	_label.set_autowrap(true)

func _physics_process(delta):
	if(_state == STATE_OUTPUT): # Output
		if(_buffer.size() == 0):
			set_state(STATE_WAITING)
			emit_signal("buff_end")
			return
		
		var o = _buffer[0] # Calling this var 'o' was one of my biggest mistakes during the development of this code. I'm sorry about this.
		
		if (o["buff_type"] == BUFF_DEBUG): # ---- It's a debug! ----
			if(o["debug_label"] == false):
				if(o["debug_arg"] == null):
					print(self.call(o["debug_function"]))
				else:
					print(self.call(o["debug_function"],o["debug_arg"]))
			else:
				if(o["debug_arg"] == null):
					print(_label.call(o["debug_function"]))
				else:
					print(_label.call(o["debug_function"],o["debug_arg"]))
			_buffer.pop_front()
		elif (o["buff_type"] == BUFF_TEXT): # ---- It's a text! ----
			# -- Print Text --
			
			if(o["buff_tag"] != "" and _buff_beginning == true):
				emit_signal("tag_buff", o["buff_tag"])
			
			if (_turbo): # In case of turbo, print everything on this buff
				o["buff_vel"] = 0
			
			if(o["buff_vel"] == 0): # If the velocity is 0, than just print everything
				while(o["buff_text"] != ""): # Not optimal (not really printing everything at the same time); but is the only way to work with line break
					if(AUTO_SKIP_WORDS and (o["buff_text"][0] == " " or _buff_beginning)):
						_skip_word()
					_label_print(o["buff_text"][0])
					_buff_beginning = false
					o["buff_text"] = o["buff_text"].right(1)
					if(_max_lines_reached == true):
						break
					
			else: # Else, print each character according to velocity
				_output_delay_limit = o["buff_vel"]
				if(_buff_beginning):
					_output_delay = _output_delay_limit + delta
				else:
					_output_delay += delta
				if(_output_delay > _output_delay_limit):
					if(AUTO_SKIP_WORDS and (o["buff_text"][0] == " " or _buff_beginning)):
						_skip_word()
					_label_print(o["buff_text"][0])
					_buff_beginning = false
					_output_delay -= _output_delay_limit
					o["buff_text"] = o["buff_text"].right(1)
			# -- Popout Buff --
			if (o["buff_text"] == ""): # This buff finished, so pop it out of the array
				_buffer.pop_front()
				_buff_beginning = true
				_output_delay = 0
		elif (o["buff_type"] == BUFF_SILENCE): # ---- It's a silence! ----
			if(o["buff_tag"] != "" and _buff_beginning == true):
				emit_signal("tag_buff", o["buff_tag"])
				_buff_beginning = false
			_output_delay_limit = o["buff_length"] # Length of the silence
			_output_delay += delta
			if(_output_delay > _output_delay_limit):
				_output_delay = 0
				_buff_beginning = true
				_buffer.pop_front()
		elif (o["buff_type"] == BUFF_BREAK): # ---- It's a break! ----
			if(o["buff_tag"] != "" and _buff_beginning == true):
				emit_signal("tag_buff", o["buff_tag"])
				_buff_beginning = false
			if(_turbo): # Ignore this break
				_buffer.pop_front()
			elif(!_on_break):
				emit_signal("enter_break")
				_on_break = true
		elif (o["buff_type"] == BUFF_INPUT): # ---- It's an Input! ----
			if(o["buff_tag"] != ""and _buff_beginning == true):
				emit_signal("tag_buff", o["buff_tag"])
				_buff_beginning = false
			set_state(STATE_INPUT)
			_buffer.pop_front()
		elif (o["buff_type"] == BUFF_CLEAR): # ---- It's a clear command! ----
			if(o["buff_tag"] != ""and _buff_beginning == true):
				emit_signal("tag_buff", o["buff_tag"])
				_buff_beginning = false
			_label.set_text("")
			_buffer.pop_front()
			emit_signal("buff_cleared")
	elif(_state == STATE_INPUT):
		if BLINKING_INPUT:
			_blink_input_timer += delta
			if(_blink_input_timer > _input_timer_limit):
				_blink_input_timer -= _input_timer_limit
				_blink_input()

func _input(event):
	if(event is InputEventKey and event.is_pressed() == true ):
		if(SCROLL_SKIPPED_LINES and event.scancode == KEY_UP or event.scancode == KEY_DOWN): # User is just scrolling the text
			if(event.scancode == KEY_UP):
				if(_label.get_lines_skipped() > 0):
					_label.set_lines_skipped(_label.get_lines_skipped()-1)
			else:
				if(_label.get_lines_skipped() < _label.get_line_count()-_max_lines):
					_label.set_lines_skipped(_label.get_lines_skipped()+1)
		elif(_state == 1 and _on_break): # If its on a break
			if(event.scancode == _break_key):
				emit_signal("resume_break")
				_buffer.pop_front() # Pop out break buff
				_on_break = false
		elif(_state == 2): # If its on the input state
			if(BLINKING_INPUT): # Stop blinking line while inputing
				_blink_input(true) 
			
			var input = _label.get_text().right(_input_index) # Get Input
			input = input.replace("\n","")

			if(event.scancode == KEY_BACKSPACE): # Delete last character
				_delete_last_character(true)
			elif(event.scancode == KEY_ENTER): # Finish input
				emit_signal("input_enter", input)
				if(!PRINT_INPUT): # Delete input
					var i = _label.get_text().length() - _input_index
					while(i > 0):
						_delete_last_character()
						i-=1
				set_state(STATE_OUTPUT)

			else: # Add character
				if(INPUT_CHARACTERS_LIMIT < 0 or input.length() < INPUT_CHARACTERS_LIMIT):
					_label_print(char(event.unicode))

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
	var ot = _buffer[0]["buff_text"]
	
	# which comes first, a space or a new line (else, till the end)
	var f_space = ot.findn(" ",1)
	if f_space == -1:
		f_space = ot.length()
	var f_newline = ot.findn("\n",1)
	if f_newline == -1:
		f_newline = ot.length()
	var length = min(f_space, f_newline)
	
	if(_has_to_skip_word(ot.substr(0,length))):
		
		if(_buffer[0]["buff_text"][0] == " "):
			
			_buffer[0]["buff_text"][0] = "\n"
		else:
			_buffer[0]["buff_text"] = _buffer[0]["buff_text"].insert(0,"\n")

func _label_print(t): # Add text to the label
	var n = _label.get_line_count()
	_label.set_text(_label.get_text() + t)
	if(_label.get_line_count() > n): # If number of lines increased
		if(_label.get_line_count()-_label.get_lines_skipped() > _max_lines): # If it exceeds _max_lines
			# Check if it is a rogue blinking input
			if(_blink_input_visible == true):
				_blink_input(true)
				return
			
			if(_state == 1 and BREAK_ON_MAX_LINES and _max_lines_reached == false): # Add a break when maximum lines are reached
				_delete_last_character()
				_max_lines_reached = true
				_buffer[0]["buff_text"] = t + _buffer[0]["buff_text"]
				buff_break("", true)
				return t
			
			if(_max_lines_reached): # Reset maximum lines break
				_max_lines_reached = false
			
			if(SCROLL_ON_MAX_LINES): # Scroll text, or clear everything
				_label.set_lines_skipped(_label.get_lines_skipped()+1)
			else:
				_label.set_lines_skipped(_label.get_lines_skipped()+_max_lines)
		
		if (t != "\n" and n > 0): # Add a line breaker, so the engine will be able to get each line
			_label.set_text(_label.get_text().insert( _label.get_text().length()-1,"\n"))
		
		if(LOG_SKIPPED_LINES == false): # Delete skipped lines
			_clear_skipped_lines()
	return t
