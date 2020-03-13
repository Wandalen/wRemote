( function _Persistent_test_s_( ) {

'use strict';

/*
*/

if( typeof module !== 'undefined' )
{
  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );;

  require( '../l3/persistent/Include.s' );

}

var _global = _global_;
var _ = _global_.wTools;

// --
// tests
// --

function basicArray( test )
{

  test.description = 'wipe';
  _.persistent.open({ name : '.' + test.suite.name }).clean().close();

  test.description = 'writing';
  var structure1 = { a : '1', b : { c : [ 1, 2, 3 ], d : null } }
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  persistent.array( 'account' ).append( structure1 );
  persistent.close();

  var structure2 = { a : '21', b : { c : [ 21, 22, 23 ], d : null } }
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  persistent.array( 'account' ).append( structure2 );
  persistent.close();

  var structure3 = { a : '31', b : { c : [ 31, 32, 33 ], d : null } }
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  persistent.array( 'account' ).prepend( structure3 );
  persistent.close();

  test.description = 'written 3';
  var exp =
  [
    { a : '31', b : { c : [ 31, 32, 33 ], d : null } },
    { a : '1', b : { c : [ 1, 2, 3 ], d : null } },
    { a : '21', b : { c : [ 21, 22, 23 ], d : null } },
  ]
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var read = persistent.array( 'account' ).read();
  persistent.close();
  test.identical( read, exp );

  test.description = 'clean';
  _.persistent.open( '.' + test.suite.name ).array( 'account' ).clean();
  var exp =
  [
  ]
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var read = persistent.array( 'account' ).read();
  persistent.close();
  test.identical( read, exp );

  _.persistent.open({ name : '.' + test.suite.name }).clean().close();
}

basicArray.description =
`
- method append appends element of array and store the structure
- method prepend prepends element of array and store the structure
- method clean deletes collection
`

//

function write( test )
{

  test.description = 'wipe';
  _.persistent.open({ name : '.' + test.suite.name }).clean().close();
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var structure1 = { a : 1 }
  var structure2 = { a : 2 }
  var structure3 = { a : 3 }

  /* */

  test.case = 'write /';
  persistent.clean();
  var exp =
  {
    a : 1
  }
  persistent.write( '/', structure1 );
  var read = persistent.read();
  test.identical( read, exp );

  /* */

  test.case = 'write /a';
  persistent.clean();
  var exp =
  {
    a : { a : 2 }
  }
  persistent.write( '/a', structure2 );
  var read = persistent.read();
  test.identical( read, exp );

  /* */

  test.case = 'write /a/a';
  persistent.clean();
  var exp =
  {
    a : { a : { a : 3 } }
  }
  persistent.write( '/a/a', structure3 );
  var read = persistent.read();
  test.identical( read, exp );

  /* */

  test.description = 'wipe';
  _.persistent.open({ name : '.' + test.suite.name }).clean().close();

  /* */

}

write.description =
`
- write writes on 0th level
- write writes on 1st level
- write writes on 2nd level
`

//

function writeString( test )
{

  test.description = 'wipe';
  _.persistent.open({ name : '.' + test.suite.name }).clean().close();
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var str1 = 'str'

  /* */

  test.shouldThrowErrorSync( () =>
  {
    test.case = 'write /';
    persistent.clean();
    var exp = 'str';
    persistent.write( '/', str1 );
    var read = persistent.read();
    test.identical( read, exp );
  });

  /* */

  test.case = 'write /a';
  persistent.clean();
  var exp =
  {
    a : 'str'
  }
  persistent.write( '/a', str1 );
  var read = persistent.read();
  test.identical( read, exp );

  /* */

  test.case = 'write /a/a';
  persistent.clean();
  var exp =
  {
    a : { a : 'str' }
  }
  persistent.write( '/a/a', str1 );
  var read = persistent.read();
  test.identical( read, exp );

  /* */

  test.description = 'wipe';
  _.persistent.open({ name : '.' + test.suite.name }).clean().close();

  /* */

}

writeString.description =
`
- xxx
`

//

function append( test )
{

  /* */

  test.description = 'wipe';
  var persistent = _.persistent.open({ name : '.' + test.suite.name }).clean();
  test.description = 'append /a/b';
  var structure1 = { x : 1 }
  persistent.append( '/a/b', structure1 );

  var exp =
  {
    'a' :
    {
      'b' :
      [
        { 'x' : 1 }
      ]
    }
  }
  var read = persistent.read();
  test.identical( read, exp );

  /* */

  test.description = 'wipe';
  var persistent = _.persistent.open({ name : '.' + test.suite.name }).clean();
  test.description = 'append /a';
  var structure1 = { x : 1 }
  persistent.append( '/a', structure1 );

  var exp =
  {
    'a' :
    [
      { 'x' : 1 }
    ]
  }
  var read = persistent.read();
  test.identical( read, exp );

  /* */

  test.description = 'wipe';
  var persistent = _.persistent.open({ name : '.' + test.suite.name }).clean();
  test.description = 'append /';
  var structure1 = { x : 1 }

  test.shouldThrowErrorSync( () =>
  {
    persistent.append( '/', structure1 );
  });

  /* */

  persistent.close();
  _.persistent.open({ name : '.' + test.suite.name }).clean().close();
}

append.description =
`
- append prepends elements of array on levels 1, 2
- append throws error on level 0
`

//

function prepend( test )
{

  /* */

  test.description = 'wipe';
  var persistent = _.persistent.open({ name : '.' + test.suite.name }).clean();
  test.description = 'prepend /a/b';
  var structure1 = { x : 1 }
  persistent.prepend( '/a/b', structure1 );

  var exp =
  {
    'a' :
    {
      'b' :
      [
        { 'x' : 1 }
      ]
    }
  }
  var read = persistent.read();
  test.identical( read, exp );

  /* */

  test.description = 'wipe';
  var persistent = _.persistent.open({ name : '.' + test.suite.name }).clean();
  test.description = 'prepend /a';
  var structure1 = { x : 1 }
  persistent.prepend( '/a', structure1 );

  var exp =
  {
    'a' :
    [
      { 'x' : 1 }
    ]
  }
  var read = persistent.read();
  test.identical( read, exp );

  /* */

  test.description = 'wipe';
  var persistent = _.persistent.open({ name : '.' + test.suite.name }).clean();
  test.description = 'prepend /';
  var structure1 = { x : 1 }

  test.shouldThrowErrorSync( () =>
  {
    persistent.prepend( '/', structure1 );
  });

  /* */

  persistent.close();
  _.persistent.open({ name : '.' + test.suite.name }).clean().close();
}

prepend.description =
`
- prepend prepends elements of array on levels 1, 2
- prepend throws error on level 0
`

//

function insert( test )
{

  /* */

  test.description = 'wipe';
  var persistent = _.persistent.open({ name : '.' + test.suite.name }).clean();
  test.description = 'insert /a/b';
  var structure1 = { x : 1 }
  persistent.insert( '/a/b', structure1 );

  var exp =
  {
    'a' :
    {
      'b' : { 'x' : 1 }
    }
  }
  var read = persistent.read();
  test.identical( read, exp );

  /* */

  test.description = 'wipe';
  var persistent = _.persistent.open({ name : '.' + test.suite.name }).clean();
  test.description = 'insert /a';
  var structure1 = { x : 1 }
  persistent.insert( '/a', structure1 );

  var exp =
  {
    'a' : { 'x' : 1 }
  }
  var read = persistent.read();
  test.identical( read, exp );

  /* */

  test.description = 'wipe';
  var persistent = _.persistent.open({ name : '.' + test.suite.name }).clean();
  test.description = 'insert /';
  var structure1 = { x : 1 }
  persistent.insert( '/', structure1 );

  var exp = { 'x' : 1 }
  var read = persistent.read();
  test.identical( read, exp );

  /* */

  persistent.close();
  _.persistent.open({ name : '.' + test.suite.name }).clean().close();
}

insert.description =
`
- insert prepends elements of array on levels 0, 1, 2
`

//

function deleteRewriting( test )
{

  /* */

  write();
  test.case = 'delete /';
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var exp =
  {
    'down' :
    {
      'a' :
      {
        'b' :
        [
          { 'x' : 2 },
          { 'x' : 1 },
        ]
      },
      'c' :
      {
        'd' :
        {
          'x' : 2
        }
      }
    }
  }
  var read = persistent.read();
  persistent.delete( '/' );
  persistent.write( '/down', read );
  var read = persistent.read();
  test.identical( read, exp );

  /* */

  write();
  test.case = 'delete /a';
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var exp =
  {
    'c' :
    {
      'd' :
      {
        'x' : 2
      }
    }
  }
  persistent.delete( '/a' );
  var read = persistent.read();
  test.identical( read, exp );

  /* */

  write();
  test.case = 'delete /a/b';
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var exp =
  {
    'a' : {},
    'c' :
    {
      'd' : { 'x' : 2 }
    }
  }
  persistent.delete( '/a/b' );
  var read = persistent.read();
  test.identical( read, exp );

  /* */

  test.description = 'wipe';
  _.persistent.open({ name : '.' + test.suite.name }).clean().close();

  /* */

  function write()
  {
    test.description = 'wipe';
    _.persistent.open({ name : '.' + test.suite.name }).clean().close();

    test.description = 'writing';
    var structure1 = { x : 1 }
    var structure2 = { x : 2 }
    var persistent = _.persistent.open({ name : '.' + test.suite.name });
    persistent.append( 'a/b', structure1 );
    persistent.prepend( 'a/b', structure2 );
    persistent.insert( 'c/d', structure2 );
    persistent.close();

    test.description = 'written';
    var exp =
    {
      'a' :
      {
        'b' :
        [
          { 'x' : 2 },
          { 'x' : 1 },
        ]
      },
      'c' :
      {
        'd' :
        {
          'x' : 2
        }
      }
    }
    var persistent = _.persistent.open({ name : '.' + test.suite.name });
    var read = persistent.read();
    test.identical( read, exp );

  }
}

deleteRewriting.description =
`
- delete works on levels 0, 1, 2
`

//

function basicMap( test )
{

  test.description = 'was clean';
  var exp = {}
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var read = persistent.map( 'account' ).read();
  persistent.close();
  test.identical( read, exp );

  test.description = 'writing';
  var structure1 = { a : '1', b : { c : [ 1, 2, 3 ], d : null } }
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  persistent.map( 'account' ).insert( 's1', structure1 );
  persistent.close();

  var structure2 = { a : '21', b : { c : [ 21, 22, 23 ], d : null } }
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  persistent.map( 'account' ).insert( 's2', structure2 );
  persistent.close();

  var structure3 = { a : '31', b : { c : [ 31, 32, 33 ], d : null } }
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  persistent.map( 'account' ).insert( 's3', structure3 );
  persistent.close();

  test.description = 'written 3';
  var exp =
  {
    s3 : { a : '31', b : { c : [ 31, 32, 33 ], d : null } },
    s1 : { a : '1', b : { c : [ 1, 2, 3 ], d : null } },
    s2 : { a : '21', b : { c : [ 21, 22, 23 ], d : null } },
  }
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var read = persistent.collection( 'account' ).read();
  persistent.close();
  test.identical( read, exp );

  test.description = 'clean';
  _.persistent.open( '.' + test.suite.name ).array( 'account' ).clean();
  var exp =
  {
  }
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var read = persistent.map( 'account' ).read();
  persistent.close();
  test.identical( read, exp );

  _.persistent.open({ name : '.' + test.suite.name }).clean().close();
}

basicMap.description =
`
- method append insert element of map and store the structure
- method clean deletes collection
`
//
// //
//
// function secondLevel( test )
// {
//
//   test.description = 'was clean';
//   var exp = {}
//   var persistent = _.persistent.open({ name : '.' + test.suite.name });
//   var read = persistent.map( 'account' ).read();
//   persistent.close();
//   test.identical( read, exp );
//
//   test.description = 'writing';
//   var structure1 = { a : '1', b : { c : [ 1, 2, 3 ], d : null } }
//   var persistent = _.persistent.open({ name : '.' + test.suite.name });
//   persistent.map( 'account' ).insert( 's1', structure1 );
//   persistent.close();
//
//   var structure2 = { a : '21', b : { c : [ 21, 22, 23 ], d : null } }
//   var persistent = _.persistent.open({ name : '.' + test.suite.name });
//   persistent.map( 'account' ).array( 'l2' ).append( structure2 );
//   persistent.close();
//
//   // var structure3 = { a : '31', b : { c : [ 31, 32, 33 ], d : null } }
//   // var persistent = _.persistent.open({ name : '.' + test.suite.name });
//   // persistent.map( 'account' ).array( 'l2' ).map( 'l3' ).insert( 's3', structure3 );
//   // persistent.close();
//
//   test.description = 'written 3';
//   var exp =
//   {
//   }
//   var persistent = _.persistent.open({ name : '.' + test.suite.name });
//   var read = persistent.collection( 'account' ).read();
//   persistent.close();
//   test.identical( read, exp );
//
//   test.description = 'clean';
//   _.persistent.open( '.' + test.suite.name ).array( 'account' ).clean();
//   var exp =
//   {
//   }
//   var persistent = _.persistent.open({ name : '.' + test.suite.name });
//   var read = persistent.map( 'account' ).read();
//   persistent.close();
//   test.identical( read, exp );
//
//   _.persistent.open({ name : '.' + test.suite.name }).clean();
// }
//
// secondLevel.description =
// `
// - method append appends element of array and store structure
// - method prepend prepends element of array and store structure
// - method clean deletes collection
// `

//

function secondLevel( test )
{

  test.description = 'was clean';
  var exp = {}
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var read = persistent.read();
  persistent.close();
  test.identical( read, exp );

  test.description = 'writing';
  var structure1 = { a : '1', b : { c : [ 1, 2, 3 ], d : null } }
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  persistent.insert( '/account/s1', structure1 );
  persistent.close();

  test.description = 'written 1';
  var exp =
  {
    'account' :
    {
      's1' :
      {
        'a' : '1',
        'b' :
        {
          'c' : [ 1, 2, 3 ],
          'd' : null
        }
      }
    }
  }
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var read = persistent.read( '/' );
  persistent.close();
  test.identical( read, exp );

  test.description = 'written 1';
  var exp =
  {
    's1' :
    {
      'a' : '1',
      'b' :
      {
        'c' : [ 1, 2, 3 ],
        'd' : null
      }
    }
  }
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var read = persistent.read( '/account' );
  persistent.close();
  test.identical( read, exp );

  test.description = 'written 1';
  var exp =
  {
    'a' : '1',
    'b' :
    {
      'c' : [ 1, 2, 3 ],
      'd' : null
    }
  }
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var read = persistent.read( '/account/s1' );
  persistent.close();
  test.identical( read, exp );

  var structure2 = { a : '21', b : { c : [ 21, 22, 23 ], d : null } }
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  persistent.append( '/account/s1/x', structure2 );
  persistent.close();

  test.description = 'written 2';
  var exp =
  {
    'a' : '1',
    'b' :
    {
      'c' : [ 1, 2, 3 ],
      'd' : null
    },
    'x' :
    [
      {
        'a' : '21',
        'b' :
        {
          'c' : [ 21, 22, 23 ],
          'd' : null
        }
      }
    ]
  }
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var read = persistent.read( '/account/s1' );
  persistent.close();
  test.identical( read, exp );

  test.description = 'written 2';
  var exp =
  {
    's1' :
    {
      'a' : '1',
      'b' :
      {
        'c' : [ 1, 2, 3 ],
        'd' : null
      },
      'x' :
      [
        {
          'a' : '21',
          'b' :
          {
            'c' : [ 21, 22, 23 ],
            'd' : null
          }
        }
      ]
    }
  }
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var read = persistent.read( '/account' );
  persistent.close();
  test.identical( read, exp );

  test.description = 'written 2';
  var exp =
  {
    'account' :
    {
      's1' :
      {
        'a' : '1',
        'b' :
        {
          'c' : [ 1, 2, 3 ],
          'd' : null
        },
        'x' :
        [
          {
            'a' : '21',
            'b' :
            {
              'c' : [ 21, 22, 23 ],
              'd' : null
            }
          }
        ]
      }
    }
  }
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var read = persistent.read( '/' );
  persistent.close();
  test.identical( read, exp );

  test.description = 'clean';
  _.persistent.open( '.' + test.suite.name ).clean().close();
  var exp ={}
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var read = persistent.read( '/' );
  persistent.close();
  test.identical( read, exp );

}

secondLevel.description =
`
- method append appends element of array and store structure
- method prepend prepends element of array and store structure
- method clean deletes collection
`

//

function persistentClean( test )
{

  test.description = 'writing';
  var structure1 = { a : '1', b : { c : [ 1, 2, 3 ], d : null } }
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  persistent.write( '/', { account : [] } );
  persistent.append( '/account', structure1 );
  persistent.close();

  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var got = persistent.exists();
  test.identical( got, true );

  test.description = 'written 2';
  var exp =
  [
    { a : '1', b : { c : [ 1, 2, 3 ], d : null } },
  ]
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var read = persistent.array( 'account' ).read();
  persistent.close();
  test.identical( read, exp );

  test.description = 'clean';
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  persistent.clean()
  persistent.close();
  var exp =
  [
  ]
  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var read = persistent.array( 'account' ).read();
  persistent.close();
  test.identical( read, exp );

  var persistent = _.persistent.open({ name : '.' + test.suite.name });
  var got = persistent.exists();
  test.identical( got, false );

}

persistentClean.description =
`
- removes whole persistent
- persistent.exists give true if persistent exists, otherwise false
`

// --
// define class
// --

var Self =
{

  name : 'Tools.amid.Persistent',
  silencing : 1,

  tests :
  {

    basicArray,
    write,
    writeString,
    append,
    prepend,
    insert,
    deleteRewriting,
    basicMap,
    secondLevel,
    persistentClean,

  }

}

// --
// export
// --

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
