( function _TsMicrosoft_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  _global_.TsParser = require( 'typescript' );

}

//

let _ = _global_.wTools;
let Parent = _.introspector.Parser;
let Self = function wIntrospectionParserTsMicrosoft( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'TsMicrosoft';

// --
// inter
// --

function _form()
{
  let parser = this;
  let sys = parser.sys;
  if( !parser._parser )
  parser._parser = _global_.TsParser;
}

//

function _parse( o )
{
  let parser = this;
  _.assertRoutineOptions( _parse, arguments );

  let opts = Object.create( null );
  let result = Object.create( null );
  // debugger;
  result.returned = parser._parser.createSourceFile( o.filePath || '', o.src );
  result.root = result.returned;
  // debugger;

  return result;
}

_parse.defaults = _.mapExtend( null, Parent.prototype.parse.defaults );

//

function _nodeIs( node )
{
  let parser = this;
  if( !node )
  return false;
  return parser._parser.isNode( node );
}

//

function _nodeRange( node )
{
  let parser = this;
  _.assert( arguments.length === 1 );
  _.assert( parser.nodeIs( node ) );
  debugger;
  return [ node.pos, node.end ];
}

//

function _nodeType( node )
{
  let parser = this;
  return parser._parser.SyntaxKind[ node.kind ];
}

// --
// meta
// --

function _Setup()
{
  let parser = this;

  parser._TypeAssociationsFromSchema();

  // _.mapKeys( _global_.Esprima.Syntax ).forEach( ( name ) =>
  // {
  //   parser.TypeAssociation[ name ] = [ name ];
  // });

  parser._TypeAssociationsNormalize();

}

// --
// relations
// --

let TypeAssociation = Object.create( null );

var native = { native : true };
var general = { native : false, general : true };
let Schema = _.schema.system({ name : 'Ts.MicrosoftAst' });
Schema.define([ 'FunctionDeclaration', 'MethodDeclaration', 'Constructor', 'FunctionExpression', 'ArrowFunction' ]).label( native ).terminal();
Schema.define( 'gRoutine' ).label( general ).alternative([ 'FunctionDeclaration', 'MethodDeclaration', 'Constructor', 'FunctionExpression', 'ArrowFunction' ]);
Schema.form();

let Composes =
{
}

let Aggregates =
{
}

let Associates =
{
  sys : null,
  _parser : null,
}

let Restricts =
{
  formed : 0,
}

let Statics =
{

  _Setup,

  Schema,
  TypeAssociation,

}

let Forbids =
{
}

let Accessors =
{
}

// --
// declare
// --

let Proto =
{

  // inter

  _form,
  _parse,
  _nodeIs,
  _nodeType,
  _nodeRange,

  // meta

  _Setup,

  // relation

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,
  Forbids,
  Accessors,

}

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

Self._Setup();

_.introspector.Parser[ Self.shortName ] = Self;

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _global_.wTools;

})();
