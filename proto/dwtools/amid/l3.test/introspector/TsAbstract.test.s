( function _TsAbstract_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../Tools.s' );
  require( './Abstract.test.s' );

}

//

var _ = _global_.wTools;
var fileProvider = _.fileProvider;
var path = fileProvider.path;
var Parent = wTests[ 'Tools.mid.Introspector' ];

// --
// assets
// --

let tsProgramSourceCode1 =
`
function programWithCommentsAndRoutines(): void
{
  /* comment1 */
  console.log( 'program' );
  process.on( 'exit', () => console.log( 'arrow1' ) );
  process.on( 'exit', () => { console.log( 'arrow2' ) } );
  process.on( 'exit', function(){ console.log( 'anonymous1' ) } );
  process.on( 'exit', function function1(){ console.log( 'function1' ) } );
  let function2 = function function2_(){ console.log( 'function2' ) };
  class SomeClass
  {
    constructor()
    {
    }
    method2(): void
    {
      console.log( 'method2' );
    }
  }
  // comment2
}
`

/*
`
import { Syntax } from './syntax';

export type ArgumentListElement = Expression | SpreadElement;
export type ArrayExpressionElement = Expression | SpreadElement | null;

export class ArrayExpression
{
  readonly type: string;
  readonly elements: ArrayExpressionElement[];
  constructor(elements: ArrayExpressionElement[])
  {
    this.type = Syntax.ArrayExpression;
    this.elements = elements;
  }
}

function routine( s : string ) : Namespace1.Class1 | Namespace1.Class2
{
    return 'x'.indexOf( s );
}

`
*/

// --
// tests
// --

function parseStringCommon( test )
{
  let context = this;
  let sourceCode = context.defaultProgramSourceCode;

  test.is( _.constructorIs( _.introspector.Parser.Default ) );
  test.is( _.constructorIs( context.defaultParser ) );

  let sys = _.introspector.System({ defaultParserClass : context.defaultParser });
  let file = _.introspector.File({ data : sourceCode, sys });
  file.refine();

  logger.log( file.productExportInfo() );

  test.is( file.nodeIs( file.product.root ) );
  test.identical( file.product.byType.gRoutine.length, 8 );
  test.identical( file.nodeCode( file.product.root ), sourceCode );
  test.identical( file.parser.nodeRange( file.product.root ), [ 0, sourceCode.length ] );

  return null;
}

parseStringCommon.description =
`
Parsing from string with espima js parser produce proper AST.
Routine nodeCode returns proper source code.
`

// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.Introspector.Ts',
  abstract : 1,

  context :
  {

    tsProgramSourceCode1,
    defaultProgramSourceCode : tsProgramSourceCode1,

  },

  tests :
  {
    parseStringCommon,
  },

}

//

var Self = new wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
