{BufferedProcess} = require 'atom'

class LinterEncore
  lintProcess: null

  lint: (textEditor) =>
    return new Promise (resolve, reject) =>
      output = ''
      command = 'encorec'
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
    warningLines = (i for line, i in output when /line ([0-9]+), column ([0-9]+)/.test(line))
    for i, warning of warningLines
      if i is warningLines.length
        messages.push @generateMessage output[warningLines[i]..], filePath
      else
        messages.push @generateMessage output[warningLines[i]..warningLines[i+1]], filePath

    return messages

  generateMessage: (output, filePath) ->
    match = output[0].match(/line ([0-9]+), column ([0-9]+)/)
    if match
      line = parseInt(match[1])
      col  = parseInt(match[2])

    message = {
      type: 'Error',
      text: output[1..].join('\n'),
      range:[[line-1,col], [line-1,col+5]],
      filePath: filePath
    }

    return message



module.exports = LinterEncore
