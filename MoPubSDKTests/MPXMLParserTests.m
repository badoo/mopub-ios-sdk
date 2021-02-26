//
//  MPXMLParserTests.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPXMLParser.h"

@interface MPXMLParserTests : XCTestCase

@end

@implementation MPXMLParserTests

- (void)testNoData {
    // Preconditions
    NSData *emptyData = [[NSData alloc] init];

    // Parsing
    MPXMLParser *parser = [[MPXMLParser alloc] init];
    NSDictionary *json = [parser dictionaryWithData:emptyData];
    XCTAssert([json isEqualToDictionary:@{}]);
}

- (void)testInvlidXmlData {
    // Preconditions
    NSString *badXml = @"<xml>I am bad xml";
    NSData *badData = [badXml dataUsingEncoding:NSUTF8StringEncoding];

    // Parsing
    MPXMLParser *parser = [[MPXMLParser alloc] init];
    NSDictionary *json = [parser dictionaryWithData:badData];
    XCTAssertNil(json);
}

- (void)testSimpleXmlData {
    // Preconditions
    NSString *xml = @"<xml>This is text content</xml>";
    NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];

    // Parsing
    MPXMLParser *parser = [[MPXMLParser alloc] init];
    NSDictionary *json = [parser dictionaryWithData:data];
    XCTAssertNotNil(json);

    NSDictionary *xmlJson = json[@"xml"];
    XCTAssertNotNil(xmlJson);
    XCTAssert([xmlJson[@"text"] isEqualToString:@"This is text content"]);
}

- (void)testAttributeParsing {
    // Preconditions
    NSString *xml = @"<xml attr1='text' attr2='10' attr3='false'/>";
    NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];

    // Parsing
    MPXMLParser *parser = [[MPXMLParser alloc] init];
    NSDictionary *json = [parser dictionaryWithData:data];
    XCTAssertNotNil(json);

    NSDictionary *xmlJson = json[@"xml"];
    XCTAssertNotNil(xmlJson);
    XCTAssert([xmlJson[@"attr1"] isEqualToString:@"text"]);
    XCTAssert([xmlJson[@"attr2"] isEqualToString:@"10"]);
    XCTAssert([xmlJson[@"attr3"] isEqualToString:@"false"]);
}

- (void)testArrayParsing {
    // Preconditions
    NSString *xml = @"<xml><nodes><node>node1</node><node>node2</node><node>node3</node></nodes></xml>";
    NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];

    // Parsing
    MPXMLParser *parser = [[MPXMLParser alloc] init];
    NSDictionary *json = [parser dictionaryWithData:data];
    XCTAssertNotNil(json);

    NSDictionary *xmlJson = json[@"xml"];
    XCTAssertNotNil(xmlJson);

    NSArray *nodes = xmlJson[@"nodes"][@"node"];
    XCTAssertNotNil(nodes);
    XCTAssert(nodes.count == 3);
}

@end
