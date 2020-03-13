( function _IncludeBase_s_( ) {

'use strict';

/* introspection */

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../Tools.s' );

  _.include( 'wCopyable' );
  _.include( 'wAppBasic' );
  _.include( 'wFiles' );
  _.include( 'wConsequence' );
  _.include( 'wLooker' );
  _.include( 'wLookerExtra' );
  _.include( 'wLogger' );
  _.include( 'wStringer' );
  _.include( 'wSchema' );

  // _global_.Acorn = require( 'acorn' );
  // _global_.Esprima = require( 'esprima' );
  // _global_.Babel = require( '@babel/core' );
  // _global_.TsParser = require( 'typescript' );
  // _global_.UglifyEs = require( 'uglify-es' );

}

})();
