( function _Center_s_() {

'use strict';

var _ToolsPath_ = process.env._TOOLS_PATH_;
var _RemotePath_ = process.env._REMOTE_PATH_;

if( typeof module !== 'undefined' )
{
  var _ = require( _ToolsPath_ );
  _.include( _RemotePath_ );
  module.exports = _;
}

//

var _ = _global_.wTools;
let Parent = null;
let Self = function wStarterCenter( o )
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

unform.operation =
{
  remote : 0,
}

//

function form()
{
  let center = this;

  center.flock = _.remote.Flock
  ({
    // object : center,
    entryPath : __filename,
    // entryPath : _MainPath_,
  });

  center.flock.on( 'connectEnd', () =>
  {
    if( center.flock.connections.length === 1 )
    center.flock.send( `Message from ${center.flock.role}` );
  });

  return center.flock.form();
  // .then( ( arg ) =>
  // {
  //   debugger;
  //   return center.remote.workerOpen();
  // })
  // .then( ( slave ) =>
  // {
  //   debugger;
  //   center._slave = slave;
  //   return center._slave.execImmediate();
  // });

}

form.operation =
{
  remote : 0,
}

//

function Exec()
{
  let center = new this.Self();
  return center.exec();
}

Exec.operation =
{
  remote : 0,
}

//

function exec()
{
  let center = this;
  return center.form();
}

exec.operation =
{
  remote : 0,
}

// --
// relationships
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

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

if( !module.parent )
Self.Exec();

})();
