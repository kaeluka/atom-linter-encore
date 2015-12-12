{CompositeDisposable} = require 'atom'

module.exports = AtomLinterEncore =
  config:
    encorecPath:
      type: 'string'
      default: 'encorec'
      description: "Path to Encore's compiler `encorec`"

  activate: (state) ->
    console.log 'linter-encore: package loaded,
                ready to get initialized by AtomLinter.'

    if not atom.packages.getLoadedPackage 'linter'
      atom.notifications.addError 'Linter package not found',
      detail: '[linter-rust] `linter` package not found. \
      Please install https://github.com/AtomLinter/Linter'

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.config.observe 'linter-rust.rustcPath', (rustcPath) =>
      @rustcPath = rustcPath

  deactivate: ->
    @subscriptions.dispose()

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
