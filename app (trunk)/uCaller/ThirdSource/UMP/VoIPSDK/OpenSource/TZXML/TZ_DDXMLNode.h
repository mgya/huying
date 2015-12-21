#import <Foundation/Foundation.h>
#import <libxml/tree.h>

@class TZ_DDXMLDocument;

/**
 * Welcome to KissXML.
 * 
 * The project page has documentation if you have questions.
 * https://github.com/robbiehanson/KissXML
 * 
 * If you're new to the project you may wish to read the "Getting Started" wiki.
 * https://github.com/robbiehanson/KissXML/wiki/GettingStarted
 * 
 * KissXML provides a drop-in replacement for Apple's NSXML class cluster.
 * The goal is to get the exact same behavior as the NSXML classes.
 * 
 * For API Reference, see Apple's excellent documentation,
 * either via Xcode's Mac OS X documentation, or via the web:
 * 
 * https://github.com/robbiehanson/KissXML/wiki/Reference
**/

enum {
	TZ_DDXMLInvalidKind                = 0,
	TZ_DDXMLDocumentKind               = XML_DOCUMENT_NODE,
	TZ_DDXMLElementKind                = XML_ELEMENT_NODE,
	TZ_DDXMLAttributeKind              = XML_ATTRIBUTE_NODE,
	TZ_DDXMLNamespaceKind              = XML_NAMESPACE_DECL,
	TZ_DDXMLProcessingInstructionKind  = XML_PI_NODE,
	TZ_DDXMLCommentKind                = XML_COMMENT_NODE,
	TZ_DDXMLTextKind                   = XML_TEXT_NODE,
	TZ_DDXMLDTDKind                    = XML_DTD_NODE,
	TZ_DDXMLEntityDeclarationKind      = XML_ENTITY_DECL,
	TZ_DDXMLAttributeDeclarationKind   = XML_ATTRIBUTE_DECL,
	TZ_DDXMLElementDeclarationKind     = XML_ELEMENT_DECL,
	TZ_DDXMLNotationDeclarationKind    = XML_NOTATION_NODE
};
typedef NSUInteger TZ_DDXMLNodeKind;

enum {
	TZ_DDXMLNodeOptionsNone            = 0,
	TZ_DDXMLNodeExpandEmptyElement     = 1 << 1,
	TZ_DDXMLNodeCompactEmptyElement    = 1 << 2,
	TZ_DDXMLNodePrettyPrint            = 1 << 17,
};


//extern struct _xmlKind;


@interface TZ_DDXMLNode : NSObject <NSCopying>
{
	// Every TZ_DDXML object is simply a wrapper around an underlying libxml node
	struct _xmlKind *genericPtr;
	
	// Every libxml node resides somewhere within an xml tree heirarchy.
	// We cannot free the tree heirarchy until all referencing nodes have been released.
	// So all nodes retain a reference to the node that created them,
	// and when the last reference is released the tree gets freed.
	TZ_DDXMLNode *owner;
}

//- (id)initWithKind:(TZ_DDXMLNodeKind)kind;

//- (id)initWithKind:(TZ_DDXMLNodeKind)kind options:(NSUInteger)options;

//+ (id)document;

//+ (id)documentWithRootElement:(TZ_DDXMLElement *)element;

+ (id)elementWithName:(NSString *)name;

+ (id)elementWithName:(NSString *)name URI:(NSString *)URI;

+ (id)elementWithName:(NSString *)name stringValue:(NSString *)string;

+ (id)elementWithName:(NSString *)name children:(NSArray *)children attributes:(NSArray *)attributes;

+ (id)attributeWithName:(NSString *)name stringValue:(NSString *)stringValue;

+ (id)attributeWithName:(NSString *)name URI:(NSString *)URI stringValue:(NSString *)stringValue;

+ (id)namespaceWithName:(NSString *)name stringValue:(NSString *)stringValue;

+ (id)processingInstructionWithName:(NSString *)name stringValue:(NSString *)stringValue;

+ (id)commentWithStringValue:(NSString *)stringValue;

+ (id)textWithStringValue:(NSString *)stringValue;

//+ (id)DTDNodeWithXMLString:(NSString *)string;

#pragma mark --- Properties ---

- (TZ_DDXMLNodeKind)kind;

- (void)setName:(NSString *)name;
- (NSString *)name;

//- (void)setObjectValue:(id)value;
//- (id)objectValue;

- (void)setStringValue:(NSString *)string;
//- (void)setStringValue:(NSString *)string resolvingEntities:(BOOL)resolve;
- (NSString *)stringValue;

#pragma mark --- Tree Navigation ---

- (NSUInteger)index;

- (NSUInteger)level;

- (TZ_DDXMLDocument *)rootDocument;

- (TZ_DDXMLNode *)parent;
- (NSUInteger)childCount;
- (NSArray *)children;
- (TZ_DDXMLNode *)childAtIndex:(NSUInteger)index;

- (TZ_DDXMLNode *)previousSibling;
- (TZ_DDXMLNode *)nextSibling;

- (TZ_DDXMLNode *)previousNode;
- (TZ_DDXMLNode *)nextNode;

- (void)detach;

- (NSString *)XPath;

#pragma mark --- QNames ---

- (NSString *)localName;
- (NSString *)prefix;

- (void)setURI:(NSString *)URI;
- (NSString *)URI;

+ (NSString *)localNameForName:(NSString *)name;
+ (NSString *)prefixForName:(NSString *)name;
//+ (TZ_DDXMLNode *)predefinedNamespaceForPrefix:(NSString *)name;

#pragma mark --- Output ---

- (NSString *)description;
- (NSString *)XMLString;
- (NSString *)XMLStringWithOptions:(NSUInteger)options;
//- (NSString *)canonicalXMLStringPreservingComments:(BOOL)comments;

#pragma mark --- XPath/XQuery ---

- (NSArray *)nodesForXPath:(NSString *)xpath error:(NSError **)error;
//- (NSArray *)objectsForXQuery:(NSString *)xquery constants:(NSDictionary *)constants error:(NSError **)error;
//- (NSArray *)objectsForXQuery:(NSString *)xquery error:(NSError **)error;

@end
