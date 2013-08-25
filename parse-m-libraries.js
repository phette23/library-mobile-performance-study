// www.libsuccess.org/index.php?title=M-Libraries
// object for storing site URLs & their link text
var output = { "sites": [] };

// grab via ID
$( '#Mobile_interfaces_\\.28and\\.2For_OPACS\\.29' )
    // = h3 > span#Mobile_interfaces...
    .parent()
    // get all the siblings
    .nextUntil( 'h3' )
    // ...except the 1st <p>
    .filter( 'ul' )
    // get the links
    .find( 'li a' )
    // throw the hrefs & their link text in an object
    .each( function ( i, el ) {
	output.sites.push( { title : this.innerText, url : this.href } );
    } );

stringOutput = JSON.stringify( output );
