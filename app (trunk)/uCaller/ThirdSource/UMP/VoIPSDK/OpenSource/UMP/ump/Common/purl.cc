//
//  purl.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-7.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "purl.h"
#include "pfactory.h"
#include "pipsock.h"

#define DEFAULT_SCHEME "http"
#define DEFAULT_H323RAS_PORT    1719

PURL::PURL()
: //scheme(SchemeTable[DEFAULT_SCHEME].name),
scheme(DEFAULT_SCHEME),
port(0),
portSupplied (FALSE),
relativePath(FALSE)
{
}


PURL::PURL(const char * str, const char * defaultScheme)
{
    Parse(str, defaultScheme);
}


PURL::PURL(const PString & str, const char * defaultScheme)
{
    Parse(str, defaultScheme);
}

PObject::Comparison PURL::Compare(const PObject & obj) const
{
    PAssert(PIsDescendant(&obj, PURL), PInvalidCast);
    return urlString.Compare(((const PURL &)obj).urlString);
}


PINDEX PURL::HashFunction() const
{
    return urlString.HashFunction();
}


void PURL::PrintOn(ostream & stream) const
{
    stream << urlString;
}


void PURL::ReadFrom(istream & stream)
{
    PString s;
    stream >> s;
    Parse(s);
}


PString PURL::TranslateString(const PString & str, TranslationType type)
{
    PString xlat = str;
    
    PString safeChars = "abcdefghijklmnopqrstuvwxyz"
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    "0123456789$-_.!*'(),";
    switch (type) {
        case LoginTranslation :
            safeChars += "+;?&=";
            break;
            
        case PathTranslation :
            safeChars += "+:@&=";
            break;
            
        case QueryTranslation :
            safeChars += ":@";
    }
    PINDEX pos = (PINDEX)-1;
    while ((pos += 1+strspn(&xlat[pos+1], safeChars)) < xlat.GetLength())
        xlat.Splice(psprintf("%%%02X", (BYTE)xlat[pos]), pos, 1);
    
    if (type == QueryTranslation) {
        PINDEX space = (PINDEX)-1;
        while ((space = xlat.Find(' ', space+1)) != P_MAX_INDEX)
            xlat[space] = '+';
    }
    
    return xlat;
}


PString PURL::UntranslateString(const PString & str, TranslationType type)
{
    PString xlat = str;
    xlat.MakeUnique();
    
    PINDEX pos;
    if (type == PURL::QueryTranslation) {
        pos = (PINDEX)-1;
        while ((pos = xlat.Find('+', pos+1)) != P_MAX_INDEX)
            xlat[pos] = ' ';
    }
    
    pos = (PINDEX)-1;
    while ((pos = xlat.Find('%', pos+1)) != P_MAX_INDEX) {
        int digit1 = xlat[pos+1];
        int digit2 = xlat[pos+2];
        if (isxdigit(digit1) && isxdigit(digit2)) {
            xlat[pos] = (char)(
                               (isdigit(digit2) ? (digit2-'0') : (toupper(digit2)-'A'+10)) +
                               ((isdigit(digit1) ? (digit1-'0') : (toupper(digit1)-'A'+10)) << 4));
            xlat.Delete(pos+1, 2);
        }
    }
    
    return xlat;
}


static void SplitVars(const PString & str, PStringToString & vars, char sep1, char sep2)
{
    PINDEX sep1prev = 0;
    do {
        PINDEX sep1next = str.Find(sep1, sep1prev);
        if (sep1next == P_MAX_INDEX)
            sep1next--; // Implicit assumption string is not a couple of gigabytes long ...
        
        PINDEX sep2pos = str.Find(sep2, sep1prev);
        if (sep2pos > sep1next)
            sep2pos = sep1next;
        
        PCaselessString key = PURL::UntranslateString(str(sep1prev, sep2pos-1), PURL::QueryTranslation);
        if (!key) {
            PString data = PURL::UntranslateString(str(sep2pos+1, sep1next-1), PURL::QueryTranslation);
            
            if (vars.Contains(key))
                vars.SetAt(key, vars[key] + ',' + data);
            else
                vars.SetAt(key, data);
        }
        
        sep1prev = sep1next+1;
    } while (sep1prev != P_MAX_INDEX);
}


void PURL::SplitQueryVars(const PString & queryStr, PStringToString & queryVars)
{
    SplitVars(queryStr, queryVars, '&', '=');
}


PBOOL PURL::InternalParse(const char * cstr, const char * defaultScheme)
{
    urlString = cstr;
    
    scheme.MakeEmpty();
    username.MakeEmpty();
    password.MakeEmpty();
    hostname.MakeEmpty();
    port = 0;
    portSupplied = FALSE;
    relativePath = FALSE;
    pathStr.MakeEmpty();
    path.SetSize(0);
    paramVars.RemoveAll();
    fragment.MakeEmpty();
    queryVars.RemoveAll();
    
    // copy the string so we can take bits off it
    while (isspace(*cstr))
        cstr++;
    PString url = cstr;
    
    // Character set as per RFC2396
    PINDEX pos = 0;
    while (isalnum(url[pos]) || url[pos] == '+' || url[pos] == '-' || url[pos] == '.')
        pos++;
    
    PString schemeName;
    
    // get information which tells us how to parse URL for this
    // particular scheme
    PURLScheme * schemeInfo = NULL;
    
    // Determine if the URL has an explicit scheme
    if (url[pos] == ':') {
        
        // get the scheme information, or get the default scheme
        schemeInfo = PFactory<PURLScheme>::CreateInstance(url.Left(pos));
        if (schemeInfo == NULL && defaultScheme == NULL) {
            PFactory<PURLScheme>::KeyList_T keyList = PFactory<PURLScheme>::GetKeyList();
            if (keyList.size() != 0)
                schemeInfo = PFactory<PURLScheme>::CreateInstance(keyList[0]);
        }
        if (schemeInfo != NULL)
            url.Delete(0, pos+1);
    }
    
    // if we could not match a scheme, then use the specified default scheme
    if (schemeInfo == NULL && defaultScheme != NULL)
        schemeInfo = PFactory<PURLScheme>::CreateInstance(defaultScheme);
    
    // if that still fails, then use the global default scheme
    if (schemeInfo == NULL)
        schemeInfo = PFactory<PURLScheme>::CreateInstance(DEFAULT_SCHEME);
    
    // if that fails, then there is nowehere to go
    PAssert(schemeInfo != NULL, "Default scheme not available");
    scheme = schemeInfo->GetName();
    if (!schemeInfo->Parse(url, *this))
        return FALSE;
    
    return !IsEmpty();
}

PBOOL PURL::LegacyParse(const PString & _url, const PURLLegacyScheme * schemeInfo)

{
    PString url = _url;
    PINDEX pos;
    
    // Super special case!
    if (scheme *= "callto") {
        
        // Actually not part of MS spec, but a lot of people put in the // into
        // the URL, so we take it out of it is there.
        if (url.GetLength() > 2 && url[0] == '/' && url[1] == '/')
            url.Delete(0, 2);
        
        // For some bizarre reason callto uses + instead of ; for paramters
        // We do a loop so that phone numbers of the form +61243654666 still work
        do {
            pos = url.Find('+');
        } while (pos != P_MAX_INDEX && isdigit(url[pos+1]));
        
        if (pos != P_MAX_INDEX) {
            SplitVars(url(pos+1, P_MAX_INDEX), paramVars, '+', '=');
            url.Delete(pos, P_MAX_INDEX);
        }
        
        hostname = paramVars("gateway");
        if (!hostname)
            username = UntranslateString(url, LoginTranslation);
        else {
            PCaselessString type = paramVars("type");
            if (type == "directory") {
                pos = url.Find('/');
                if (pos == P_MAX_INDEX)
                    username = UntranslateString(url, LoginTranslation);
                else {
                    hostname = UntranslateString(url.Left(pos), LoginTranslation);
                    username = UntranslateString(url.Mid(pos+1), LoginTranslation);
                }
            }
            else {
                // Now look for an @ and split user and host
                pos = url.Find('@');
                if (pos != P_MAX_INDEX) {
                    username = UntranslateString(url.Left(pos), LoginTranslation);
                    hostname = UntranslateString(url.Mid(pos+1), LoginTranslation);
                }
                else {
                    if (type == "ip" || type == "host")
                        hostname = UntranslateString(url, LoginTranslation);
                    else
                        username = UntranslateString(url, LoginTranslation);
                }
            }
        }
        
        // Allow for [ipv6] form
        pos = hostname.Find(']');
        if (pos == P_MAX_INDEX)
            pos = 0;
        pos = hostname.Find(':', pos);
        if (pos != P_MAX_INDEX) {
            port = (WORD)hostname.Mid(pos+1).AsUnsigned();
            portSupplied = TRUE;
            hostname.Delete(pos, P_MAX_INDEX);
        }
        
        password = paramVars("password");
        return TRUE;
    }
    
    // if the URL should have leading slash, then remove it if it has one
    if (schemeInfo != NULL && schemeInfo->hasHostPort && schemeInfo->hasPath) {
        if (url.GetLength() > 2 && url[0] == '/' && url[1] == '/')
            url.Delete(0, 2);
        else
            relativePath = TRUE;
    }
    
    // parse user/password/host/port
    if (!relativePath && schemeInfo->hasHostPort) {
        PString endHostChars;
        if (schemeInfo->hasPath)
            endHostChars += '/';
        if (schemeInfo->hasQuery)
            endHostChars += '?';
        if (schemeInfo->hasParameters)
            endHostChars += ';';
        if (schemeInfo->hasFragments)
            endHostChars += '#';
        if (endHostChars.IsEmpty())
            pos = P_MAX_INDEX;
        else
            pos = url.FindOneOf(endHostChars);
        
        PString uphp = url.Left(pos);
        if (pos != P_MAX_INDEX)
            url.Delete(0, pos);
        else
            url.MakeEmpty();
        
        // if the URL is of type UserPasswordHostPort, then parse it
        if (schemeInfo->hasUsername) {
            // extract username and password
            PINDEX pos2 = uphp.Find('@');
            PINDEX pos3 = P_MAX_INDEX;
            if (schemeInfo->hasPassword)
                pos3 = uphp.Find(':');
            switch (pos2) {
                case 0 :
                    uphp.Delete(0, 1);
                    break;
                    
                case P_MAX_INDEX :
                    if (schemeInfo->defaultToUserIfNoAt) {
                        if (pos3 == P_MAX_INDEX)
                            username = UntranslateString(uphp, LoginTranslation);
                        else {
                            username = UntranslateString(uphp.Left(pos3), LoginTranslation);
                            password = UntranslateString(uphp.Mid(pos3+1), LoginTranslation);
                        }
                        uphp.MakeEmpty();
                    }
                    break;
                    
                default :
                    if (pos3 > pos2)
                        username = UntranslateString(uphp.Left(pos2), LoginTranslation);
                    else {
                        username = UntranslateString(uphp.Left(pos3), LoginTranslation);
                        password = UntranslateString(uphp(pos3+1, pos2-1), LoginTranslation);
                    }
                    uphp.Delete(0, pos2+1);
            }
        }
        
        // if the URL does not have a port, then this is the hostname
        if (schemeInfo->defaultPort == 0)
            hostname = UntranslateString(uphp, LoginTranslation);
        else {
            // determine if the URL has a port number
            // Allow for [ipv6] form
            pos = uphp.Find(']');
            if (pos == P_MAX_INDEX)
                pos = 0;
            pos = uphp.Find(':', pos);
            if (pos == P_MAX_INDEX)
                hostname = UntranslateString(uphp, LoginTranslation);
            else {
                hostname = UntranslateString(uphp.Left(pos), LoginTranslation);
                port = (WORD)uphp.Mid(pos+1).AsUnsigned();
                portSupplied = TRUE;
            }
            
            if (hostname.IsEmpty() && schemeInfo->defaultHostToLocal)
                hostname = PIPSocket::GetHostName();
        }
    }
    
    if (schemeInfo->hasQuery) {
        // chop off any trailing query
        pos = url.Find('?');
        if (pos != P_MAX_INDEX) {
            SplitQueryVars(url(pos+1, P_MAX_INDEX), queryVars);
            url.Delete(pos, P_MAX_INDEX);
        }
    }
    
    if (schemeInfo->hasParameters) {
        // chop off any trailing parameters
        pos = url.Find(';');
        if (pos != P_MAX_INDEX) {
            SplitVars(url(pos+1, P_MAX_INDEX), paramVars, ';', '=');
            url.Delete(pos, P_MAX_INDEX);
        }
    }
    
    if (schemeInfo->hasFragments) {
        // chop off any trailing fragment
        pos = url.Find('#');
        if (pos != P_MAX_INDEX) {
            fragment = UntranslateString(url(pos+1, P_MAX_INDEX), PathTranslation);
            url.Delete(pos, P_MAX_INDEX);
        }
    }
    
    if (schemeInfo->hasPath)
        SetPathStr(url);   // the hierarchy is what is left
    else {
        // if the rest of the URL isn't a path, then we are finished!
        pathStr = UntranslateString(url, PathTranslation);
        Recalculate();
    }
    
    if (port == 0 && schemeInfo->defaultPort != 0 && !relativePath) {
        // Yes another horrible, horrible special case!
        if (scheme == "h323" && paramVars("type") == "gk")
            port = DEFAULT_H323RAS_PORT;
        else
            port = schemeInfo->defaultPort;
        Recalculate();
    }
    
    return TRUE;
}

PString PURL::AsString(UrlFormat fmt) const
{
    if (fmt == FullURL)
        return urlString;
    
    if (scheme.IsEmpty())
        return PString::Empty();
    
    //const schemeStruct * schemeInfo = GetSchemeInfo(scheme);
    //if (schemeInfo == NULL)
    //  schemeInfo = &SchemeTable[PARRAYSIZE(SchemeTable)-1];
    const PURLScheme * schemeInfo = PFactory<PURLScheme>::CreateInstance(scheme);
    if (schemeInfo == NULL)
        schemeInfo = PFactory<PURLScheme>::CreateInstance(DEFAULT_SCHEME);
    
    return schemeInfo->AsString(fmt, *this);
}

PString PURL::LegacyAsString(PURL::UrlFormat fmt, const PURLLegacyScheme * schemeInfo) const
{
    PStringStream str;
    PINDEX i;
    
    if (fmt == HostPortOnly) {
        if (schemeInfo->hasHostPort && hostname.IsEmpty())
            return str;
        
        str << scheme << ':';
        
        if (relativePath) {
            if (schemeInfo->relativeImpliesScheme)
                return PString::Empty();
            return str;
        }
        
        if (schemeInfo->hasPath && schemeInfo->hasHostPort)
            str << "//";
        
        if (schemeInfo->hasUsername) {
            if (!username) {
                str << TranslateString(username, LoginTranslation);
                if (schemeInfo->hasPassword && !password)
                    str << ':' << TranslateString(password, LoginTranslation);
                str << '@';
            }
        }
        
        if (schemeInfo->hasHostPort) {
            if (hostname.Find(':') != P_MAX_INDEX)
                str << '[' << hostname << ']';
            else
                str << hostname;
        }
        
        if (schemeInfo->defaultPort != 0) {
            if (port != schemeInfo->defaultPort || portSupplied)
                str << ':' << port;
        }
        
        return str;
    }
    
    // URIOnly and PathOnly
    if (schemeInfo->hasPath) {
        for (i = 0; i < path.GetSize(); i++) {
            if (i > 0 || !relativePath)
                str << '/';
            str << TranslateString(path[i], PathTranslation);
        }
    }
    else
        str << TranslateString(pathStr, PathTranslation);
    
    if (fmt == URIOnly) {
        if (!fragment)
            str << "#" << TranslateString(fragment, PathTranslation);
        
        for (i = 0; i < paramVars.GetSize(); i++) {
            str << ';' << TranslateString(paramVars.GetKeyAt(i), QueryTranslation);
            PString data = paramVars.GetDataAt(i);
            if (!data)
                str << '=' << TranslateString(data, QueryTranslation);
        }
        
        if (!queryVars.IsEmpty())
            str << '?' << GetQuery();
    }
    
    return str;
}


void PURL::SetScheme(const PString & s)
{
    scheme = s;
    Recalculate();
}


void PURL::SetUserName(const PString & u)
{
    username = u;
    Recalculate();
}


void PURL::SetPassword(const PString & p)
{
    password = p;
    Recalculate();
}


void PURL::SetHostName(const PString & h)
{
    hostname = h;
    Recalculate();
}


void PURL::SetPort(WORD newPort)
{
    port = newPort;
    Recalculate();
}


void PURL::SetPathStr(const PString & p)
{
    pathStr = p;
    
    path = pathStr.Tokenise("/", TRUE);
    
    if (path.GetSize() > 0 && path[0].IsEmpty())
        path.RemoveAt(0);
    
    for (PINDEX i = 0; i < path.GetSize(); i++) {
        path[i] = UntranslateString(path[i], PathTranslation);
        if (i > 0 && path[i] == ".." && path[i-1] != "..") {
            path.RemoveAt(i--);
            path.RemoveAt(i--);
        }
    }
    
    Recalculate();
}


void PURL::SetPath(const PStringArray & p)
{
    path = p;
    
    pathStr.MakeEmpty();
    for (PINDEX i = 0; i < path.GetSize(); i++)
        pathStr += '/' + path[i];
    
    Recalculate();
}


PString PURL::GetParameters() const
{
    PStringStream str;
    
    for (PINDEX i = 0; i < paramVars.GetSize(); i++) {
        if (i > 0)
            str << ';';
        str << paramVars.GetKeyAt(i);
        PString data = paramVars.GetDataAt(i);
        if (!data)
            str << '=' << data;
    }
    
    return str;
}


void PURL::SetParameters(const PString & parameters)
{
    SplitVars(parameters, paramVars, ';', '=');
    Recalculate();
}


void PURL::SetParamVars(const PStringToString & p)
{
    paramVars = p;
    Recalculate();
}


void PURL::SetParamVar(const PString & key, const PString & data)
{
    if (data.IsEmpty())
        paramVars.RemoveAt(key);
    else
        paramVars.SetAt(key, data);
    Recalculate();
}


PString PURL::GetQuery() const
{
    PStringStream str;
    
    for (PINDEX i = 0; i < queryVars.GetSize(); i++) {
        if (i > 0)
            str << '&';
        str << TranslateString(queryVars.GetKeyAt(i), QueryTranslation)
        << '='
        << TranslateString(queryVars.GetDataAt(i), QueryTranslation);
    }
    
    return str;
}


void PURL::SetQuery(const PString & queryStr)
{
    SplitQueryVars(queryStr, queryVars);
    Recalculate();
}


void PURL::SetQueryVars(const PStringToString & q)
{
    queryVars = q;
    Recalculate();
}


void PURL::SetQueryVar(const PString & key, const PString & data)
{
    if (data.IsEmpty())
        queryVars.RemoveAt(key);
    else
        queryVars.SetAt(key, data);
    Recalculate();
}


PBOOL PURL::OpenBrowser(const PString & url)
{
    return FALSE;
}


void PURL::Recalculate()
{
    //if (scheme.IsEmpty())
    //  scheme = SchemeTable[DEFAULT_SCHEME].name;
    if (scheme.IsEmpty())
        scheme = DEFAULT_SCHEME;
    
    urlString = AsString(HostPortOnly) + AsString(URIOnly);
}
