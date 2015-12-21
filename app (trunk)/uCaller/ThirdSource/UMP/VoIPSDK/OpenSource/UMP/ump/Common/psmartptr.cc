//
//  psmartptr.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "psmartptr.h"


PSmartPointer::PSmartPointer(const PSmartPointer & ptr)
{
    object = ptr.object;
    if (object != NULL)
        ++object->referenceCount;
}


PSmartPointer & PSmartPointer::operator=(const PSmartPointer & ptr)
{
    if (object == ptr.object)
        return *this;
    
    if ((object != NULL) && (--object->referenceCount == 0))
        delete object;
    
    object = ptr.object;
    if (object != NULL)
        ++object->referenceCount;
    
    return *this;
}


PSmartPointer::~PSmartPointer()
{
    if ((object != NULL) && (--object->referenceCount == 0))
        delete object;
}


PObject::Comparison PSmartPointer::Compare(const PObject & obj) const
{
    PAssert(PIsDescendant(&obj, PSmartPointer), PInvalidCast);
    PSmartObject * other = ((const PSmartPointer &)obj).object;
    if (object == other)
        return EqualTo;
    return object < other ? LessThan : GreaterThan;
}
