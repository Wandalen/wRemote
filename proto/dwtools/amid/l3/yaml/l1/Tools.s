( function _Tools_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../IncludeBase.s' );

}

let _ = _global_.wTools;
let Self = _.yaml = _.yaml || Object.create( null );
let Yaml,YamlTypes;

// --
// inter
// --

function lineFind( src, ins )
{

  let r = Object.create( null );
  r.regexp = new RegExp( '\\n(((?!\\n)\\s)*)(' + _.regexpEscape( ins ) + ')(.*?)\\n' );
  let match = src.match( r.regexp );

  if( !match )
  return null;

  r.line = match[ 0 ].replace( '\n', '' ).replace( '\n', '' );
  r.pre = match[ 1 ];
  r.before = src.substring( 0, match.index );
  r.after = src.substring( match.index + match[ 0 ].length );

  return r;
}

//

function commentOut( content, name )
{
  let regexp = new RegExp( '\\n(((?!\\n)\\s)*)(' + _.regexpEscape( name ) + ')(\\s*:.*?)\\n' );

  let match = content.match( regexp );
  if( !match )
  return false;

  let before = content.substring( 0, match.index );
  let after = content.substring( match.index + match[ 0 ].length );
  let inside = match[ 0 ].replace( '\n', '' ).replace( '\n', '' );
  let pre = match[ 1 ];
  let result = before;

  add( inside );

  after = after.split( '\n' );

  while( after.length )
  {
    let line = after[ 0 ];
    after.splice( 0, 1 );
    if( !line.trim().length )
    {
      add( line );
      continue;
    }
    if( line.length <= pre.length )
    {
      close( line );
      break;
    }
    if( line.charCodeAt( pre.length+1 ) > 32 )
    {
      close( line );
      break;
    }
    add( line );
  }

  result += after.join( '\n' );

  return result;

  function close( line )
  {
    result += '\n' + line + '\n';
  }

  function add( line )
  {
    line = line.replace( /^\s*/, '' );
    result += `\n${pre}# ${line}`;
  }
}

//

function configEdit( o )
{
  _.assert( arguments.length === 1 );
  _.routineOptions( configEdit, o );

  _.assert( _.strDefined( o.config ) );
  _.assert( _.mapIs( o.setMap ) );

  if( !Yaml )
  {
    Yaml = require( 'yaml' );
    YamlTypes = require( 'yaml/types' );
  }

  let doc = Yaml.parseDocument( o.config );

  _.each( o.setMap, ( value, path ) => set( path, value ) );

  if( o.asDocument )
  return doc;

  return doc.toString();

  /*  */

  function set( path, value )
  {
    let parts = path.split( '/' );
    let target = parts.pop();
    let result = doc;

    _.each( parts, ( selector ) =>
    {
      if( result.has( selector ) )
      result = result.get( selector )
      else
      result.set( selector, new YamlTypes.YAMLMap() );
    })

    let node = Yaml.createNode( value, false );
    result.set( target, node );

    if( parts.length === 0 )
    if( node instanceof YamlTypes.YAMLMap )
    node.spaceBefore = true;
  }
}

var defaults = configEdit.defaults = Object.create( null );
defaults.config = null;
defaults.setMap = null;
defaults.asDocument = false; //for testing



function configFileEdit( o )
{
  _.routineOptions( configFileEdit, o );
  _.assert( _.strDefined( o.filePath ) );

  if( !_.fileProvider.isTerminal( o.filePath ) )
  throw _.err( 'configFileEdit expects yaml file at path:', o.filePath );

  let o2 = _.mapOnly( o, configEdit.defaults );
  o2.config = _.fileProvider.fileRead( o.filePath );

  return this.configEdit( o2 );
}

_.routineExtend( configFileEdit, configEdit );

var defaults = configFileEdit.defaults;
delete defaults.config;
defaults.filePath = null;

// --
// relations
// --

// --
// declare
// --

let Extend =
{

  lineFind,
  commentOut,

  configEdit,
  configFileEdit,

}

_.mapExtend( Self, Extend );

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _global_.wTools;

})();
