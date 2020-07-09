( function _Namespace_s_( ) {

'use strict';

let _ = _global_.wTools;
let Self = _.remote = _.remote || Object.create( null );

// --
// inter
// --

function agentPathIs( agentPath )
{

  if( !_.strDefined( agentPath ) )
  return false;

  if( !_.strBegins( agentPath, '/master' ) && !_.strBegins( agentPath, '/slave' ) )
  return false;

  return true;
}

//

function roleFromAgentPath( agentPath )
{
  _.assert( this.agentPathIs( agentPath ) );
  if( _.strBegins( agentPath, '/master' ) )
  return 'master';
  if( _.strBegins( agentPath, '/slave' ) )
  return 'slave';
  return undefined;
}

//

function idFromAgentPath( agentPath )
{
  _.assert( this.agentPathIs( agentPath ) );
  if( _.strBegins( agentPath, '/master' ) )
  return Number( _.strRemoveBegin( agentPath, '/master' ) );
  if( _.strBegins( agentPath, '/slave' ) )
  return Number( _.strRemoveBegin( agentPath, '/slave' ) );
  return undefined;
}

//

function agentPathFromRole( role, id )
{
  if( role === 'master' )
  if( id === null || id === undefined )
  {
    id = 1;
  }

  _.assert( id >= 1 );
  _.assert( ( role === 'master' ) ^ !( id === 1 ) );
  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( _.longHas( [ 'master', 'slave' ], role ) );

  return `/${role}${id}`;
}

// --
// declare
// --

let Extension =
{

  agentPathIs,
  roleFromAgentPath,
  idFromAgentPath,
  agentPathFromRole,

}

_.mapExtend( Self, Extension );

//

if( typeof module !== 'undefined' )
module[ 'exports' ] = _global_.wTools;

})();
