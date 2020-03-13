( function _JsUglify_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../Tools.s' );
  require( './JsAbstract.test.s' );

}

//

var _ = _global_.wTools;
var fileProvider = _.fileProvider;
var path = fileProvider.path;
var Parent = wTests[ 'Tools.mid.Introspector.Js' ];

// --
// tests
// --

function parseStringSpecial( test )
{
  let context = this;
  let sourceCode = context.defaultProgramSourceCode;

  test.description = 'setup';

  test.is( _.constructorIs( _.introspector.Parser.JsUglify ) );
  test.is( _.constructorIs( context.defaultParser ) );
  test.is( context.defaultParser === _.introspector.Parser.JsUglify );

  let sys = _.introspector.System({ defaultParserClass : context.defaultParser });
  let file = _.introspector.File({ data : sourceCode, sys });
  file.refine();
  logger.log( file.productExportInfo() );

  test.description = 'nodes';
  test.identical( file.product.nodes.length, 152 );
  test.identical( _.mapKeys( file.product.byType ).length, 21 );
  test.identical( file.product.byType.gRoutine.length, 8 );

  test.description = 'root';
  test.identical( file.product.byType.Toplevel.length, 1 );
  test.is( file.product.byType.Toplevel.first() === file.product.root );

  // the most broken JS parser among added
  // [ 207, 290 ]

  debugger;
  return null;
}

parseStringSpecial.description =
`
Parsing from string with espima js parser produce proper AST.
`

// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.Introspector.JsUglify',

  context :
  {

    defaultParser : _.introspector.Parser.JsUglify,

  },

  tests :
  {

    parseStringSpecial,

  },

}

//

var Self = new wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
