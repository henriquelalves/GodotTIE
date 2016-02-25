
extends Control

func _ready():
	var tie = get_node("text_interface_engine")
	tie.buff_text("HAIEAHOU EAOWUIEHO \nAWIE JOAWIE ", 0.04)
	tie.buff_silence(2)
	tie.buff_text("HAIEAHOU \nEAOWUIEHO AWIE JOAWIE ", 0.1)
	tie.buff_text("HAIEAHOU EAOWUIEHO AWIE JOAWIE ", 0.04)
	tie.buff_break()
	tie.buff_text("HAIEAHOU EAOWUIEHO AWIE JOAWIE ", 0.04)
	tie.buff_text("HAIEAHOU EAOWUIEHO AWIE JOAWIE ", 0.04)
	tie.set_state(tie.STATE_OUTPUT)