( function _JsAcorn_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  _global_.Acorn = require( 'acorn' );

}

//

let _ = _global_.wTools;
let Parent = _.introspector.Parser;
let Self = function wIntrospectionParserJsAcorn( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'JsAcorn';

// --
// inter
// --

function _form()
{
  let parser = this;
  let sys = parser.sys;
  if( !parser._parser )
  parser._parser = _global_.Acorn;
}

//

function _parse( o )
{
  let parser = this;
  _.assertRoutineOptions( _parse, arguments );

  let opts = Object.create( null );
  opts.onComment = [];
  let result = Object.create( null );
  result.returned = parser._parser.parse( o.src, opts );
  result.root = result.returned;
  result.comments = opts.onComment;
  result.root.comments = result.comments;

  return result;
}

_parse.defaults = _.mapExtend( null, Parent.prototype.parse.defaults );

//

function _nodeIs( node )
{
  let parser = this;
  let result = node instanceof parser._parser.Node;
  if( result )
  return result;
  /*
  comment node is not instance of `parser._parser.Node`
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
let Schema = _.schema.system({ name : 'Js.AcornAst' });
Schema.define([ 'FunctionDeclaration', 'FunctionExpression', 'ArrowFunctionExpression' ]).label( native ).terminal();
Schema.define( 'gRoutine' ).label( general ).alternative([ 'FunctionDeclaration', 'FunctionExpression', 'ArrowFunctionExpression' ]);
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
