( function _Repo_s_( ) {

'use strict';

//

let _ = _global_.wTools;
let Parent = null;
let Self = function wRepo( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Repo';

// --
// inter
// --

function init( o )
{
  let repo = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.workpiece.initFields( repo );
  Object.preventExtensions( repo );

  if( o )
  repo.copy( o );

  /* */

  _.sure( _.strDefined( repo.name ) && repo.name[ 0 ] === '.', `Expects name of repositroy {- name -} which begins with dot, but got ${repo.name}` );

}

//

function close()
{
  let repo = this;

  repo.finit();
}

//

function _collection( o )
{
  let repo = this;

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.name ) );

  return _.persistent.Collection
  ({
    repo : repo,
    name : o.name,
    kind : o.kind,
  });
}

//

function collection( collectionName )
{
  let repo = this;

  _.assert( arguments.length === 1 );

  return repo._collection({ name : collectionName });
}

//

function array( collectionName )
{
  let repo = this;

  _.assert( arguments.length === 1 );

  return repo._collection({ name : collectionName, kind : 'array' });
}

//

function map( collectionName )
{
  let repo = this;

  _.assert( arguments.length === 1 );

  return repo._collection({ name : collectionName, kind : 'map' });
}

//

function collectionsNames()
{
  let repo = this;
  let result = _.fileProvider.dirRead( repo.filePathGet() );
  if( !result )
  return [];
  return result;
}

//

function filePathGet()
{
  let repo = this;
  let path = _.fileProvider.path;
  let filePath = path.join( path.dirUserHome(), repo.name );
  return filePath;
}

//

function filePathFor( collectionName )
{
  let repo = this;
  let path = _.fileProvider.path;

  _.assert( _.strIs( collectionName ) );
  _.assert( !_.strHas( collectionName, '/' ) );
  _.assert( arguments.length === 1 );

  let filePath = path.join( path.dirUserHome(), repo.name, collectionName );
  return filePath;
}

// --
// manipulator
// --

function _fileRead( selector )
{
  let repo = this;
  let result = Object.create( null );

  result.selector = selector || '/';

  _.assert( arguments.length === 0 || arguments.length === 1 );

  let selectorArray = _.path.split( result.selector );
  if( !selectorArray[ 0 ] )
  selectorArray.splice( 0, 1 );
  result.selector1 = selectorArray[ 0 ];
  result.selector2 = selectorArray.slice( 1 ).join( '/' );
  result.filePath = repo.filePathFor( result.selector1 );

  if( result.selector1 === '' )
  {
    result.structure = Object.create( null );
    let names = repo.collectionsNames();
    names.forEach( ( name ) => result.structure[ name ] = repo.read( `/${name}` ) );
    return result;
  }

  if( !_.fileProvider.isTerminal( result.filePath ) )
  {
    return result;
  }

  result.structure = _.fileProvider.fileRead({ filePath : result.filePath, encoding : 'json' });

  return result;
}

//

function read( selector )
{
  let repo = this;
  let result = repo._fileRead( selector );

  if( result.structure === undefined )
  return result.structure;

  if( !result.selector2 || result.selector2 === '/' )
  return result.structure;
  else
  return _.select( result.structure, result.selector2 );

}

//

function write( selector, structure )
{
  let repo = this;
  let read = repo._fileRead( selector );

  _.assert( arguments.length === 2 );

  if( !read.selector1 )
  {
    _.assert( _.mapIs( structure ), 'Should be map here' );
    for( let s in structure )
    repo.write( _.path.join( selector, s ), structure[ s ] );
    return;
  }

  if( !read.selector2 || read.selector2 === '/' || read.selector2 === '.' )
  {
    read.structure = structure;
  }
  else if( read.selector2  )
  {
    if( read.structure === undefined )
    read.structure = Object.create( null );
    _.selectSet({ src : read.structure, selector : read.selector2, set : structure });
  }

  if( _.fileProvider.isDir( read.filePath ) )
  throw _.err( `${read.filePath} is directory, cant overwrite!` );
  _.fileProvider.fileWrite( read.filePath, _.toJson( read.structure ) );

}

//

function insert( selector, structure )
{
  let repo = this;
  let read = repo._fileRead( selector );


  if( read.structure === undefined )
  read.structure = Object.create( null );

  if( read.selector2 )
  _.selectSet
  ({
    src : read.structure,
    selector : read.selector2,
    set : structure,
  })
  else
  read.structure = structure;

  repo.write( read.selector1, read.structure );
  return read;
}

//

function _pend( selector, structure, appending )
{
  let repo = this;
  let read = repo._fileRead( selector );
  let selected;

  if( read.selector2 )
  {
    if( read.structure !== undefined )
    selected = _.select
    ({
      src : read.structure,
      selector : read.selector2,
    })
  }

  if( read.structure === undefined )
  read.structure = Object.create( null );

  if( !selected )
  {
    selected = [];
    if( read.selector2 )
    _.selectSet
    ({
      src : read.structure,
      selector : read.selector2,
      set : selected,
    })
    else
    read.structure = selected;
  }

  if( appending )
  selected.push( structure )
  else
  selected.unshift( structure )
  repo.write( read.selector1, read.structure );
}

//

function append( selector, structure )
{
  let repo = this;
  return repo._pend( selector, structure, 1 );
}

//

function prepend( selector, structure )
{
  let repo = this;
  return repo._pend( selector, structure, 0 );
}

//

/* qqq : please cover routines delete and deleteStrict. check returned value and throwing cases */

function delete_pre( routine, args )
{
  let repo = this;

  if( _.strIs( args[ 0 ] ) )
  {
    args = [ { selector : args[ 0 ] } ]
  }

  _.assert( args.length === 1 );
  _.routineOptions( routine, args );

  let o = args[ 0 ];

  if( o.selector === undefined )
  o.selector = '/';
  if( o.selector === '' )
  o.selector = '/';

  return o;
}

function delete_body( o )
{
  let repo = this;

  _.assertRoutineOptions( delete_body, arguments );

  if( o.selector === '/' )
  {
    return repo.clean({ strict : o.strict });
  }

  let read = repo._fileRead( o.selector );

  if( !read.selector2 )
  {
    if( !_.fileProvider.isTerminal( read.filePath ) )
    {
      if( o.strict )
      throw _.err( `Does not exist ${o.selector}` );
      return false;
    }
    _.fileProvider.fileDelete( read.filePath );
  }
  else
  {
    _.selectSet
    ({
      src : read.structure,
      selector : read.selector2,
      set : undefined,
      missingAction : o.strict ? 'throw' : 'undefine',
    });
    _.fileProvider.fileWrite( read.filePath, _.toJson( read.structure ) );
  }

  return true;
}

delete_body.defaults =
{
  selector : null,
  strict : 0,
}

//

let delete_ = _.routineFromPreAndBody( delete_pre, delete_body, 'delete' );
delete_.defaults.strict = 0;

let deleteStrict = _.routineFromPreAndBody( delete_pre, delete_body, 'deleteStrict' );
deleteStrict.defaults.strict = 1;

//

function clean( o )
{
  let repo = this;
  let path = _.fileProvider.path;
  let filePath = repo.filePathGet();

  o = _.routineOptions( clean, arguments );

  _.fileProvider.filesDelete({ filePath, mandatory : o.strict });

  return repo;
}

clean.defaults =
{
  strict : 0,
}

//

function exists()
{
  let repo = this;
  let path = _.fileProvider.path;
  let filePath = repo.filePathGet();

  return _.fileProvider.isDir( filePath );
}

// --
// exporter
// --

function exportStructure( o )
{
  let resource = this;

  o = _.routineOptions( exportStructure, arguments );

  if( o.src === null )
  o.src = resource;

  o.dst = o.src.read( '/' );

  return o.dst;
}

exportStructure.defaults =
{
  ... _.workpiece.exportStructure.defaults,
}

//

function exportInfo( o )
{
  let resource = this;
  return _.workpiece.exportInfo( resource, ... arguments );
}

exportInfo.defaults =
{
  ... _.workpiece.exportInfo.defaults,
}

// --
// relations
// --

let Composes =
{
  name : null,
}

let Aggregates =
{
}

let Associates =
{
}

let Restricts =
{
}

let Statics =
{
}

let Forbids =
{
  structure : 'structure',
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

  init,
  close,

  //

  _collection,
  collection,
  array,
  map,
  collectionsNames,
  // structureGet,
  filePathGet,
  filePathFor,

  // manipulator

  _fileRead,
  read, /* qqq : check coverage */
  write, /* qqq : check coverage */
  insert, /* qqq : check coverage */
  _pend,
  append, /* qqq : check coverage */
  prepend, /* qqq : check coverage */
  delete : delete_, /* qqq : check coverage */
  deleteStrict, /* qqq : check coverage */

  clean, /* qqq : check coverage */
  exists, /* qqq : check coverage */

  // exporter

  exportStructure,
  exportInfo,

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

// --
// export
// --

_.persistent[ Self.shortName ] = Self;
if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _global_.wTools;

})();
