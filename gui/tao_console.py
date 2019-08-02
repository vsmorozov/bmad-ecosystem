import tkinter as tk
class tao_console(tk.Frame):
  '''
  Console for running tao commands and displaying
  text output.  This frame takes the place of the
  terminal from which the gui is run, so that
  command line output can still be read if the gui is
  started independent of a terminal.

  Parameters:
  parent: the parent widget (usually the tao root window)
  root: the tao root window (required to access command history,
      the gui's global variablese, etc)
  pipe: tao_interface object (needed to run commands)
  '''
  def __init__(self, parent, root, pipe):
    tk.Frame.__init__(self, parent)
    self.root = root
    self.pipe = pipe
    self._wid = tk.Text(self, blockcursor=True)
    if self.root.font_size != None:
      self._wid.configure(
          font='Monospace '+str(self.root.font_size), fg="white", bg="black")
    else:
      self._wid.configure(font='Monospace 16', fg="white", bg="black")
    self._wid.configure(insertbackground="white")
    #self._wid.insert('end', self.pipe.startup_message)
    #self._wid.insert('end', '\nTao>')
    # Tag definitions (used to color error messages)
    self._wid.tag_config("normal")
    self._wid.tag_config("error", foreground="yellow")
    self._wid.tag_config("fatal", foreground="red")
    # Scrollbar
    self.scrollbar=tk.Scrollbar(self,orient="vertical",
        command=self._wid.yview)
    self._wid.configure(yscrollcommand=self.scrollbar.set)
    # Pack _wid and scrollbar
    self.scrollbar.pack(side="right", fill='y')
    self._wid.pack(side="left", fill="both", expand=1)
    # Used to keep track of the current command and location:
    self.command = ""
    self.cstart = self._wid.index('insert')
    #self.cend = self._wid.index('end')
    self.cpos = 0 #index of cursor in self.command

    self._wid.bind('<Key>', self._key_handler)
    self._wid.bind('<Return>', self._ret_handler)
    self._wid.bind('<BackSpace>', self._bs_handler)
    self._wid.bind('<Left>', self._l_handler)
    self._wid.bind('<Right>', self._r_handler)
    self._wid.bind('<Up>', self._u_handler)
    self._wid.bind('<Down>', self._d_handler)
    self.pipe.printed.trace('w', self.warning_callback)
    self.show_output(self.pipe.startup_message)

  def set_command(self, new_command):
    '''
    Deletes the current command and sets self.command
    to new_command (also updates console display)
    '''
    # Delete current command
    self._wid.delete(self.cstart, self.cstart + '+'
        + str(len(self.command)) + 'c')
    # Set self.command to new_command
    self.command = str(new_command)
    self.cpos = len(self.command)
    # Insert the new command into the console
    self._wid.insert(self.cstart, str(new_command))
    self._wid.mark_set('insert',
        self.cstart + '+' + str(self.cpos) + 'c')

  def show_output(self, output, mode='normal'):
    '''
    Prints output to the console and starts a new
    line for the command prompt.  Also clears
    self.command
    mode can be any of 'normal', 'error', or 'fatal'
    '''
    # Print output
    #initial_output = output
    #output = ""
    #for c in initial_output:
    #  if not c.isprintable()
    #    output += '\n'
    #  else:
    #    output += c
    while output.find('\r\n') != -1:
      output = output.replace('\r\n', '\n')
    self._wid.insert('end', '\n' + output, mode)
    self._wid.insert('end', '\nTao>', "normal")
    # Clear self.command
    self._wid.mark_set('insert', 'end')
    self.command = ""
    self.cstart = self._wid.index('insert')
    self.cpos = 0
    # Make sure we can see the command prompt
    self._wid.see(self.cstart)

  def warning_callback(self, *args):
    if self.pipe.printed.get():
      self.show_output(self.pipe.message, self.pipe.message_type)
      self.pipe.message = ""
      self.pipe_message_type = 'normal'
      self.pipe.printed.set(False)

  def run_command(self):
    '''
    Runs self.command at the Tao command line and
    displays the output.  Appends self.command to
    self.root.history and clears self.command.
    '''
    result = self.pipe.cmd_in(self.command, no_warn=True)
    self.root.history[0].append(self.command)
    self.show_output(result, self.pipe.message_type)
    # Try to refresh the history window
    try:
      self.root.history_window.refresh()
    except:
      pass
    # Check the place buffer and place plots
    self.default_plots(include_init=False)

  def _get_curs_l(self):
    '''
    Returns the cursor's current line as an int
    '''
    curs_index = self._wid.index('insert')
    curs_line = int(curs_index[:curs_index.find('.')])
    return curs_line

  def _get_curs_c(self):
    '''
    Returns the cursor's current column as an int
    '''
    curs_index = self._wid.index('insert')
    curs_col = int(curs_index[curs_index.find('.')+1:])
    return curs_col

  def _curs_check(self):
    '''
    Returns True if the cursor is after the start of
    the current command and false otherwise.
    '''
    curs_line = self._get_curs_l()
    curs_col = self._get_curs_c()
    line = int(self.cstart[:self.cstart.find('.')])
    col = int(self.cstart[self.cstart.find('.')+1:])
    if (line <= curs_line) & (col < curs_col):
      return True
    else:
      return False

  # HANDLERS
  def _key_handler(self, event):
    if (event.state != 8) & (event.char != "") & (event.char).isprintable():
      #Make sure we insert at the command prompt
      if (not self._curs_check()) & (
          self._wid.index('insert') != self.cstart):
        self._wid.mark_set('insert', self.cstart
            + '+' + str(len(self.command)) + 'c')
      self.command = (self.command[:self.cpos]
          + event.char + self.command[self.cpos:])
      self._wid.insert('insert', event.char)
      self.cpos += 1
      self._wid.see(self.cstart)
      return 'break'

  def _ret_handler(self, event):
    if self.command != "":
      # Read what appears in the command line into self.command to be safe
      self.command = self._wid.get(self.cstart, 'end-1c')
      self.run_command()
    self.root.history_pos = 0
    return 'break'

  def _bs_handler(self, event):
    if self._curs_check():
      self._wid.delete("insert-1c", "insert")
      self.cpos -= 1
      self.command = self.command[:self.cpos] \
          + self.command[self.cpos+1:]
      self._wid.see(self.cstart)
    return 'break'

  def _l_handler(self, event):
    curs_line = self._get_curs_l()
    curs_col = self._get_curs_c()
    if self._curs_check():
      self._wid.mark_set('insert',
          str(curs_line) + '.' + str(curs_col-1))
      self.cpos -= 1
    return 'break'

  def _r_handler(self, event):
    curs_line = self._get_curs_l()
    curs_col = self._get_curs_c()
    self._wid.mark_set('insert',
        str(curs_line) + '.' + str(curs_col+1))
    if self.cpos < len(self.command):
      self.cpos += 1
    return 'break'

  def _u_handler(self, event=None):
    #if there's room left to scroll up in history
    if len(self.root.history[0]) > self.root.history_pos:
      self.root.history_pos += 1
      self.set_command(self.root.history[0][-1*self.root.history_pos])
      self._wid.see(self.cstart)
    return 'break'

  def _d_handler(self, event=None):
    if self.root.history_pos > 0:
      self.root.history_pos -= 1
      if self.root.history_pos > 0:
        self.set_command(self.root.history[0][-1*self.root.history_pos])
      else:
        self.set_command("")
      self._wid.see(self.cstart)
    return 'break'
