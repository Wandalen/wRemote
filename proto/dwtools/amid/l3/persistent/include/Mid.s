( function _Mid_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './Base.s' );

  require( '../l1/Namespace.s' );

  require( '../l3/Collection.s' );
  require( '../l3/Repo.s' );

}

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _global_.wTools;

})();
