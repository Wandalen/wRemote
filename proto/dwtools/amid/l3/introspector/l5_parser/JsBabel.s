( function _JsBabel_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  _global_.Babel = require( '@babel/core' );

}

//

let _ = _global_.wTools;
let Parent = _.introspector.Parser;
let Self = function wIntrospectionParserJsBabel( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'JsBabel';

// --
// inter
// --

function _form()
{
  let parser = this;
  let sys = parser.sys;
  if( !parser._parser )
  parser._parser = _global_.Babel;
}

//

function _parse( o )
{
  let parser = this;
  _.assertRoutineOptions( _parse, arguments );

  let opts = Object.create( null );
  opts.comments = true;
  let result = Object.create( null );
  result.returned = parser._parser.parse( o.src, opts );
  result.root = result.returned;

  return result;
}

_parse.defaults = _.mapExtend( null, Parent.prototype.parse.defaults );

//

function _nodeIs( node )
{
  let parser = this;
  let result = parser._parser.types.isNode( node );
  if( result )
  return result;
  /*
  _parser.types.isNode gives false for comment nodes
  */
  if( _.objectIs( node ) && _.strIs( node.type ) )
  return true;
  return result;
}

//

function _nodeRange( node )
{
  let parser = this;

  _.assert( arguments.length === 1 );
  _.assert( parser.nodeIs( node ) );

  return [ node.start, node.end ];
}

//

function _nodeType( node )
{
  let parser = this;
  return node.type;
}

// --
// meta
// --

function _Setup()
{
  let parser = this;

  parser._TypeAssociationsFromSchema();

  // xxx
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
let Schema = _.schema.system({ name : 'Js.BabelAst' });
Schema.define([ 'FunctionDeclaration', 'FunctionExpression', 'ArrowFunctionExpression', 'ClassMethod' ]).label( native ).terminal();
Schema.define( 'gRoutine' ).label( general ).alternative([ 'FunctionDeclaration', 'FunctionExpression', 'ArrowFunctionExpression', 'ClassMethod' ]);
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
