( function _Namespace_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( '../../../../node_modules/Tools' );
  _.include( 'wTesting' );
  require( '../../l3/remote/include/Mid.s' );
}

const _ = _global_.wTools;
const __ = _globals_.testing.wTools;

// --
// tests
// --

function trivial( test )
{
  test.case = 'trivial, check map attemptDefaults';
  test.true( _.remote !== undefined );
  test.true( _.map.is( _.remote ) );
  test.true( _.map.is( _.remote.attemptDefaults ) );
  test.ge( _.remote.attemptDefaults.attemptLimit, 1 );
  test.ge( _.remote.attemptDefaults.attemptDelay, 0 );
  test.ge( _.remote.attemptDefaults.attemptDelayMultiplier, 1 );
}

// --
// declare
// --

const Proto =
{
  name : 'Tools.mid.Remote.Int',
  silencing : 1,

  tests :
  {
    trivial,
  }
};

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
