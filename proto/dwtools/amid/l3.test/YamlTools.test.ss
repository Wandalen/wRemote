( function _YamlTools_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../Tools.s' );
  _.include( 'wTesting' );
  require( '../l3/yaml/IncludeMid.s' );
}

//

var _ = _global_.wTools;

// --
// context
// --

function onSuiteBegin( test )
{
  let context = this;
  context.provider = _.fileProvider;
  let path = context.provider.path;
  context.suitePath = context.provider.path.pathDirTempOpen( path.join( __dirname, '../..'  ),'YamlTools' );
  context.suitePath = context.provider.pathResolveLinkFull({ filePath : context.suitePath, resolvingSoftLink : 1 });
  context.suitePath = context.suitePath.absolutePath;

}

//

function onSuiteEnd( test )
{
  let context = this;
  let path = context.provider.path;
  _.assert( _.strHas( context.suitePath, 'YamlTools' ), context.suitePath );
  path.pathDirTempClose( context.suitePath );
}

// --
// tests
// --

function trivial( test )
{

  var src =
`

about :
  name : some name
  version : 0.0.0

path :
  in : .
  out : out

`

  var exp =
  {
    'line' : '  in : .',
    'pre' : '  ',
  }
  var got = _.yaml.lineFind( src, 'in' );
  test.contains( got, exp );

}

// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.YamlTools',
  silencing : 1,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    provider : null,
    suitePath : null,
  },

  tests :
  {
    trivial,
  },

}

//

var Self = new wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
