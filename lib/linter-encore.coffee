# path = require 'path'
{BufferedProcess} = require 'atom'

class LinterEncore
  lintProcess: null

  lint: (textEditor) ->
    return new Promise (resolve, reject) ->
      output = ''
      command = 'encorec'
      args = ['-tc', textEditor.getPath()]
      options = process.env

      stdout = (data) ->
        output += data
      stderr = (data) ->
        atom.notifications.addWarning data
      exit = (code) ->
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

      @lintProcess = new BufferedProcess({command, args, options, stdout, stderr, exit})
      @lintProcess.onWillThrowError ({error, handle}) ->
        atom.notifications.addError "Failed to run #{command}",
          detail: "#{error.message}"
          dismissable: true
        handle()
        resolve []


module.exports = LinterEncore
