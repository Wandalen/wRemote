( function _TsMicrosoft_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../Tools.s' );
  require( './TsAbstract.test.s' );

}

//

var _ = _global_.wTools;
var fileProvider = _.fileProvider;
var path = fileProvider.path;
var Parent = wTests[ 'Tools.mid.Introspector.Ts' ];

// --
// tests
// --

function parseStringSpecial( test )
{
  let context = this;
  let sourceCode = context.defaultProgramSourceCode;

  test.description = 'setup';

  test.is( _.constructorIs( _.introspector.Parser.TsMicrosoft ) );
  test.is( _.constructorIs( context.defaultParser ) );
  test.is( context.defaultParser === _.introspector.Parser.TsMicrosoft );

  let sys = _.introspector.System({ defaultParserClass : context.defaultParser });
  let file = _.introspector.File({ data : sourceCode, sys });
  file.refine();
  logger.log( file.productExportInfo() );

  test.description = 'nodes';
  test.identical( file.product.nodes.length, 52 );
  test.identical( _.mapKeys( file.product.byType ).length, 15 );
  test.identical( file.product.byType.gRoutine.length, 8 ); debugger;

  test.description = 'root';
  test.identical( file.product.byType.SourceFile.length, 1 );
  test.is( file.product.byType.SourceFile.first() === file.product.root );

/*

file.nodeCode( file.product.byType.CallExpression.toArray().original[1].arguments[1] )
" () => console.log( 'arrow1' )"

file.nodeType( file.product.byType.CallExpression.toArray().original[1].arguments[1] )
"ArrowFunction"

*/

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

  name : 'Tools.mid.Introspector.TsMicrosoft',

  context :
  {

    defaultParser : _.introspector.Parser.TsMicrosoft,

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
