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
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Center';

// --
// routine
// --

function unform()
{
  let center = this;
  flock.close();
}

//

function form()
{
  let center = this;
  let flock = center.flock = _.remote.Flock
  ({
    entryPath : __filename,
  });

  flock.localHandlesAdd({ objects : { center : center } });

  flock.on( 'connectEnd', () =>
  {

    flock.send( `Message1 from ${flock.role}` );
    flock.send( `Message2 from ${flock.role}` );
    flock.send( `Message3 from ${flock.role}` );

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
  field1 : 1,
  field2 : 2,
}

let Associates =
{
  flock : null,
  slave : null,
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

  // inter

  unform,
  form,
  Exec,
  exec,

  //

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
