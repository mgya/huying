//
//  purl.h
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__purl__
#define __UMPStack__purl__

#ifdef P_USE_PRAGMA
#pragma interface
#endif


#include "pcommon.h"
#include "pstring.h"


//////////////////////////////////////////////////////////////////////////////
// PURL

class PURLLegacyScheme;

/**
 This class describes a Universal Resource Locator.
 This is the desciption of a resource location as used by the World Wide
 Web and the #PHTTPSocket# class.
 */
class PURL : public PObject
{
    PCLASSINFO(PURL, PObject)
public:
    /**Construct a new URL object from the URL string. */
    PURL();
    /**Construct a new URL object from the URL string. */
    PURL(
         const char * cstr,    ///< C string representation of the URL.
         const char * defaultScheme = NULL ///< Default scheme for URL
    );
    /**Construct a new URL object from the URL string. */
    PURL(
         const PString & str,  ///< String representation of the URL.
         const char * defaultScheme = NULL ///< Default scheme for URL
    );
    
    /**@name Overrides from class PObject */
    //@{
    /**Compare the two URLs and return their relative rank.
     
     @return
     #LessThan#, #EqualTo# or #GreaterThan#
     according to the relative rank of the objects.
     */
    virtual Comparison Compare(
                               const PObject & obj   ///< Object to compare against.
    ) const;
    
    /**This function yields a hash value required by the #PDictionary#
     class. A descendent class that is required to be the key of a dictionary
     should override this function. The precise values returned is dependent
     on the semantics of the class. For example, the #PString# class
     overrides it to provide a hash function for distinguishing text strings.
     
     The default behaviour is to return the value zero.
     
     @return
     hash function value for class instance.
     */
    virtual PINDEX HashFunction() const;
    
    /**Output the contents of the URL to the stream as a string.
     */
    virtual void PrintOn(
                         ostream &strm   ///< Stream to print the object into.
    ) const;
    
    /**Input the contents of the URL from the stream. The input is a URL in
     string form.
     */
    virtual void ReadFrom(
                          istream &strm   ///< Stream to read the objects contents from.
    );
    //@}
    
    /**@name New functions for class. */
    //@{
    /**Parse the URL string into the fields in the object instance. */
    inline PBOOL Parse(
                      const char * cstr,   ///< URL as a string to parse.
                      const char * defaultScheme = NULL ///< Default scheme for URL
    ) { return InternalParse(cstr, defaultScheme); }
    /**Parse the URL string into the fields in the object instance. */
    inline PBOOL Parse(
                      const PString & str, ///< URL as a string to parse.
                      const char * defaultScheme = NULL ///< Default scheme for URL
    ) { return InternalParse((const char *)str, defaultScheme); }
    
    /**Print/String output representation formats. */
    enum UrlFormat {
        /// Translate to a string as a full URL
        FullURL,
        /// Translate to a string as only path
        PathOnly,
        /// Translate to a string with no scheme or host
        URIOnly,
        /// Translate to a string with scheme and host/port
        HostPortOnly
    };
    
    /**Convert the URL object into its string representation. The parameter
     indicates whether a full or partial representation os to be produced.
     
     @return
     String representation of the URL.
     */
    PString AsString(
                     UrlFormat fmt = FullURL   ///< The type of string to be returned.
    ) const;
    
    /**Get the "file:" URL as a file path.
     If the URL is not a "file:" URL then returns an empty string.
     */
    /// Type for translation of strings to URL format,
    enum TranslationType {
        /// Translate a username/password field for a URL.
        LoginTranslation,
        /// Translate the path field for a URL.
        PathTranslation,
        /// Translate the query parameters field for a URL.
        QueryTranslation
    };
    
    /**Translate a string from general form to one that can be included into
     a URL. All reserved characters for the particular field type are
     escaped.
     
     @return
     String for the URL ready translation.
     */
    static PString TranslateString(
                                   const PString & str,    ///< String to be translated.
                                   TranslationType type    ///< Type of translation.
    );
    
    /**Untranslate a string from a form that was included into a URL into a
     normal string. All reserved characters for the particular field type
     are unescaped.
     
     @return
     String from the URL untranslated.
     */
    static PString UntranslateString(
                                     const PString & str,    ///< String to be translated.
                                     TranslationType type    ///< Type of translation.
    );
    
    /** Split a string in &= form to a dictionary of names and values. */
    static void SplitQueryVars(
                               const PString & queryStr,   ///< String to split into variables.
                               PStringToString & queryVars ///< Dictionary of variable names and values.
    );
    
    
    /// Get the scheme field of the URL.
    const PCaselessString & GetScheme() const { return scheme; }
    
    /// Set the scheme field of the URL
    void SetScheme(const PString & scheme);
    
    /// Get the username field of the URL.
    const PString & GetUserName_() const { return username; }
    
    /// Set the username field of the URL.
    void SetUserName(const PString & username);
    
    /// Get the password field of the URL.
    const PString & GetPassword() const { return password; }
    
    /// Set the password field of the URL.
    void SetPassword(const PString & password);
    
    /// Get the hostname field of the URL.
    const PCaselessString & GetHostName() const { return hostname; }
    
    /// Set the hostname field of the URL.
    void SetHostName(const PString & hostname);
    
    /// Get the port field of the URL.
    WORD GetPort() const { return port; }
    
    /// Set the port field in the URL.
    void SetPort(WORD newPort);
    
    /// Get if path is relative or absolute
    PBOOL GetRelativePath() const { return relativePath; }
    
    /// Get the path field of the URL as a string.
    const PString & GetPathStr() const { return pathStr; }
    
    /// Set the path field of the URL as a string.
    void SetPathStr(const PString & pathStr);
    
    /// Get the path field of the URL as a string array.
    const PStringArray & GetPath() const { return path; }
    
    /// Set the path field of the URL as a string array.
    void SetPath(const PStringArray & path);
    
    /// Get the parameter (;) field of the URL.
    PString GetParameters() const;
    
    /// Set the parameter (;) field of the URL.
    void SetParameters(const PString & parameters);
    
    /// Get the parameter (;) field(s) of the URL as a string dictionary.
    const PStringToString & GetParamVars() const { return paramVars; }
    
    /// Set the parameter (;) field(s) of the URL as a string dictionary.
    void SetParamVars(const PStringToString & paramVars);
    
    /// Set the parameter (;) field of the URL as a string dictionary.
    void SetParamVar(const PString & key, const PString & data);
    
    /// Get the fragment (##) field of the URL.
    const PString & GetFragment() const { return fragment; }
    
    /// Get the Query (?) field of the URL as a string.
    PString GetQuery() const;
    
    /// Set the Query (?) field of the URL as a string.
    void SetQuery(const PString & query);
    
    /// Get the Query (?) field of the URL as a string dictionary.
    const PStringToString & GetQueryVars() const { return queryVars; }
    
    /// Set the Query (?) field(s) of the URL as a string dictionary.
    void SetQueryVars(const PStringToString & queryVars);
    
    /// Set the Query (?) field of the URL as a string dictionary.
    void SetQueryVar(const PString & key, const PString & data);
    
    /// Return TRUE if the URL is an empty string.
    PBOOL IsEmpty() const { return urlString.IsEmpty(); }
    
    
    /**Open the URL in a browser.
     
     @return
     The browser was successfully opened. This does not mean the URL exists and was
     displayed.
     */
    static PBOOL OpenBrowser(
                            const PString & url   ///< URL to open
    );
    //@}
    
    PBOOL LegacyParse(const PString & _url, const PURLLegacyScheme * schemeInfo);
    PString LegacyAsString(PURL::UrlFormat fmt, const PURLLegacyScheme * schemeInfo) const;
    
protected:
    virtual PBOOL InternalParse(
                               const char * cstr,         ///< URL as a string to parse.
                               const char * defaultScheme ///< Default scheme for URL
    );
    void Recalculate();
    PString urlString;
    
    PCaselessString scheme;
    PString username;
    PString password;
    PCaselessString hostname;
    WORD port;
    PBOOL portSupplied;          /// port was supplied in string input
    PBOOL relativePath;
    PString pathStr;
    PStringArray path;
    PStringToString paramVars;
    PString fragment;
    PStringToString queryVars;
};


//////////////////////////////////////////////////////////////////////////////
// PURLScheme

class PURLScheme : public PObject
{
    PCLASSINFO(PURLScheme, PObject);
public:
    virtual PString GetName() const = 0;
    virtual PBOOL Parse(const PString & url, PURL & purl) const = 0;
    virtual PString AsString(PURL::UrlFormat fmt, const PURL & purl) const = 0;
};

//////////////////////////////////////////////////////////////////////////////
// PURLLegacyScheme

class PURLLegacyScheme : public PURLScheme
{
public:
    PURLLegacyScheme(const char * _scheme)
    : scheme(_scheme) { }
    
    PBOOL Parse(const PString & url, PURL & purl) const
    { return purl.LegacyParse(url, this); }
    
    PString AsString(PURL::UrlFormat fmt, const PURL & purl) const
    { return purl.LegacyAsString(fmt, this); }
    
    PString GetName() const     
    { return scheme; }
    
    PString scheme;
    PBOOL hasUsername;
    PBOOL hasPassword;
    PBOOL hasHostPort;
    PBOOL defaultToUserIfNoAt;
    PBOOL defaultHostToLocal;
    PBOOL hasQuery;
    PBOOL hasParameters;
    PBOOL hasFragments;
    PBOOL hasPath;
    PBOOL relativeImpliesScheme;
    WORD defaultPort;
};


#endif /* defined(__UMPStack__purl__) */
