( function _JsUglify_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  _global_.UglifyEs = require( 'uglify-es' );

}

//

let _ = _global_.wTools;
let Parent = _.introspector.Parser;
let Self = function wIntrospectionParserJsUglify( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'JsUglify';

// --
// inter
// --

function _form()
{
  let parser = this;
  let sys = parser.sys;
  if( !parser._parser )
  parser._parser = _global_.UglifyEs;
}

//

function _parse( o )
{
  let parser = this;
  _.assertRoutineOptions( _parse, arguments );

  let opts = {};
  // opts.comments = true;
  // opts.comments = true;
  let result = Object.create( null );
  if( o.filePath )
  result.filename = o.filePath;
  // debugger;
  result.returned = parser._parser.parse( o.src, opts );
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
  if( !_.objectIs( node ) )
  return false;
  if( !node.TYPE )
  return false;
  if( !( node instanceof parser._parser.AST_Node ) && !( node instanceof parser._parser.AST_Token ) )
  {
    return false; 
  }
  return true;
}

//

function _nodeRange( node )
{
  let parser = this;

  _.assert( arguments.length === 1 );
  _.assert( parser.nodeIs( node ) );

  if( node.start )
  {
    _.assert( !!node.start );
    let end;
    /* not all nodes of js uglify AST has end postion */
    if( node.end == undefined )
    end = node.start.endpos;
    else
    end = node.end.endpos;
    return [ node.start.pos, end ];
  }
  else
  {
    _.assert( node.pos !== undefined && node.endpos !== undefined );
    return [ node.pos, node.endpos ];
  }

}

//

function _nodeType( node )
{
  let parser = this;
  return node.TYPE;
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
let Schema = _.schema.system({ name : 'Js.UglifyAst' });
Schema.define([ 'Arrow', 'Function', 'Defun', 'ConciseMethod' ]).label( native ).terminal();
Schema.define( 'gRoutine' ).label( general ).alternative([ 'Arrow', 'Function', 'Defun', 'ConciseMethod' ]);
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
  _nodeRange,
  _nodeType,

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
