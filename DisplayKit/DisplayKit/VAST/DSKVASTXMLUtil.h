//
//  VASTXMLUtil.h
//  VAST
//
//  Created by Jay Tucker on 10/15/13.
//  Copyright (c) 2013 Nexage. All rights reserved.
//
//  VASTXMLUtil validates a VAST document for correct XML syntax and conformance to the VAST 2.0.1.xsd schema.

#import <Foundation/Foundation.h>

BOOL DSK_validateXMLDocSyntax(NSData *document);                         // check for valid XML syntax using xmlReadMemory
BOOL DSK_validateXMLDocAgainstSchema(NSData *document, NSData *schema);  // check for valid VAST 2.0 syntax using xmlSchemaValidateDoc & vast_2.0.1.xsd schema
NSArray *DSK_performXMLXPathQuery(NSData *document, NSString *query);    // parse the document for the xpath in 'query' using xmlXPathEvalExpression
