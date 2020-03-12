( function _Flock_ss_() {

'use strict';

if( typeof module !== 'undefined' )
{
  var Net = require( 'net' );
}

//

let Express = null;
let ExpressLogger = null;
let ExpressDir = null;
let Querystring = null;
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
      ready.then( () => flock.slaveOpenMaster() );

      ready.then( () => flock.slaveConnectMaster() );

    }
    else
    {
      // ready.then( () => _.time.out( 1000 ) );
      ready.then( () => flock.masterOpen() );
    }

    return ready;
  });

  return ready;
}

// --
// worker
// --

function workerOpen( o )
{
  let flock = this;
  let logger = flock.logger;

  _.routineOptions( workerOpen, o );

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
      routine : 'workerOpen',
      args : [],
    }

    return flock.request
    ({
      deserialized :
      {
        channel : 'call',
        recipient : 'master',
        body : body,
      },
    });

  }

}

workerOpen.defaults =
{
}

// --
// common
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

function connectionIsAlive( connection )
{
  let flock = this;
  let logger = flock.logger;
  _.assert( connection.destroyed !== undefined );
  return !connection.destroyed;
}

//

function connectionDefaultGet()
{
  let flock = this;
  let logger = flock.logger;
  _.assert( flock.role === 'slave' );
  _.assert( flock.connections.length === 1 );
  return flock.connections[ 0 ];
}

//

function objectGet( alias )
{
  let flock = this;
  if( alias === 'flock' )
  return flock;
  throw _.err( `Unknown object::${alias}` );
}

//

function recipientIsMe( recipient )
{
  let flock = this;

  _.assert( recipient === null || recipient === 'master' );
  _.assert( !!flock.role );

  if( recipient === flock.role )
  return true;
  return false;
}

//

function serialize( o )
{
  let flock = this;
  let logger = flock.logger;
  _.assert( _.strDefined( o.channel ) );
  let serialized = _.toJson( o );
  return serialized;
}

serialize.defaults =
{
  channel : null,
  data : null,
}

//

function deserialize( o )
{
  let flock = this;
  let logger = flock.logger;
  if( _.bufferAnyIs( o.data ) )
  o.data = _.bufferToStr( o.data );
  let deserialized = JSON.parse( o.data );
  return deserialized;
}

deserialize.defaults =
{
  data : null,
}

//

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
  _.assert( o.deserialized.recipient === null || o.deserialized.recipient === 'master' );

  if( o.deserialized.recipient )
  {
    debugger;
    if( flock.recipientIsMe( o.deserialized.recipient ) )
    {
      _.assert( flock.role === 'master' );
      flock.masterRecieveGot({ deserialized : o.deserialized });
      return;
    }
    else _.assert( 0 );
  }

  if( o.connection === null )
  o.connection = flock.connectionDefaultGet();

  if( o.serialized === null )
  {
    o.serialized = flock.serialize( o.deserialized );
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
  o.deserialized.requestId = flock.requestCounter;

  let request =
  {
    id : flock.requestCounter,
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
  _.assert( !!request );
  _.assert( request.status === 1 );

  if( o.deserialized === _.undefined )
  o.deserialized = flock._requestDeserialize({ serialized });

  request.deserialized = o.deserialized;
  request.serialized = o.serialized;
  request.status = 2;
  request.ready.take( o.deserialized );

  delete flock.requests[ o.id ];

  return request;
}

_requestClose.defaults =
{
  id : null,
  serialized : _.undefined,
  deserialized : _.undefined,
}

//

function _requestPerform( o )
{
  let flock = this;
  let logger = flock.logger;

  _.routineOptions( _requestPerform, arguments );

  debugger;

  return _.Consequence.Try( () =>
  {

    debugger;
    if( o.deserialized === _.undefined )
    o.deserialized = flock._requestDeserialize({ serialized });

    _.assert( o.deserialized.channel === 'call' );
    _.assert( _.longIs( o.deserialized.body.args ) );

    let object = flock.objectGet( o.deserialized.body.object );

    _.assert( _.routineIs( object[ o.deserialized.body.routine ] ) );

    let result = object[ o.deserialized.body.routine ]( ... o.deserialized.body.args );
    if( result === undefined )
    return _.undefined;
  })
  .then( ( result ) =>
  {

    debugger;

    let packet =
    {
      channel : 'response',
      body : flock._requestSerialize({ deserialized : result }),
    }

    let o2 =
    {
      connection : o.connection || flock.connectionDefaultGet(),
      deserialized : packet,
    }

    flock._send( o2 );

  });
}

_requestPerform.defaults =
{
  id : null,
  serialized : _.undefined,
  deserialized : _.undefined,
  connection : null,
}

//

function _requestSerialize( o )
{
  let flock = this;
  return o.deserialized;
}

_requestSerialize.defaults =
{
  deserialized : null,
}

//

function _requestDeserialize( o )
{
  let flock = this;
  return o.serialized;
}

_requestDeserialize.defaults =
{
  serialized : null,
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
  o.deserialized = flock.deserialize({ data : o.serialized });

  if( o.deserialized.recipient )
  {
    if( !flock.recipientIsMe( o.deserialized.recipient ) )
    {
      flock._send
      ({
        deserialized : o.deserialized,
      });
      flock.log( -5, `resend . ${o.deserialized.body}` );
      return;
    }
  }

  if( o.deserialized.requestId )
  {
    if( o.deserialized.channel === 'call' )
    flock._requestPerform
    ({
      id : -o.deserialized.requestId,
      serialized : o.deserialized.body,
      connection : o.connection,
    });
    else if( o.deserialized.channel === 'response' )
    flock._requestClose
    ({
      id : -o.deserialized.requestId,
      serialized : o.deserialized.body,
    });
    else _.assert( `Unknown channel ${o.deserialized.channel}` );
  }

  flock.log( -5, `recieved . ${o.deserialized.body}` );
}

commonRecieveGot.defaults =
{
  serialized : null,
  deserialized : null,
  connection : null,
}

// --
// slave
// --

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

  debugger;
  result.then( ( process ) =>
  {
    debugger;
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

  flock._connectAttemptsMade += 1; debugger;

  let attempt = flock._connectAttemptsMade;

  _.assert( _.numberDefined( masterPathParsed.port ) );
  _.assert( flock.role === 'slave' );
  _.assert( flock.connections.length === 0 );
  _.assert( flock._connectAttemptsMade <= flock.connectAttempts );
  _.assert( flock._connectStatus === 'closed' );

  flock.slaveConnectBegin({ attempt });

  let o2 = { port : masterPathParsed.port };
  let connection = Net.createConnection( o2, () => flock.slaveConnectEnd({ attempt }) );

  flock.connections.push( connection );

  connection.on( 'data', ( data ) => flock.slaveRecieveGot({ serialized : data }) );
  connection.on( 'error', ( err ) => flock.slaveErrorGot({ err }) );
  connection.on( 'end', () => flock.slaveDisconnectEnd({ connection, attempt }) )

  _.time.out( 10000, () =>
  {
    flock.slaveDisconnectMaster();
  });

  return flock;
}

//

function slaveConnectMasterMaybe()
{
  let flock = this;
  let logger = flock.logger;

  if( _.longHas( [ 'closed', 'connecting' ], flock._connectStatus ) )
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

  flock.log( -7, `slaveConnectBegin. Attempt ${flock._connectAttemptsMade} / ${flock.connectAttempts}` );
}

slaveConnectBegin.defaults =
{
  attempt : null,
}

//

function slaveConnectEnd( o )
{
  let flock = this;
  let logger = flock.logger;

  _.assert( flock._connectStatus === 'connecting' );
  flock._connectStatus = 'connected';

  flock.log( -7, `slaveConnectEnd` );

  flock.eventGive
  ({
    kind : 'connectEnd',
    connection : flock.connectionDefaultGet(),
    attempt : o.attempt,
  });

  // flock._send /* xxx : temp */
  // ({
  //   connection : flock.connections[ 0 ],
  //   deserialized :
  //   {
  //     body : 'SLAVE-SENDING: Hello this is client!',
  //   }
  // });

}

slaveConnectEnd.defaults =
{
  attempt : null,
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
  return flock.commonRecieveGot( ... arguments );
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
    logger.error( _.err( 'slaveErrorGot error\n', err ) );
  }

  logger.error( _.err( 'Slave error\n', o.err ) );

}

slaveErrorGot.defaults =
{
  err : null,
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

  flock.masterOpenBegin();

  if( !flock.masterPath )
  flock.masterPath = flock.MasterPathFindFree();

  _.assert( !!flock.masterPath );
  let masterPathParsed = _.uri.parse( flock.masterPath );
  masterPathParsed.port = _.strToNumberMaybe( masterPathParsed.port );
  _.assert( _.numberDefined( masterPathParsed.port ) );

  flock.server = Net.createServer( ( connection ) =>
  {
    flock.masterConnectBegin({ connection });
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

  debugger;
  flock.terminationTimer = _.time.begin( flock.terminationPeriod, () => flock._masterCloseMaybe() );
  debugger;

  return true;
}

//

function masterCloseSoonCancel()
{
  let flock = this;
  let logger = flock.logger;

  if( flock.terminationTimer )
  {
    debugger;
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

  _.time.out( flock.openingPeriod, () => flock.masterCloseSoonMaybe() );

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

  _.arrayAppendOnceStrictly( flock.connections, o.connection );

  flock.masterCloseSoonCancel();

  flock.log( -7, `${o.connection.remoteAddress} connected. ${flock.connections.length} connections` );

}

masterConnectBegin.defaults =
{
  connection : null,
}

//

function masterConnectEnd( o )
{
  let flock = this;
  let logger = flock.logger;

  flock.log( -7, `masterConnectEnd` );

  flock.eventGive
  ({
    kind : 'connectEnd',
    connection : o.connection,
  });

  // flock._send /* xxx : temp */
  // ({
  //   connection : o.connection,
  //   deserialized :
  //   {
  //     body : 'MASTER-SENDING: Hello! This is server speaking.',
  //   },
  // });

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

  flock.log( -7, `${o.connection.remoteAddress} disconnected. ${flock.connections.length} connections` );
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
  logger.error( _.err( 'Master error\n', o.err ) );
  debugger;
}

masterErrorGot.defaults =
{
  err : null,
  connection : null,
}

// --
// center
// --

function CenterProxyGet( original, fieldName, proxy )
{
  debugger;
}

//

function CenterProxySet( original, fieldName, value, proxy )
{
  debugger;
}

// --
// etc
// --

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

// --
// relationships
// --

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
  openingPeriod : 5000,

  entryPath : null,
  masterPath : null,

  connectAttempts : 2,
  connectAttemptDelay : 250,

}

let Associates =
{
  logger : null,
  server : null,
  connections : _.define.own( [] ),
  object : null,
  _process : null,
}

let Restricts =
{

  terminationTimer : null,

  role : null,
  _connectAttemptsMade : 0,
  _connectStatus : 'closed',

  requestCounter : 0,
  requests : _.define.own( {} ),

}

let Events =
{
  connectEnd : {},
}

  // masterOpen,
  // masterClose,
  // masterIsOpened,
  // masterCloseSoonMaybe,
  // masterCloseSoonCancel,
  // _masterCloseMaybe,
  // masterCloseCan,
  //
  // masterCloseBegin,
  // masterCloseEnd,
  // masterOpenBegin,
  // masterOpenEnd,
  // masterConnectBegin,
  // masterConnectEnd,
  // masterDisconnectEnd,
  // masterRecieveGot,
  // masterErrorGot,

let Statics =
{

  MasterPathFindOpened,
  MasterPathFindFree,

  CenterProxyGet,
  CenterProxySet,

  Packet,

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

  // worker

  workerOpen,

  // etc

  close,
  connectionIsAlive,
  connectionDefaultGet,
  objectGet,

  serialize,
  deserialize,

  send,
  _send,
  request,
  _requestOpen,
  _requestClose,
  _requestPerform,
  _requestSerialize,
  _requestDeserialize,

  // common

  commonRecieveGot,

  // slave

  slaveOpenMaster,
  slaveConnectMaster,
  slaveConnectMasterMaybe,
  slaveDisconnectMaster,
  slaveIsConnected,

  slaveConnectBegin,
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

  // center

  CenterProxyGet,
  CenterProxySet,

  // etc

  roleDetermine,
  _roleDetermine,
  format,
  log,

  /* */

  Composes,
  Associates,
  Restricts,
  Events,
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
_.EventHandler.mixin( Self );

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;
_.remote[ Self.shortName ] = Self;

})();
