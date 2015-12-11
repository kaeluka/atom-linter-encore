{CompositeDisposable} = require 'atom'

module.exports = AtomLinterEncore =
  activate: (state) ->
    console.log 'linter-encore: package loaded,
                ready to get initialized by AtomLinter.'

    if not atom.packages.getLoadedPackage 'linter'
      atom.notifications.addError 'Linter package not found',
      detail: '[linter-rust] `linter` package not found. \
      Please install https://github.com/AtomLinter/Linter'

  deactivate: ->
    console.log 'linter-encore: package deactivated.'

  serialize: ->
    atomLinterEncoreViewState: @atomLinterEncoreView.serialize()

  provideLinter: ->
    LinterEncore = require('./linter-encore')
    @provider = new LinterEncore()
    return {
      name: 'Encore',
      grammarScopes: ['source.enc'],
      scope: 'file', # or 'project'
      lintOnFly: true,
      lint: @provider.lint
    }
