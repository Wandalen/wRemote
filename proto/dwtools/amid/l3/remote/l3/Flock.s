( function _Flock_s_() {

'use strict';

if( typeof module !== 'undefined' )
{
  var Net = require( 'net' );
}

//

let _ = _global_.wTools;
let Parent = null;
let Self = function wFlock( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Flock';

// --
// inter
// --

function finit()
{
  let flock = this;
  flock.unform();
  _.Copyable.prototype.finit.call( flock );
}

//

function init( o )
{
  let flock = this;

  _.assert( arguments.length === 1 );

  _.workpiece.initFields( flock );
  Object.preventExtensions( flock );

  if( o )
  flock.copy( o );

  return flock;
}

//

function unform()
{
  let flock = this;

  flock.close();

/*
qqq : cover, please
*/

}

//

function form()
{
  let flock = this;
  let ready = _.Consequence().take( null );

  if( flock.logger === null )
  {
    flock.logger = new _.Logger({ output : _global_.logger });
    flock.logger.verbosity = 7;
  }

  let logger = flock.logger;

  _.process.on( 'exit', () =>
  {
    flock.log( -5, `exit` );
  });

  ready.then( () => flock.roleDetermine() );

  ready.then( ( arg ) =>
  {
    let ready = _.Consequence().take( arg );

    flock.log( -5, `start` );

    if( flock.role === 'slave' )
    {

      if( !flock.masterPath )
      {
        ready.then( () => flock.slaveOpenMaster() );
        ready.then( () => _.time.out( flock.slaveDelay ) );
      }
      ready.then( () => flock.slaveConnectMaster() );

    }
    else
    {
      ready.then( () => _.time.out( flock.masterDelay ) );
      ready.then( () => flock.masterOpen() );
    }

    return ready;
  });

  return ready;
}

// --
// etc
// --

function close()
{
  let flock = this;
  let logger = flock.logger;

  if( flock.role === 'slave' )
  {
    if( flock.slaveIsConnected() )
    flock.slaveDisconnectMaster();
  }
  else if( flock.role === 'master' )
  {
    if( flock.masterIsOpened() )
    flock.masterClose();
  }

}

//

function connectionIs( connection )
{
  let flock = this;
  return _.objectIs( connection );
}

//

function connectionIsAlive( connection )
{
  let flock = this;
  _.assert( connection.destroyed !== undefined );
  return !connection.destroyed;
}

//

function connectionDefaultGet()
{
  let flock = this;
  _.assert( flock.connections.length === 1 );
  return flock.connections[ 0 ];
}

//

function connectionToRepresentative( connection )
{
  let flock = this;
  _.assert( flock.connectionIs( connection ) );
  return flock.connectionToRepresentativeHash.get( connection );
}

//

function roleDetermine()
{
  let flock = this;

  if( flock.role !== null )
  return end();

  if( flock.masterPath === null || flock.masterPath === undefined )
  flock.masterPath = flock.MasterPathFindOpened();

  if( flock.masterPath )
  return end( 'slave' );

  flock._roleDetermine();

  return end();

  function end( role )
  {
    if( role !== undefined )
    flock.role = role;
    _.assert( _.longHas( [ 'slave', 'master' ], flock.role ), () => `Unknown role ${flock.role}` );

    return flock.role;
  }
}

//

function _roleDetermine()
{
  let flock = this;

  _.assert( flock.role === null );

  let args = _.process.args();

  if( args.map.role !== undefined )
  {
    flock.role = args.map.role;
  }
  else
  {
    flock.role = 'slave';
  }

  return flock.role;
}

//

function format()
{
  let flock = this;
  let logger = flock.logger;
  return [ `${flock.role} .`, ... arguments ];
}

//

function log( level, ... msgs )
{
  let flock = this;
  let logger = flock.logger;

  logger.begin({ verbosity : level });
  logger.log( ... flock.format( ... msgs ) );
  logger.end({ verbosity : level });

}

//

function representativeMake( o )
{
  let flock = this;
  let logger = flock.logger;

  o.flock = flock;

  return _.remote.Representative( o );
}

// --
// handle
// --

function LocalHandleIs( src )
{
  if( _.numberIs( src ) )
  return true;
  if( _.strIs( src ) )
  return true;
  return false;
}

//

function localHandleToObjectDescriptor( key )
{
  let flock = this;
  _.assert( _.strIs( key ) || _.numberIs( key ) );
  if( _.strIs( key ) )
  return flock.nameToHandleDescriptorHash.get( key );
  else
  return flock.idToHandleDescriptorHash.get( key );
}

//

function objectToLocalHandleDescriptor( object )
{
  let flock = this;
  return flock.objectToHandleDescriptorHash.get( object );
}

//

function localHandleToObject( key )
{
  let flock = this;
  let desc = flock.localHandleToObjectDescriptor( key );
  if( !desc )
  return;
  return desc.object;
}

//

// function localHandleToObject( alias )
// {
//   let flock = this;
//   if( alias === 'flock' )
//   return flock;
//   throw _.err( `Unknown handle::${alias}` );
// }

//

function objectToId( object )
{
  let flock = this;
  let desc = flock.objectToLocalHandleDescriptor( object );
  if( !desc )
  return;
  return desc.id;
}

//

function localHandlesAdd( o )
{
  let flock = this;

  _.routineOptions( localHandlesAdd, arguments );

  let result = _.map( o.objects, ( object, k ) =>
  {
    if( _.numberIs( k ) )
    return flock._localHandleAdd({ object });
    else
    return flock._localHandleAdd({ object, name : k });
  });

  return result;
}

localHandlesAdd.defaults =
{
  objects : null,
}

//

function _localHandleAdd( o )
{
  let flock = this;
  let desc;

  _.assert( o.object !== undefined && o.object !== null );
  _.routineOptions( _localHandleAdd, arguments );
  _.assert( o.name === null || _.strDefined( o.name ) );

  desc = flock.objectToHandleDescriptorHash.get( o.object );
  if( desc )
  {
    _.assert( desc.name === o.name, `Object already added with name ${desc.name}. Cant change name to ${o.name}` );
    return desc;
  }

  if( o.name )
  {
    desc = flock.nameToHandleDescriptorHash.get( o.name );
    if( desc )
    {
      debugger;
      throw _.err( `Object with name ${o.name} already exists. Cant overwrite it.` );
    }
  }

  flock.objectCounter += 1;

  desc = Object.create( null );
  desc.id = flock.objectCounter;
  desc.name = o.name;
  desc.object = o.object;

  flock.idToHandleDescriptorHash.set( desc.id, desc );
  if( o.name )
  flock.nameToHandleDescriptorHash.set( desc.name, desc );
  flock.objectToHandleDescriptorHash.set( desc.object, desc );

  return desc;
}

_localHandleAdd.defaults =
{
  name : null,
  object : null,
}

//

function localHandlesRemoveObjects( objects )
{
  let flock = this;

  _.routineOptions( localHandlesRemoveObjects, arguments );

  let result = _.map( objects, ( object, k ) =>
  {
    return flock.localHandlesRemoveObject( object );
  });

  return result;
}

//

function localHandlesRemoveObject( object )
{
  let flock = this;

  let desc = flock.objectToHandleDescriptorHash.get( object );

  _.assert( !!desc, () => `Cant remove object. It was not added` );

  return result;
}

//

function PrimitiveHandleIs( src )
{
  if( _.numberIs( src ) )
  return true;
  if( _.strIs( src ) )
  return true;
  return false;
}

//

function RemoteHandleIs( src )
{
  if( !_.objectIs( src ) )
  return false;
  if( !src[ twinSymbol ] )
  return false;
  // if( !src.representative )
  // return false;
  // if( !src.handle )
  // return false;
  return true;
}

//

function handleFrom( src )
{
  let flock = this;
  let result = src;
  if( flock.RemoteHandleIs( result ) )
  result = src[ twinSymbol ].handle;
  _.assert( flock.PrimitiveHandleIs( result ) );
  return result;
}

// --
// send
// --

function send( body )
{
  let flock = this;
  let logger = flock.logger;

  return flock._send
  ({
    deserialized : { body },
  });

}

//

function _send( o )
{
  let flock = this;
  let logger = flock.logger;

  _.routineOptions( _send, arguments );
  _.mapOptionsApplyDefaults( o.deserialized, flock.Packet );
  _.assert( o.deserialized.recipient === null || _.remote.agentPathIs( o.deserialized.recipient ) );

  if( o.deserialized.recipient )
  {
    if( o.deserialized.recipient === flock.agentPath )
    {
      _.assert( flock.role === 'master' );
      flock.masterRecieveGot({ deserialized : o.deserialized });
      return;
    }
  }

  if( o.connection === null )
  o.connection = flock.connectionDefaultGet();

  if( o.serialized === null )
  {
    o.serialized = flock._serialize( o.deserialized );
  }

  o.connection.write( o.serialized );

}

_send.defaults =
{
  connection : null,
  deserialized : null,
  serialized : null,
}

//

function requestCall( o )
{
  let flock = this;
  let logger = flock.logger;

  _.assert( _.remote.agentPathIs( o.recipient ) );
  _.assert( _.longIs( o.args ) );
  _.assert( _.strDefined( o.routine ) );

  if( o.context !== null )
  o.context = flock.handleFrom( o.context );
  o.object = flock.handleFrom( o.object );

  if( o.context === o.object )
  o.context = null;

  _.assert( o.context === null || flock.PrimitiveHandleIs( o.context ) );
  _.assert( flock.PrimitiveHandleIs( o.object ) );

  o.context = flock._pack({ structure : o.context });
  o.object = flock._pack({ structure : o.object });
  o.args = flock._pack({ structure : o.args });

  let body =
  {
    object : o.object,
    routine : o.routine,
    args : o.args,
    context : o.context,
  }

  return flock.request
  ({
    deserialized :
    {
      channel : 'call',
      recipient : o.recipient,
      body : body,
    },
  });

}

requestCall.defaults =
{
  recipient : null,
  object : null,
  routine : null,
  args : null,
  context : null,
}

//

function request( o )
{
  let flock = this;
  let logger = flock.logger;
  let request = flock._requestOpen( ... arguments );

  flock._send( o );

  return request;
}

request.defaults =
{
  ... _send.defaults,
}

//

function _requestOpen( o )
{
  let flock = this;
  let logger = flock.logger;

  _.routineOptions( _requestOpen, arguments );
  _.mapOptionsApplyDefaults( o.deserialized, flock.Packet );
  _.assert( arguments.length === 1 );
  _.assert( o.deserialized.requestId === null );

  flock.requestCounter += 1;
  let id = flock.requestCounter;
  o.deserialized.requestId = id;

  let request =
  {
    id,
    deserialized : o.deserialized,
    ready : _.Consequence(),
    status : 1,
    returned : _.undefined,
  }

  _.assert( flock.requests[ id ] === undefined );

  flock.requests[ id ] = request;

  return request;
}

_requestOpen.defaults =
{
  ... request.defaults,
}

//

function _requestClose( o )
{
  let flock = this;
  let logger = flock.logger;

  _.routineOptions( _requestClose, arguments );

  let request = flock.requests[ o.id ];
  _.assert( !!request, `Unknown request id ${o.id}` );
  _.assert( request.status === 1 );

  if( o.unpacked === _.undefined )
  o.unpacked = flock._unpack({ structure : o.packed });

  request.unpacked = o.unpacked;
  request.packed = o.packed;
  request.status = 2;
  request.ready.take( o.unpacked );

  delete flock.requests[ o.id ];

  return request;
}

_requestClose.defaults =
{
  id : null,
  packed : _.undefined,
  unpacked : _.undefined,
}

//

function _requestPerform( o )
{
  let flock = this;
  let logger = flock.logger;

  _.routineOptions( _requestPerform, arguments );

  return _.Consequence.Try( () =>
  {

    if( o.unpacked === _.undefined )
    o.unpacked = flock._unpack({ structure : o.packed });

    _.assert( _.longIs( o.unpacked.args ) );
    _.assert( o.id >= 1 );

    let object = flock.localHandleToObject( o.unpacked.object );

    _.assert( _.routineIs( object[ o.unpacked.routine ] ), `No such routine::${o.unpacked.routine}` );

    let result = object[ o.unpacked.routine ]( ... o.unpacked.args );
    if( result === undefined )
    result = _.undefined;
    return result;
  })
  .then( ( result ) =>
  {

    let packet =
    {
      channel : 'response',
      body : flock._pack({ structure : result }),
      requestId : o.id,
    }

    let o2 =
    {
      connection : o.connection || flock.connectionDefaultGet(),
      deserialized : packet,
    }

    flock._send( o2 );

    return result;
  });
}

_requestPerform.defaults =
{
  id : null,
  packed : _.undefined,
  unpacked : _.undefined,
  connection : null,
}

function _serialize( o )
{
  let flock = this;
  let logger = flock.logger;
  let serialized;
  try
  {
    _.assert( _.strDefined( o.channel ), 'Channel is not specified' );
    serialized = _.toJson( o );
    serialized = serialized.length + ' ' + serialized;
  }
  catch( err )
  {
    err = _.err( err, `Agent::{${flock.agentPath}} failed to _serialize structure` );
  }
  return serialized;
}

_serialize.defaults =
{
  channel : null,
  data : null,
}

//

function _deserialize( o )
{
  let flock = this;
  let logger = flock.logger;
  let converters = _.Gdf.Select({ in : 'string', out : 'structure', ext : 'json', default : 1 })
  let converter = converters[ 0 ];
  let result = [];

  if( _.bufferAnyIs( o.data ) )
  o.data = _.bufferToStr( o.data );

  let left = o.data;

  do
  {
    try
    {
      let size = parseFloat( left );
      _.assert( size > 0, () => `Failed to parse prologue of the package "${left.substring( 0, Math.max( left.length, 30 ) )}..."` );
      let sizeStr = String( size );
      let current = left.substring( sizeStr.length + 1, sizeStr.length + size + 1 );
      left = left.substring( sizeStr.length + size + 1, left.length );
      let deserialized = converter.encode({ data : current });
      _.assert( _.mapIs( deserialized.data ) );
      // let deserialized = JSON.parse( o.data );
      result.push( deserialized.data );
    }
    catch( err )
    {
      err = _.err( err, `\nagent::{${flock.agentPath}} failed to parse recieved packet\n` );
      debugger;
      throw err;
    }
  }
  while( left.length );

  return result;
}

_deserialize.defaults =
{
  data : null,
}

//

function _pack( o )
{
  let flock = this;
  return o.structure;
}

_pack.defaults =
{
  structure : null,
}

//

function _unpack( o )
{
  let flock = this;
  return o.structure;
}

_unpack.defaults =
{
  structure : null,
}

// --
// common
// --

function commonRecieveGot( o )
{
  let flock = this;
  let logger = flock.logger;

  _.routineOptions( commonRecieveGot, arguments );

  if( o.deserialized === null )
  o.deserialized = flock._deserialize({ data : o.serialized });

  if( _.longIs( o.deserialized ) )
  {
    for( let d = 0 ; d < o.deserialized.length ; d++ )
    flock.commonRecieveGot
    ({
      deserialized : o.deserialized[ d ],
      connection : o.connection,
    });
    return;
  }

  if( o.deserialized.recipient )
  {
    if( o.deserialized.recipient !== flock.agentPath )
    {
      flock._send
      ({
        deserialized : o.deserialized,
      });
      flock.log( -5, `resend . ${o.deserialized.body}` );
      return;
    }
  }

  if( o.deserialized.channel !== null )
  {
    _.assert( _.strDefined( o.deserialized.channel ) );
    let methodName = `_channel${_.strCapitalize( o.deserialized.channel )}`;
    _.sure( _.routineIs( flock[ methodName ] ), `Unknown channel ${o.deserialized.channel}` );
    flock[ methodName ]( o );
  }

  flock.log( -5, `recieved . ${o.deserialized.channel} . ${o.deserialized.body}` );
}

commonRecieveGot.defaults =
{
  serialized : null,
  deserialized : null,
  connection : null,
}

//

function commonErrorGot( o )
{
  let flock = this;
  let logger = flock.logger;

  logger.error( _.errOnce( `Error of ${flock.agentPath || flock.role}\n`, o.err ) );

  flock.masterCloseSoonMaybe();

  flock.eventGive
  ({
    kind : 'errorGot',
    representative : !o.connection ? null : flock.connectionToRepresentative( o.connection ),
    err : o.err,
  });

}

commonErrorGot.defaults =
{
  err : null,
  connection : null,
}

//

function _channelMessage( o )
{
  let flock = this;
  let logger = flock.logger;

  flock.eventGive
  ({
    kind : 'channelMessage',
    representative : !o.connection ? null : flock.connectionToRepresentative( o.connection ),
    message : o.deserialized.body,
  });

}

//

function _channelCall( o )
{
  let flock = this;
  let logger = flock.logger;

  return flock._requestPerform
  ({
    id : o.deserialized.requestId,
    packed : o.deserialized.body,
    connection : o.connection,
  });
}

//

function _channelResponse( o )
{
  let flock = this;
  let logger = flock.logger;

  return flock._requestClose
  ({
    id : o.deserialized.requestId,
    packed : o.deserialized.body,
  });
}

//

function _channelIdentity( o )
{
  let flock = this;
  let logger = flock.logger;

  flock.slaveConnectEnd
  ({
    connection : o.connection,
    attempt : flock._connectAttemptsMade,
    id : o.deserialized.body.id,
  });

}

// --
// slave
// --

function slaveOpenSlave( o )
{
  let flock = this;
  let logger = flock.logger;

  _.routineOptions( slaveOpenSlave, o );

  debugger;

  if( flock.role === 'master' )
  {

    return flock.masterSlaveOpen()
    .then( ( slaveFlock ) =>
    {
      debugger;
      return slaveFlock.object;
    });

  }
  else
  {

    let body =
    {
      object : 'flock',
      routine : 'slaveOpenSlave',
      args : [],
    }

    return flock.request
    ({
      deserialized :
      {
        channel : 'call',
        recipient : '/master1',
        body : body,
      },
    });

  }

}

slaveOpenSlave.defaults =
{
}

//

function slaveOpenMaster()
{
  let flock = this;
  let logger = flock.logger;

  flock.masterPath = flock.MasterPathFindFree();

  _.assert( _.strDefined( flock.masterPath ) );
  _.assert( _.strDefined( flock.entryPath ) );
  _.assert( flock._process === null );

  let result = flock._process = _.process.startNode
  ({
    execPath : flock.entryPath,
    args : `role:master masterPath:${flock.masterPath}`,
    sync : 0,
    deasync : 0,
    detaching : 1,
    stdio : 'pipe',
  });

  result.then( ( process ) =>
  {
    _.assert( flock._process === result );
    flock._process = process;
    return process;
  });

  return result;
}

//

function slaveConnectMaster()
{
  let flock = this;
  let logger = flock.logger;

  let masterPathParsed = _.uri.parse( flock.masterPath );
  masterPathParsed.port = _.strToNumberMaybe( masterPathParsed.port );

  flock._connectAttemptsMade += 1;

  let attempt = flock._connectAttemptsMade;

  _.assert( _.numberDefined( masterPathParsed.port ) );
  _.assert( flock.role === 'slave' );
  _.assert( flock.connections.length === 0 );
  _.assert( flock._connectAttemptsMade <= flock.connectAttempts );
  _.assert( flock._connectStatus === 'closed' );

  flock.slaveConnectBegin({ attempt });

  let o2 = { port : masterPathParsed.port };
  let connection = Net.createConnection( o2, () => flock.slaveConnectEndWaitingForIdentity({ attempt, connection }) );

  flock.connections.push( connection );

  connection.on( 'data', ( data ) => flock.slaveRecieveGot({ serialized : data }) );
  connection.on( 'error', ( err ) => flock.slaveErrorGot({ err }) );
  connection.on( 'end', () => flock.slaveDisconnectEnd({ connection, attempt }) )

  let ready = _.Consequence();

  flock.once( 'connectEnd', connectEnd );
  flock.once( 'errorGot', errorGot );

  return ready;

  function connectEnd( e )
  {
    flock.off( 'connectEnd', connectEnd );
    flock.off( 'errorGot', errorGot );
    ready.take( flock.master );
  }

  function errorGot( e )
  {
    flock.off( 'connectEnd', connectEnd );
    flock.off( 'errorGot', errorGot );
    ready.error( e.error );
  }

}

//

function slaveConnectMasterMaybe()
{
  let flock = this;
  let logger = flock.logger;

  if( _.longHas( [ 'closed', 'connecting', 'connection.waiting.for.identity' ], flock._connectStatus ) )
  if( flock.connectAttempts > flock._connectAttemptsMade )
  {
    flock.slaveConnectMaster();
    return true;
  }

  return false;
}

//

function slaveDisconnectMaster()
{
  let flock = this;
  let logger = flock.logger;

  flock._connectStatus = 'closed';

  if( flock.connections.length )
  {
    _.assert( flock.connections.length === 1 );
    flock.connections[ 0 ].end();
  }

  if( flock._process )
  {
    let process = flock._process;
    flock._process = null;
    process.disconnect();
  }

}

//

function slaveIsConnected()
{
  let flock = this;
  let logger = flock.logger;
  return !!flock.connections.length;
}

//

function slaveConnectBegin( o )
{
  let flock = this;
  let logger = flock.logger;

  _.assert( flock._connectStatus === 'closed' );
  flock._connectStatus = 'connecting';

  flock.eventGive
  ({
    kind : 'connectBegin',
    attempt : o.attempt,
  });

  flock.log( -7, `slaveConnectBegin. Attempt ${flock._connectAttemptsMade} / ${flock.connectAttempts}` );
}

slaveConnectBegin.defaults =
{
  attempt : null,
}

//

function slaveConnectEndWaitingForIdentity( o )
{
  let flock = this;
  let logger = flock.logger;

  _.assert( !!o.connection );
  _.assert( flock._connectStatus === 'connecting' );
  flock._connectStatus = 'connection.waiting.for.identity';

  flock.master = flock.representativeMake
  ({
    agentPath : _.remote.agentPathFromRole( 'master' ),
    connection : o.connection,
  })

  flock.eventGive
  ({
    kind : 'connectEndWaitingForIdentity',
    attempt : o.attempt,
    representative : flock.master,
  });

  flock.log( -7, `slaveConnectEndWaitingForIdentity` );
}

slaveConnectEndWaitingForIdentity.defaults =
{
  connection : null,
  attempt : null,
}

//

function slaveConnectEnd( o )
{
  let flock = this;
  let logger = flock.logger;

  _.assert( !!o.connection );
  _.assert( flock._connectStatus === 'connection.waiting.for.identity' );
  flock._connectStatus = 'connected';

  /* qqq : write explanation for every assert. ask how to */

  _.assert( flock.role === 'slave' );
  _.assert( flock.id === 0 );
  _.assert( o.id >= 2 );
  _.assert( _.numberIs( o.id ) );
  flock.id = o.id;
  _.assert( flock.agentPath === null );
  flock.agentPath = _.remote.agentPathFromRole( flock.role, flock.id );

  flock.eventGive
  ({
    kind : 'connectEnd',
    attempt : o.attempt,
    representative : flock.master,
  });

  flock.log( -7, `slaveConnectEnd` );
}

slaveConnectEnd.defaults =
{
  connection : null,
  attempt : null,
  id : null,
}

//

function slaveDisconnectEnd( o )
{
  let flock = this;
  let logger = flock.logger;
  flock.log( -7, `slaveDisconnectEnd` );

  _.assert( flock.connections.length === 1 );
  _.assert( flock.connections[ 0 ] === o.connection )

  flock.connections.splice( 0, 1 );
}

slaveDisconnectEnd.defaults =
{
  connection : null,
  attempt : null,
}

//

function slaveRecieveGot( o )
{
  let flock = this;
  let logger = flock.logger;
  _.routineOptions( slaveRecieveGot, arguments );
  if( o.connection === null )
  o.connection = flock.connectionDefaultGet();
  return flock.commonRecieveGot( o );
}

slaveRecieveGot.defaults =
{
  ... commonRecieveGot.defaults,
}

//

function slaveErrorGot( o )
{
  let flock = this;
  let logger = flock.logger;

  debugger;
  try
  {
    if( !flock.connectionIsAlive( flock.connections[ 0 ] ) )
    {
      flock.connections.splice( 0, 1 );
      flock.slaveDisconnectMaster();
      if( flock.slaveConnectMasterMaybe() )
      return;
    }
  }
  catch( err )
  {
    logger.error( _.errOnce( 'slaveErrorGot error\n', err ) );
  }

  if( !o.connection )
  try
  {
    if( flock.connections.length )
    o.connection = flock.connectionDefaultGet();
  }
  catch( err )
  {
    logger.error( _.errOnce( 'slaveErrorGot error\n', err ) );
  }

  return flock.commonErrorGot( o );
}

slaveErrorGot.defaults =
{
  ... commonErrorGot.defaults,
}

// --
// master
// --

function MasterPathFindOpened()
{
  return null;
}

//

function MasterPathFindFree()
{
  return 'http://0.0.0.0:13000';
}

//

function masterOpen()
{
  let flock = this;
  let logger = flock.logger;

  _.assert( flock.agentCounter === 0 );
  flock.agentCounter += 1;
  _.assert( flock.id === 0 );
  flock.id = flock.agentCounter;
  _.assert( flock.agentPath === null );
  flock.agentPath = _.remote.agentPathFromRole( flock.role, flock.id );

  flock.masterOpenBegin();

  if( !flock.masterPath )
  flock.masterPath = flock.MasterPathFindFree();

  _.assert( !!flock.masterPath );
  let masterPathParsed = _.uri.parse( flock.masterPath );
  masterPathParsed.port = _.strToNumberMaybe( masterPathParsed.port );
  _.assert( _.numberDefined( masterPathParsed.port ) );

  flock.server = Net.createServer( ( connection ) =>
  {
    flock.masterConnectBegin({});
    connection
    .on( 'data', ( data ) => flock.masterRecieveGot({ connection, serialized : data }) )
    .on( 'end', () => flock.masterDisconnectEnd({ connection }) )
    .on( 'error', ( err ) => flock.masterErrorGot({ connection, err }) )
    ;
    flock.masterConnectEnd({ connection });
  })
  .on( 'error', ( err ) => flock.masterErrorGot({ err }) )
  .on( 'close', () => flock.masterCloseEnd() )
  ;

  flock.server.listen( masterPathParsed.port, () => flock.masterOpenEnd() );

  return flock;
}

//

function masterClose()
{
  let flock = this;
  let logger = flock.logger;

  _.assert( !!flock.server );

  flock.masterCloseBegin();

  flock.server.close();

  return flock;
}

//

function masterIsOpened()
{
  let flock = this;
  let logger = flock.logger;
  return !!flock.server;
}

//

function masterCloseSoonMaybe()
{
  let flock = this;
  let logger = flock.logger;

  if( !flock.masterCloseCan() )
  return false;

  flock.terminationTimer = _.time.begin( flock.terminationPeriod, () => flock._masterCloseMaybe() );

  return true;
}

//

function masterCloseSoonCancel()
{
  let flock = this;
  let logger = flock.logger;

  if( flock.terminationTimer )
  {
    flock.terminationTimer = _.time.cancel( flock.terminationTimer );
    flock.terminationTimer = null;
  }

}

//

function _masterCloseMaybe()
{
  let flock = this;
  let logger = flock.logger;

  if( flock.masterCloseCan() )
  flock.masterClose();

}

//

function masterCloseCan()
{
  let flock = this;
  let logger = flock.logger;

  if( flock.connections.length )
  return false;

  return true;
}

//

function masterCloseBegin()
{
  let flock = this;
  let logger = flock.logger;
}

//

function masterCloseEnd()
{
  let flock = this;
  let logger = flock.logger;
  flock.server = null;
  _.assert( flock.connections.length === 0 ); /* qqq : reproduce the case when this assertion fails */
}

//

function masterOpenBegin()
{
  let flock = this;
  let logger = flock.logger;

  _.assert( flock._connectStatus === 'closed' );
  flock._connectStatus = 'opening';

  _.time.out( flock.terminationOnOpeningExtraPeriod, () => flock.masterCloseSoonMaybe() );

}

//

function masterOpenEnd()
{
  let flock = this;
  let logger = flock.logger;

  _.assert( flock._connectStatus === 'opening' );
  flock._connectStatus = 'opened';

  flock.log( -7, `opened server on port::${flock.server.address().port}` );
}

//

function masterConnectBegin( o )
{
  let flock = this;
  let logger = flock.logger;

  _.assert( !o.connection );

  flock.masterCloseSoonCancel();

  flock.eventGive
  ({
    kind : 'connectBegin',
  });

}

masterConnectBegin.defaults =
{
}

//

function masterConnectEnd( o )
{
  let flock = this;
  let logger = flock.logger;

  _.assert( !!o.connection );

  _.arrayAppendOnceStrictly( flock.connections, o.connection );

  flock.agentCounter += 1;
  let id = flock.agentCounter;
  let agentPath = _.remote.agentPathFromRole( 'slave', id );

  _.assert( id >= 2 );

  let representative = flock.representativeMake
  ({
    agentPath,
    connection : o.connection,
  });

  _.assert( flock.representativesMap[ id ] === representative );
  _.assert( id === representative.id );
  _.assert( o.connection === representative.connection );

  flock._send
  ({
    connection : o.connection,
    deserialized :
    {
      channel : 'identity',
      body : { id }
    }
  });

  flock.eventGive
  ({
    kind : 'connectEnd',
    representative,
  });

  flock.log( -7, `${o.connection.remoteAddress} connected. ${flock.connections.length} connection(s)` );

}

masterConnectEnd.defaults =
{
  connection : null,
}

//

function masterDisconnectEnd( o )
{
  let flock = this;
  let logger = flock.logger;
  _.arrayRemoveOnceStrictly( flock.connections, o.connection );

  flock.masterCloseSoonMaybe();

  flock.log( -7, `${o.connection.remoteAddress} disconnected. ${flock.connections.length} connection(s)` );
}

masterDisconnectEnd.defaults =
{
  connection : null,
}

//

function masterRecieveGot( o )
{
  let flock = this;
  let logger = flock.logger;

  _.routineOptions( masterRecieveGot, arguments );

  return flock.commonRecieveGot( ... arguments );
}

masterRecieveGot.defaults =
{
  ... commonRecieveGot.defaults,
}

//

function masterErrorGot( o )
{
  let flock = this;
  let logger = flock.logger;
  return flock.commonErrorGot( o );
}

masterErrorGot.defaults =
{
  ... commonErrorGot.defaults,
}

// --
// relationships
// --

let twinSymbol = Symbol.for( 'twin' );

let Packet =
{
  recipient : null,
  requestId : null,
  channel : 'message',
  body : null,
}

let Composes =
{

  terminationPeriod : 5000,
  terminationOnOpeningExtraPeriod : 5000,
  slaveDelay : 1000,
  masterDelay : 0,

  connectAttempts : 2,
  connectAttemptDelay : 250,

  entryPath : null,
  masterPath : null,
  agentPath : null,

}

let Associates =
{

  logger : null,

}

let Restricts =
{

  server : null,
  connections : _.define.own( [] ),
  _process : null,

  master : null,
  representativesMap : _.define.own( {} ),
  connectionToRepresentativeHash : _.define.own( new HashMap ),

  terminationTimer : null,

  agentCounter : 0,
  role : null,
  id : 0,
  _connectAttemptsMade : 0,
  _connectStatus : 'closed',

  requestCounter : 0,
  requests : _.define.own( {} ),

  objectCounter : 0,
  idToHandleDescriptorHash : _.define.own( new HashMap ),
  nameToHandleDescriptorHash : _.define.own( new HashMap ),
  objectToHandleDescriptorHash : _.define.own( new HashMap ),

}

let Events =
{

  errorGot : {},

  connectBegin : {},
  connectEndWaitingForIdentity : {},
  connectEnd : {},

  channelMessage : {},

}

let Statics =
{

  LocalHandleIs,
  PrimitiveHandleIs,
  RemoteHandleIs,

  MasterPathFindOpened,
  MasterPathFindFree,

  Packet,

}

let Forbids =
{
  object : 'object',
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

  finit,
  init,
  unform,
  form,

  // etc

  close,
  connectionIs,
  connectionIsAlive,
  connectionDefaultGet,
  connectionToRepresentative,

  roleDetermine,
  _roleDetermine,
  format,
  log,

  representativeMake,

  // handles

  LocalHandleIs,

  localHandleToObjectDescriptor,
  objectToLocalHandleDescriptor,
  localHandleToObject,
  objectToId,

  localHandlesAdd,
  _localHandleAdd,

  localHandlesRemoveObjects,
  localHandlesRemoveObject,

  PrimitiveHandleIs,
  RemoteHandleIs,
  handleFrom,

  // send

  send,
  _send,

  requestCall,
  request,
  _requestOpen,
  _requestClose,
  _requestPerform,

  _serialize,
  _deserialize,
  _pack,
  _unpack,

  // common

  commonRecieveGot,
  commonErrorGot,

  _channelMessage,
  _channelCall,
  _channelResponse,
  _channelIdentity,

  // slave

  slaveOpenSlave,
  slaveOpenMaster,
  slaveConnectMaster,
  slaveConnectMasterMaybe,
  slaveDisconnectMaster,
  slaveIsConnected,

  slaveConnectBegin,
  slaveConnectEndWaitingForIdentity,
  slaveConnectEnd,
  slaveDisconnectEnd,
  slaveRecieveGot,
  slaveErrorGot,

  // master

  MasterPathFindOpened,
  MasterPathFindFree,

  masterOpen,
  masterClose,
  masterIsOpened,
  masterCloseSoonMaybe,
  masterCloseSoonCancel,
  _masterCloseMaybe,
  masterCloseCan,

  masterCloseBegin,
  masterCloseEnd,
  masterOpenBegin,
  masterOpenEnd,
  masterConnectBegin,
  masterConnectEnd,
  masterDisconnectEnd,
  masterRecieveGot,
  masterErrorGot,

  // relations

  Composes,
  Associates,
  Restricts,
  Events,
  Statics,
  Forbids,
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
_.EventHandler.mixin( Self );

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;
_.remote[ Self.shortName ] = Self;

})();
