( function _Namespace_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../IncludeBase.s' );

}

let _ = _global_.wTools;
let Self = _.introspector = _.introspector || Object.create( null );

// --
// inter
// --

function thisFile()
{
  _.assert( arguments.length === 0, 'Expects no arguments' );
  let location = _.introspector.location({ level : 1 });
  let file = _.introspector.File({ filePath : location.filePath });
  return file;
}

// --
// declare
// --

let Extend =
{

  thisFile,

}

_.mapExtend( Self, Extend );

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _global_.wTools;

})();
