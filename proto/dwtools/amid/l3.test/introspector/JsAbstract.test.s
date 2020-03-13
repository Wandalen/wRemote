( function _JsAbstract_test_s_( ) {

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

function programWithCommentsAndRoutines()
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
    method2()
    {
      console.log( 'method2' );
    }
  }
  // comment2
}

let defaultProgram = programWithCommentsAndRoutines;
let defaultProgramSourceCode = defaultProgram.toString();

// --
// tests
// --

function fromData( test )
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

  let foundNodes = _.containerAdapter.from( [] );
  let foundDescriptors = _.containerAdapter.from( [] );

  logger.log( file.productExportInfo() );
  logger.log( '' );

  file.product.nodes.each( ( node ) =>
  {
    if( !_.strBegins( file.nodeCode( node ), 'test.setsAreIdentical(' ) || !_.strEnds( file.nodeCode( node ), ')' ) )
    return;
    foundNodes.append( node );
    foundDescriptors.append( file.nodeDescriptor( node ) );
  });

  debugger;
  /*
    xxx : implement
    type = [ CallExpression, ExpressionStatement ]
    calle/code >= ( 'test.setsAreIdentical' )
    arguments/0 -> '_.setFrom( {- arguments/0/code -} )'
    arguments/1 -> '_.setFrom( {- arguments/1/code -} )'
  */

  var foundStr = foundDescriptors.map( ( d ) =>
  {
    return `at ${d.path} :\nfound ${file.descriptorToCode( d )}\n`;
  }).join( '\n' );

  logger.log( foundStr );

  test.identical( _.strCount( foundStr, `found test.setsAreIdentical( rel( _.arrayFlatten( _.select( arr, '*/filePath' ) ) ), [] )` ), 1 );
  test.identical( _.strCount( foundStr, `found test.setsAreIdentical( rel( _.mapKeys( map ) ), [] )` ), 1 );
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

fromData.description =
`
Manual search for specific nodes finds 2 nodes.
`

//

function descriptorsSearch( test )
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

  let foundDescriptors = file.descriptorsSearch( 'setsAreIdentical' );

  var foundStr = _.map( foundDescriptors, ( d ) =>
  {
    return `at ${d.path}\nfound ${file.descriptorToCode( d )}\n`;
  }).join( '\n' );
  logger.log( foundStr );
  // test.identical( _.strCount( foundStr, `found setsAreIdentical` ), 2 );
  test.identical( _.strCount( foundStr, `found` ), 2 );

  var foundStr = _.map( foundDescriptors, ( d ) =>
  {
    return `at ${file.path.dirClosest( d.path, 2 )}\nfound ${file.descriptorToCode( d.down.down )}\n`;
  }).join( '\n' );
  logger.log( foundStr );
  test.identical( _.strCount( foundStr, `found test.setsAreIdentical( rel( _.arrayFlatten( _.select( arr, '*/filePath' ) ) ), [] )` ), 1 );
  test.identical( _.strCount( foundStr, `found test.setsAreIdentical( rel( _.mapKeys( map ) ), [] )` ), 1 );
  test.identical( _.strCount( foundStr, `found` ), 2 );

  var foundStr = _.map( foundDescriptors, ( d ) =>
  {
    return `at ${file.path.dirNodes( d.path, 2 )}\nfound ${file.nodeCode( file.nodeSelect( file.path.dirNodes( d.path, 2 ) ) )}\n`;
  }).join( '\n' );
  logger.log( foundStr );
  test.identical( _.strCount( foundStr, `found test.setsAreIdentical( rel( _.arrayFlatten( _.select( arr, '*/filePath' ) ) ), [] )` ), 1 );
  test.identical( _.strCount( foundStr, `found test.setsAreIdentical( rel( _.mapKeys( map ) ), [] )` ), 1 );
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

descriptorsSearch.description =
`
Routine descriptorsSearch finds 2 nodes.
`

//
// //
//
// function descriptorsSearchKind( test )
// {
//   let context = this;
//   let program = _.program.preform( programRoutine );
//
//   logger.log( '' );
//   logger.log( _.strLinesNumber( program.sourceCode ) );
//   logger.log( '' );
//
//   test.is( _.constructorIs( context.defaultParser ) );
//
//   let file = _.introspector.File.FromData( program.sourceCode );
//   file.sys.defaultParserClass = context.defaultParser;
//   file.refine();
//
//   logger.log( file.productExportInfo() );
//   logger.log( '' );
//
//   let foundDescriptors = file.descriptorsSearch( 'setsAreIdentical' );
//
//   var foundStr = _.map( foundDescriptors, ( d ) =>
//   {
//     return `at ${d.path}\nfound ${file.descriptorToCode( d )}\n`;
//   }).join( '\n' );
//   logger.log( foundStr );
//   // test.identical( _.strCount( foundStr, `found setsAreIdentical` ), 2 );
//   test.identical( _.strCount( foundStr, `found` ), 2 );
//
//   var foundStr = _.map( foundDescriptors, ( d ) =>
//   {
//     return `at ${file.path.dirClosest( d.path, 2 )}\nfound ${file.descriptorToCode( d.down.down )}\n`;
//   }).join( '\n' );
//   logger.log( foundStr );
//   test.identical( _.strCount( foundStr, `found test.setsAreIdentical( rel( _.arrayFlatten( _.select( arr, '*/filePath' ) ) ), [] )` ), 1 );
//   test.identical( _.strCount( foundStr, `found test.setsAreIdentical( rel( _.mapKeys( map ) ), [] )` ), 1 );
//   test.identical( _.strCount( foundStr, `found` ), 2 );
//
//   var foundStr = _.map( foundDescriptors, ( d ) =>
//   {
//     return `at ${file.path.dirNodes( d.path, 2 )}\nfound ${file.nodeCode( file.nodeSelect( file.path.dirNodes( d.path, 2 ) ) )}\n`;
//   }).join( '\n' );
//   logger.log( foundStr );
//   test.identical( _.strCount( foundStr, `found test.setsAreIdentical( rel( _.arrayFlatten( _.select( arr, '*/filePath' ) ) ), [] )` ), 1 );
//   test.identical( _.strCount( foundStr, `found test.setsAreIdentical( rel( _.mapKeys( map ) ), [] )` ), 1 );
//   test.identical( _.strCount( foundStr, `found` ), 2 );
//
//   /* */
//
//   function programRoutine()
//   {
//     var _ = require( toolsPath );
//     function r1()
//     {
//       test.setsAreIdentical( rel( _.arrayFlatten( _.select( arr, '*/filePath' ) ) ), [] );
//       _.process.on( 'exit', () =>
//       {
//         test.setsAreIdentical( rel( _.mapKeys( map ) ), [] );
//       });
//     }
//
//   }
//
// }
//
// descriptorsSearchKind.description =
// `
// xxx
// `

//

function descriptorsSearchComment( test )
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

  let foundDescriptors = file.descriptorsSearch( 'setsAreIdentical' );
  var foundStr = _.map( foundDescriptors, ( d ) =>
  {
    return `at ${d.path}\nfound ${file.descriptorToCode( d )}\n`;
  }).join( '\n' );
  logger.log( foundStr );

  test.identical( _.strCount( foundStr, `found setsAreIdentical` ), 2 );
  test.identical( _.strCount( foundStr, `found // setsAreIdentical` ), 1 );
  test.identical( _.strCount( foundStr, `found /* setsAreIdentical */` ), 1 );
  test.identical( _.strCount( foundStr, `at / ` ), 0 );
  test.identical( _.strCount( foundStr, `at ` ), 4 );

  /* */

  function programRoutine()
  {
    var _ = require( toolsPath );

    // setsAreIdentical

    function r1()
    {
      test.setsAreIdentical( rel( _.arrayFlatten( _.select( arr, '*/filePath' ) ) ), [] );
      _.process.on( 'exit', () =>
      {
        test.setsAreIdentical( rel( _.mapKeys( map ) ), [] );
      });
    }

    /* setsAreIdentical */

  }

}

descriptorsSearchComment.description =
`
find comment node
`

//

function thisFile( test )
{
  let context = this;
  let a = test.assetFor( false );
  let toolsPath = a.path.nativize( a.path.join( __dirname, '../../../Tools.s' ) );
  let programPath = a.program({ routine : program, locals : { defaultParserName : context.defaultParser.shortName, toolsPath } });

  a.jsNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'error' ), 0 );
    test.identical( _.strCount( op.output, `found : test.setsAreIdentical( rel( _.arrayFlatten( _.select( arr, '*/filePath' ) ) ), [] )` ), 1 );
    test.identical( _.strCount( op.output, `found : test.setsAreIdentical( rel( _.mapKeys( map ) ), [] )` ), 1 );
    test.identical( _.strCount( op.output, `found` ), 2 );
    return null;
  });

  return a.ready;

  /* */

  function program()
  {
    var _ = require( toolsPath );
    _.include( 'wIntrospector' );

    _.introspector.Parser.Default = _.introspector.Parser[ defaultParserName ];
    console.log( `default parser : ${_.introspector.Parser.Default.name}` );
    let file = _.introspector.thisFile().refine();
    let nodes = _.containerAdapter.from( [] );

    logger.log( file.productExportInfo() );

    file.product.nodes.each( ( node ) =>
    {
      // if( file.nodeType( node ) !== 'CallExpression' )
      // return;
      // if( file.nodeCode( node.callee ) !== 'test.setsAreIdentical' )
      // return;
      // if( node.arguments.length !== 2 )
      // return;
      if( !_.strBegins( file.nodeCode( node ), 'test.setsAreIdentical(' ) || !_.strEnds( file.nodeCode( node ), ')' ) )
      return;
      nodes.append( node );
    });

    logger.log( 'found : ' + file.nodesCodes( nodes ).join( '\nfound : ' ) );

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

thisFile.description =
`
Parsing of this file find itself.
Parsing produces AST.
Manual search for specific nodes finds 2 nodes.
`

//

function thisFileSearch( test )
{
  let context = this;
  let a = test.assetFor( false );
  let toolsPath = a.path.nativize( a.path.join( __dirname, '../../../Tools.s' ) );
  let programPath = a.program({ routine : program, locals : { defaultParserName : context.defaultParser.shortName, toolsPath } });

  a.jsNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'error' ), 0 );
    // test.identical( _.strCount( op.output, `found file.descriptorsSearch( 'setsAreIdentical' )` ), 1 );
    // test.identical( _.strCount( op.output, `found test.setsAreIdentical( rel( _.arrayFlatten( _.select( arr, '*/filePath' ) ) ), [] )` ), 1 );
    // test.identical( _.strCount( op.output, `found test.setsAreIdentical( rel( _.mapKeys( map ) ), [] )` ), 1 );
    test.identical( _.strCount( op.output, `found 'setsAreIdentical'` ), 1 );
    // test.identical( _.strCount( op.output, `found setsAreIdentical` ), 2 );
    test.identical( _.strCount( op.output, `at / ` ), 0 );
    test.identical( _.strCount( op.output, `at ` ), 3 );
    return null;
  });

  return a.ready;

  function program()
  {
    var _ = require( toolsPath );
    _.include( 'wIntrospector' );

    _.introspector.Parser.Default = _.introspector.Parser[ defaultParserName ];
    console.log( `default parser : ${_.introspector.Parser.Default.name}` );
    let file = _.introspector.thisFile().refine();
    let nodes = _.containerAdapter.from( [] );

    logger.log( file.productExportInfo() );

    let foundMap = file.descriptorsSearch( 'setsAreIdentical' );
    let found = foundMap.map( ( d ) => d.path );

    // found.forEach( ( path ) =>
    // {
    //   logger.log( `at ${path}\nfound ${file.nodeCode( file.path.dirClosest( path, 2 ) )}\n` );
    //   logger.log( '' );
    // });

    found.forEach( ( path ) =>
    {
      logger.log( `at ${path}\nfound ${file.nodeCode( file.path.dirClosest( path, 0 ) )}\n` );
      logger.log( '' );
    });

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

thisFileSearch.description =
`
Routine nodesSearch finds 4 elements.
`

//

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

  name : 'Tools.mid.Introspector.Js',
  abstract : 1,

  context :
  {

    programWithCommentsAndRoutines,
    defaultProgram,
    defaultProgramSourceCode,

  },

  tests :
  {

    fromData,
    descriptorsSearch,
    // descriptorsSearchKind,
    descriptorsSearchComment,

    thisFile,
    thisFileSearch,

    parseStringCommon,

  },

}

//

var Self = new wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
