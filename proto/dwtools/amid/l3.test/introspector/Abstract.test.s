( function _Introspector_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../Tools.s' );
  _.include( 'wTesting' );
  require( '../../l3/introspector/IncludeMid.s' );

}

//

var _ = _global_.wTools;
var fileProvider = _.fileProvider;
var path = fileProvider.path;

// --
// context
// --

function onSuiteBegin()
{
  let self = this;

  self.suiteTempPath = path.pathDirTempOpen( path.join( __dirname, '../..'  ), 'err' );
  self.assetsOriginalSuitePath = path.join( __dirname, '_asset' );

}

//

function onSuiteEnd()
{
  let self = this;
  _.assert( _.strHas( self.suiteTempPath, '/err-' ) )
  path.pathDirTempClose( self.suiteTempPath );
}

// --
// assets
// --

// --
// tests
// --

// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.Introspector',
  silencing : 1,
  abstract : 1,
  routineTimeOut : 30000,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {

    suiteTempPath : null,
    assetsOriginalSuitePath : null,
    execJsPath : null,
    defaultParser : null,
    defaultProgramSourceCode : null,

  },

  tests :
  {

  },

}

//

var Self = new wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
