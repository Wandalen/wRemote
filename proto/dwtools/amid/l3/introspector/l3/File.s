( function _File_s_( ) {

'use strict';

//

let _ = _global_.wTools;
let vectorize = _.routineDefaults( null, _.vectorize, { vectorizingContainerAdapter : 1, unwrapingContainerAdapter : 0 } );
let vectorizeAll = _.routineDefaults( null, _.vectorizeAll, { vectorizingContainerAdapter : 1, unwrapingContainerAdapter : 0 } );
let vectorizeAny = _.routineDefaults( null, _.vectorizeAny, { vectorizingContainerAdapter : 1, unwrapingContainerAdapter : 0 } );
let vectorizeNone = _.routineDefaults( null, _.vectorizeNone, { vectorizingContainerAdapter : 1, unwrapingContainerAdapter : 0 } );

//

let Parent = null;
let Self = function wIntrospectionFile( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'File';

// --
// inter
// --

function FromData( dataStr )
{
  let cls = this.Self;
  let file = new cls();
  file.readBegin();
  file.data = dataStr;
  file.readEnd();
  return file;
}

//

function init( o )
{
  let file = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  _.workpiece.initFields( file );
  Object.preventExtensions( file );

  if( o )
  file.copy( o );

  file.form();
}

//

function unform()
{
  let file = this;
  let sys = file.sys;

  if( !file.formed )
  return file;

  _.arrayRemoveOnce( sys.filesArray, file )

  file.formed = 1;
  return file;
}

// --
// perform
// --

function form()
{
  let file = this;

  if( file.formed )
  return file;

  if( !file.sys )
  file.sys = new _.introspector.System();
  if( !file.sys.formed )
  file.sys.form();

  let sys = file.sys;
  _.assert( sys instanceof _.introspector.System );

  _.arrayAppendOnce( sys.filesArray, file )

  file.path = Object.create( _.introspector._path );
  file.path.file = file;
  file.path.Init();

  file.formed = 1;
  return file;
}

//

function read()
{
  let file = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );

  if( file.dataFormed )
  return file;

  return file.reread();
}

//

function reread()
{
  let file = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );

  file.dataFormed = 0;

  if( file.formed === 0 )
  file.form();

  let sys = file.sys;
  let fs = sys.fileSystem;
  let path = fs.path;

  file.readBegin();

  file.data = fs.fileRead( file.filePath );

  file.readEnd();

  _.assert( file.dataFormed === 1 );
  return file;
}

//

function readBegin()
{
  let file = this;
  _.assert( file.dataFormed === 0 );
  return file;
}

//

function readEnd()
{
  let file = this;

  _.assert( file.dataFormed === 0 );

  if( _.routineIs( file.data ) )
  file.data = file.data.toString();

  file.dataFormed = 1;

  _.assert( _.strIs( file.data ) );

  return file;
}

//

function parse()
{
  let file = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );

  if( file.structure )
  return file;

  return file.reparse();
}

//

function reparse()
{
  let file = this;
  let sys = file.sys;

  if( file.data === null )
  file.read();

  file.parser = sys.parserClassFor( file )({ sys }).form();
  file.structure = file.parser.parse( file.data );

  return file;
}

//

function fine()
{
  let file = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );

  if( file.product )
  return file;

  return file.refine();
}

//

function refine()
{
  let file = this;

  if( file.structure === null )
  file.parse();

  let sys = file.sys;
  let parser = file.parser;
  let product = file.product = Object.create( null );
  product.root = null;
  product.nodes = _.containerAdapter.from( new Set );
  product.nodeToDescriptorHashMap = new HashMap;
  product.byType = Object.create( null );

  let o2 = Object.create( null );
  o2.iterationExtension = o2.iterationExtension || Object.create( null );
  o2.iterationExtension.srcAsContainer = null;
  o2.src = file.structure.root;
  o2.onUp = onUp;
  o2.onDown = onDown;
  o2.onPathJoin = onPathJoin;

  _.look( o2 );

  return file;

  /* */

  function onPathJoin( selectorPath, upToken, defaultUpToken, selectorName )
  {
    let it = this;
    return file._iterationPathJoin( it, ... arguments );
  }

  function onUp( node, k, it )
  {
    if( !file.nodeIs( node ) )
    return;
    nodeConsider( node, it );
    file._iterationUpNodesMap( it );
  }

  function onDown( src, k, it )
  {
  }

  function descriptorMake( node, it )
  {

    let descriptor = file.descriptorFromIteration( it );

    // let descriptor = product.nodeToDescriptorHashMap.get( node );
    // if( !descriptor )
    // {
    //   descriptor = Object.create( null );
    //   product.nodeToDescriptorHashMap.set( node, descriptor );
    // }
    // descriptor.node = node;
    // descriptor.iterations = descriptor.iterations || [];
    // descriptor.iterations.push( it );
    // descriptor.iteration = descriptor.iteration || it;
    // descriptor.path = descriptor.path || it.path;
    // descriptor.down = null;
    // if( it.down )
    // {
    //   it = it.down;
    //   while( it.down && !file.nodeIs( it.src ) )
    //   it = it.down;
    //   if( file.nodeIs( it.src ) )
    //   {
    //     let downDescriptor = product.nodeToDescriptorHashMap.get( it.src );
    //     _.assert( file.descriptorIs( downDescriptor ) );
    //     descriptor.down = downDescriptor;
    //   }
    // }

  }

  function nodeConsider( node, it )
  {
    let type1 = parser.nodeType( node );
    _.assert( _.strIs( type1 ) );

    if( !product.nodes.length )
    product.root = node;
    product.nodes.append( node );

    descriptorMake( node, it );

    let nodes = product.byType[ type1 ];
    if( !nodes )
    nodes = product.byType[ type1 ] = _.containerAdapter.from( new Set );
    nodes.appendOnce( node );

    // if( _.longHas( [ 'FunctionDeclaration', 'FunctionExpression', 'ArrowFunctionExpression' ], type1 ) )
    // {
    //   debugger;
    // }

    let association = parser.TypeAssociation[ type1 ];
    if( association )
    for( let a = 0 ; a < association.length ; a++ )
    {
      let type2 = association[ a ];
      if( type1 === type2 )
      continue;
      let nodes = product.byType[ type2 ];
      if( !nodes )
      nodes = product.byType[ type2 ] = _.containerAdapter.from( new Set );
      nodes.appendOnce( node );
    }

  }

}

// --
// node
// --

function _iterationUpNodesMapAndFields( it )
{
  let file = this;
  let parser = file.parser;
  let node = it.src;

  _.assert( file.nodeIs( node ), 'Not a node' );
  _.assert( arguments.length === 1 );
  _.assert( it.srcAsContainer !== undefined );

  if( it.srcAsContainer === null )
  {
    it.srcAsContainer = parser.nodeChildrenMapGet( node );
    it.srcAsContainer[ '@code' ] = file.nodeCode( node );
  }

  it.iterable = 'Node';
  it.ascendAct = function nodeAscend( node )
  {
    let it = this;

    _.assert( file.nodeIs( node ), 'Not a node' );
    _.assert( it.srcAsContainer !== undefined );

    // it.srcAsContainer = parser.nodeChildrenMapGet( node );
    // _.mapExtend( map, parser.nodeMapGet( node ) );
    // return this._mapAscend( map );

    return this._mapAscend( it.srcAsContainer );
  }

  it.revisitedEval( it.src );

}

//

function _iterationUpNodesMap( it )
{
  let file = this;
  let parser = file.parser;
  let node = it.src;

  _.assert( file.nodeIs( node ), 'Not a node' );
  _.assert( arguments.length === 1 );
  _.assert( it.srcAsContainer !== undefined );

  if( it.srcAsContainer === null )
  {
    it.srcAsContainer = parser.nodeChildrenMapGet( node );
  }

  it.iterable = 'Node';
  it.ascendAct = function nodeAscend( node )
  {
    let it = this;
    _.assert( file.nodeIs( node ), 'Not a node' );
    _.assert( it.srcAsContainer !== undefined );
    return this._mapAscend( it.srcAsContainer );
    // let map = parser.nodeChildrenMapGet( node );
    // return this._mapAscend( map );
  }

  it.revisitedEval( it.src );

}

//

function _iterationUpNodesArray( it )
{
  let file = this;
  let parser = file.parser;
  let node = it.src;

  _.assert( file.nodeIs( node ), 'Not a node' );
  _.assert( it.srcAsContainer !== undefined );

  it.iterable = 'Node';
  it.ascendAct = function nodeAscend( node )
  {
    let it = this;
    _.assert( file.nodeIs( node ), 'Not a node' );
    _.assert( it.srcAsContainer !== undefined );
    return this._arrayAscend( it.srcAsContainer );
    // let map = file._nodeChildrenArrayGet( node );
    // return this._arrayAscend( map );
  }

  it.revisitedEval( it.src );

}

//

function _iterationPathJoin( it, selectorPath, upToken, defaultUpToken, selectorName )
{
  let file = this;
  let parser = file.parser;
  let result;

  _.assert( arguments.length === 5 );

  if( file.nodeIs( it.src ) )
  selectorName = `${file.nodeType( it.src )}::${selectorName}`

  if( _.strEnds( selectorPath, upToken ) )
  {
    result = selectorPath + selectorName;
  }
  else
  {
    result = selectorPath + defaultUpToken + selectorName;
  }

  return result;
}

//

function nodeSelect( node, path )
{
  let file = this;
  let sys = file.sys;

  if( _.strIs( arguments[ 0 ] ) )
  {
    node = null;
    path = arguments[ 0 ];
    _.assert( arguments.length === 1 );
  }
  else
  {
    _.assert( arguments.length === 2 );
  }

  if( node === null )
  node = file.product.root;

  _.assert( _.strIs( path ) );
  _.assert( file.nodeIs( node ), 'Not a node' );

  let result = _.select
  ({
    src : node,
    selector : path,
    onSelectorUndecorate,
  });

  return result;

  function onSelectorUndecorate()
  {
    let it = this;
    if( !_.strIs( it.selector ) )
    return;
    if( !_.strHas( it.selector, '::' ) )
    return;
    it.selector = _.strIsolateRightOrAll( it.selector, '::' )[ 2 ];
  }

}

//

function nodeIs( node )
{
  let file = this;
  let parser = file.parser;
  return parser.nodeIs( node );
}

//

function nodeType( node )
{
  let file = this;
  let parser = file.parser;
  let result = parser.nodeType( node );
  return result;
}

//

function nodePath( node )
{
  let file = this;
  let parser = file.parser;
  let descriptor = file.nodeDescriptor( node );
  return descriptor.path;
}

//

function nodeCode( node )
{
  let file = this;
  let sys = file.sys;
  let parser = file.parser;

  _.assert( arguments.length === 1 );

  if( _.strIs( node ) )
  node = file.nodeSelect( node );

  _.assert( file.nodeIs( node ), 'Not a node' );

  let result = parser.nodeCode( node, file.data );

  return result;
}

//

function nodeDescriptor( node )
{
  let file = this;
  let product = file.product;
  _.assert( file.nodeIs( node ), 'Not a node' );
  let descriptor = product.nodeToDescriptorHashMap.get( node );
  _.assert( file.descriptorIs( descriptor ) );
  return descriptor;
}

//

function search_pre( routine, args )
{
  let file = this;
  let product = file.product;
  let o = args[ 0 ];

  if( !_.mapIs( o ) )
  {
    o = Object.create( null );
    if( file.nodeIs( args[ 0 ] ) )
    {
      o.src = args[ 0 ];
      o.ins = args[ 1 ];
      debugger;
    }
    else
    {
      o.ins = args[ 0 ];
    }
  }

  o = _.routineOptions( routine, o );

  if( o.src === null )
  o.src = file.product.root;

  _.assert( file.nodeIs( o.src ) );
  _.assert( _.strIs( o.ins ) || _.numberIs( o.ins ) );
  _.assert( arguments.length === 2 );

  return o;
}

function search_body( o )
{
  let file = this;
  let parser = file.parser;
  let product = file.product;

  _.assert( arguments.length === 1 );

  let onUp0 = o.onUp;
  o.onUp = onUp1;
  o.onPathJoin = onPathJoin;
  o.returning = 'it';
  o.order = 'top-to-bottom';
  o.iterationExtension = o.iterationExtension || Object.create( null );
  o.iterationExtension.srcAsContainer = null;
  o.onValueForCompare = onValueForCompare;

  let found = _.entitySearch( o );

  return found;

  function onPathJoin( selectorPath, upToken, defaultUpToken, selectorName )
  {
    let it = this;
    return file._iterationPathJoin( it, ... arguments );
  }

  function onUp1( node, k, it )
  {

    if( k === '@code' )
    if( it.down.added )
    it.continue = false;

    // logger.log( `onUp1 ${it.path}` );

    if( !file.nodeIs( node ) )
    return;

    file._iterationUpNodesMapAndFields( it );

    if( onUp0 )
    return onUp0.apply( this, arguments );
  }

  function onValueForCompare( e )
  {
    let it = this;
    _.assert( it.srcAsContainer !== undefined );
    if( it.srcAsContainer !== null )
    return it.srcAsContainer;
    return e;
  }

}

search_body.defaults =
{
  ... _.mapExtend( null, _.entitySearch.defaults ),
  returning : 'it',
}

delete search_body.defaults.Looker;

let search = _.routineFromPreAndBody( search_pre, search_body );

//

function nodesSearch_body( o )
{
  let file = this;
  let parser = file.parser;
  let product = file.product;

  _.assertRoutineOptions( nodesSearch_body, arguments );

  let its = file.search.body.call( file, o );

  let nodesMap = Object.create( null );
  _.each( its, ( it ) =>
  {
    let path = it.path;
    while( it.down && !file.nodeIs( it.src ) )
    it = it.down;
    nodesMap[ it.path ] = it.src;
  })

  _.assert( _.mapIs( nodesMap ) );

  return nodesMap;
}

_.routineExtend( nodesSearch_body, search.body );

let nodesSearch = _.routineFromPreAndBody( search_pre, nodesSearch_body );

// --
// descriptor
// --

function descriptorIs( descriptor )
{
  if( !descriptor )
  return false;
  return descriptor instanceof _.introspector.NodeDescriptor;
  // if( !_.mapIs( descriptor ) )
  // return false;
  // return descriptor.node !== undefined && descriptor.path !== undefined;
}

//

function descriptorFromIteration( it )
{
  let file = this;
  let product = file.product;
  let node = it.src;

  _.assert( file.nodeIs( node ) );

  let descriptor = product.nodeToDescriptorHashMap.get( node );
  if( !descriptor )
  {
    descriptor = new _.introspector.NodeDescriptor({ iteration : it, file : file });
    // descriptor = Object.create( null );
    // product.nodeToDescriptorHashMap.set( node, descriptor );
  }

  // descriptor.node = node;
  // descriptor.iterations = descriptor.iterations || [];
  // descriptor.iterations.push( it );
  // descriptor.iteration = descriptor.iteration || it;
  // descriptor.path = descriptor.path || it.path;
  // descriptor.down = null;
  // if( it.down )
  // {
  //   it = it.down;
  //   while( it.down && !file.nodeIs( it.src ) )
  //   it = it.down;
  //   if( file.nodeIs( it.src ) )
  //   {
  //     let downDescriptor = product.nodeToDescriptorHashMap.get( it.src );
  //     _.assert( file.descriptorIs( downDescriptor ) );
  //     descriptor.down = downDescriptor;
  //   }
  // }

  _.assert( descriptor instanceof _.introspector.NodeDescriptor );

  return descriptor;
}

//

function descriptorToNode( descriptor )
{
  let file = this;
  let product = file.product;

  _.assert( file.descriptorIs( descriptor ) );

  let node = descriptor.node;

  _.assert( file.nodeIs( node ), 'Not a node' );

  return node;
}

//

function descriptorToCode( descriptor )
{
  let file = this;
  let product = file.product;
  let node = file.descriptorToNode( descriptor );
  return file.nodeCode( node );
}

//

function descriptorsSearch_body( o )
{
  let file = this;
  let product = file.product;

  _.assertRoutineOptions( descriptorsSearch_body, arguments );

  let nodes = file.nodesSearch( ... arguments );
  nodes = _.mapVals( nodes );

  let visited = new Set();
  let descriptors = [];
  _.each( nodes, ( node ) =>
  {
    if( visited.has( node ) )
    return;
    visited.add( node );
    descriptors.push( file.nodeDescriptor( node ) );
  })

  return descriptors;
}

_.routineExtend( descriptorsSearch_body, search.body );

let descriptorsSearch = _.routineFromPreAndBody( search_pre, descriptorsSearch_body );

// --
// product
// --

function productExportInfo( o )
{
  let file = this;
  let product = file.product;
  let result = '';

  o = _.routineOptions( productExportInfo, arguments );

  result += `File ${file.filePath}\n`;

  if( !product )
  return result;

  if( o.verbosity >= 2 )
  {
    result += `  nodes : ${product.nodes.length}\n`;
    result += `  types : ${_.mapKeys( product.byType ).length}\n`;

    if( o.verbosity >= 3 )
    result += `  types : ${_.mapKeys( product.byType ).join( ' ' )}\n`;

    result += '\n';
  }

  if( o.verbosity >= 4 )
  {
    let types = _.mapKeys( product.byType );
    types = types.map( ( k ) => [ k, product.byType[ k ].length ] );
    types = types.sort( ( a, b ) => a[ 1 ] - b[ 1 ] );
    types.forEach( ( pair ) =>
    {
      result += `  ${pair[ 0 ]} : ${pair[ 1 ]}\n`;
    });
  }

  return result;
}

productExportInfo.defaults =
{
  verbosity : 9,
}

// --
// relations
// --

let Composes =
{
  filePath : null,
}

let Aggregates =
{
  data : null,
  structure : null,
  product : null,
}

let Associates =
{
  sys : null,
  parser : null,
}

let Restricts =
{
  formed : 0,
  dataFormed : 0,
  path : null,
}

let Statics =
{
  FromData,
}

let Forbids =
{
  _nodeChildrenMapGet : '_nodeChildrenMapGet',
  _nodeMapGet : '_nodeMapGet',
}

let Accessors =
{
}

// --
// define class
// --

let Proto =
{

  // inter

  FromData,
  init,

  // perform

  form,

  read,
  reread,
  readBegin,
  readEnd,

  parse,
  reparse,
  fine,
  refine,

  // node

  _iterationUpNodesMapAndFields,
  _iterationUpNodesMap,
  _iterationUpNodesArray,
  _iterationPathJoin,

  nodeSelect,

  nodeIs,
  nodePath,
  nodesPaths : vectorize( nodePath ),
  nodeType,
  nodesTypes : vectorize( nodeType ),
  nodeCode,
  nodesCodes : vectorize( nodeCode ),
  nodeDescriptor,
  nodesDescriptors : vectorize( nodeDescriptor ),

  search,
  nodesSearch,

  // descriptor

  descriptorIs,
  descriptorFromIteration,
  descriptorToNode,
  descriptorsToNodes : vectorize( descriptorToNode ),
  descriptorToCode,
  descriptorsToCodes : vectorize( descriptorToCode ),
  descriptorsSearch,

  // product

  productExportInfo,

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

_.Copyable.mixin( Self );
_.introspector[ Self.shortName ] = Self;
if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _global_.wTools;

})();
