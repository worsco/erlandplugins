# ======================================================================
#
# Copyright (C) 2000-2003 Paul Kulchenko (paulclinger@yahoo.com)
# SOAP::Lite is free software; you can redistribute it
# and/or modify it under the same terms as Perl itself.
#
# $Id: Data.pm,v 1.3 2004/11/14 19:30:49 byrnereese Exp $
#
# ======================================================================

=pod

=head1 NAME

SOAP::Data - this class provides the means by which to explicitly manipulate and control all aspects of the way in which Perl data gets expressed as SOAP data entities.

=head1 DESCRIPTION

The SOAP::Data class provides the means by which to explicitly manipulate and control all aspects of the way in which Perl data gets expressed as SOAP data entities. Most of the methods are accessors, which like those in SOAP::Lite are designed to return the current value if no new one is passed, while returning the object reference otherwise (allowing for chained method calls). Note that most accessors (except value) accept a new value for the data object as a second argument. 

=head1 METHODS

=over 

=item new(optional key/value pairs)

    $obj = SOAP::Data->new(name => 'idx', value => 5);

This is the class constructor. Almost all of the attributes related to the class may be passed to the constructor as key/value pairs. This method isn't often used directly because SOAP::Data objects are generally created for temporary use. It is available for those situations that require it.

=item name(new name, optional value)

    $obj->name('index');

Gets or sets the current value of the name, as the object regards it. The name is what the serializer will use for the tag when generating the XML for this object. It is what will become the accessor for the data element. Optionally, the object's value may be updated if passed as a second argument.

=item type(new type, optional value)

    $obj->type('int');

Gets or sets the type associated with the current value in the object. This is useful for those cases where the SOAP::Data object is used to explicitly specify the type of data that would otherwise be interpreted as a different type completely (such as perceiving the string 123 as an integer, instead). Allows the setting of the object's value, if passed as a second argument to the method.

=item uri(new uri, optional value)

    $obj->uri('http://www.perl.com/SOAP');

Gets or sets the URI that will be used as the namespace for the resulting XML entity, if one is desired. This doesn't set the label for the namespace. If one isn't provided by means of the prefix method, one is generated automatically when needed. Also allows the setting of the object's value, if passed as a second argument to the method.

=item prefix(new prefix, optional value)

    $obj->prefix('perl');

Provides the prefix, or label, for use when associating the data object with a specific namespace. Also allows the setting of the object's value, if passed as a second argument to the method.

=item attr(hash reference of attributes, optional value)

    $obj->attr({ attr1 => 'value' });

Allows for the setting of arbitrary attributes on the data object. Keep in mind the requirement that any attributes not natively known to SOAP must be namespace-qualified. Also allows the setting of the object's value, if passed as a second argument to the method.

=item value(new value)

    $obj->value(10);

Fetches the current value encapsulated by the object, or explicitly sets it.

=back

The last four methods are convenience shortcuts for the attributes that SOAP itself supports. Each also permits inclusion of a new value, as an optional second argument. 

=over

=item actor(new actor, optional value)

    $obj->actor($new_actor_name);

Gets or sets the value of the actor attribute; useful only when the object generates an entity for the message header.

=item mustUnderstand(boolean, optional value)

    $obj->mustUnderstand(0);

Manipulates the mustUnderstand attribute, which tells the SOAP processor whether it is required to understand the entity in question.

=item encodingStyle(new encoding URN, optional value)

    $obj->encodingStyle($soap_11_encoding);

This method is most likely to be used in places outside the header creation. Sets encodingStyle, which specifies an encoding that differs from the one that would otherwise be defaulted to.

=item root(boolean, optional value)

    $obj->root(1);

When the application must explicitly specify which data element is to be regarded as the root element for the sake of generating the object model, this method provides the access to the root attribute.

=back

=head1 TYPE DETECTION

SOAP::Lite's serializer will detect the type of any scalar passed in as a SOAP::Data object's value. Because Perl is loosely typed, the serializer is only able to detect types based upon a predetermined set of regular expressions. Therefore, type detection is not always 100% accurate. In such a case you may need to explicitly set the type of the element being encoded. For example, by default the following code will be serialized as an integer:

  $elem = SOAP::Data->name('idx')->value(5);

If, however, you need to serialize this into a long, then the following code will do so:

  $elem = SOAP::Data->name('idx')->value(5)->type('long');

=head1 EXAMPLES

=head2 SIMPLE TYPES

The following example will all produce the same XML:

    $elem1 = SOAP::Data->new(name => 'idx', value => 5);
    $elem2 = SOAP::Data->name('idx' => 5);
    $elem3 = SOAP::Data->name('idx')->value(5);

=head2 COMPLEX TYPES

A common question is how to do you created nested XML elements using SOAP::Lite. The following example demonstrates how:

    SOAP::Data->name('foo' => \SOAP::Data->value(
        SOAP::Data->name('bar' => '123')));

The above code will produce the following XML:

    <foo>
      <bar>123</bar>
    </foo>

=head2 ARRAYS

The following code:

    $elem1 = SOAP::Data->name('item' => 123)->type('SomeObject');
    $elem2 = SOAP::Data->name('item' => 456)->type('SomeObject');
    push(@array,$elem1);
    push(@array,$elem2);

    my $client = SOAP::Lite
        ->readable(1)
        ->uri($NS)
        ->proxy($HOST);

    $temp_elements = SOAP::Data
        ->name("CallDetails" => \SOAP::Data->value(
              SOAP::Data->name("elem1" => 'foo'), 
              SOAP::Data->name("elem2" => 'baz'), 
              SOAP::Data->name("someArray" => \SOAP::Data->value(
                  SOAP::Data->name("someArrayItem" => @array)
                            ->type("SomeObject"))
                       )->type("ArrayOf_SomeObject") ))

	->type("SomeObject"); 

    $response = $client->someMethod($temp_elements);

Will produce the following XML:

    <?xml version="1.0" encoding="UTF-8"?>
    <SOAP-ENV:Envelope
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
        xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns:namesp2="http://namespaces.soaplite.com/perl"
        SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
      <SOAP-ENV:Body>
        <namesp1:someMethod xmlns:namesp1="urn:TemperatureService">
          <CallDetails xsi:type="namesp2:SomeObject">
            <elem1 xsi:type="xsd:string">foo</elem1>
            <elem2 xsi:type="xsd:string">baz</elem2>
            <someArray xsi:type="namesp2:ArrayOf_SomeObject">
              <item xsi:type="namesp2:SomeObject">123</bar>
              <item xsi:type="namesp2:SomeObject">456</bar>
            </someArray>
          </CallDetails>
        </namesp1:test>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>

In the code above, the @array variable can be an array of anything. If you pass
in an array of numbers, then SOAP::Lite will properly serialize that into such. 
If however you need to encode an array of complex types, then simply pass in an 
array of other SOAP::Data objects and you are all set.

=head2 COMPOSING MESSAGES USING RAW XML

In some circumstances you may need to encode a message using raw unserialized 
XML text. To instantiate a SOAP::Data object using raw XML, do the following:

    $xml_content = "<foo><bar>123</bar></foo>";
    $elem = SOAP::Data->type('xml' => $xml_content);

SOAP::Lite's serializer simple takes whatever text is passed to it, and inserts 
into the encoded SOAP::Data element I<verbatim>. The text input is NOT validated to 
ensure it is valid XML, nor is the resulting SOAP::Data element validated to 
ensure that it will produce valid XML. Therefore, it is incumbent upon the 
developer to ensure that any XML data used in this fashion is valid and will 
result in a valid XML document.

=head2 MULTIPLE NAMESPACES

When working with complex types it may be necessary to declare multiple namespaces. The following code demonstrates how to do so:

    $elem = SOAP::Data->name("myElement" => "myValue")
                      ->attr( { 'xmlns:foo2' => 'urn:Foo2', 
                                'xmlns:foo3' => 'urn:Foo3' } );

This will produce the following XML:

    <myElement xmlns:foo2="urn:Foo2" xmlns:foo3="urn:Foo3">myValue</myElement>

=head1 SEE ALSO

L<SOAP::Header>, L<SOAP::SOM>, L<SOAP::Serializer> 

=head1 ACKNOWLEDGEMENTS

Special thanks to O'Reilly publishing which has graciously allowed SOAP::Lite to republish and redistribute large excerpts from I<Programming Web Services with Perl>, mainly the SOAP::Lite reference found in Appendix B.

=head1 COPYRIGHT

Copyright (C) 2000-2004 Paul Kulchenko. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHORS

Paul Kulchenko (paulclinger@yahoo.com)

Randy J. Ray (rjray@blackperl.com)

Byrne Reese (byrne@majordojo.com)

=cut

