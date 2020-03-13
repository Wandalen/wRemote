( function _Sys_s_( ) {

'use strict';

//

let _ = _global_.wTools;
let Parent = null;
let Self = function wIntrospectionSys( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'System';

// --
// inter
// --

function init( o )
{
  let sys = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  _.workpiece.initFields( sys );
  Object.preventExtensions( sys );

  if( o )
  sys.copy( o );

}

//

function form()
{
  let sys = this;
  if( sys.formed )
  return;

  if( !sys.fileSystem )
  sys.fileSystem = _.FileProvider.Default();

  _.assert( sys.filesArray === null );
  sys.filesArray = [];

  sys.formed = 1;
  return sys;
}

//

function parserClassFor( file )
{
  let sys = this;
  let parserClass = sys.defaultParserClass || _.introspector.Parser.Default;
  return parserClass;
}

// --
// relations
// --

let Composes =
{
}

let Aggregates =
{
}

let Associates =
{
  fileSystem : null,
  defaultParserClass : null,
}

let Restricts =
{
  filesArray : null,
  formed : 0,
}

let Statics =
{
}

let Forbids =
{
}

let Accessors =
{
}

// --
// declare
// --

let Proto =
{

  // inter

  init,
  form,
  parserClassFor,

  // relation

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,
  Forbids,
  Accessors,

}

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );
_.introspector[ Self.shortName ] = Self;
if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _global_.wTools;

})();
