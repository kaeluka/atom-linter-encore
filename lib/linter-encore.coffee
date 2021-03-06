{BufferedProcess} = require 'atom'

class LinterEncore
  lintProcess: null

  config: (key) ->
    atom.config.get "linter-encore.#{key}"

  lint: (textEditor) =>
    return new Promise (resolve, reject) =>
      output = ''
      command = @config 'encorecPath'
      args = ['-tc', textEditor.getPath()]
      options = process.env

      stdout = (data) ->
        output += data
      stderr = (data) ->
        atom.notifications.addWarning data
      exit = (code) =>
        if code is 0
          resolve []
        else
          messages = @parse output, textEditor.getPath()
          resolve messages

      @lintProcess = new BufferedProcess({command, args, options, stdout, stderr, exit})
      @lintProcess.onWillThrowError ({error, handle}) ->
        atom.notifications.addError "Failed to run #{command}",
          detail: "#{error.message}"
          dismissable: true
        handle()
        resolve []

  parse: (output, filePath) =>
    messages = []
    output = output.split('\n')
    warningLines = (i for line, i in output when /(Warning|Error)/.test(line))

    i = 0
    while i < warningLines.length
      if i >= warningLines.length - 1
        messages.push @generateMessage output[warningLines[i]..], filePath
      else
        messages.push @generateMessage output[warningLines[i]..warningLines[i+1]-1], filePath
      i++

    return messages

  generateMessage: (output, filePath) ->
    messageType = 'Warning'
    if /(Error)/.test(output[0])
      output = output[1..]
      messageType = 'Error'

    match = output[0].match(/line ([0-9]+), column ([0-9]+)/)

    if match
      line = parseInt(match[1])
      col  = parseInt(match[2])

    message = {
      type: messageType,
      text: output[1..].join('\n'),
      range:[[line-1,col-1], [line-1,col+5]],
      filePath: filePath
    }

    return message



module.exports = LinterEncore
