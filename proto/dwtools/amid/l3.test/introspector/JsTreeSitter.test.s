( function _JsTreeSitter_test_s_( ) {

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

  test.is( _.constructorIs( _.introspector.Parser.JsTreeSitter ) );
  test.is( _.constructorIs( context.defaultParser ) );
  test.is( context.defaultParser === _.introspector.Parser.JsTreeSitter );

  let sys = _.introspector.System({ defaultParserClass : context.defaultParser });
  let file = _.introspector.File({ data : sourceCode, sys });
  file.refine();
  logger.log( file.productExportInfo() );

  test.description = 'nodes';
  test.identical( file.product.nodes.length, 220 );
  test.identical( _.mapKeys( file.product.byType ).length, 20 );
  test.identical( file.product.byType.gRoutine.length, 8 );

  test.description = 'root';
  test.identical( file.product.byType.program.length, 1 );
  test.is( file.product.byType.program.first() === file.product.root );

  return null;
}

parseStringSpecial.description =
`
Parsing from string with espima js parser produce proper AST.
`

//

function descriptorsSearchKind( test )
{
  let context = this;
  let program = _.program.preform( programRoutine );

  logger.log( '' );
  logger.log( _.strLinesNumber( program.sourceCode ) );
  logger.log( '' );

  test.is( _.constructorIs( context.defaultParser ) );

  let file = _.introspector.File.FromData( program.sourceCode );
  file.sys.defaultParserClass = context.defaultParser;
  file.refine();

  logger.log( file.productExportInfo() );
  logger.log( '' );

  /*
    xxx : implement
    type = [ CallExpression, ExpressionStatement ]
    calle/code >= ( 'test.setsAreIdentical' )
    arguments/0 -> '_.setFrom( {- arguments/0/code -} )'
    arguments/1 -> '_.setFrom( {- arguments/1/code -} )'
  */

  /*
    xxx : implement
    @code >= ( 'test.setsAreIdentical' )
    .../@type = [ call_expression, expression_statement ]
    arguments/0 -> '_.setFrom( {- arguments/0/code -} )'
    arguments/1 -> '_.setFrom( {- arguments/1/code -} )'
  */

  let request =
  {
    kind : 'and',
    elements :
    [
      {
        kind : 'has',
        left : '@code',
        right :
        {
          kind : 'and',
          elements :
          [
            {
              kind : 'scalar',
              value : 'test.setsAreIdentical',
            }
          ],
        }
      },
      {
        kind : 'identical',
        left : { kind : 'selector', value : '.../@type' },
        right : { kind : 'or', elements :
        [
          {
            kind : 'scalar',
            value : 'call_expression',
          },
          {
            kind : 'scalar',
            value : 'expression_statement',
          },
        ]},
      },
    ],
  }

  // let foundDescriptors = file.descriptorsSearch( 'setsAreIdentical', { type : 'call_expression' } );
  let foundDescriptors = file.descriptorsSearch( 'setsAreIdentical' );
  debugger;

  var foundStr = _.map( foundDescriptors, ( d ) =>
  {
    return `at ${d.path}\nfound ${file.descriptorToCode( d )}\n`;
  }).join( '\n' );
  logger.log( foundStr );
  test.identical( _.strCount( foundStr, `found` ), 2 );

  /* */

  function programRoutine()
  {
    var _ = require( toolsPath );
    function r1()
    {
      test.setsAreIdentical( rel( _.arrayFlatten( _.select( arr, '*/filePath' ) ) ), [] );
      _.process.on( 'exit', () =>
      {
        test.setsAreIdentical( rel( _.mapKeys( map ) ), [] );
      });
    }

  }

}

descriptorsSearchKind.description =
`
xxx
`

// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.Introspector.JsTreeSitter',

  context :
  {

    defaultParser : _.introspector.Parser.JsTreeSitter,

  },

  tests :
  {

    parseStringSpecial,
    descriptorsSearchKind

  },

}

//

var Self = new wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
