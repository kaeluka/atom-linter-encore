{BufferedProcess} = require 'atom'

class LinterEncore
  lint: (textEditor) ->
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
        exit: (code) ->
            if code is 0
              resolve []
            else
              match = output.match(/line ([0-9]+), column ([0-9]+)/)
              if match
                line = parseInt(match[1])
                col  = parseInt(match[2])

              #remove the first two lines that contain no useful information:
              lines = output.split('\n')
              lines.splice(0,2)

              output = lines.join('\n')
              resolve [{
                type: 'Error',
                text: output,
                range:[[line-1,col], [line-1,col+5]],
                filePath: textEditor.getPath()
              }]

module.exports = LinterEncore
