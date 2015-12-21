//
//  pcontainer.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "pcontainer.h"

#include <stdlib.h>
#include <ctype.h>

#include "parray.h"
#include "plist.h"
#include "pdict.h"
#include "pstring.h"

#ifdef __NUCLEUS_PLUS__
extern "C" int vsprintf(char *, const char *, va_list);
#endif

#define regexpression  ((regex_t *)expression)

#if !P_USE_INLINES

///////////////////////////////////////////////////////////////////////////////

PINLINE PContainer & PContainer::operator=(const PContainer & cont)
{ AssignContents(cont); return *this; }

PINLINE void PContainer::CloneContents(const PContainer *)
{ }

PINLINE void PContainer::CopyContents(const PContainer &)
{ }

PINLINE PINDEX PContainer::GetSize() const
{ return PAssertNULL(reference)->size; }

PINLINE PBOOL PContainer::IsEmpty() const
{ return GetSize() == 0; }

PINLINE PBOOL PContainer::IsUnique() const
{ return PAssertNULL(reference)->count <= 1; }


///////////////////////////////////////////////////////////////////////////////

PString::PString()
: PCharArray(1) { }

PString::PString(const PString & str)
: PCharArray(str) { }

PString::PString(int, const PString * str)
: PCharArray(*str) { }

PString::PString(const std::string & str)
: PCharArray(PString(str.c_str())) { }

PString::PString(char c)
: PCharArray(2) { SetAt(0, c); }

PString PString::Empty()
{ return PString(); }

PString & PString::operator=(const PString & str)
{ AssignContents(str); return *this; }

PString & PString::operator=(const char * cstr)
{ AssignContents(PString(cstr)); return *this; }

PString & PString::operator=(char ch)
{ AssignContents(PString(ch)); return *this; }

PBOOL PString::MakeMinimumSize()
{ return SetSize(GetLength()+1); }

PINDEX PString::GetLength() const
{ return strlen(theArray); }

bool PString::operator!() const
{ return !IsEmpty(); }

PString PString::operator+(const PString & str) const
{ return operator+((const char *)str); }

PString operator+(const char * cstr, const PString & str)
{ return PString(cstr) + str; }

PString operator+(char c, const PString & str)
{ return PString(c) + str; }

PString & PString::operator+=(const PString & str)
{ return operator+=((const char *)str); }

PString PString::operator&(const PString & str) const
{ return operator&((const char *)str); }

PString operator&(const char * cstr, const PString & str)
{ return PString(cstr) & str; }

PString operator&(char c, const PString & str)
{ return PString(c) & str; }

PString & PString::operator&=(const PString & str)
{ return operator&=((const char *)str); }

bool PString::operator==(const PObject & obj) const
{ return PObject::operator==(obj); }

bool PString::operator!=(const PObject & obj) const
{ return PObject::operator!=(obj); }

bool PString::operator<(const PObject & obj) const
{ return PObject::operator<(obj); }

bool PString::operator>(const PObject & obj) const
{ return PObject::operator>(obj); }

bool PString::operator<=(const PObject & obj) const
{ return PObject::operator<=(obj); }

bool PString::operator>=(const PObject & obj) const
{ return PObject::operator>=(obj); }

bool PString::operator*=(const PString & str) const
{ return operator*=((const char *)str); }

bool PString::operator==(const char * cstr) const
{ return InternalCompare(0, P_MAX_INDEX, cstr) == EqualTo; }

bool PString::operator!=(const char * cstr) const
{ return InternalCompare(0, P_MAX_INDEX, cstr) != EqualTo; }

bool PString::operator<(const char * cstr) const
{ return InternalCompare(0, P_MAX_INDEX, cstr) == LessThan; }

bool PString::operator>(const char * cstr) const
{ return InternalCompare(0, P_MAX_INDEX, cstr) == GreaterThan; }

bool PString::operator<=(const char * cstr) const
{ return InternalCompare(0, P_MAX_INDEX, cstr) != GreaterThan; }

bool PString::operator>=(const char * cstr) const
{ return InternalCompare(0, P_MAX_INDEX, cstr) != LessThan; }

PINDEX PString::Find(const PString & str, PINDEX offset) const
{ return Find((const char *)str, offset); }

PINDEX PString::FindLast(const PString & str, PINDEX offset) const
{ return FindLast((const char *)str, offset); }

PINDEX PString::FindOneOf(const PString & str, PINDEX offset) const
{ return FindOneOf((const char *)str, offset); }

void PString::Splice(const PString & str, PINDEX pos, PINDEX len)
{ Splice((const char *)str, pos, len); }

PStringArray
PString::Tokenise(const PString & separators, PBOOL onePerSeparator) const
{ return Tokenise((const char *)separators, onePerSeparator); }

PString::operator const unsigned char *() const
{ return (const unsigned char *)theArray; }

PString & PString::vsprintf(const PString & fmt, va_list args)
{ return vsprintf((const char *)fmt, args); }

PString pvsprintf(const PString & fmt, va_list args)
{ return pvsprintf((const char *)fmt, args); }

PInt64 PString::AsInt64(unsigned base) const
{
    char * dummy;
    return strtol(theArray, &dummy, base);
}

PUInt64 PString::AsUnsigned64(unsigned base) const
{
    char * dummy;
    return strtoul(theArray, &dummy, base);
}

const char* PString::toChar()
{
	return (const char *)theArray;
}
///////////////////////////////////////////////////////////////////////////////

PCaselessString::PCaselessString()
: PString() { }

PCaselessString::PCaselessString(const char * cstr)
: PString(cstr) { }

PCaselessString::PCaselessString(const PString & str)
: PString(str) { }

PCaselessString::PCaselessString(int dummy,const PCaselessString * str)
: PString(dummy, str) { }

PCaselessString & PCaselessString::operator=(const PString & str)
{ AssignContents(str); return *this; }

PCaselessString & PCaselessString::operator=(const char * cstr)
{ AssignContents(PString(cstr)); return *this; }

PCaselessString & PCaselessString::operator=(char ch)
{ AssignContents(PString(ch)); return *this; }


///////////////////////////////////////////////////////////////////////////////

PStringStream::Buffer::Buffer(const Buffer & b)
: string(b.string) { }

PStringStream::Buffer& PStringStream::Buffer::operator=(const Buffer&b)
{ string = b.string; return *this; }

PStringStream & PStringStream::operator=(const PStringStream & strm)
{ AssignContents(strm); return *this; }

PStringStream & PStringStream::operator=(const PString & str)
{ AssignContents(str); return *this; }

PStringStream & PStringStream::operator=(const char * cstr)
{ AssignContents(PString(cstr)); return *this; }

PStringStream & PStringStream::operator=(char ch)
{ AssignContents(PString(ch)); return *this; }


///////////////////////////////////////////////////////////////////////////////

PINLINE PCollection::PCollection(PINDEX initialSize)
: PContainer(initialSize) { }

PINLINE PCollection::PCollection(int dummy, const PCollection * c)
: PContainer(dummy, c) { }

PINLINE void PCollection::AllowDeleteObjects(PBOOL yes)
{ reference->deleteObjects = yes; }

PINLINE void PCollection::DisallowDeleteObjects()
{ AllowDeleteObjects(FALSE); }


///////////////////////////////////////////////////////////////////////////////

PINLINE PArrayObjects::PArrayObjects(PINDEX initialSize)
: theArray(PNEW ObjPtrArray(initialSize)) { }


///////////////////////////////////////////////////////////////////////////////

PINLINE PINDEX PStringArray::AppendString(const PString & str)
{ return Append(str.Clone()); }

PINLINE PStringArray & PStringArray::operator += (const PString & str)
{ Append(str.Clone()); return *this; }

PINLINE PStringArray PStringArray::operator + (const PStringArray & v)
{ PStringArray arr = *this; arr += v; return arr; }

PINLINE PStringArray PStringArray::operator + (const PString & v)
{ PStringArray arr = *this; arr += v; return arr; }

PINLINE PINDEX PStringArray::GetStringsIndex(const PString & str) const
{ return GetValuesIndex(str); }

///////////////////////////////////////////////////////////////////////////////

PINLINE PAbstractList::PAbstractList()
: info(new Info) { PAssert(info != NULL, POutOfMemory); }

PINLINE PObject & PAbstractList::GetReferenceAt(PINDEX index) const
{ PObject * obj = GetAt(index);
    PAssert(obj != NULL, PInvalidArrayIndex); return *obj; }

///////////////////////////////////////////////////////////////////////////////

PINLINE PINDEX PStringList::AppendString(const PString & str)
{ return Append(str.Clone()); }

PINLINE PINDEX PStringList::InsertString(
                                         const PString & before, const PString & str)
{ return Insert(before, str.Clone()); }

PINLINE PStringList & PStringList::operator += (const PString & str)
{ Append(str.Clone()); return *this; }

PINLINE PStringList PStringList::operator + (const PStringList & v)
{ PStringList arr = *this; arr += v; return arr; }

PINLINE PStringList PStringList::operator + (const PString & v)
{ PStringList arr = *this; arr += v; return arr; }

PINLINE PINDEX PStringList::GetStringsIndex(const PString & str) const
{ return GetValuesIndex(str); }

///////////////////////////////////////////////////////////////////////////////

PINLINE PINDEX PSortedStringList::AppendString(const PString & str)
{ return Append(str.Clone()); }

PINLINE PINDEX PSortedStringList::GetStringsIndex(const PString & str) const
{ return GetValuesIndex(str); }


///////////////////////////////////////////////////////////////////////////////

PINLINE POrdinalKey::POrdinalKey(PINDEX newKey)
: theKey(newKey) { }

PINLINE POrdinalKey & POrdinalKey::operator=(PINDEX newKey)
{ theKey = newKey; return *this; }

PINLINE POrdinalKey::operator PINDEX() const
{ return theKey; }

PINLINE PINDEX POrdinalKey::operator++()
{ return ++theKey; }

PINLINE PINDEX POrdinalKey::operator++(int)
{ return theKey++; }

PINLINE PINDEX POrdinalKey::operator--()
{ return --theKey; }

PINLINE PINDEX POrdinalKey::operator--(int)
{ return theKey--; }

PINLINE POrdinalKey & POrdinalKey::operator+=(PINDEX add)
{ theKey += add; return *this; }

PINLINE POrdinalKey & POrdinalKey::operator-=(PINDEX minus)
{ theKey -= minus; return *this; }


///////////////////////////////////////////////////////////////////////////////

PINLINE PBOOL PHashTable::AbstractContains(const PObject & key) const
{ return hashTable->GetElementAt(key) != NULL; }


///////////////////////////////////////////////////////////////////////////////

PINLINE PAbstractSet::PAbstractSet()
{ hashTable->deleteKeys = reference->deleteObjects; }


PINLINE void PStringSet::Include(const PString & str)
{ PAbstractSet::Append(str.Clone()); }

PINLINE PStringSet & PStringSet::operator+=(const PString & str)
{ PAbstractSet::Append(str.Clone()); return *this; }

PINLINE void PStringSet::Exclude(const PString & str)
{ PAbstractSet::Remove(&str); }

PINLINE PStringSet & PStringSet::operator-=(const PString & str)
{ PAbstractSet::Remove(&str); return *this; }


///////////////////////////////////////////////////////////////////////////////

PINLINE PAbstractDictionary::PAbstractDictionary()
{ hashTable->deleteKeys = TRUE; }

PINLINE PAbstractDictionary::PAbstractDictionary(int dummy,
                                                 const PAbstractDictionary * c)
: PHashTable(dummy, c) { }



#endif

#define new PNEW
#undef  __CLASS__
#define __CLASS__ GetClass()


///////////////////////////////////////////////////////////////////////////////

PContainer::PContainer(PINDEX initialSize)
{
    reference = new Reference(initialSize);
    PAssert(reference != NULL, POutOfMemory);
}

PContainer::PContainer(int, const PContainer * cont)
{
    PAssert(cont != NULL, PInvalidParameter);
    PAssert2(cont->reference != NULL, cont->GetClass(), "Clone of deleted container");
    
#if PCONTAINER_USES_CRITSEC
    PEnterAndLeave m(cont->reference->critSec);
#endif
    
    reference = new Reference(*cont->reference);   // create a new reference
    PAssert(reference != NULL, POutOfMemory);
}

PContainer::PContainer(const PContainer & cont)
{
    PAssert2(cont.reference != NULL, cont.GetClass(), "Copy of deleted container");
    
#if PCONTAINER_USES_CRITSEC
    PEnterAndLeave m(cont.reference->critSec);
#endif
    
    ++cont.reference->count;
    reference = cont.reference;  // copy the reference pointer
}

void PContainer::AssignContents(const PContainer & cont)
{
#if PCONTAINER_USES_CRITSEC
    // make sure the critsecs are entered and left in the right order to avoid deadlock
    cont.reference->critSec.Enter();
    reference->critSec.Enter();
#endif
    
    PAssert2(cont.reference != NULL, cont.GetClass(), "Assign of deleted container");
    
    if (reference == cont.reference) {
#if PCONTAINER_USES_CRITSEC
        reference->critSec.Leave();
        cont.reference->critSec.Leave();
#endif
        return;
    }
    
    //modified by brant @2007-7-24
    if ((--reference->count)>0) {
        //--reference->count;
        reference = NULL;
        
#if PCONTAINER_USES_CRITSEC
        reference->critSec.Leave();
#endif
    } else {
#if PCONTAINER_USES_CRITSEC
        reference->critSec.Leave();
#endif
        DestroyContents();
        delete reference;
        reference = NULL;
    }
    /*
     if (!IsUnique()) {
     --reference->count;
     
     #if PCONTAINER_USES_CRITSEC
     reference->critSec.Leave();
     #endif
     } else {
     #if PCONTAINER_USES_CRITSEC
     reference->critSec.Leave();
     #endif
     DestroyContents();
     delete reference;
     reference = NULL;
     }*/
    
    
    ++cont.reference->count;
    reference = cont.reference;
    
#if PCONTAINER_USES_CRITSEC
    cont.reference->critSec.Leave();
#endif
    
}


void PContainer::Destruct()
{
    if (reference != NULL) {
        
#if PCONTAINER_USES_CRITSEC
        Reference * ref = reference;
        ref->critSec.Enter();
#endif
        
        //modified by brant @2007-7-24
        
        if (--reference->count > 0) {
            reference = NULL;
#if PCONTAINER_USES_CRITSEC
            ref->critSec.Leave();
#endif
        }
        
        else {
#if PCONTAINER_USES_CRITSEC
            ref->critSec.Leave();
#endif
            DestroyContents();
            delete reference;
            reference = NULL;
        }
        
        /*
         --reference->count;
         
         if (reference->count > 0) {
         reference = NULL;
         #if PCONTAINER_USES_CRITSEC
         ref->critSec.Leave();
         #endif
         }
         
         else {
         #if PCONTAINER_USES_CRITSEC
         ref->critSec.Leave();
         #endif
         DestroyContents();
         delete reference;
         reference = NULL;
         }
         */
        
    }
}


PBOOL PContainer::SetMinSize(PINDEX minSize)
{
    PASSERTINDEX(minSize);
    if (minSize < 0)
        minSize = 0;
    if (minSize < GetSize())
        minSize = GetSize();
    return SetSize(minSize);
}


PBOOL PContainer::MakeUnique()
{
#if PCONTAINER_USES_CRITSEC
    PEnterAndLeave m(reference->critSec);
#endif
    
    if (IsUnique())
        return TRUE;
    
    Reference * oldReference = reference;
    reference = new Reference(*reference);
    --oldReference->count;
    
    return FALSE;
}


///////////////////////////////////////////////////////////////////////////////

PAbstractArray::PAbstractArray(PINDEX elementSizeInBytes, PINDEX initialSize)
: PContainer(initialSize)
{
    elementSize = elementSizeInBytes;
    PAssert(elementSize != 0, PInvalidParameter);
    
    if (GetSize() == 0)
        theArray = NULL;
    else {
        theArray = (char *)calloc(GetSize(), elementSize);
        PAssert(theArray != NULL, POutOfMemory);
    }
    
    allocatedDynamically = TRUE;
}


PAbstractArray::PAbstractArray(PINDEX elementSizeInBytes,
                               const void *buffer,
                               PINDEX bufferSizeInElements,
                               PBOOL dynamicAllocation)
: PContainer(bufferSizeInElements)
{
    elementSize = elementSizeInBytes;
    PAssert(elementSize != 0, PInvalidParameter);
    
    allocatedDynamically = dynamicAllocation;
    
    if (GetSize() == 0)
        theArray = NULL;
    else if (dynamicAllocation) {
        PINDEX sizebytes = elementSize*GetSize();
        theArray = (char *)malloc(sizebytes);
        PAssert(theArray != NULL, POutOfMemory);
        memcpy(theArray, PAssertNULL(buffer), sizebytes);
    }
    else
        theArray = (char *)buffer;
}


void PAbstractArray::DestroyContents()
{
    if (theArray != NULL) {
        if (allocatedDynamically)
            free(theArray);
        theArray = NULL;
    }
}


void PAbstractArray::CopyContents(const PAbstractArray & array)
{
    elementSize = array.elementSize;
    theArray = array.theArray;
    allocatedDynamically = array.allocatedDynamically;
}


void PAbstractArray::CloneContents(const PAbstractArray * array)
{
    elementSize = array->elementSize;
    PINDEX sizebytes = elementSize*GetSize();
    char * newArray = (char *)malloc(sizebytes);
    if (newArray == NULL)
        reference->size = 0;
    else
        memcpy(newArray, array->theArray, sizebytes);
    theArray = newArray;
    allocatedDynamically = TRUE;
}


void PAbstractArray::PrintOn(ostream & strm) const
{
    char separator = strm.fill();
    int width = strm.width();
    for (PINDEX  i = 0; i < GetSize(); i++) {
        if (i > 0 && separator != '\0')
            strm << separator;
        strm.width(width);
        PrintElementOn(strm, i);
    }
    if (separator == '\n')
        strm << '\n';
}


void PAbstractArray::ReadFrom(istream & strm)
{
    PINDEX i = 0;
    while (strm.good()) {
        ReadElementFrom(strm, i);
        if (!strm.fail())
            i++;
    }
    SetSize(i);
}


PObject::Comparison PAbstractArray::Compare(const PObject & obj) const
{
    PAssert(PIsDescendant(&obj, PAbstractArray), PInvalidCast);
    const PAbstractArray & other = (const PAbstractArray &)obj;
    
    char * otherArray = other.theArray;
    if (theArray == otherArray)
        return EqualTo;
    
    if (elementSize < other.elementSize)
        return LessThan;
    
    if (elementSize > other.elementSize)
        return GreaterThan;
    
    PINDEX thisSize = GetSize();
    PINDEX otherSize = other.GetSize();
    
    if (thisSize < otherSize)
        return LessThan;
    
    if (thisSize > otherSize)
        return GreaterThan;
    
    if (thisSize == 0)
        return EqualTo;
    
    int retval = memcmp(theArray, otherArray, elementSize*thisSize);
    if (retval < 0)
        return LessThan;
    if (retval > 0)
        return GreaterThan;
    return EqualTo;
}


PBOOL PAbstractArray::SetSize(PINDEX newSize)
{
    return InternalSetSize(newSize, FALSE);
}


PBOOL PAbstractArray::InternalSetSize(PINDEX newSize, PBOOL force)
{
    if (newSize < 0)
        newSize = 0;
    
    PINDEX newsizebytes = elementSize*newSize;
    PINDEX oldsizebytes = elementSize*GetSize();
    
    if (!force && (newsizebytes == oldsizebytes))
        return TRUE;
    
    char * newArray;
    
#if PCONTAINER_USES_CRITSEC
    PEnterAndLeave m(reference->critSec);
#endif
    
    if (!IsUnique()) {
        
        if (newsizebytes == 0)
            newArray = NULL;
        else {
            if ((newArray = (char *)malloc(newsizebytes)) == NULL)
                return FALSE;
            
            if (theArray != NULL)
                memcpy(newArray, theArray, PMIN(oldsizebytes, newsizebytes));
        }
        
        --reference->count;
        reference = new Reference(newSize);
        
    } else {
        
        if (theArray != NULL) {
            if (newsizebytes == 0) {
                if (allocatedDynamically)
                    free(theArray);
                newArray = NULL;
            }
            else if (allocatedDynamically) {
                if ((newArray = (char *)realloc(theArray, newsizebytes)) == NULL)
                    return FALSE;
            }
            else {
                if ((newArray = (char *)malloc(newsizebytes)) == NULL)
                    return FALSE;
                memcpy(newArray, theArray, PMIN(newsizebytes, oldsizebytes));
                allocatedDynamically = TRUE;
            }
        }
        else if (newsizebytes != 0) {
            if ((newArray = (char *)malloc(newsizebytes)) == NULL)
                return FALSE;
        }
        else
            newArray = NULL;
        
        reference->size = newSize;
    }
    
    if (newsizebytes > oldsizebytes)
        memset(newArray+oldsizebytes, 0, newsizebytes-oldsizebytes);
    
    theArray = newArray;
    return TRUE;
}

void PAbstractArray::Attach(const void *buffer, PINDEX bufferSize)
{
    if (allocatedDynamically && theArray != NULL)
        free(theArray);
    
#if PCONTAINER_USES_CRITSEC
    PEnterAndLeave m(reference->critSec);
#endif
    
    theArray = (char *)buffer;
    reference->size = bufferSize;
    allocatedDynamically = FALSE;
}


void * PAbstractArray::GetPointer(PINDEX minSize)
{
    PAssert(SetMinSize(minSize), POutOfMemory);
    return theArray;
}


PBOOL PAbstractArray::Concatenate(const PAbstractArray & array)
{
    if (!allocatedDynamically || array.elementSize != elementSize)
        return FALSE;
    
    PINDEX oldLen = GetSize();
    PINDEX addLen = array.GetSize();
    
    if (!SetSize(oldLen + addLen))
        return FALSE;
    
    memcpy(theArray+oldLen*elementSize, array.theArray, addLen*elementSize);
    return TRUE;
}


void PAbstractArray::PrintElementOn(ostream & /*stream*/, PINDEX /*index*/) const
{
}


void PAbstractArray::ReadElementFrom(istream & /*stream*/, PINDEX /*index*/)
{
}


///////////////////////////////////////////////////////////////////////////////

void PCharArray::PrintOn(ostream & strm) const
{
    PINDEX width = strm.width();
    if (width > GetSize())
        width -= GetSize();
    else
        width = 0;
    
    PBOOL left = (strm.flags()&ios::adjustfield) == ios::left;
    if (left)
        strm.write(theArray, GetSize());
    
    while (width-- > 0)
        strm << (char)strm.fill();
    
    if (!left)
        strm.write(theArray, GetSize());
}


void PCharArray::ReadFrom(istream &strm)
{
    PINDEX size = 0;
    SetSize(size+100);
    
    while (strm.good()) {
        strm >> theArray[size++];
        if (size >= GetSize())
            SetSize(size+100);
    }
    
    SetSize(size);
}


void PBYTEArray::PrintOn(ostream & strm) const
{
    PINDEX line_width = strm.width();
    if (line_width == 0)
        line_width = 16;
    strm.width(0);
    
    PINDEX indent = strm.precision();
    
    PINDEX val_width = ((strm.flags()&ios::basefield) == ios::hex) ? 2 : 3;
    
    PINDEX i = 0;
    while (i < GetSize()) {
        if (i > 0)
            strm << '\n';
        PINDEX j;
        for (j = 0; j < indent; j++)
            strm << ' ';
        for (j = 0; j < line_width; j++) {
            if (j == line_width/2)
                strm << ' ';
            if (i+j < GetSize())
                strm << setw(val_width) << (theArray[i+j]&0xff);
            else {
                PINDEX k;
                for (k = 0; k < val_width; k++)
                    strm << ' ';
            }
            strm << ' ';
        }
        if ((strm.flags()&ios::floatfield) != ios::fixed) {
            strm << "  ";
            for (j = 0; j < line_width; j++) {
                if (i+j < GetSize()) {
                    unsigned val = theArray[i+j]&0xff;
                    if (isprint(val))
                        strm << (char)val;
                    else
                        strm << '.';
                }
            }
        }
        i += line_width;
    }
}


void PBYTEArray::ReadFrom(istream &strm)
{
    PINDEX size = 0;
    SetSize(size+100);
    
    while (strm.good()) {
        unsigned v;
        strm >> v;
        theArray[size] = (BYTE)v;
        if (!strm.fail()) {
            size++;
            if (size >= GetSize())
                SetSize(size+100);
        }
    }
    
    SetSize(size);
}


///////////////////////////////////////////////////////////////////////////////

PBitArray::PBitArray(PINDEX initialSize)
: PBYTEArray((initialSize+7)>>3)
{
}


PBitArray::PBitArray(const void * buffer,
                     PINDEX length,
                     PBOOL dynamic)
: PBYTEArray((const BYTE *)buffer, (length+7)>>3, dynamic)
{
}


PObject * PBitArray::Clone() const
{
    return new PBitArray(*this);
}


PINDEX PBitArray::GetSize() const
{
    return PBYTEArray::GetSize()<<3;
}


PBOOL PBitArray::SetSize(PINDEX newSize)
{
    return PBYTEArray::SetSize((newSize+7)>>3);
}


PBOOL PBitArray::SetAt(PINDEX index, PBOOL val)
{
    if (!SetMinSize(index+1))
        return FALSE;
    
    if (val)
        theArray[index>>3] |= (1 << (index&7));
    else
        theArray[index>>3] &= ~(1 << (index&7));
    return TRUE;
}


PBOOL PBitArray::GetAt(PINDEX index) const
{
    PASSERTINDEX(index);
    if (index >= GetSize())
        return FALSE;
    
    return (theArray[index>>3]&(1 << (index&7))) != 0;
}


void PBitArray::Attach(const void * buffer, PINDEX bufferSize)
{
    PBYTEArray::Attach((const BYTE *)buffer, (bufferSize+7)>>3);
}


BYTE * PBitArray::GetPointer(PINDEX minSize)
{
    return PBYTEArray::GetPointer((minSize+7)>>3);
}


PBOOL PBitArray::Concatenate(const PBitArray & array)
{
    return PAbstractArray::Concatenate(array);
}


///////////////////////////////////////////////////////////////////////////////

PString::PString(const char * cstr)
: PCharArray(cstr != NULL ? strlen(cstr)+1 : 1)
{
    if (cstr != NULL)
        memcpy(theArray, cstr, GetSize());
}


PString::PString(const wchar_t * ustr)
{
    if (ustr == NULL)
        SetSize(1);
    else {
        PINDEX len = 0;
        while (ustr[len] != 0)
            len++;
        InternalFromUCS2(ustr, len);
    }
}


PString::PString(const char * cstr, PINDEX len)
: PCharArray(len+1)
{
    if (len > 0)
        memcpy(theArray, PAssertNULL(cstr), len);
}


PString::PString(const wchar_t * ustr, PINDEX len)
: PCharArray(len+1)
{
    InternalFromUCS2(ustr, len);
}


PString::PString(const PWCharArray & ustr)
{
    InternalFromUCS2(ustr, ustr.GetSize());
}


static int TranslateHex(char x)
{
    if (x >= 'a')
        return x - 'a' + 10;
    
    if (x >= 'A')
        return x - 'A' + '\x0a';
    
    return x - '0';
}


static const unsigned char PStringEscapeCode[]  = {  'a',  'b',  'f',  'n',  'r',  't',  'v' };
static const unsigned char PStringEscapeValue[] = { '\a', '\b', '\f', '\n', '\r', '\t', '\v' };

static void TranslateEscapes(const char * src, char * dst)
{
    if (*src == '"')
        src++;
    
    while (*src != '\0') {
        int c = *src++ & 0xff;
        if (c == '"' && *src == '\0')
            c  = '\0'; // Trailing '"' is ignored
        else if (c == '\\') {
            c = *src++ & 0xff;
            for (PINDEX i = 0; i < PARRAYSIZE(PStringEscapeCode); i++) {
                if (c == PStringEscapeCode[i])
                    c = PStringEscapeValue[i];
            }
            
            if (c == 'x' && isxdigit(*src & 0xff)) {
                c = TranslateHex(*src++);
                if (isxdigit(*src & 0xff))
                    c = (c << 4) + TranslateHex(*src++);
            }
            else if (c >= '0' && c <= '7') {
                int count = c <= '3' ? 3 : 2;
                src--;
                c = 0;
                do {
                    c = (c << 3) + *src++ - '0';
                } while (--count > 0 && *src >= '0' && *src <= '7');
            }
        }
        
        *dst++ = (char)c;
    }
}


PString::PString(ConversionType type, const char * str, ...)
{
    switch (type) {
        case Pascal :
            if (*str != '\0') {
                PINDEX len = *str & 0xff;
                PAssert(SetSize(len+1), POutOfMemory);
                memcpy(theArray, str+1, len);
            }
            break;
            
        case Basic :
            if (str[0] != '\0' && str[1] != '\0') {
                PINDEX len = (str[0] & 0xff) | ((str[1] & 0xff) << 8);
                PAssert(SetSize(len+1), POutOfMemory);
                memcpy(theArray, str+2, len);
            }
            break;
            
        case Literal :
            PAssert(SetSize(strlen(str)+1), POutOfMemory);
            TranslateEscapes(str, theArray);
            PAssert(MakeMinimumSize(), POutOfMemory);
            break;
            
        case Printf : {
            va_list args;
            va_start(args, str);
            vsprintf(str, args);
            va_end(args);
            break;
        }
            
        default :
            PAssertAlways(PInvalidParameter);
    }
}


template <class T> char * p_unsigned2string(T value, T base, char * str)
{
    if (value >= base)
        str = p_unsigned2string<T>(value/base, base, str);
    value %= base;
    if (value < 10)
        *str = (char)(value + '0');
    else
        *str = (char)(value + 'A'-10);
    return str+1;
}


template <class T> char * p_signed2string(T value, T base, char * str)
{
    if (value >= 0)
        return p_unsigned2string<T>(value, base, str);
    
    *str = '-';
    return p_unsigned2string<T>(-value, base, str+1);
}


PString::PString(short n)
: PCharArray(sizeof(short)*3+1)
{
    p_signed2string<int>(n, 10, theArray);
    MakeMinimumSize();
}


PString::PString(unsigned short n)
: PCharArray(sizeof(unsigned short)*3+1)
{
    p_unsigned2string<unsigned int>(n, 10, theArray);
    MakeMinimumSize();
}


PString::PString(int n)
: PCharArray(sizeof(int)*3+1)
{
    p_signed2string<int>(n, 10, theArray);
    MakeMinimumSize();
}


PString::PString(unsigned int n)
: PCharArray(sizeof(unsigned int)*3+1)
{
    p_unsigned2string<unsigned int>(n, 10, theArray);
    MakeMinimumSize();
}


PString::PString(long n)
: PCharArray(sizeof(long)*3+1)
{
    p_signed2string<long>(n, 10, theArray);
    MakeMinimumSize();
}


PString::PString(unsigned long n)
: PCharArray(sizeof(unsigned long)*3+1)
{
    p_unsigned2string<unsigned long>(n, 10, theArray);
    MakeMinimumSize();
}


PString::PString(PInt64 n)
: PCharArray(sizeof(PInt64)*3+1)
{
    p_signed2string<PInt64>(n, 10, theArray);
    MakeMinimumSize();
}


PString::PString(PUInt64 n)
: PCharArray(sizeof(PUInt64)*3+1)
{
    p_unsigned2string<PUInt64>(n, 10, theArray);
    MakeMinimumSize();
}


PString::PString(ConversionType type, long value, unsigned base)
: PCharArray(sizeof(long)*3+1)
{
    PAssert(base >= 2 && base <= 36, PInvalidParameter);
    switch (type) {
        case Signed :
            p_signed2string<long>(value, base, theArray);
            break;
            
        case Unsigned :
            p_unsigned2string<unsigned long>(value, base, theArray);
            break;
            
        default :
            PAssertAlways(PInvalidParameter);
    }
    MakeMinimumSize();
}


PString::PString(ConversionType type, double value, unsigned places)
{
    switch (type) {
        case Decimal :
            sprintf("%0.*f", (int)places, value);
            break;
            
        case Exponent :
            sprintf("%0.*e", (int)places, value);
            break;
            
        default :
            PAssertAlways(PInvalidParameter);
    }
}


PString & PString::operator=(short n)
{
    SetMinSize(sizeof(short)*3+1);
    p_signed2string<int>(n, 10, theArray);
    MakeMinimumSize();
    return *this;
}


PString & PString::operator=(unsigned short n)
{
    SetMinSize(sizeof(unsigned short)*3+1);
    p_unsigned2string<unsigned int>(n, 10, theArray);
    MakeMinimumSize();
    return *this;
}


PString & PString::operator=(int n)
{
    SetMinSize(sizeof(int)*3+1);
    p_signed2string<int>(n, 10, theArray);
    MakeMinimumSize();
    return *this;
}


PString & PString::operator=(unsigned int n)
{
    SetMinSize(sizeof(unsigned int)*3+1);
    p_unsigned2string<unsigned int>(n, 10, theArray);
    MakeMinimumSize();
    return *this;
}


PString & PString::operator=(long n)
{
    SetMinSize(sizeof(long)*3+1);
    p_signed2string<long>(n, 10, theArray);
    MakeMinimumSize();
    return *this;
}


PString & PString::operator=(unsigned long n)
{
    SetMinSize(sizeof(unsigned long)*3+1);
    p_unsigned2string<unsigned long>(n, 10, theArray);
    MakeMinimumSize();
    return *this;
}


PString & PString::operator=(PInt64 n)
{
    SetMinSize(sizeof(PInt64)*3+1);
    p_signed2string<PInt64>(n, 10, theArray);
    MakeMinimumSize();
    return *this;
}


PString & PString::operator=(PUInt64 n)
{
    SetMinSize(sizeof(PUInt64)*3+1);
    p_unsigned2string<PUInt64>(n, 10, theArray);
    MakeMinimumSize();
    return *this;
}


PString & PString::MakeEmpty()
{
    SetSize(1);
    *theArray = '\0';
    return *this;
}


PObject * PString::Clone() const
{
    return new PString(*this);
}


void PString::PrintOn(ostream &strm) const
{
    strm << theArray;
}


void PString::ReadFrom(istream &strm)
{
    SetMinSize(100);
    char * ptr = theArray;
    PINDEX len = 0;
    int c;
    while ((c = strm.get()) != EOF && c != '\n') {
        *ptr++ = (char)c;
        len++;
        if (len >= GetSize()) {
            SetSize(len + 100);
            ptr = theArray + len;
        }
    }
    *ptr = '\0';
    if ((len > 0) && (ptr[-1] == '\r'))
        ptr[-1] = '\0';
    PAssert(MakeMinimumSize(), POutOfMemory);
}


PObject::Comparison PString::Compare(const PObject & obj) const
{
    PAssert(PIsDescendant(&obj, PString), PInvalidCast);
    return InternalCompare(0, P_MAX_INDEX, ((const PString &)obj).theArray);
}


PINDEX PString::HashFunction() const
{
    // Hash function from "Data Structures and Algorithm Analysis in C++" by
    // Mark Allen Weiss, with limit of only executing over first 8 characters to
    // increase speed when dealing with large strings.
    
    PINDEX hash = 0;
    for (PINDEX i = 0; i < 8 && theArray[i] != 0; i++)
        hash = (hash << 5) ^ tolower(theArray[i] & 0xff) ^ hash;
    return PABSINDEX(hash)%127;
}


PBOOL PString::IsEmpty() const
{
    return (theArray == NULL) || (*theArray == '\0');
}


PBOOL PString::SetSize(PINDEX newSize)
{
    return InternalSetSize(newSize, TRUE);
}


PBOOL PString::MakeUnique()
{
#if PCONTAINER_USES_CRITSEC
    PEnterAndLeave m(reference->critSec);
#endif
    
    if (IsUnique())
        return TRUE;
    
    InternalSetSize(GetSize(), TRUE);
    return FALSE;
}


PString PString::operator+(const char * cstr) const
{
    if (cstr == NULL)
        return *this;
    
    PINDEX olen = GetLength();
    PINDEX alen = strlen(cstr)+1;
    PString str;
    str.SetSize(olen+alen);
    memmove(str.theArray, theArray, olen);
    memcpy(str.theArray+olen, cstr, alen);
    return str;
}


PString PString::operator+(char c) const
{
    PINDEX olen = GetLength();
    PString str;
    str.SetSize(olen+2);
    memmove(str.theArray, theArray, olen);
    str.theArray[olen] = c;
    return str;
}


PString & PString::operator+=(const char * cstr)
{
    if (cstr == NULL)
        return *this;
    
    PINDEX olen = GetLength();
    PINDEX alen = strlen(cstr)+1;
    SetSize(olen+alen);
    memcpy(theArray+olen, cstr, alen);
    return *this;
}


PString & PString::operator+=(char ch)
{
    PINDEX olen = GetLength();
    SetSize(olen+2);
    theArray[olen] = ch;
    return *this;
}


PString PString::operator&(const char * cstr) const
{
    if (cstr == NULL)
        return *this;
    
    PINDEX alen = strlen(cstr)+1;
    if (alen == 1)
        return *this;
    
    PINDEX olen = GetLength();
    PString str;
    PINDEX space = olen > 0 && theArray[olen-1]!=' ' && *cstr!=' ' ? 1 : 0;
    str.SetSize(olen+alen+space);
    memmove(str.theArray, theArray, olen);
    if (space != 0)
        str.theArray[olen] = ' ';
    memcpy(str.theArray+olen+space, cstr, alen);
    return str;
}


PString PString::operator&(char c) const
{
    PINDEX olen = GetLength();
    PString str;
    PINDEX space = olen > 0 && theArray[olen-1] != ' ' && c != ' ' ? 1 : 0;
    str.SetSize(olen+2+space);
    memmove(str.theArray, theArray, olen);
    if (space != 0)
        str.theArray[olen] = ' ';
    str.theArray[olen+space] = c;
    return str;
}


PString & PString::operator&=(const char * cstr)
{
    if (cstr == NULL)
        return *this;
    
    PINDEX alen = strlen(cstr)+1;
    if (alen == 1)
        return *this;
    PINDEX olen = GetLength();
    PINDEX space = olen > 0 && theArray[olen-1]!=' ' && *cstr!=' ' ? 1 : 0;
    SetSize(olen+alen+space);
    if (space != 0)
        theArray[olen] = ' ';
    memcpy(theArray+olen+space, cstr, alen);
    return *this;
}


PString & PString::operator&=(char ch)
{
    PINDEX olen = GetLength();
    PINDEX space = olen > 0 && theArray[olen-1] != ' ' && ch != ' ' ? 1 : 0;
    SetSize(olen+2+space);
    if (space != 0)
        theArray[olen] = ' ';
    theArray[olen+space] = ch;
    return *this;
}


void PString::Delete(PINDEX start, PINDEX len)
{
    if (start < 0 || len < 0)
        return;
    
    MakeUnique();
    
    register PINDEX slen = GetLength();
    if (start > slen)
        return;
    
    if (len > slen - start)
        SetAt(start, '\0');
    else
        memmove(theArray+start, theArray+start+len, slen-start-len+1);
    MakeMinimumSize();
}


PString PString::operator()(PINDEX start, PINDEX end) const
{
    if (end < 0 || start < 0 || end < start)
        return Empty();
    
    register PINDEX len = GetLength();
    if (start > len)
        return Empty();
    
    if (end >= len) {
        if (start == 0)
            return *this;
        end = len-1;
    }
    len = end - start + 1;
    
    return PString(theArray+start, len);
}


PString PString::Left(PINDEX len) const
{
    if (len <= 0)
        return Empty();
    
    if (len >= GetLength())
        return *this;
    
    return PString(theArray, len);
}


PString PString::Right(PINDEX len) const
{
    if (len <= 0)
        return Empty();
    
    PINDEX srclen = GetLength();
    if (len >= srclen)
        return *this;
    
    return PString(theArray+srclen-len, len);
}


PString PString::Mid(PINDEX start, PINDEX len) const
{
    if (len <= 0 || start < 0)
        return Empty();
    
    if (start+len < start) // Beware of wraparound
        return operator()(start, P_MAX_INDEX);
    else{
        int end = start+len-1 ;
        if(end < 0){
            end =P_MAX_INDEX;
        }
        return operator()(start, end);
    }
}


bool PString::operator*=(const char * cstr) const
{
    if (cstr == NULL)
        return IsEmpty() != FALSE;
    
    const char * pstr = theArray;
    while (*pstr != '\0' && *cstr != '\0') {
        if (toupper(*pstr & 0xff) != toupper(*cstr & 0xff))
            return FALSE;
        pstr++;
        cstr++;
    }
    return *pstr == *cstr;
}


PObject::Comparison PString::NumCompare(const PString & str, PINDEX count, PINDEX offset) const
{
    if (offset < 0 || count < 0)
        return LessThan;
    PINDEX len = str.GetLength();
    if (count > len)
        count = len;
    return InternalCompare(offset, count, str);
}


PObject::Comparison PString::NumCompare(const char * cstr, PINDEX count, PINDEX offset) const
{
    if (offset < 0 || count < 0)
        return LessThan;
    PINDEX len = ::strlen(cstr);
    if (count > len)
        count = len;
    return InternalCompare(offset, count, cstr);
}


PObject::Comparison PString::InternalCompare(PINDEX offset, char c) const
{
    if (offset < 0)
        return LessThan;
    const int ch = theArray[offset] & 0xff;
    if (ch < (c & 0xff))
        return LessThan;
    if (ch > (c & 0xff))
        return GreaterThan;
    return EqualTo;
}


PObject::Comparison PString::InternalCompare(
                                             PINDEX offset, PINDEX length, const char * cstr) const
{
    if (offset < 0 || length < 0)
        return LessThan;
    
    if (offset == 0 && theArray == cstr)
        return EqualTo;
    
    if (offset < 0 || cstr == NULL)
        return IsEmpty() ? EqualTo : LessThan;
    
    int retval;
    if (length == P_MAX_INDEX)
        retval = strcmp(theArray+offset, cstr);
    else
        retval = strncmp(theArray+offset, cstr, length);
    
    if (retval < 0)
        return LessThan;
    
    if (retval > 0)
        return GreaterThan;
    
    return EqualTo;
}


PINDEX PString::Find(char ch, PINDEX offset) const
{
    if (offset < 0)
        return P_MAX_INDEX;
    
    register PINDEX len = GetLength();
    while (offset < len) {
        if (InternalCompare(offset, ch) == EqualTo)
            return offset;
        offset++;
    }
    return P_MAX_INDEX;
}


PINDEX PString::Find(const char * cstr, PINDEX offset) const
{
    if (cstr == NULL || *cstr == '\0' || offset < 0)
        return P_MAX_INDEX;
    
    PINDEX len = GetLength();
    PINDEX clen = strlen(cstr);
    if (clen > len)
        return P_MAX_INDEX;
    
    if (offset > len - clen)
        return P_MAX_INDEX;
    
    if (len - clen < 10) {
        while (offset+clen <= len) {
            if (InternalCompare(offset, clen, cstr) == EqualTo)
                return offset;
            offset++;
        }
        return P_MAX_INDEX;
    }
    
    int strSum = 0;
    int cstrSum = 0;
    for (PINDEX i = 0; i < clen; i++) {
        strSum += toupper(theArray[offset+i] & 0xff);
        cstrSum += toupper(cstr[i] & 0xff);
    }
    
    // search for a matching substring
    while (offset+clen <= len) {
        if (strSum == cstrSum && InternalCompare(offset, clen, cstr) == EqualTo)
            return offset;
        strSum += toupper(theArray[offset+clen] & 0xff);
        strSum -= toupper(theArray[offset] & 0xff);
        offset++;
    }
    
    return P_MAX_INDEX;
}


PINDEX PString::FindLast(char ch, PINDEX offset) const
{
    PINDEX len = GetLength();
    if (len == 0 || offset < 0)
        return P_MAX_INDEX;
    if (offset >= len)
        offset = len-1;
    
    while (InternalCompare(offset, ch) != EqualTo) {
        if (offset == 0)
            return P_MAX_INDEX;
        offset--;
    }
    
    return offset;
}


PINDEX PString::FindLast(const char * cstr, PINDEX offset) const
{
    if (cstr == NULL || *cstr == '\0' || offset < 0)
        return P_MAX_INDEX;
    
    PINDEX len = GetLength();
    PINDEX clen = strlen(cstr);
    if (clen > len)
        return P_MAX_INDEX;
    
    if (offset > len - clen)
        offset = len - clen;
    
    int strSum = 0;
    int cstrSum = 0;
    for (PINDEX i = 0; i < clen; i++) {
        strSum += toupper(theArray[offset+i] & 0xff);
        cstrSum += toupper(cstr[i] & 0xff);
    }
    
    // search for a matching substring
    while (strSum != cstrSum || InternalCompare(offset, clen, cstr) != EqualTo) {
        if (offset == 0)
            return P_MAX_INDEX;
        --offset;
        strSum += toupper(theArray[offset] & 0xff);
        strSum -= toupper(theArray[offset+clen] & 0xff);
    }
    
    return offset;
}


PINDEX PString::FindOneOf(const char * cset, PINDEX offset) const
{
    if (cset == NULL || *cset == '\0' || offset < 0)
        return P_MAX_INDEX;
    
    PINDEX len = GetLength();
    while (offset < len) {
        const char * p = cset;
        while (*p != '\0') {
            if (InternalCompare(offset, *p) == EqualTo)
                return offset;
            p++;
        }
        offset++;
    }
    return P_MAX_INDEX;
}

void PString::Replace(const PString & target,
                      const PString & subs,
                      PBOOL all, PINDEX offset)
{
    if (offset < 0)
        return;
    
    MakeUnique();
    
    PINDEX tlen = target.GetLength();
    PINDEX slen = subs.GetLength();
    do {
        PINDEX pos = Find(target, offset);
        if (pos == P_MAX_INDEX)
            return;
        Splice(subs, pos, tlen);
        offset = pos + slen;
    } while (all);
}


void PString::Splice(const char * cstr, PINDEX pos, PINDEX len)
{
    if (len < 0 || pos < 0)
        return;
    
    register PINDEX slen = GetLength();
    if (pos >= slen)
        operator+=(cstr);
    else {
        MakeUnique();
        PINDEX clen = cstr != NULL ? strlen(cstr) : 0;
        PINDEX newlen = slen-len+clen;
        if (clen > len)
            SetSize(newlen+1);
        if (pos+len < slen)
            memmove(theArray+pos+clen, theArray+pos+len, slen-pos-len+1);
        if (clen > 0)
            memcpy(theArray+pos, cstr, clen);
        theArray[newlen] = '\0';
    }
}


PStringArray
PString::Tokenise(const char * separators, PBOOL onePerSeparator) const
{
    PStringArray tokens;
    
    if (separators == NULL || IsEmpty())  // No tokens
        return tokens;
    
    PINDEX token = 0;
    PINDEX p1 = 0;
    PINDEX p2 = FindOneOf(separators);
    
    if (p2 == 0) {
        if (onePerSeparator) { // first character is a token separator
            tokens[token] = Empty();
            token++;                        // make first string in array empty
            p1 = 1;
            p2 = FindOneOf(separators, 1);
        }
        else {
            do {
                p1 = p2 + 1;
            } while ((p2 = FindOneOf(separators, p1)) == p1);
        }
    }
    
    while (p2 != P_MAX_INDEX) {
        if (p2 > p1)
            tokens[token] = operator()(p1, p2-1);
        else
            tokens[token] = Empty();
        token++;
        
        // Get next separator. If not one token per separator then continue
        // around loop to skip over all the consecutive separators.
        do {
            p1 = p2 + 1;
        } while ((p2 = FindOneOf(separators, p1)) == p1 && !onePerSeparator);
    }
    
    tokens[token] = operator()(p1, P_MAX_INDEX);
    
    return tokens;
}


PStringArray PString::Lines() const
{
    PStringArray lines;
    
    if (IsEmpty())
        return lines;
    
    PINDEX line = 0;
    PINDEX p1 = 0;
    PINDEX p2;
    while ((p2 = FindOneOf("\r\n", p1)) != P_MAX_INDEX) {
        lines[line++] = operator()(p1, p2-1);
        p1 = p2 + 1;
        if (theArray[p2] == '\r' && theArray[p1] == '\n') // CR LF pair
            p1++;
    }
    if (p1 < GetLength())
        lines[line] = operator()(p1, P_MAX_INDEX);
    return lines;
}

PStringArray & PStringArray::operator += (const PStringArray & v)
{
    PINDEX i;
    for (i = 0; i < v.GetSize(); i++)
        AppendString(v[i]);
    
    return *this;
}

PString PString::LeftTrim() const
{
    const char * lpos = theArray;
    while (isspace(*lpos & 0xff))
        lpos++;
    return PString(lpos);
}


PString PString::RightTrim() const
{
    char * rpos = theArray+GetLength()-1;
    if (isspace(*rpos & 0xff))
        return *this;
    
    while (isspace(*rpos & 0xff)) {
        if (rpos == theArray)
            return Empty();
        rpos--;
    }
    
    // make Apple & Tornado gnu compiler happy
    PString retval(theArray, rpos - theArray + 1);
    return retval;
}


PString PString::Trim() const
{
    const char * lpos = theArray;
    while (isspace(*lpos & 0xff))
        lpos++;
    if (*lpos == '\0')
        return Empty();
    
    const char * rpos = theArray+GetLength()-1;
    if (!isspace(*rpos & 0xff))
        return PString(lpos);
    
    while (isspace(*rpos & 0xff))
        rpos--;
    return PString(lpos, rpos - lpos + 1);
}


PString PString::ToLower() const
{
    PString newStr(theArray);
    for (char *cpos = newStr.theArray; *cpos != '\0'; cpos++) {
        if (isupper(*cpos & 0xff))
            *cpos = (char)tolower(*cpos & 0xff);
    }
    return newStr;
}


PString PString::ToUpper() const
{
    PString newStr(theArray);
    for (char *cpos = newStr.theArray; *cpos != '\0'; cpos++) {
        if (islower(*cpos & 0xff))
            *cpos = (char)toupper(*cpos & 0xff);
    }
    return newStr;
}


long PString::AsInteger(unsigned base) const
{
    PAssert(base >= 2 && base <= 36, PInvalidParameter);
    char * dummy;
    return strtol(theArray, &dummy, base);
}


DWORD PString::AsUnsigned(unsigned base) const
{
    PAssert(base >= 2 && base <= 36, PInvalidParameter);
    char * dummy;
    return strtoul(theArray, &dummy, base);
}


double PString::AsReal() const
{
#ifndef __HAS_NO_FLOAT
    char * dummy;
    return strtod(theArray, &dummy);
#else
    return 0.0;
#endif
}


//

//modified by brant
//add null trailing for return value
//and then add some code to BMPString in ASN
PWCharArray PString::AsUCS2() const
{
#ifdef P_HAS_G_CONVERT
    
    gsize g_len = 0;
    gchar * g_ucs2 = g_convert(theArray, GetLength(), "UCS-2", "UTF-8", 0, &g_len, 0);
    if (g_ucs2 == NULL)
        return PWCharArray();
    
    PWCharArray ucs2((const WORD *)g_ucs2, (PINDEX)g_len);
    g_free(g_ucs2);
    ucs2.SetSize(ucs2.GetSize()+1);
    return ucs2;
    
#else
    
    
    
    PINDEX length = GetLength();
    
    PWCharArray ucs2(length+1); // Always bigger than required
    
    PINDEX count = 0;
    PINDEX i = 0;
    while (i < length) {
        int c = theArray[i];
        if ((c&0x80) == 0)
            ucs2[count++] = (BYTE)theArray[i++];
        else if ((c&0xe0) == 0xc0) {
            if (i < length-1)
                ucs2[count++] = (WORD)(((theArray[i  ]&0x1f)<<6)|
                                       (theArray[i+1]&0x3f));
            i += 2;
        }
        else if ((c&0xf0) == 0xe0) {
            if (i < length-2)
                ucs2[count++] = (WORD)(((theArray[i  ]&0x0f)<<12)|
                                       ((theArray[i+1]&0x3f)<< 6)|
                                       (theArray[i+2]&0x3f));
            i += 3;
        }
        else {
            if ((c&0xf8) == 0xf0)
                i += 4;
            else if ((c&0xfc) == 0xf8)
                i += 5;
            else
                i += 6;
            if (i <= length)
                ucs2[count++] = 0xffff;
        }
    }
    
    ucs2.SetSize(count+1);
    return ucs2;
    
    
#endif
}


void PString::InternalFromUCS2(const wchar_t * ptr, PINDEX len)
{
    if (ptr == NULL || len <= 0) {
        *this = Empty();
        return;
    }
    
#ifdef P_HAS_G_CONVERT
    
    gsize g_len = 0;
    gchar * g_utf8 = g_convert(ptr, len, "UTF-8", "UCS-2", 0, &g_len, 0);
    if (g_utf8 == NULL) {
        *this = Empty();
        return;
    }
    
    SetSize(&g_len);
    memcpy(theArray, g_char, g_len);
    g_free(g_utf8);
    
#else
    
    PINDEX i;
    PINDEX count = 1;
    for (i = 0; i < len; i++) {
        if (ptr[i] < 0x80)
            count++;
        else if (ptr[i] < 0x800)
            count += 2;
        else
            count += 3;
    }
    SetSize(count);
    
    count = 0;
    for (i = 0; i < len; i++) {
        unsigned v = *ptr++;
        if (v < 0x80)
            theArray[count++] = (char)v;
        else if (v < 0x800) {
            theArray[count++] = (char)(0xc0|((v>>6)&0x1f));
            theArray[count++] = (char)(0x80|(v&0x3f));
        }
        else {
            theArray[count++] = (char)(0xe0|((v>>12)&0x1f));
            theArray[count++] = (char)(0x80|((v>>6)&0x3f));
            theArray[count++] = (char)(0x80|(v&0x3f));
        }
    }
    
#endif
}


PBYTEArray PString::ToPascal() const
{
    PINDEX len = GetLength();
    PAssert(len < 256, "Cannot convert to PASCAL string");
    BYTE buf[256];
    buf[0] = (BYTE)len;
    memcpy(&buf[1], theArray, len);
    return PBYTEArray(buf, len+1);
}


PString PString::ToLiteral() const
{
    PString str('"');
    for (char * p = theArray; *p != '\0'; p++) {
        if (*p == '"')
            str += "\\\"";
        else if (isprint(*p & 0xff))
            str += *p;
        else {
            PINDEX i;
            for (i = 0; i < PARRAYSIZE(PStringEscapeValue); i++) {
                if (*p == PStringEscapeValue[i]) {
                    str += PString('\\') + (char)PStringEscapeCode[i];
                    break;
                }
            }
            if (i >= PARRAYSIZE(PStringEscapeValue))
                str.sprintf("\\%03o", *p & 0xff);
        }
    }
    return str + '"';
}


PString & PString::sprintf(const char * fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    return vsprintf(fmt, args);
}

#if defined(__GNUC__) || defined(__SUNPRO_CC)
#define _vsnprintf vsnprintf
#endif

PString & PString::vsprintf(const char * fmt, va_list arg)
{
    PINDEX len = theArray != NULL ? GetLength() : 0;
    /*
     PINDEX size = 0;
     do {
     size += 1000;
     PAssert(SetSize(size), POutOfMemory);
     } while (_vsnprintf(theArray+len, size-len, fmt, arg) == -1);*/
    //modified by brant
    PINDEX size=100;
    for(;;)
    {
        PAssert(SetSize(size+len), POutOfMemory);
        PINDEX  n = _vsnprintf (theArray + len , size, fmt, arg);
        if (n > -1 && n < size)
            break;
        
        if (n > -1)    /* glibc 2.1 */
            size = n+1; /* precisely what is needed */
        else           /* glibc 2.0 */
            size *= 2;  /* twice the old size */
        
    }
    
    PAssert(MakeMinimumSize(), POutOfMemory);
    return *this;
}


PString psprintf(const char * fmt, ...)
{
    PString str;
    va_list args;
    va_start(args, fmt);
    return str.vsprintf(fmt, args);
}


PString pvsprintf(const char * fmt, va_list arg)
{
    PString str;
    return str.vsprintf(fmt, arg);
}


///////////////////////////////////////////////////////////////////////////////

PObject * PCaselessString::Clone() const
{
    return new PCaselessString(*this);
}


PObject::Comparison PCaselessString::InternalCompare(PINDEX offset, char c) const
{
    if (offset < 0)
        return LessThan;
    
    int c1 = toupper(theArray[offset] & 0xff);
    int c2 = toupper(c & 0xff);
    if (c1 < c2)
        return LessThan;
    if (c1 > c2)
        return GreaterThan;
    return EqualTo;
}


PObject::Comparison PCaselessString::InternalCompare(
                                                     PINDEX offset, PINDEX length, const char * cstr) const
{
    if (offset < 0 || length < 0)
        return LessThan;
    
    if (cstr == NULL)
        return IsEmpty() ? EqualTo : LessThan;
    
    while (length-- > 0 && (theArray[offset] != '\0' || *cstr != '\0')) {
        Comparison c = PCaselessString::InternalCompare(offset++, *cstr++);
        if (c != EqualTo)
            return c;
    }
    return EqualTo;
}



///////////////////////////////////////////////////////////////////////////////

PStringStream::Buffer::Buffer(PStringStream & str, PINDEX size)
: string(str),
fixedBufferSize(size != 0)
{
    string.SetMinSize(size > 0 ? size : 256);
    sync();
}


int PStringStream::Buffer::overflow(int c)
{
    if (pptr() >= epptr()) {
        if (fixedBufferSize)
            return EOF;
        
        int gpos = gptr() - eback();
        int ppos = pptr() - pbase();
        char * newptr = string.GetPointer(string.GetSize() + 32);
        setp(newptr, newptr + string.GetSize() - 1);
        pbump(ppos);
        setg(newptr, newptr + gpos, newptr + ppos);
    }
    
    if (c != EOF) {
        *pptr() = (char)c;
        pbump(1);
    }
    
    return 0;
}


int PStringStream::Buffer::underflow()
{
    return gptr() >= egptr() ? EOF : *gptr();
}


int PStringStream::Buffer::sync()
{
    char * base = string.GetPointer();
    PINDEX len = string.GetLength();
    setg(base, base, base + len);
    setp(base, base + string.GetSize() - 1);
    pbump(len);
    return 0;
}

#ifdef __USE_STL__
streambuf::pos_type PStringStream::Buffer::seekoff(off_type off, ios_base::seekdir dir, ios_base::openmode mode)
#else
streampos PStringStream::Buffer::seekoff(streamoff off, ios::seek_dir dir, int mode)
#endif
{
    int len = string.GetLength();
    int gpos = gptr() - eback();
    int ppos = pptr() - pbase();
    char * newgptr;
    char * newpptr;
    switch (dir) {
        case ios::beg :
            if (off < 0)
                newpptr = newgptr = eback();
            else if (off >= len)
                newpptr = newgptr = egptr();
            else
                newpptr = newgptr = eback()+off;
            break;
            
        case ios::cur :
            if (off < -ppos)
                newpptr = eback();
            else if (off >= len-ppos)
                newpptr = epptr();
            else
                newpptr = pptr()+off;
            if (off < -gpos)
                newgptr = eback();
            else if (off >= len-gpos)
                newgptr = egptr();
            else
                newgptr = gptr()+off;
            break;
            
        case ios::end :
            if (off < -len)
                newpptr = newgptr = eback();
            else if (off >= 0)
                newpptr = newgptr = egptr();
            else
                newpptr = newgptr = egptr()+off;
            break;
            
        default:
            PAssertAlways2(string.GetClass(), PInvalidParameter);
            newgptr = gptr();
            newpptr = pptr();
    }
    
    if ((mode&ios::in) != 0)
        setg(eback(), newgptr, egptr());
    
    if ((mode&ios::out) != 0)
        setp(newpptr, epptr());
    
    return 0;
}


#ifdef __USE_STL__
streampos PStringStream::Buffer::seekpos(pos_type pos, ios_base::openmode mode)
{
    return seekoff(pos, ios_base::beg, mode);
}
#endif


#ifdef _MSC_VER
#pragma warning(disable:4355)
#endif

PStringStream::PStringStream()
: iostream(new PStringStream::Buffer(*this, 0))
{
}


PStringStream::PStringStream(PINDEX fixedBufferSize)
: iostream(new PStringStream::Buffer(*this, fixedBufferSize))
{
}


PStringStream::PStringStream(const PString & str)
: PString(str),
iostream(new PStringStream::Buffer(*this, 0))
{
}


PStringStream::PStringStream(const char * cstr)
: PString(cstr),
iostream(new PStringStream::Buffer(*this, 0))
{
}

#ifdef _MSC_VER
#pragma warning(default:4355)
#endif


PStringStream::~PStringStream()
{
    delete (PStringStream::Buffer *)rdbuf();

    init(NULL);
}


PString & PStringStream::MakeEmpty()
{
    *theArray = '\0';
    flush();
    return *this;
}


void PStringStream::AssignContents(const PContainer & cont)
{
    PString::AssignContents(cont);
    flush();
}


///////////////////////////////////////////////////////////////////////////////

PStringArray::PStringArray(PINDEX count, char const * const * strarr, PBOOL caseless)
{
    if (count == 0)
        return;
    
    if (PAssertNULL(strarr) == NULL)
        return;
    
    if (count == P_MAX_INDEX) {
        count = 0;
        while (strarr[count] != NULL)
            count++;
    }
    
    SetSize(count);
    for (PINDEX i = 0; i < count; i++) {
        PString * newString;
        if (caseless)
            newString = new PCaselessString(strarr[i]);
        else
            newString = new PString(strarr[i]);
        SetAt(i, newString);
    }
}


PStringArray::PStringArray(const PString & str)
{
    SetSize(1);
    (*theArray)[0] = new PString(str);
}


PStringArray::PStringArray(const PStringList & list)
{
    SetSize(list.GetSize());
    for (PINDEX i = 0; i < list.GetSize(); i++)
        (*theArray)[i] = new PString(list[i]);
}


PStringArray::PStringArray(const PSortedStringList & list)
{
    SetSize(list.GetSize());
    for (PINDEX i = 0; i < list.GetSize(); i++)
        (*theArray)[i] = new PString(list[i]);
}


void PStringArray::ReadFrom(istream & strm)
{
    while (strm.good()) {
        PString str;
        strm >> str;
        AppendString(str);
    }
}


PString PStringArray::operator[](PINDEX index) const
{
    PASSERTINDEX(index);
    if (index < GetSize() && (*theArray)[index] != NULL)
        return *(PString *)(*theArray)[index];
    return PString::Empty();
}


PString & PStringArray::operator[](PINDEX index)
{
    PASSERTINDEX(index);
    PAssert(SetMinSize(index+1), POutOfMemory);
    if ((*theArray)[index] == NULL)
        (*theArray)[index] = new PString;
    return *(PString *)(*theArray)[index];
}


char ** PStringArray::ToCharArray(PCharArray * storage) const
{
    PINDEX i;
    
    PINDEX mySize = GetSize();
    PINDEX storageSize = (mySize+1)*sizeof(char *);
    for (i = 0; i < mySize; i++)
        storageSize += (*this)[i].GetLength()+1;
    
    char ** storagePtr;
    if (storage != NULL)
        storagePtr = (char **)storage->GetPointer(storageSize);
    else
        storagePtr = (char **)malloc(storageSize);
    
    if (storagePtr == NULL)
        return NULL;
    
    char * strPtr = (char *)&storagePtr[GetSize()+1];
    
    for (i = 0; i < mySize; i++) {
        storagePtr[i] = strPtr;
        const PString & str = (*this)[i];
        PINDEX len = str.GetLength()+1;
        memcpy(strPtr, (const char *)str, len);
        strPtr += len;
    }
    
    storagePtr[i] = NULL;
    
    return storagePtr;
}


///////////////////////////////////////////////////////////////////////////////

PStringList::PStringList(PINDEX count, char const * const * strarr, PBOOL caseless)
{
    if (count == 0)
        return;
    
    if (PAssertNULL(strarr) == NULL)
        return;
    
    for (PINDEX i = 0; i < count; i++) {
        PString * newString;
        if (caseless)
            newString = new PCaselessString(strarr[i]);
        else
            newString = new PString(strarr[i]);
        Append(newString);
    }
}


PStringList::PStringList(const PString & str)
{
    AppendString(str);
}


PStringList::PStringList(const PStringArray & array)
{
    for (PINDEX i = 0; i < array.GetSize(); i++)
        AppendString(array[i]);
}


PStringList::PStringList(const PSortedStringList & list)
{
    for (PINDEX i = 0; i < list.GetSize(); i++)
        AppendString(list[i]);
}

PStringList & PStringList::operator += (const PStringList & v)
{
    PINDEX i;
    for (i = 0; i < v.GetSize(); i++)
        AppendString(v[i]);
    
    return *this;
}


void PStringList::ReadFrom(istream & strm)
{
    while (strm.good()) {
        PString str;
        strm >> str;
        AppendString(str);
    }
}


///////////////////////////////////////////////////////////////////////////////

PSortedStringList::PSortedStringList(PINDEX count,
                                     char const * const * strarr,
                                     PBOOL caseless)
{
    if (count == 0)
        return;
    
    if (PAssertNULL(strarr) == NULL)
        return;
    
    for (PINDEX i = 0; i < count; i++) {
        PString * newString;
        if (caseless)
            newString = new PCaselessString(strarr[i]);
        else
            newString = new PString(strarr[i]);
        Append(newString);
    }
}


PSortedStringList::PSortedStringList(const PString & str)
{
    AppendString(str);
}


PSortedStringList::PSortedStringList(const PStringArray & array)
{
    for (PINDEX i = 0; i < array.GetSize(); i++)
        AppendString(array[i]);
}


PSortedStringList::PSortedStringList(const PStringList & list)
{
    for (PINDEX i = 0; i < list.GetSize(); i++)
        AppendString(list[i]);
}



void PSortedStringList::ReadFrom(istream & strm)
{
    while (strm.good()) {
        PString str;
        strm >> str;
        AppendString(str);
    }
}


PINDEX PSortedStringList::GetNextStringsIndex(const PString & str) const
{
    PINDEX len = str.GetLength();
    
    info->lastIndex = InternalStringSelect(str, len, info->root);
    
    if (info->lastIndex != 0) {
        Element * prev;
        while ((prev = info->Predecessor(info->lastElement)) != &info->pnil &&
               ((PString *)prev->data)->NumCompare(str, len) >= EqualTo) {
            info->lastElement = prev;
            info->lastIndex--;
        }
    }
    
    return info->lastIndex;
}


PINDEX PSortedStringList::InternalStringSelect(const char * str,
                                               PINDEX len,
                                               Element * thisElement) const
{
    if (thisElement == &info->pnil)
        return 0;
    
    switch (((PString *)thisElement->data)->NumCompare(str, len)) {
        case PObject::LessThan :
        {
            PINDEX index = InternalStringSelect(str, len, thisElement->right);
            return thisElement->left->subTreeSize + index + 1;
        }
            
        case PObject::GreaterThan :
            return InternalStringSelect(str, len, thisElement->left);
            
        default :
            info->lastElement = thisElement;
            return thisElement->left->subTreeSize;
    }
}


///////////////////////////////////////////////////////////////////////////////

PStringSet::PStringSet(PINDEX count, char const * const * strarr, PBOOL caseless)
{
    if (count == 0)
        return;
    
    if (PAssertNULL(strarr) == NULL)
        return;
    
    for (PINDEX i = 0; i < count; i++) {
        if (caseless)
            Include(PCaselessString(strarr[i]));
        else
            Include(PString(strarr[i]));
    }
}


PStringSet::PStringSet(const PString & str)
{
    Include(str);
}


void PStringSet::ReadFrom(istream & strm)
{
    while (strm.good()) {
        PString str;
        strm >> str;
        Include(str);
    }
}


///////////////////////////////////////////////////////////////////////////////

POrdinalToString::POrdinalToString(PINDEX count, const Initialiser * init)
{
    while (count-- > 0) {
        SetAt(init->key, init->value);
        init++;
    }
}


void POrdinalToString::ReadFrom(istream & strm)
{
    while (strm.good()) {
        POrdinalKey key;
        char equal;
        PString str;
        strm >> key >> ws >> equal >> str;
        if (equal != '=')
            SetAt(key, PString::Empty());
        else
            SetAt(key, str.Mid(equal+1));
    }
}


///////////////////////////////////////////////////////////////////////////////

PStringToOrdinal::PStringToOrdinal(PINDEX count,
                                   const Initialiser * init,
                                   PBOOL caseless)
{
    while (count-- > 0) {
        if (caseless)
            SetAt(PCaselessString(init->key), init->value);
        else
            SetAt(init->key, init->value);
        init++;
    }
}


void PStringToOrdinal::ReadFrom(istream & strm)
{
    while (strm.good()) {
        PString str;
        strm >> str;
        PINDEX equal = str.FindLast('=');
        if (equal == P_MAX_INDEX)
            SetAt(str, 0);
        else
            SetAt(str.Left(equal), str.Mid(equal+1).AsInteger());
    }
}


///////////////////////////////////////////////////////////////////////////////

PStringToString::PStringToString(PINDEX count,
                                 const Initialiser * init,
                                 PBOOL caselessKeys,
                                 PBOOL caselessValues)
{
    while (count-- > 0) {
        if (caselessValues)
            if (caselessKeys)
                SetAt(PCaselessString(init->key), PCaselessString(init->value));
            else
                SetAt(init->key, PCaselessString(init->value));
            else
                if (caselessKeys)
                    SetAt(PCaselessString(init->key), init->value);
                else
                    SetAt(init->key, init->value);
        init++;
    }
}


void PStringToString::ReadFrom(istream & strm)
{
    while (strm.good()) {
        PString str;
        strm >> str;
        PINDEX equal = str.Find('=');
        if (equal == P_MAX_INDEX)
            SetAt(str, PString::Empty());
        else
            SetAt(str.Left(equal), str.Mid(equal+1));
    }
}


//////////////////////////////////////////////////////////////////////////////
//collect.cxx

#define new PNEW
#undef  __CLASS__
#define __CLASS__ GetClass()

///////////////////////////////////////////////////////////////////////////////

void PCollection::PrintOn(ostream &strm) const
{
    char separator = strm.fill();
    int width = strm.width();
    for (PINDEX  i = 0; i < GetSize(); i++) {
        if (i > 0 && separator != ' ')
            strm << separator;
        PObject * obj = GetAt(i);
        if (obj != NULL) {
            if (separator != ' ')
                strm.width(width);
            strm << *obj;
        }
    }
    if (separator == '\n')
        strm << '\n';
}


void PCollection::RemoveAll()
{
    while (GetSize() > 0)
        RemoveAt(0);
}


///////////////////////////////////////////////////////////////////////////////

void PArrayObjects::CopyContents(const PArrayObjects & array)
{
    theArray = array.theArray;
}


void PArrayObjects::DestroyContents()
{
    if (reference->deleteObjects && theArray != NULL) {
        for (PINDEX i = 0; i < theArray->GetSize(); i++) {
            if ((*theArray)[i] != NULL)
                delete (*theArray)[i];
        }
    }
    delete theArray;
    theArray = NULL;
}


void PArrayObjects::RemoveAll()
{
    SetSize(0);
}


void PArrayObjects::CloneContents(const PArrayObjects * array)
{
    ObjPtrArray & oldArray = *array->theArray;
    theArray = new ObjPtrArray(oldArray.GetSize());
    for (PINDEX i = 0; i < GetSize(); i++) {
        PObject * ptr = oldArray[i];
        if (ptr != NULL)
            SetAt(i, ptr->Clone());
    }
}


PObject::Comparison PArrayObjects::Compare(const PObject & obj) const
{
    PAssert(PIsDescendant(&obj, PArrayObjects), PInvalidCast);
    const PArrayObjects & other = (const PArrayObjects &)obj;
    PINDEX i;
    for (i = 0; i < GetSize(); i++) {
        if (i >= other.GetSize() || *(*theArray)[i] < *(*other.theArray)[i])
            return LessThan;
        if (*(*theArray)[i] > *(*other.theArray)[i])
            return GreaterThan;
    }
    return i < other.GetSize() ? GreaterThan : EqualTo;
}


PINDEX PArrayObjects::GetSize() const
{
    return theArray->GetSize();
}


PBOOL PArrayObjects::SetSize(PINDEX newSize)
{
    PINDEX sz = theArray->GetSize();
    if (reference->deleteObjects && sz > 0) {
        for (PINDEX i = sz; i > newSize; i--) {
            PObject * obj = theArray->GetAt(i-1);
            if (obj != NULL)
                delete obj;
        }
    }
    return theArray->SetSize(newSize);
}


PINDEX PArrayObjects::Append(PObject * obj)
{
    PINDEX where = GetSize();
    SetAt(where, obj);
    return where;
}


PINDEX PArrayObjects::Insert(const PObject & before, PObject * obj)
{
    PINDEX where = GetObjectsIndex(&before);
    InsertAt(where, obj);
    return where;
}


PBOOL PArrayObjects::Remove(const PObject * obj)
{
    PINDEX i = GetObjectsIndex(obj);
    if (i == P_MAX_INDEX)
        return FALSE;
    RemoveAt(i);
    return TRUE;
}


PObject * PArrayObjects::GetAt(PINDEX index) const
{
    return (*theArray)[index];
}


PBOOL PArrayObjects::SetAt(PINDEX index, PObject * obj)
{
    if (!theArray->SetMinSize(index+1))
        return FALSE;
    PObject * oldObj = theArray->GetAt(index);
    if (oldObj != NULL && reference->deleteObjects)
        delete oldObj;
    (*theArray)[index] = obj;
    return TRUE;
}


PINDEX PArrayObjects::InsertAt(PINDEX index, PObject * obj)
{
    for (PINDEX i = GetSize(); i > index; i--)
        (*theArray)[i] = (*theArray)[i-1];
    (*theArray)[index] = obj;
    return index;
}


PObject * PArrayObjects::RemoveAt(PINDEX index)
{
    PObject * obj = (*theArray)[index];
    
    PINDEX size = GetSize()-1;
    PINDEX i;
    for (i = index; i < size; i++)
        (*theArray)[i] = (*theArray)[i+1];
    (*theArray)[i] = NULL;
    
    SetSize(size);
    
    if (obj != NULL && reference->deleteObjects) {
        delete obj;
        obj = NULL;
    }
    
    return obj;
}


PINDEX PArrayObjects::GetObjectsIndex(const PObject * obj) const
{
    for (PINDEX i = 0; i < GetSize(); i++) {
        if ((*theArray)[i] == obj)
            return i;
    }
    return P_MAX_INDEX;
}


PINDEX PArrayObjects::GetValuesIndex(const PObject & obj) const
{
    for (PINDEX i = 0; i < GetSize(); i++) {
        PObject * elmt = (*theArray)[i];
        if (elmt != NULL && *elmt == obj)
            return i;
    }
    return P_MAX_INDEX;
}


///////////////////////////////////////////////////////////////////////////////

void PAbstractList::DestroyContents()
{
    RemoveAll();
    delete info;
    info = NULL;
}


void PAbstractList::CopyContents(const PAbstractList & list)
{
    info = list.info;
}


void PAbstractList::CloneContents(const PAbstractList * list)
{
    Element * element = list->info->head;
    
    info = new Info;
    PAssert(info != NULL, POutOfMemory);
    
    while (element != NULL) {
        Element * newElement = new Element(element->data->Clone());
        
        if (info->head == NULL)
            info->head = info->tail = newElement;
        else {
            newElement->prev = info->tail;
            info->tail->next = newElement;
            info->tail = newElement;
        }
        
        element = element->next;
    }
}


PObject::Comparison PAbstractList::Compare(const PObject & obj) const
{
    PAssert(PIsDescendant(&obj, PAbstractList), PInvalidCast);
    Element * elmt1 = info->head;
    Element * elmt2 = ((const PAbstractList &)obj).info->head;
    while (elmt1 != NULL && elmt2 != NULL) {
        if (elmt1 == NULL)
            return LessThan;
        if (elmt2 == NULL)
            return GreaterThan;
        if (*elmt1->data < *elmt2->data)
            return LessThan;
        if (*elmt1->data > *elmt2->data)
            return GreaterThan;
        elmt1 = elmt1->next;
        elmt2 = elmt2->next;
    }
    return EqualTo;
}


PBOOL PAbstractList::SetSize(PINDEX)
{
    return TRUE;
}


PINDEX PAbstractList::Append(PObject * obj)
{
    if (PAssertNULL(obj) == NULL)
        return P_MAX_INDEX;
    
    Element * element = new Element(obj);
    if (info->tail != NULL)
        info->tail->next = element;
    element->prev = info->tail;
    element->next = NULL;
    if (info->head == NULL)
        info->head = element;
    info->tail = element;
    info->lastElement = element;
    info->lastIndex = GetSize();
    reference->size++;
    return info->lastIndex;
}


PINDEX PAbstractList::Insert(const PObject & before, PObject * obj)
{
    if (PAssertNULL(obj) == NULL)
        return P_MAX_INDEX;
    
    PINDEX where = GetObjectsIndex(&before);
    InsertAt(where, obj);
    return where;
}


PINDEX PAbstractList::InsertAt(PINDEX index, PObject * obj)
{
    if (PAssertNULL(obj) == NULL)
        return P_MAX_INDEX;
    
    if (index >= GetSize())
        return Append(obj);
    
    PAssert(SetCurrent(index), PInvalidArrayIndex);
    
    Element * newElement = new Element(obj);
    if (info->lastElement->prev != NULL)
        info->lastElement->prev->next = newElement;
    else
        info->head = newElement;
    newElement->prev = info->lastElement->prev;
    newElement->next = info->lastElement;
    info->lastElement->prev = newElement;
    info->lastElement = newElement;
    info->lastIndex = index;
    reference->size++;
    return index;
}


PBOOL PAbstractList::Remove(const PObject * obj)
{
    PINDEX i = GetObjectsIndex(obj);
    if (i == P_MAX_INDEX)
        return FALSE;
    RemoveAt(i);
    return TRUE;
}


PObject * PAbstractList::RemoveAt(PINDEX index)
{
    if (!SetCurrent(index)) {
        PAssertAlways(PInvalidArrayIndex);
        return NULL;
    }
    
    if(info == NULL){
        PAssertAlways("info is null");
        return NULL;
    }
    
    Element * elmt = info->lastElement;
    
    if(elmt == NULL){
        PAssertAlways("elmt is null");
        return NULL;
    }
    
    if (elmt->prev != NULL)
        elmt->prev->next = elmt->next;
    else {
        info->head = elmt->next;
        if (info->head != NULL)
            info->head->prev = NULL;
    }
    
    if (elmt->next != NULL)
        elmt->next->prev = elmt->prev;
    else {
        info->tail = elmt->prev;
        if (info->tail != NULL)
            info->tail->next = NULL;
    }
    
    if (elmt->next != NULL)
        info->lastElement = elmt->next;
    else {
        info->lastElement = elmt->prev;
        info->lastIndex--;
    }
    
    if((reference == NULL) || (reference->size == 0)){
        PAssertAlways("reference is null or reference->size == 0");
        return NULL;
    }
    reference->size--;
    
    PObject * obj = elmt->data;
    if (obj != NULL && reference->deleteObjects) {
        delete obj;
        obj = NULL;
    }
    delete elmt;
    return obj;
}


PObject * PAbstractList::GetAt(PINDEX index) const
{
    return SetCurrent(index) ? info->lastElement->data : (PObject *)NULL;
}


PBOOL PAbstractList::SetAt(PINDEX index, PObject * val)
{
    if (!SetCurrent(index))
        return FALSE;
    info->lastElement->data = val;
    return TRUE;
}

PBOOL PAbstractList::ReplaceAt(PINDEX index, PObject * val)
{
    if (!SetCurrent(index))
        return FALSE;
    
    if (info->lastElement->data != NULL && reference->deleteObjects) {
        delete info->lastElement->data;
    }
    
    info->lastElement->data = val;
    return TRUE;
}

PINDEX PAbstractList::GetObjectsIndex(const PObject * obj) const
{
    PINDEX index = 0;
    Element * element = info->head;
    while (element != NULL) {
        if (element->data == obj) {
            info->lastElement = element;
            info->lastIndex = index;
            return index;
        }
        element = element->next;
        index++;
    }
    
    return P_MAX_INDEX;
}


PINDEX PAbstractList::GetValuesIndex(const PObject & obj) const
{
    PINDEX index = 0;
    Element * element = info->head;
    while (element != NULL) {
        if (*element->data == obj) {
            info->lastElement = element;
            info->lastIndex = index;
            return index;
        }
        element = element->next;
        index++;
    }
    
    return P_MAX_INDEX;
}


PBOOL PAbstractList::SetCurrent(PINDEX index) const
{
    if (index >= GetSize())
        return FALSE;
    
    if (info->lastElement == NULL || info->lastIndex >= GetSize() ||
        index < info->lastIndex/2 || index > (info->lastIndex+GetSize())/2) {
        if (index < GetSize()/2) {
            info->lastIndex = 0;
            info->lastElement = info->head;
        }
        else {
            info->lastIndex = GetSize()-1;
            info->lastElement = info->tail;
        }
    }
    
    while (info->lastIndex < index) {
        info->lastElement = info->lastElement->next;
        info->lastIndex++;
    }
    
    while (info->lastIndex > index) {
        info->lastElement = info->lastElement->prev;
        info->lastIndex--;
    }
    
    return TRUE;
}


PAbstractList::Element::Element(PObject * theData)
{
    next = prev = NULL;
    data = theData;
}


///////////////////////////////////////////////////////////////////////////////

PAbstractSortedList::PAbstractSortedList()
{
    info = new Info;
    PAssert(info != NULL, POutOfMemory);
}


PAbstractSortedList::Info::Info()
{
    root = &pnil;
    lastElement = NULL;
    lastIndex = P_MAX_INDEX;
    pnil.parent = pnil.left = pnil.right = &pnil;
    pnil.subTreeSize = 0;
    pnil.colour = Element::Black;
    pnil.data = NULL;
}


void PAbstractSortedList::DestroyContents()
{
    RemoveAll();
    delete info;
    info = NULL;
}


void PAbstractSortedList::CopyContents(const PAbstractSortedList & list)
{
    info = list.info;
}


void PAbstractSortedList::CloneContents(const PAbstractSortedList * list)
{
    Info * otherInfo = list->info;
    
    info = new Info;
    PAssert(info != NULL, POutOfMemory);
    reference->size = 0;
    
    // Have to do this in this manner rather than just doing a for() loop
    // as "this" and "list" may be the same object and we just changed info in
    // "this" so we need to use the info in "list" saved previously.
    Element * element = otherInfo->OrderSelect(otherInfo->root, 1);
    while (element != &otherInfo->pnil) {
        Append(element->data->Clone());
        element = otherInfo->Successor(element);
    }
}


PBOOL PAbstractSortedList::SetSize(PINDEX)
{
    return TRUE;
}


PObject::Comparison PAbstractSortedList::Compare(const PObject & obj) const
{
    PAssert(PIsDescendant(&obj, PAbstractSortedList), PInvalidCast);
    Element * elmt1 = info->root;
    while (elmt1->left != &info->pnil)
        elmt1 = elmt1->left;
    
    Element * elmt2 = ((const PAbstractSortedList &)obj).info->root;
    while (elmt2->left != &info->pnil)
        elmt2 = elmt2->left;
    
    while (elmt1 != &info->pnil && elmt2 != &info->pnil) {
        if (elmt1 == &info->pnil)
            return LessThan;
        if (elmt2 == &info->pnil)
            return GreaterThan;
        if (*elmt1->data < *elmt2->data)
            return LessThan;
        if (*elmt1->data > *elmt2->data)
            return GreaterThan;
        elmt1 = info->Successor(elmt1);
        elmt2 = info->Successor(elmt2);
    }
    return EqualTo;
}


PINDEX PAbstractSortedList::Append(PObject * obj)
{
    if (PAssertNULL(obj) == NULL)
        return P_MAX_INDEX;
    
    Element * z = new Element;
    z->parent = z->left = z->right = &info->pnil;
    z->colour = Element::Black;
    z->subTreeSize = 1;
    z->data = obj;
    
    Element * x = info->root;
    Element * y = &info->pnil;
    while (x != &info->pnil) {
        x->subTreeSize++;
        y = x;
        x = *z->data < *x->data ? x->left : x->right;
    }
    z->parent = y;
    if (y == &info->pnil)
        info->root = z;
    else if (*z->data < *y->data)
        y->left = z;
    else
        y->right = z;
    
    info->lastElement = x = z;
    
    x->colour = Element::Red;
    while (x != info->root && x->parent->colour == Element::Red) {
        if (x->parent == x->parent->parent->left) {
            y = x->parent->parent->right;
            if (y->colour == Element::Red) {
                x->parent->colour = Element::Black;
                y->colour = Element::Black;
                x->parent->parent->colour = Element::Red;
                x = x->parent->parent;
            }
            else {
                if (x == x->parent->right) {
                    x = x->parent;
                    LeftRotate(x);
                }
                x->parent->colour = Element::Black;
                x->parent->parent->colour = Element::Red;
                RightRotate(x->parent->parent);
            }
        }
        else {
            y = x->parent->parent->left;
            if (y->colour == Element::Red) {
                x->parent->colour = Element::Black;
                y->colour = Element::Black;
                x->parent->parent->colour = Element::Red;
                x = x->parent->parent;
            }
            else {
                if (x == x->parent->left) {
                    x = x->parent;
                    RightRotate(x);
                }
                x->parent->colour = Element::Black;
                x->parent->parent->colour = Element::Red;
                LeftRotate(x->parent->parent);
            }
        }
    }
    
    info->root->colour = Element::Black;
    
    x = info->lastElement;
    info->lastIndex = x->left->subTreeSize;
    while (x != info->root) {
        if (x != x->parent->left)
            info->lastIndex += x->parent->left->subTreeSize+1;
        x = x->parent;
    }
    
    reference->size++;
    return info->lastIndex;
}


PBOOL PAbstractSortedList::Remove(const PObject * obj)
{
    if (GetObjectsIndex(obj) == P_MAX_INDEX)
        return FALSE;
    
    RemoveElement(info->lastElement);
    return TRUE;
}


PObject * PAbstractSortedList::RemoveAt(PINDEX index)
{
    Element * node = info->OrderSelect(info->root, index+1);
    if (node == &info->pnil)
        return NULL;
    
    PObject * data = node->data;
    RemoveElement(node);
    return reference->deleteObjects ? (PObject *)NULL : data;
}


void PAbstractSortedList::RemoveAll()
{
    if (info->root != &info->pnil) {
        DeleteSubTrees(info->root, reference->deleteObjects);
        delete info->root;
        info->root = &info->pnil;
        reference->size = 0;
    }
}


PINDEX PAbstractSortedList::Insert(const PObject &, PObject * obj)
{
    return Append(obj);
}


PINDEX PAbstractSortedList::InsertAt(PINDEX, PObject * obj)
{
    return Append(obj);
}


PBOOL PAbstractSortedList::SetAt(PINDEX, PObject *)
{
    return FALSE;
}


PObject * PAbstractSortedList::GetAt(PINDEX index) const
{
    if (index >= GetSize())
        return NULL;
    
    if (index != info->lastIndex) {
        if (index == info->lastIndex-1) {
            info->lastIndex--;
            info->lastElement = info->Predecessor(info->lastElement);
        }
        else if (index == info->lastIndex+1 && info->lastElement != NULL) {
            info->lastIndex++;
            info->lastElement = info->Successor(info->lastElement);
        }
        else {
            info->lastIndex = index;
            info->lastElement = info->OrderSelect(info->root, index+1);
        }
    }
    
    return PAssertNULL(info->lastElement)->data;
}


PINDEX PAbstractSortedList::GetObjectsIndex(const PObject * obj) const
{
    Element * elmt = NULL;
    PINDEX pos = ValueSelect(info->root, *obj, (const Element **)&elmt);
    if (pos == P_MAX_INDEX)
        return P_MAX_INDEX;
    
    if (elmt->data != obj) {
        PINDEX savePos = pos;
        Element * saveElmt = elmt;
        while (elmt->data != obj &&
               (elmt = info->Predecessor(elmt)) != &info->pnil &&
               *obj == *elmt->data)
            pos--;
        if (elmt->data != obj) {
            pos = savePos;
            elmt = saveElmt;
            while (elmt->data != obj &&
                   (elmt = info->Successor(elmt)) != &info->pnil &&
                   *obj == *elmt->data)
                pos++;
            if (elmt->data != obj)
                return P_MAX_INDEX;
        }
    }
    
    info->lastIndex = pos;
    info->lastElement = elmt;
    
    return pos;
}


PINDEX PAbstractSortedList::GetValuesIndex(const PObject & obj) const
{
    PINDEX pos = ValueSelect(info->root, obj, (const Element **)&info->lastElement);
    if (pos == P_MAX_INDEX)
        return P_MAX_INDEX;
    
    info->lastIndex = pos;
    
    Element * prev;
    while ((prev = info->Predecessor(info->lastElement)) != &info->pnil &&
           prev->data->Compare(obj) == EqualTo) {
        info->lastElement = prev;
        info->lastIndex--;
    }
    
    return info->lastIndex;
}


void PAbstractSortedList::RemoveElement(Element * node)
{
    // Don't try an remove one of the special leaf nodes!
    if (PAssertNULL(node) == &info->pnil)
        return;
    
    if (node->data != NULL && reference->deleteObjects)
        delete node->data;
    
    Element * y = node->left == &info->pnil || node->right == &info->pnil ? node : info->Successor(node);
    
    Element * t = y;
    while (t != &info->pnil) {
        t->subTreeSize--;
        t = t->parent;
    }
    
    Element * x = y->left != &info->pnil ? y->left : y->right;
    x->parent = y->parent;
    
    if (y->parent == &info->pnil)
        info->root = x;
    else if (y == y->parent->left)
        y->parent->left = x;
    else
        y->parent->right = x;
    
    if (y != node)
        node->data = y->data;
    
    if (y->colour == Element::Black) {
        while (x != info->root && x->colour == Element::Black) {
            if (x == x->parent->left) {
                Element * w = x->parent->right;
                if (w->colour == Element::Red) {
                    w->colour = Element::Black;
                    x->parent->colour = Element::Red;
                    LeftRotate(x->parent);
                    w = x->parent->right;
                }
                if (w->left->colour == Element::Black && w->right->colour == Element::Black) {
                    w->colour = Element::Red;
                    x = x->parent;
                }
                else {
                    if (w->right->colour == Element::Black) {
                        w->left->colour = Element::Black;
                        w->colour = Element::Red;
                        RightRotate(w);
                        w = x->parent->right;
                    }
                    w->colour = x->parent->colour;
                    x->parent->colour = Element::Black;
                    w->right->colour = Element::Black;
                    LeftRotate(x->parent);
                    x = info->root;
                }
            }
            else {
                Element * w = x->parent->left;
                if (w->colour == Element::Red) {
                    w->colour = Element::Black;
                    x->parent->colour = Element::Red;
                    RightRotate(x->parent);
                    w = x->parent->left;
                }
                if (w->right->colour == Element::Black && w->left->colour == Element::Black) {
                    w->colour = Element::Red;
                    x = x->parent;
                }
                else {
                    if (w->left->colour == Element::Black) {
                        w->right->colour = Element::Black;
                        w->colour = Element::Red;
                        LeftRotate(w);
                        w = x->parent->left;
                    }
                    w->colour = x->parent->colour;
                    x->parent->colour = Element::Black;
                    w->left->colour = Element::Black;
                    RightRotate(x->parent);
                    x = info->root;
                }
            }
        }
        x->colour = Element::Black;
    }
    
    delete y;
    
    reference->size--;
    info->lastIndex = P_MAX_INDEX;
    info->lastElement = NULL;
}


void PAbstractSortedList::LeftRotate(Element * node)
{
    Element * pivot = PAssertNULL(node)->right;
    node->right = pivot->left;
    if (pivot->left != &info->pnil)
        pivot->left->parent = node;
    pivot->parent = node->parent;
    if (node->parent == &info->pnil)
        info->root = pivot;
    else if (node == node->parent->left)
        node->parent->left = pivot;
    else
        node->parent->right = pivot;
    pivot->left = node;
    node->parent = pivot;
    pivot->subTreeSize = node->subTreeSize;
    node->subTreeSize = node->left->subTreeSize + node->right->subTreeSize + 1;
}


void PAbstractSortedList::RightRotate(Element * node)
{
    Element * pivot = PAssertNULL(node)->left;
    node->left = pivot->right;
    if (pivot->right != &info->pnil)
        pivot->right->parent = node;
    pivot->parent = node->parent;
    if (node->parent == &info->pnil)
        info->root = pivot;
    else if (node == node->parent->right)
        node->parent->right = pivot;
    else
        node->parent->left = pivot;
    pivot->right = node;
    node->parent = pivot;
    pivot->subTreeSize = node->subTreeSize;
    node->subTreeSize = node->left->subTreeSize + node->right->subTreeSize + 1;
}


PAbstractSortedList::Element * PAbstractSortedList::Info ::Successor(const Element * node) const
{
    Element * next;
    if (node->right != &pnil) {
        next = node->right;
        while (next->left != &pnil)
            next = next->left;
    }
    else {
        next = node->parent;
        while (next != &pnil && node == next->right) {
            node = next;
            next = node->parent;
        }
    }
    return next;
}


PAbstractSortedList::Element * PAbstractSortedList::Info ::Predecessor(const Element * node) const
{
    Element * pred;
    if (node->left != &pnil) {
        pred = node->left;
        while (pred->right != &pnil)
            pred = pred->right;
    }
    else {
        pred = node->parent;
        while (pred != &pnil && node == pred->left) {
            node = pred;
            pred = node->parent;
        }
    }
    return pred;
}


PAbstractSortedList::Element * PAbstractSortedList::Info::OrderSelect(Element * node, PINDEX index) const
{
    PINDEX r = node->left->subTreeSize+1;
    if (index == r)
        return node;
    
    if (index < r) {
        if (node->left != &pnil)
            return OrderSelect(node->left, index);
    }
    else {
        if (node->right != &pnil)
            return OrderSelect(node->right, index - r);
    }
    
    PAssertAlways2("PAbstractSortedList::Element", "Order select failed!");
    return (Element *)&pnil;
}


PINDEX PAbstractSortedList::ValueSelect(const Element * node,
                                        const PObject & obj,
                                        const Element ** lastElement) const
{
    if (node != &info->pnil) {
        switch (node->data->Compare(obj)) {
            case PObject::LessThan :
            {
                PINDEX index = ValueSelect(node->right, obj, lastElement);
                if (index != P_MAX_INDEX)
                    return node->left->subTreeSize + index + 1;
                break;
            }
                
            case PObject::GreaterThan :
                return ValueSelect(node->left, obj, lastElement);
                
            default :
                *lastElement = node;
                return node->left->subTreeSize;
        }
    }
    
    return P_MAX_INDEX;
}


void PAbstractSortedList::DeleteSubTrees(Element * node, PBOOL deleteObject)
{
    if (node->left != &info->pnil) {
        DeleteSubTrees(node->left, deleteObject);
        delete node->left;
        node->left = &info->pnil;
    }
    if (node->right != &info->pnil) {
        DeleteSubTrees(node->right, deleteObject);
        delete node->right;
        node->right = &info->pnil;
    }
    if (deleteObject) {
        delete node->data;
        node->data = NULL;
    }
}


///////////////////////////////////////////////////////////////////////////////

PObject * POrdinalKey::Clone() const
{
    return new POrdinalKey(theKey);
}


PObject::Comparison POrdinalKey::Compare(const PObject & obj) const
{
    PAssert(PIsDescendant(&obj, POrdinalKey), PInvalidCast);
    const POrdinalKey & other = (const POrdinalKey &)obj;
    
    if (theKey < other.theKey)
        return LessThan;
    
    if (theKey > other.theKey)
        return GreaterThan;
    
    return EqualTo;
}


PINDEX POrdinalKey::HashFunction() const
{
    return PABSINDEX(theKey)%23;
}


void POrdinalKey::PrintOn(ostream & strm) const
{
    strm << theKey;
}


///////////////////////////////////////////////////////////////////////////////

void PHashTable::Table::DestroyContents()
{
    for (PINDEX i = 0; i < GetSize(); i++) {
        Element * list = GetAt(i);
        if (list != NULL) {
            Element * elmt = list;
            do {
                Element * nextElmt = elmt->next;
                if (elmt->data != NULL && reference->deleteObjects)
                    delete elmt->data;
                if (deleteKeys)
                    delete elmt->key;
                delete elmt;
                elmt = nextElmt;
            } while (elmt != list);
        }
    }
    PAbstractArray::DestroyContents();
}


PINDEX PHashTable::Table::AppendElement(PObject * key, PObject * data)
{
    lastElement = NULL;
    
    PINDEX bucket = PAssertNULL(key)->HashFunction();
    Element * list = GetAt(bucket);
    Element * element = new Element;
    PAssert(element != NULL, POutOfMemory);
    element->key = key;
    element->data = data;
    if (list == NULL) {
        element->next = element->prev = element;
        SetAt(bucket, element);
    }
    else if (list == list->prev) {
        list->next = list->prev = element;
        element->next = element->prev = list;
    }
    else {
        element->next = list;
        element->prev = list->prev;
        list->prev->next = element;
        list->prev = element;
    }
    lastElement = element;
    lastIndex = P_MAX_INDEX;
    return bucket;
}


PObject * PHashTable::Table::RemoveElement(const PObject & key)
{
    PObject * obj = NULL;
    if (GetElementAt(key) != NULL) {
        if (lastElement == lastElement->prev)
            SetAt(key.HashFunction(), NULL);
        else {
            lastElement->prev->next = lastElement->next;
            lastElement->next->prev = lastElement->prev;
            SetAt(key.HashFunction(), lastElement->next);
        }
        obj = lastElement->data;
        if (deleteKeys)
            delete lastElement->key;
        delete lastElement;
        lastElement = NULL;
    }
    return obj;
}


PBOOL PHashTable::Table::SetLastElementAt(PINDEX index)
{
    if (index == 0 || lastElement == NULL || lastIndex == P_MAX_INDEX) {
        lastIndex = 0;
        lastBucket = 0;
        while ((lastElement = GetAt(lastBucket)) == NULL) {
            if (lastBucket >= GetSize())
                return FALSE;
            lastBucket++;
        }
    }
    
    if (lastIndex == index)
        return TRUE;
    
    if (lastIndex < index) {
        while (lastIndex != index) {
            if (lastElement->next != operator[](lastBucket))
                lastElement = lastElement->next;
            else {
                do {
                    if (++lastBucket >= GetSize())
                        return FALSE;
                } while ((lastElement = operator[](lastBucket)) == NULL);
            }
            lastIndex++;
        }
    }
    else {
        while (lastIndex != index) {
            if (lastElement != operator[](lastBucket))
                lastElement = lastElement->prev;
            else {
                do {
                    if (lastBucket-- == 0)
                        return FALSE;
                } while ((lastElement = operator[](lastBucket)) == NULL);
                lastElement = lastElement->prev;
            }
            lastIndex--;
        }
    }
    
    return TRUE;
}


PHashTable::Element * PHashTable::Table::GetElementAt(const PObject & key)
{
    if (lastElement != NULL && *lastElement->key == key)
        return lastElement;
    
    Element * list = GetAt(key.HashFunction());
    if (list != NULL) {
        Element * element = list;
        do {
            if (*element->key == key) {
                lastElement = element;
                lastIndex = P_MAX_INDEX;
                return lastElement;
            }
            element = element->next;
        } while (element != list);
    }
    return NULL;
}


PINDEX PHashTable::Table::GetElementsIndex(
                                           const PObject * obj, PBOOL byValue, PBOOL keys) const
{
    PINDEX index = 0;
    for (PINDEX i = 0; i < GetSize(); i++) {
        Element * list = operator[](i);
        if (list != NULL) {
            Element * element = list;
            do {
                PObject * keydata = keys ? element->key : element->data;
                if (byValue ? (*keydata == *obj) : (keydata == obj))
                    return index;
                element = element->next;
                index++;
            } while (element != list);
        }
    }
    return P_MAX_INDEX;
}


///////////////////////////////////////////////////////////////////////////////

PHashTable::PHashTable()
: hashTable(new PHashTable::Table)
{
    PAssert(hashTable != NULL, POutOfMemory);
    hashTable->lastElement = NULL;
}


void PHashTable::DestroyContents()
{
    if (hashTable != NULL) {
        hashTable->reference->deleteObjects = reference->deleteObjects;
        delete hashTable;
        hashTable = NULL;
    }
}


void PHashTable::CopyContents(const PHashTable & hash)
{
    hashTable = hash.hashTable;
}


void PHashTable::CloneContents(const PHashTable * hash)
{
    PINDEX sz = PAssertNULL(hash)->GetSize();
    PHashTable::Table * original = PAssertNULL(hash->hashTable);
    
    hashTable = new PHashTable::Table(original->GetSize());
    PAssert(hashTable != NULL, POutOfMemory);
    hashTable->lastElement = NULL;
    
    for (PINDEX i = 0; i < sz; i++) {
        original->SetLastElementAt(i);
        PObject * data = original->lastElement->data;
        if (data != NULL)
            data = data->Clone();
        hashTable->AppendElement(original->lastElement->key->Clone(), data);
    }
}


PObject::Comparison PHashTable::Compare(const PObject & obj) const
{
    PAssert(PIsDescendant(&obj, PHashTable), PInvalidCast);
    return reference != ((const PHashTable &)obj).reference
    ? GreaterThan : EqualTo;
}


PBOOL PHashTable::SetSize(PINDEX)
{
    return TRUE;
}


PObject & PHashTable::AbstractGetDataAt(PINDEX index) const
{
    PAssert(hashTable->SetLastElementAt(index), PInvalidArrayIndex);
    return *hashTable->lastElement->data;
}


const PObject & PHashTable::AbstractGetKeyAt(PINDEX index) const
{
    PAssert(hashTable->SetLastElementAt(index), PInvalidArrayIndex);
    return *hashTable->lastElement->key;
}


///////////////////////////////////////////////////////////////////////////////

void PAbstractSet::DestroyContents()
{
    hashTable->deleteKeys = reference->deleteObjects;
    PHashTable::DestroyContents();
}


void PAbstractSet::CopyContents(const PAbstractSet & )
{
}


void PAbstractSet::CloneContents(const PAbstractSet * )
{
}


PINDEX PAbstractSet::Append(PObject * obj)
{
    if (AbstractContains(*obj)) {
        if (reference->deleteObjects)
            delete obj;
        return P_MAX_INDEX;
    }
    
    reference->size++;
    return hashTable->AppendElement(obj, NULL);
}


PINDEX PAbstractSet::Insert(const PObject &, PObject * obj)
{
    return Append(obj);
}


PINDEX PAbstractSet::InsertAt(PINDEX, PObject * obj)
{
    return Append(obj);
}


PBOOL PAbstractSet::Remove(const PObject * obj)
{
    if (PAssertNULL(obj) == NULL)
        return FALSE;
    
    if (hashTable->GetElementAt(*obj) == NULL)
        return FALSE;
    
    hashTable->deleteKeys = hashTable->reference->deleteObjects = reference->deleteObjects;
    hashTable->RemoveElement(*obj);
    reference->size--;
    return TRUE;
}


PObject * PAbstractSet::RemoveAt(PINDEX index)
{
    if (!hashTable->SetLastElementAt(index))
        return NULL;
    
    PObject * obj = hashTable->lastElement->key;
    hashTable->deleteKeys = hashTable->reference->deleteObjects = reference->deleteObjects;
    hashTable->RemoveElement(*obj);
    reference->size--;
    return obj;
}


PINDEX PAbstractSet::GetObjectsIndex(const PObject * obj) const
{
    return hashTable->GetElementsIndex(obj, FALSE, TRUE);
}


PINDEX PAbstractSet::GetValuesIndex(const PObject & obj) const
{
    return hashTable->GetElementsIndex(&obj, TRUE, TRUE);
}


PObject * PAbstractSet::GetAt(PINDEX index) const
{
    return (PObject *)&AbstractGetKeyAt(index);
}


PBOOL PAbstractSet::SetAt(PINDEX, PObject * obj)
{
    return Append(obj);
}


///////////////////////////////////////////////////////////////////////////////

PINDEX PAbstractDictionary::Append(PObject *)
{
    PAssertAlways(PUnimplementedFunction);
    return 0;
}


PINDEX PAbstractDictionary::Insert(const PObject & before, PObject * obj)
{
    AbstractSetAt(before, obj);
    return 0;
}


PINDEX PAbstractDictionary::InsertAt(PINDEX index, PObject * obj)
{
    AbstractSetAt(AbstractGetKeyAt(index), obj);
    return index;
}


PBOOL PAbstractDictionary::Remove(const PObject * obj)
{
    PINDEX idx = GetObjectsIndex(obj);
    if (idx == P_MAX_INDEX)
        return FALSE;
    
    RemoveAt(idx);
    return TRUE;
}


PObject * PAbstractDictionary::RemoveAt(PINDEX index)
{
    PObject & obj = AbstractGetDataAt(index);
    AbstractSetAt(AbstractGetKeyAt(index), NULL);
    return &obj;
}


PINDEX PAbstractDictionary::GetObjectsIndex(const PObject * obj) const
{
    return hashTable->GetElementsIndex(obj, FALSE, FALSE);
}


PINDEX PAbstractDictionary::GetValuesIndex(const PObject & obj) const
{
    return hashTable->GetElementsIndex(&obj, TRUE, FALSE);
}


PBOOL PAbstractDictionary::SetAt(PINDEX index, PObject * val)
{
    return AbstractSetAt(AbstractGetKeyAt(index), val);
}


PObject * PAbstractDictionary::GetAt(PINDEX index) const
{
    PAssert(hashTable->SetLastElementAt(index), PInvalidArrayIndex);
    return hashTable->lastElement->data;
}


PBOOL PAbstractDictionary::SetDataAt(PINDEX index, PObject * val)
{
    return AbstractSetAt(AbstractGetKeyAt(index), val);
}


PBOOL PAbstractDictionary::AbstractSetAt(const PObject & key, PObject * obj)
{
    if (obj == NULL) {
        obj = hashTable->RemoveElement(key);
        if (obj != NULL) {
            if (reference->deleteObjects)
                delete obj;
            reference->size--;
        }
    }
    else {
        Element * element = hashTable->GetElementAt(key);
        if (element == NULL) {
            hashTable->AppendElement(key.Clone(), obj);
            reference->size++;
        }
        else {
            if ((reference->deleteObjects) && (hashTable->lastElement->data != obj)) 
                delete hashTable->lastElement->data;
            hashTable->lastElement->data = obj;
        }
    }
    return TRUE;
}


PObject * PAbstractDictionary::AbstractGetAt(const PObject & key) const
{
    Element * element = hashTable->GetElementAt(key);
    return element != NULL ? element->data : (PObject *)NULL;
}


PObject & PAbstractDictionary::GetRefAt(const PObject & key) const
{
    Element * element = hashTable->GetElementAt(key);
    return *PAssertNULL(element)->data;
}


void PAbstractDictionary::PrintOn(ostream &strm) const
{
    char separator = strm.fill();
    if (separator == ' ')
        separator = '\n';
    
    for (PINDEX i = 0; i < GetSize(); i++) {
        if (i > 0)
            strm << separator;
        strm << AbstractGetKeyAt(i) << '=' << AbstractGetDataAt(i);
    }
    
    if (separator == '\n')
        strm << separator;
}


// End Of collect.cxx ///////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////

// End Of File ///////////////////////////////////////////////////////////////
