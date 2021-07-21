( function _Ext_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( '../../../../node_modules/Tools' );
  _.include( 'wTesting' );
  require( '../../l3/remote/include/Mid.s' );
}

const _ = _global_.wTools;
const __ = _globals_.testing.wTools;
const fileProvider = __.fileProvider;
const path = fileProvider.path;
let debugged = _.process.isDebugged();

// --
// context
// --

function onSuiteBegin()
{
  let context = this;

  context.suiteTempPath = path.tempOpen( path.join( __dirname, '../..'  ), 'remote' );
  context.assetsOriginalPath = path.join( __dirname, '_assets' );

}

//

function onSuiteEnd()
{
  let context = this;
  _.assert( _.strHas( context.suiteTempPath, '/remote-' ) )
  path.tempClose( context.suiteTempPath );
}

//

function assetFor( test )
{
  let context = this;
  let a = Object.create( null );

  a = test.assetFor( a );

  a.centerPath = a.path.nativize( a.abs( 'Center.s' ) );
  a.toolsPath = a.path.nativize( _.module.toolsPathGet() );
  a.remotePath = a.path.nativize( _.module.resolve( 'wRemote' ) );
  /* qqq xxx : investigate and cover this case of routine _.module.resolve */

  let envExtension =
  {
    _TOOLS_PATH_ : a.toolsPath,
    _REMOTE_PATH_ : a.remotePath,
    _DISCONNECT_DELAY_ : debugged ? 30000 : 3000,
  }
  a.env = _.mapExtend( null, process.env, envExtension );
  a.appStart = a.process.starter
  ({
    execPath : context.appJsPath || null,
    currentPath : a.routinePath,
    outputCollecting : 1,
    throwingExitCode : 1,
    outputGraying : 1,
    ready : a.ready,
    mode : 'fork',
    env : a.env,
  })

  return a;
}

// --
// tests
// --

function basic( test )
{
  let context = this;
  let a = context.assetFor( test );

  a.reflect();

  /* - */

  a.ready

  .then( () =>
  {
    test.case = 'basic';
    test.true( _.numberIs( _.remote.Flock.prototype.Composes.terminationPeriod ) );
    return null;
  })

  /* */

  a.appStart({ execPath : a.centerPath })

  .then( ( got ) =>
  {
    debugger;
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'slave . slaveConnectBegin. Attempt 1 / 2' ), 1 );
    test.identical( _.strCount( got.output, 'slave . recieved . identity .' ), 1 );
    test.identical( _.strCount( got.output, 'master . enter' ), 1 );
    test.identical( _.strCount( got.output, 'slave . slaveConnectEndWaitingForIdentity' ), 1 );
    test.identical( _.strCount( got.output, 'slave . slaveConnectEnd' ), 2 );
    test.identical( _.strCount( got.output, 'slave . slaveDisconnectEnd' ), 1 );

    test.identical( _.strCount( got.output, 'slave . enter' ), 1 );
    test.identical( _.strCount( got.output, 'slave . exit' ), 1 );

    test.identical( _.strCount( got.output, '1 connection(s)' ), 1 );
    test.identical( _.strCount( got.output, '0 connection(s)' ), 1 );

    test.identical( _.strCount( got.output, 'slave . recieved . message . from /master1' ), 1 );
    test.identical( _.strCount( got.output, 'master . recieved . message . from /slave2' ), 1 );

    return null;
  })

  .then( ( got ) =>
  {
    return _.time.out( _.remote.Flock.prototype.Composes.terminationPeriod + 3000 );
  })

  /*  */

  return a.ready;
}

basic.description =
`
- slave launch master and connect to it
- slave disconnect in 10s what cause ot exit both processes
- master process exit not instantaneously, but with delay after slave disconnect
- fieled agentPath is formed and available before event connectEnd
`

//

function manyMessages( test )
{
  let context = this;
  let a = context.assetFor( test );

  a.reflect();

  /* - */

  a.ready

  .then( () =>
  {
    test.case = 'basic';
    test.true( _.numberIs( _.remote.Flock.prototype.Composes.terminationPeriod ) );
    return null;
  })

  a.appStart({ execPath : a.centerPath })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'slave . slaveConnectBegin. Attempt 1 / 2' ), 1 );
    test.identical( _.strCount( got.output, 'slave . recieved . message .' ), 3 );
    test.identical( _.strCount( got.output, 'master . recieved . message .' ), 3 );

    test.identical( _.strCount( got.output, 'slave . enter' ), 1 );
    test.identical( _.strCount( got.output, 'slave . exit' ), 1 );

    test.identical( _.strCount( got.output, '1 connection(s)' ), 1 );
    test.identical( _.strCount( got.output, '0 connection(s)' ), 1 );

    test.identical( _.strCount( got.output, 'slave . recieved . message . Message1 from master' ), 1 );
    test.identical( _.strCount( got.output, 'slave . recieved . message . Message2 from master' ), 1 );
    test.identical( _.strCount( got.output, 'slave . recieved . message . Message3 from master' ), 1 );

    test.identical( _.strCount( got.output, 'master . recieved . message . Message1 from slave' ), 1 );
    test.identical( _.strCount( got.output, 'master . recieved . message . Message2 from slave' ), 1 );
    test.identical( _.strCount( got.output, 'master . recieved . message . Message3 from slave' ), 1 );

    return null;
  })

  .then( ( got ) =>
  {
    return _.time.out( _.remote.Flock.prototype.Composes.terminationPeriod + 3000 );
  })

  /*  */

  return a.ready;
}

manyMessages.description =
`
- many messages in raw is not a because steeam is splitted by inserts with info about length of each
- sent and recieved messages are identical. nothing lost
`

//

function slaveCallMaster( test )
{
  let context = this;
  let a = context.assetFor( test );

  a.reflect();

  /* - */

  a.ready

  .then( () =>
  {
    test.case = 'basic';
    test.true( _.numberIs( _.remote.Flock.prototype.Composes.terminationPeriod ) );
    return null;
  })

  a.appStart({ execPath : a.centerPath })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'slave . enter' ), 1 );
    test.identical( _.strCount( got.output, 'slave . exit' ), 1 );

    test.identical( _.strCount( got.output, 'slave . recieved . message . from master' ), 1 );
    test.identical( _.strCount( got.output, 'master . recieved . message . from slave' ), 1 );

    test.identical( _.strCount( got.output, 'master . recieved . call' ), 1 );
    test.identical( _.strCount( got.output, 'slave . recieved . response . 3' ), 1 );

    test.identical( _.strCount( got.output, 'master . doSomething 3' ), 1 );
    test.identical( _.strCount( got.output, 'slave . doSomething 3' ), 1 );

    return null;
  })

  .then( ( got ) =>
  {
    return _.time.out( _.remote.Flock.prototype.Composes.terminationPeriod + 3000 );
  })

  /*  */

  return a.ready;
}

slaveCallMaster.description =
`
- slave requests master and gets response
- slave call method doSomething of object::center of master
`

//

function masterCallSlave( test )
{
  let context = this;
  let a = context.assetFor( test );

  a.reflect();

  /* - */

  a.ready

  .then( () =>
  {
    test.case = 'basic';
    test.true( _.numberIs( _.remote.Flock.prototype.Composes.terminationPeriod ) );
    return null;
  })

  a.appStart({ execPath : a.centerPath })

  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'slave . enter' ), 1 );
    test.identical( _.strCount( got.output, 'slave . exit' ), 1 );

    test.identical( _.strCount( got.output, 'slave . recieved . message . from master' ), 1 );
    test.identical( _.strCount( got.output, 'master . recieved . message . from slave' ), 1 );

    test.identical( _.strCount( got.output, 'slave . recieved . call' ), 1 );
    test.identical( _.strCount( got.output, 'master . recieved . response . 3' ), 1 );

    test.identical( _.strCount( got.output, 'master . doSomething 3' ), 1 );
    test.identical( _.strCount( got.output, 'slave . doSomething 3' ), 1 );

    return null;
  })

  .then( ( got ) =>
  {
    return _.time.out( _.remote.Flock.prototype.Composes.terminationPeriod + 3000 );
  })

  /*  */

  return a.ready;
}

masterCallSlave.description =
`
- slave requests master and gets response
- slave call method doSomething of object::center of master
`

// --
// declare
// --

const Proto =
{
  name : 'Tools.mid.Remote.Ext',
  silencing : 1,
  routineTimeOut : 60000,
  enabled : 0,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    suiteTempPath : null,
    assetsOriginalPath : null,
    appJsPath : null,
    assetFor,
  },

  tests :
  {

    basic,
    manyMessages,
    slaveCallMaster,
    masterCallSlave,

  }
}

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
