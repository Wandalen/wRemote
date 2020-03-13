( function _Tools_s_( ) {

'use strict';

// let persistent = _.persistent.open({ name : '.system.wcloud' });
// persistent.array( 'account' ).write( structure );

let _ = _global_.wTools;
let Self = _.persistent = _.persistent || Object.create( null );

// --
// inter
// --

function open( o )
{


  if( _.strIs( arguments[ 0 ] ) )
  o = { name : arguments[ 0 ] }

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.name ) )

  return _.persistent.Repo( o );
}

//

function close( repo )
{
  _.assert( repo instanceof _.persistent.Repo )
  repo.finit();
}

// --
// declare
// --

let Extend =
{

  open,
  close,

}

_.mapExtend( Self, Extend );

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _global_.wTools;

})();
