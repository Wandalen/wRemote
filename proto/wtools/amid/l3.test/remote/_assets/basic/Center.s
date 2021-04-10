( function _Center_s_() {

'use strict';

var _ToolsPath_ = process.env._TOOLS_PATH_;
var _RemotePath_ = process.env._REMOTE_PATH_;
var _DisconnectDelay_ = Number( process.env._DISCONNECT_DELAY_ ) || 10000;

if( typeof module !== 'undefined' )
{
  const _ = require( _ToolsPath_ );
  _.include( _RemotePath_ );
  module.exports = _;
}

//

const _ = _global_.wTools;
const Parent = null;
const Self = wStarterCenter;
function wStarterCenter( o )
{
  // debugger;
  // if( !( context instanceof cls ) )
  // if( o instanceof cls )
  // {
  //   _.assert( args.length === 1 );
  //
  //   let handlers =
  //   {
  //     get : _.Remote.CenterProxyGet,
  //     set : _.Remote.CenterProxySet,
  //   };
  //
  //   let proxy = new Proxy( o, handlers );
  //
  //   return proxy;
  // }
  // else
  // {
    return _.workpiece.construct( Self, this, arguments );
  // }
}

Self.shortName = 'Center';

// --
// routine
// --

function unform()
{
  let center = this;

  _.assert( 0, 'not implemented' );

/*
qqq : implement please
*/

}

//

function form()
{
  let center = this;

  let flock = center.flock = _.remote.Flock
  ({
    entryPath : __filename,
  });

  flock.on( 'connectEnd', () =>
  {

    flock.send( `from ${flock.agent.agentPath}` );

    if( flock.role === 'slave' )
    _.time.out( _DisconnectDelay_, () =>
    {
      flock.close();
    });

  });

  return flock.form();
}

//

function Exec()
{
  let center = new this.Self();
  return center.exec();
}

//

function exec()
{
  let center = this;
  return center.form();
}

// --
// relations
// --

let Composes =
{
}

let Associates =
{
  flock : null,
}

let Restricts =
{
}

let Statics =
{
  Exec,
}

let Accessor =
{
}

// --
// prototype
// --

let Proto =
{

  unform,
  form,

  Exec,
  exec,

  /* */

  Composes,
  Associates,
  Restricts,
  Statics,
  Accessor,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );

//

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

if( !module.parent )
Self.Exec();

})();
