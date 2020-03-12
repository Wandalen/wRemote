( function _Ext_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../Tools.s' );
  _.include( 'wTesting' );
  require( '../../l3/remote/Include.s' );
}

let _ = _global_.wTools;
let fileProvider = _testerGlobal_.wTools.fileProvider;
let path = fileProvider.path;

// --
// context
// --

function onSuiteBegin()
{
  let self = this;

  self.suiteTempPath = path.pathDirTempOpen( path.join( __dirname, '../..'  ), 'remote' );
  self.assetsOriginalSuitePath = path.join( __dirname, '_assets' );

}

//

function onSuiteEnd()
{
  let self = this;
  _.assert( _.strHas( self.suiteTempPath, '/remote-' ) )
  path.pathDirTempClose( self.suiteTempPath );
}

// --
// tests
// --

function basic( test )
{
  let a = test.assetFor();
  let centerPath = a.path.nativize( a.abs( 'Center.s' ) );
  let toolsPath = a.path.nativize( _.module.toolsPathGet() );
  let remotePath = a.path.nativize( _.module.resolve( 'wRemote' ) ); /* qqq xxx : cover this case of routine _.module.resolve */

  a.reflect();

  /* - */

  a.ready

  .then( () =>
  {
    test.case = 'basic';
    test.is( _.numberIs( _.remote.Flock.prototype.Composes.terminationPeriod ) );
    return null;
  })

  /* */

  debugger;
  a.js({ execPath : centerPath, env : { _TOOLS_PATH_ : toolsPath, _REMOTE_PATH_ : remotePath } })

  .then( ( got ) =>
  {
    debugger;
    test.identical( got.exitCode, 0 );

    test.identical( _.strCount( got.output, 'slave . slaveConnectBegin. Attempt 1 / 2' ), 1 );
    test.identical( _.strCount( got.output, 'slave . start' ), 1 );

    test.identical( _.strCount( got.output, 'slave . recieved . Message from master' ), 1 );
    test.identical( _.strCount( got.output, 'master . recieved . Message from slave' ), 1 );

    test.identical( _.strCount( got.output, 'slave . exit' ), 1 );

    return null;
  })

  .then( ( got ) =>
  {
    return _.time.out( _.remote.Flock.prototype.Composes.terminationPeriod + 3000 );
  })

  /*  */

  return a.ready;
}

// --
// declare
// --

var Self =
{

  name : 'Tools.mid.Remote',
  silencing : 1,
  routineTimeOut : 60000,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    suiteTempPath : null,
    assetsOriginalSuitePath : null,
    execJsPath : null,
  },

  tests :
  {
    basic,
  }

}

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
