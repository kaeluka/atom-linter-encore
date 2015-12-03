
{CompositeDisposable, BufferedProcess} = require 'atom'

module.exports = AtomLinterEncore =
  activate: (state) ->
    #atom.notifications.addSuccess 'activated'

# *** Error during typechecking ***
#"compose.enc" (line 10, column 13)
#Function 'f' of type '(int) -> int' expects 1 arguments. Got 0
#In expression:
#  f()
#In expression:
#  print f()
#In expression:
#  let double = \(x : int) -> x * 2
#      bump = \(x : int) -> x + 1
#      f = compose(double, bump)
#  in
#    print f()
#In method 'main' of type 'void'
#In class 'Main'

  provideLinter: ->
    return {
      name: 'encorec',
      grammarScopes: ['source.enc'],
      scope: 'file', # or 'project'
      lintOnFly: true,
      lint: (textEditor) ->
        #atom.notifications.addSuccess 'linting..'
        #command = 'date'
        #args = []
        #stdout = (output) -> atom.notifications.addSuccess(output)
        #exit = (code) -> #nothing

        return new Promise (resolve, reject) ->
          # do something async or
          output = ''
          line = 0
          col  = 0
          #ERROR_REGEX =

          process = new BufferedProcess
            command: 'encorec'
            args: ['-tc', textEditor.getPath()]
            stdout: (data) ->
              output += data
            stderr: (data) ->
              atom.notifications.addWarning data
            exit: ->
                if output is ''
                  resolve []
                else
                  match = output.match(/line ([0-9]+), column ([0-9]+)/)
                  if match
                    line = parseInt(match[1])
                    col  = parseInt(match[2])

                  output = output.replace('*** Error during typechecking ***', '').trim()
                  lines = output.split('\n')
                  lines.splice(0,1)
                  output = lines.join('\n')
                  resolve [{
                    type: 'Error',
                    text: output,
                    range:[[line-1,col], [line-1,col+5]],
                    filePath: textEditor.getPath()
                  }]
    }

  deactivate: ->
    atom.notifications.addSuccess 'deactivated'

  serialize: ->
    atomLinterEncoreViewState: @atomLinterEncoreView.serialize()
