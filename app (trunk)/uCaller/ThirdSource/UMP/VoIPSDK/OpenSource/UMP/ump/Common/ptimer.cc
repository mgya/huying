//
//  ptime.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "ptimer.h"
#include "pprocess.h"


PINLINE PTimeInterval::PTimeInterval(PInt64 millisecs)
: milliseconds(millisecs) { }


PINLINE PObject * PTimeInterval::Clone() const
{ return PNEW PTimeInterval(milliseconds); }

PINLINE PInt64 PTimeInterval::GetMilliSeconds() const
{ return milliseconds; }

PINLINE long PTimeInterval::GetSeconds() const
{ return (long)(milliseconds/1000); }

PINLINE long PTimeInterval::GetMinutes() const
{ return (long)(milliseconds/60000); }

PINLINE int PTimeInterval::GetHours() const
{ return (int)(milliseconds/3600000); }

PINLINE int PTimeInterval::GetDays() const
{ return (int)(milliseconds/86400000); }


PINLINE PTimeInterval PTimeInterval::operator-() const
{ return PTimeInterval(-milliseconds); }

PINLINE PTimeInterval PTimeInterval::operator+(const PTimeInterval & t) const
{ return PTimeInterval(milliseconds + t.milliseconds); }

PINLINE PTimeInterval & PTimeInterval::operator+=(const PTimeInterval & t)
{ milliseconds += t.milliseconds; return *this; }

PINLINE PTimeInterval PTimeInterval::operator-(const PTimeInterval & t) const
{ return PTimeInterval(milliseconds - t.milliseconds); }

PINLINE PTimeInterval & PTimeInterval::operator-=(const PTimeInterval & t)
{ milliseconds -= t.milliseconds; return *this; }

PINLINE PTimeInterval PTimeInterval::operator*(int f) const
{ return PTimeInterval(milliseconds * f); }

PINLINE PTimeInterval & PTimeInterval::operator*=(int f)
{ milliseconds *= f; return *this; }

PINLINE PTimeInterval PTimeInterval::operator/(int f) const
{ return PTimeInterval(milliseconds / f); }

PINLINE PTimeInterval & PTimeInterval::operator/=(int f)
{ milliseconds /= f; return *this; }


PINLINE bool PTimeInterval::operator==(const PTimeInterval & t) const
{ return milliseconds == t.milliseconds; }

PINLINE bool PTimeInterval::operator!=(const PTimeInterval & t) const
{ return milliseconds != t.milliseconds; }

PINLINE bool PTimeInterval::operator> (const PTimeInterval & t) const
{ return milliseconds > t.milliseconds; }

PINLINE bool PTimeInterval::operator>=(const PTimeInterval & t) const
{ return milliseconds >= t.milliseconds; }

PINLINE bool PTimeInterval::operator< (const PTimeInterval & t) const
{ return milliseconds < t.milliseconds; }

PINLINE bool PTimeInterval::operator<=(const PTimeInterval & t) const
{ return milliseconds <= t.milliseconds; }

PINLINE bool PTimeInterval::operator==(long msecs) const
{ return (long)milliseconds == msecs; }

PINLINE bool PTimeInterval::operator!=(long msecs) const
{ return (long)milliseconds != msecs; }

PINLINE bool PTimeInterval::operator> (long msecs) const
{ return (long)milliseconds > msecs; }

PINLINE bool PTimeInterval::operator>=(long msecs) const
{ return (long)milliseconds >= msecs; }

PINLINE bool PTimeInterval::operator< (long msecs) const
{ return (long)milliseconds < msecs; }

PINLINE bool PTimeInterval::operator<=(long msecs) const
{ return (long)milliseconds <= msecs; }

DWORD PTimeInterval::GetInterval() const
{
	//modified by brant
    
	//make it safe for overflow
	return (DWORD)(milliseconds&UINT_MAX);
    /*
     if (milliseconds <= 0)
     return 0;
     
     if (milliseconds >= UINT_MAX)
     return UINT_MAX;
     
     return (DWORD)milliseconds;*/
    
}



PTimeInterval::PTimeInterval(long millisecs,
                             long seconds,
                             long minutes,
                             long hours,
                             int days)
{
    SetInterval(millisecs, seconds, minutes, hours, days);
}


PTimeInterval::PTimeInterval(const PString & str)
{
    PStringStream strm(str);
    ReadFrom(strm);
}


PObject::Comparison PTimeInterval::Compare(const PObject & obj) const
{
    PAssert(PIsDescendant(&obj, PTimeInterval), PInvalidCast);
    const PTimeInterval & other = (const PTimeInterval &)obj;
    return milliseconds < other.milliseconds ? LessThan :
    milliseconds > other.milliseconds ? GreaterThan : EqualTo;
}


void PTimeInterval::PrintOn(ostream & stream) const
{
    int precision = stream.precision();
    
    Formats fmt = NormalFormat;
    if ((stream.flags()&ios::scientific) != 0)
        fmt = SecondsOnly;
    else if (precision < 0) {
        fmt = IncludeDays;
        precision = -precision;
    }
    
    stream << AsString(precision, fmt, stream.width());
}


void PTimeInterval::ReadFrom(istream &strm)
{
    long day = 0;
    long hour = 0;
    long min = 0;
    float sec;
    strm >> sec;
    while (strm.peek() == ':') {
        day = hour;
        hour = min;
        min = (long)sec;
        strm.get();
        strm >> sec;
    }
    
    SetInterval(((long)(sec*1000))%1000, (int)sec, min, hour, day);
}


PString PTimeInterval::AsString(int precision, Formats format, int width) const
{
    PStringStream str;
    
    if (precision > 3)
        precision = 3;
    else if (precision < 0)
        precision = 0;
    
    PInt64 ms = milliseconds;
    if (ms < 0) {
        str << '-';
        ms = -ms;
    }
    
    if (format == SecondsOnly) {
        switch (precision) {
            case 1 :
                str << ms/1000 << '.' << (int)(ms%1000+50)/100;
                break;
                
            case 2 :
                str << ms/1000 << '.' << setw(2) << (int)(ms%1000+5)/10;
                break;
                
            case 3 :
                str << ms/1000 << '.' << setw(3) << (int)(ms%1000);
                break;
                
            default :
                str << (ms+500)/1000;
        }
        
        return str;
    }
    
    PBOOL hadPrevious = FALSE;
    long tmp;
    
    str.fill('0');
    
    if (format == IncludeDays) {
        tmp = (long)(ms/86400000);
        if (tmp > 0 || width > (precision+10)) {
            str << tmp << 'd';
            hadPrevious = TRUE;
        }
        
        tmp = (long)(ms%86400000)/3600000;
    }
    else
        tmp = (long)(ms/3600000);
    
    if (hadPrevious || tmp > 0 || width > (precision+7)) {
        if (hadPrevious)
            str.width(2);
        str << tmp << ':';
        hadPrevious = TRUE;
    }
    
    tmp = (long)(ms%3600000)/60000;
    if (hadPrevious || tmp > 0 || width > (precision+4)) {
        if (hadPrevious)
            str.width(2);
        str << tmp << ':';
        hadPrevious = TRUE;
    }
    
    if (hadPrevious)
        str.width(2);
    str << (long)(ms%60000)/1000;
    
    switch (precision) {
        case 1 :
            str << '.' << (int)(ms%1000)/100;
            break;
            
        case 2 :
            str << '.' << setw(2) << (int)(ms%1000)/10;
            break;
            
        case 3 :
            str << '.' << setw(3) << (int)(ms%1000);
    }
    
    return str;
}


void PTimeInterval::SetInterval(PInt64 millisecs,
                                long seconds,
                                long minutes,
                                long hours,
                                int days)
{
    milliseconds = days;
    milliseconds *= 24;
    milliseconds += hours;
    milliseconds *= 60;
    milliseconds += minutes;
    milliseconds *= 60;
    milliseconds += seconds;
    milliseconds *= 1000;
    milliseconds += millisecs;
}

// P_timeval

P_timeval::P_timeval()
{
    tval.tv_usec = 0;
    tval.tv_sec = 0;
    infinite = FALSE;
}


P_timeval & P_timeval::operator=(const PTimeInterval & time)
{
    infinite = time == PMaxTimeInterval;
    //modified by brant
    DWORD t=time.GetInterval();
    
	tval.tv_usec = (long)(t%1000)*1000;
	tval.tv_sec = t/1000;
    
    /*
     tval.tv_usec = (long)(time.GetMilliSeconds()%1000)*1000;
     tval.tv_sec = time.GetSeconds();*/
    
    return *this;
}

// PTime

PINLINE PObject * PTime::Clone() const
{ return PNEW PTime(theTime, microseconds); }

PINLINE void PTime::PrintOn(ostream & strm) const
{ strm << AsString(); }

PINLINE PBOOL PTime::IsValid() const
{ return theTime > 46800; }

PINLINE PInt64 PTime::GetTimestamp() const
{ return theTime*(PInt64)1000000 + microseconds; }

PINLINE time_t PTime::GetTimeInSeconds() const
{ return theTime; }

PINLINE long PTime::GetMicrosecond() const
{ return microseconds; }

PINLINE int PTime::GetSecond() const
{ struct tm ts; return os_localtime(&theTime, &ts)->tm_sec; }

PINLINE int PTime::GetMinute() const
{ struct tm ts; return os_localtime(&theTime, &ts)->tm_min; }

PINLINE int PTime::GetHour() const
{ struct tm ts; return os_localtime(&theTime, &ts)->tm_hour; }

PINLINE int PTime::GetDay() const
{ struct tm ts; return os_localtime(&theTime, &ts)->tm_mday; }

PINLINE PTime::Months PTime::GetMonth() const
{ struct tm ts; return (Months)(os_localtime(&theTime, &ts)->tm_mon+January); }

PINLINE int PTime::GetYear() const
{ struct tm ts; return os_localtime(&theTime, &ts)->tm_year+1900; }

PINLINE PTime::Weekdays PTime::GetDayOfWeek() const
{ struct tm ts; return (Weekdays)os_localtime(&theTime, &ts)->tm_wday; }

PINLINE int PTime::GetDayOfYear() const
{ struct tm ts; return os_localtime(&theTime, &ts)->tm_yday; }

PINLINE PBOOL PTime::IsPast() const
{ return theTime < time(NULL); }

PINLINE PBOOL PTime::IsFuture() const
{ return theTime > time(NULL); }


PINLINE PString PTime::AsString(const PString & format, int zone) const
{ return AsString((const char *)format, zone); }

PINLINE int PTime::GetTimeZone()
{ return GetTimeZone(IsDaylightSavings() ? DaylightSavings : StandardTime); }


///////////////////////////////////////////////////////////////////////////////
// PTimer

PINLINE PBOOL PTimer::IsRunning() const
{ return state == Starting || state == Running; }

PINLINE PBOOL PTimer::IsPaused() const
{ return state == Paused; }

PINLINE const PTimeInterval & PTimer::GetResetTime() const
{ return resetTime; }

PINLINE const PNotifier & PTimer::GetNotifier() const
{ return callback; }

PINLINE void PTimer::SetNotifier(const PNotifier & func)
{ callback = func; }


PTime::PTime()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    theTime = tv.tv_sec;
    microseconds = tv.tv_usec;
}


PBOOL PTime::GetTimeAMPM()
{
#if defined(P_USE_LANGINFO)
    return strstr(nl_langinfo(T_FMT), "%p") != NULL;
#elif defined(P_USE_STRFTIME)
    char buf[30];
    struct tm t;
    memset(&t, 0, sizeof(t));
    t.tm_hour = 20;
    t.tm_min = 12;
    t.tm_sec = 11;
    strftime(buf, sizeof(buf), "%X", &t);
    return strstr(buf, "20") != NULL;
#else
#warning No AMPM implementation
    return FALSE;
#endif
}


PString PTime::GetTimeAM()
{
#if defined(P_USE_LANGINFO)
    return PString(nl_langinfo(AM_STR));
#elif defined(P_USE_STRFTIME)
    char buf[30];
    struct tm t;
    memset(&t, 0, sizeof(t));
    t.tm_hour = 10;
    t.tm_min = 12;
    t.tm_sec = 11;
    strftime(buf, sizeof(buf), "%p", &t);
    return buf;
#else
#warning Using default AM string
    return "AM";
#endif
}


PString PTime::GetTimePM()
{
#if defined(P_USE_LANGINFO)
    return PString(nl_langinfo(PM_STR));
#elif defined(P_USE_STRFTIME)
    char buf[30];
    struct tm t;
    memset(&t, 0, sizeof(t));
    t.tm_hour = 20;
    t.tm_min = 12;
    t.tm_sec = 11;
    strftime(buf, sizeof(buf), "%p", &t);
    return buf;
#else
#warning Using default PM string
    return "PM";
#endif
}


PString PTime::GetTimeSeparator()
{
#if defined(P_LINUX) && !defined(VOIPBASE_ANDROID)
#  if defined(P_USE_LANGINFO)
    char * p = nl_langinfo(T_FMT);
#  elif defined(P_LINUX)
    char * p = _time_info->time;
#  endif
    char buffer[2];
    while (*p == '%' || isalpha(*p))
        p++;
    buffer[0] = *p;
    buffer[1] = '\0';
    return PString(buffer);
#elif defined(P_USE_STRFTIME)
    char buf[30];
    struct tm t;
    memset(&t, 0, sizeof(t));
    t.tm_hour = 10;
    t.tm_min = 11;
    t.tm_sec = 12;
    strftime(buf, sizeof(buf), "%X", &t);
    char * sp = strstr(buf, "11") + 2;
    char * ep = sp;
    while (*ep != '\0' && !isdigit(*ep))
        ep++;
    return PString(sp, ep-sp);
#else
#warning Using default time separator
    return ":";
#endif
}

PTime::DateOrder PTime::GetDateOrder()
{
#if defined(P_USE_LANGINFO) || (defined(P_LINUX) && !defined(VOIPBASE_ANDROID))
#  if defined(P_USE_LANGINFO)
    char * p = nl_langinfo(D_FMT);
#  else
    char * p = _time_info->date;
#  endif
    
    while (*p == '%')
        p++;
    switch (tolower(*p)) {
        case 'd':
            return DayMonthYear;
        case 'y':
            return YearMonthDay;
        case 'm':
        default:
            break;
    }
    return MonthDayYear;
    
#elif defined(P_USE_STRFTIME)
    char buf[30];
    struct tm t;
    memset(&t, 0, sizeof(t));
    t.tm_mday = 22;
    t.tm_mon = 10;
    t.tm_year = 99;
    strftime(buf, sizeof(buf), "%x", &t);
    char * day_pos = strstr(buf, "22");
    char * mon_pos = strstr(buf, "11");
    char * yr_pos = strstr(buf, "99");
    if (yr_pos < day_pos)
        return YearMonthDay;
    if (day_pos < mon_pos)
        return DayMonthYear;
    return MonthDayYear;
#else
#warning Using default date order
    return DayMonthYear;
#endif
}

PString PTime::GetDateSeparator()
{
#if defined(P_USE_LANGINFO) || (defined(P_LINUX) && !defined(VOIPBASE_ANDROID))
#  if defined(P_USE_LANGINFO)
    char * p = nl_langinfo(D_FMT);
#  else
    char * p = _time_info->date;
#  endif
    char buffer[2];
    while (*p == '%' || isalpha(*p))
        p++;
    buffer[0] = *p;
    buffer[1] = '\0';
    return PString(buffer);
#elif defined(P_USE_STRFTIME)
    char buf[30];
    struct tm t;
    memset(&t, 0, sizeof(t));
    t.tm_mday = 22;
    t.tm_mon = 10;
    t.tm_year = 99;
    strftime(buf, sizeof(buf), "%x", &t);
    char * sp = strstr(buf, "22") + 2;
    char * ep = sp;
    while (*ep != '\0' && !isdigit(*ep))
        ep++;
    return PString(sp, ep-sp);
#else
#warning Using default date separator
    return "/";
#endif
}

PString PTime::GetDayName(PTime::Weekdays day, NameType type)
{
#if defined(P_USE_LANGINFO)
    return PString(
                   (type == Abbreviated) ? nl_langinfo((nl_item)(ABDAY_1+(int)day)) :
                   nl_langinfo((nl_item)(DAY_1+(int)day))
                   );
    
#elif (defined(P_LINUX) && !defined(VOIPBASE_ANDROID))
    return (type == Abbreviated) ? PString(_time_info->abbrev_wkday[(int)day]) :
    PString(_time_info->full_wkday[(int)day]);
    
#elif defined(P_USE_STRFTIME)
    char buf[30];
    struct tm t;
    memset(&t, 0, sizeof(t));
    t.tm_wday = day;
    strftime(buf, sizeof(buf), type == Abbreviated ? "%a" : "%A", &t);
    return buf;
#else
#warning Using default day names
    static char *defaultNames[] = {
        "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday",
        "Saturday"
    };
    
    static char *defaultAbbrev[] = {
        "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
    };
    return (type == Abbreviated) ? PString(defaultNames[(int)day]) :
    PString(defaultAbbrev[(int)day]);
#endif
}

PString PTime::GetMonthName(PTime::Months month, NameType type)
{
#if defined(P_USE_LANGINFO)
    return PString(
                   (type == Abbreviated) ? nl_langinfo((nl_item)(ABMON_1+(int)month-1)) :
                   nl_langinfo((nl_item)(MON_1+(int)month-1))
                   );
#elif (defined(P_LINUX) && !defined(VOIPBASE_ANDROID))
    return (type == Abbreviated) ? PString(_time_info->abbrev_month[(int)month-1]) :
    PString(_time_info->full_month[(int)month-1]);
#elif defined(P_USE_STRFTIME)
    char buf[30];
    struct tm t;
    memset(&t, 0, sizeof(t));
    t.tm_mon = month-1;
    strftime(buf, sizeof(buf), type == Abbreviated ? "%b" : "%B", &t);
    return buf;
#else
#warning Using default monthnames
    static char *defaultNames[] = {
        "January", "February", "March", "April", "May", "June", "July", "August",
        "September", "October", "November", "December" };
    
    static char *defaultAbbrev[] = {
        "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug",
        "Sep", "Oct", "Nov", "Dec" };
    
    return (type == Abbreviated) ? PString(defaultNames[(int)month-1]) :
    PString(defaultAbbrev[(int)month-1]);
#endif
}


PBOOL PTime::IsDaylightSavings()
{
    time_t theTime = ::time(NULL);
    struct tm ts;
    return os_localtime(&theTime, &ts)->tm_isdst != 0;
}

int PTime::GetTimeZone(PTime::TimeZoneType type)
{
#if (defined(P_LINUX) && !defined(VOIPBASE_ANDROID))
    long tz = -::timezone/60;
    if (type == StandardTime)
        return tz;
    else
        return tz + ::daylight*60;
#elif defined(P_MACOSX) || defined(P_MACOS)
    time_t t;
    time(&t);
    struct tm ts;
    struct tm * tm = os_localtime(&t, &ts);
    int tz = tm->tm_gmtoff/60;
    if (type == StandardTime && tm->tm_isdst)
        return tz-60;
    if (type != StandardTime && !tm->tm_isdst)
        return tz + 60;
    return tz;
#else
#warning No timezone information
    return 0;
#endif
}

PString PTime::GetTimeZoneString(PTime::TimeZoneType type)
{
#if defined(P_LINUX)
    const char * str = (type == StandardTime) ? ::tzname[0] : ::tzname[1];
    if (str != NULL)
        return str;
    return PString();
#elif defined(P_USE_STRFTIME)
    char buf[30];
    struct tm t;
    memset(&t, 0, sizeof(t));
    t.tm_isdst = type != StandardTime;
    strftime(buf, sizeof(buf), "%Z", &t);
    return buf;
#else
#warning No timezone name information
    return PString();
#endif
}

// note that PX_tm is local storage inside the PTime instance

#ifdef P_PTHREADS
struct tm * PTime::os_localtime(const time_t * clock, struct tm * ts)
{
    return ::localtime_r(clock, ts);
}
#else
struct tm * PTime::os_localtime(const time_t * clock, struct tm *)
{
    return ::localtime(clock);
}
#endif

#ifdef P_PTHREADS
struct tm * PTime::os_gmtime(const time_t * clock, struct tm * ts)
{
    return ::gmtime_r(clock, ts);
}
#else
struct tm * PTime::os_gmtime(const time_t * clock, struct tm *)
{
    return ::gmtime(clock);
}
#endif


// PTime

static time_t p_mktime(struct tm * t, int zone)
{
    // mktime returns GMT, calculated using input_time - timezone. However, this
    // assumes that the input time was a local time. If the input time wasn't a
    // local time, then we have have to add the local timezone (without daylight
    // savings) and subtract the specified zone offset to get GMT
    // and then subtract
    t->tm_isdst = PTime::IsDaylightSavings() ? 1 : 0;
    time_t theTime = mktime(t);
    if (theTime == (time_t)-1)
        theTime = 0;
    else if (zone != PTime::Local) {
        theTime += PTime::GetTimeZone()*60;  // convert to local time
        if (theTime > (time_t) zone*60)
            theTime -= zone*60;           // and then to GMT
    }
    return theTime;
}


PTime::PTime(const PString & str)
{
    PStringStream s(str);
    ReadFrom(s);
}


PTime::PTime(int second, int minute, int hour,
             int day,    int month,  int year,
             int zone)
{
    microseconds = 0;
    
    struct tm t;
    PAssert(second >= 0 && second <= 59, PInvalidParameter);
    t.tm_sec = second;
    PAssert(minute >= 0 && minute <= 59, PInvalidParameter);
    t.tm_min = minute;
    PAssert(hour >= 0 && hour <= 23, PInvalidParameter);
    t.tm_hour = hour;
    PAssert(day >= 1 && day <= 31, PInvalidParameter);
    t.tm_mday = day;
    PAssert(month >= 1 && month <= 12, PInvalidParameter);
    t.tm_mon = month-1;
    PAssert(year >= 1970 && year <= 2038, PInvalidParameter);
    t.tm_year   = year-1900;
    
    theTime = p_mktime(&t, zone);
}


PObject::Comparison PTime::Compare(const PObject & obj) const
{
    PAssert(PIsDescendant(&obj, PTime), PInvalidCast);
    const PTime & other = (const PTime &)obj;
    if (theTime < other.theTime)
        return LessThan;
    if (theTime > other.theTime)
        return GreaterThan;
    if (microseconds < other.microseconds)
        return LessThan;
    if (microseconds > other.microseconds)
        return GreaterThan;
    return EqualTo;
}




PString PTime::AsString(TimeFormat format, int zone) const
{
    if (format >= NumTimeStrings)
        return "Invalid format : " + AsString("yyyy-MM-dd T hh:mm:ss Z");
    
    switch (format) {
        case RFC1123 :
            return AsString("wwwe, dd MMME yyyy hh:mm:ss z", zone);
        case ShortISO8601 :
            return AsString("yyyyMMddThhmmssZ");
        case LongISO8601 :
            return AsString("yyyy-MM-dd T hh:mm:ss Z");
        default :
            break;
    }
    
    PString fmt, dsep;
    
    PString tsep = GetTimeSeparator();
    PBOOL is12hour = GetTimeAMPM();
    
    switch (format ) {
        case LongDateTime :
        case LongTime :
        case MediumDateTime :
        case ShortDateTime :
        case ShortTime :
            if (!is12hour)
                fmt = "h";
            
            fmt += "h" + tsep + "mm";
            
            switch (format) {
                case LongDateTime :
                case LongTime :
                    fmt += tsep + "ss";
                    
                default :
                    break;
            }
            
            if (is12hour)
                fmt += "a";
            break;
            
        default :
            break;
    }
    
    switch (format ) {
        case LongDateTime :
        case MediumDateTime :
        case ShortDateTime :
            fmt += ' ';
            break;
            
        default :
            break;
    }
    
    switch (format ) {
        case LongDateTime :
        case LongDate :
            fmt += "wwww ";
            switch (GetDateOrder()) {
                case MonthDayYear :
                    fmt += "MMMM d, yyyy";
                    break;
                case DayMonthYear :
                    fmt += "d MMMM yyyy";
                    break;
                case YearMonthDay :
                    fmt += "yyyy MMMM d";
            }
            break;
            
        case MediumDateTime :
        case MediumDate :
            fmt += "www ";
            switch (GetDateOrder()) {
                case MonthDayYear :
                    fmt += "MMM d, yy";
                    break;
                case DayMonthYear :
                    fmt += "d MMM yy";
                    break;
                case YearMonthDay :
                    fmt += "yy MMM d";
            }
            break;
            
        case ShortDateTime :
        case ShortDate :
            dsep = GetDateSeparator();
            switch (GetDateOrder()) {
                case MonthDayYear :
                    fmt += "MM" + dsep + "dd" + dsep + "yy";
                    break;
                case DayMonthYear :
                    fmt += "dd" + dsep + "MM" + dsep + "yy";
                    break;
                case YearMonthDay :
                    fmt += "yy" + dsep + "MM" + dsep + "dd";
            }
            break;
            
        default :
            break;
    }
    
    if (zone != Local)
        fmt += " z";
    
    return AsString(fmt, zone);
}


PString PTime::AsString(const char * format, int zone) const
{
    PAssert(format != NULL, PInvalidParameter);
    
    PBOOL is12hour = strchr(format, 'a') != NULL;
    
    PStringStream str;
    str.fill('0');
    
    // the localtime call automatically adjusts for daylight savings time
    // so take this into account when converting non-local times
    if (zone == Local)
        zone = GetTimeZone();  // includes daylight savings time
    time_t realTime = theTime + zone*60;     // to correct timezone
    struct tm ts;
    struct tm * t = os_gmtime(&realTime, &ts);
    
    PINDEX repeatCount;
    
    while (*format != '\0') {
        repeatCount = 1;
        switch (*format) {
            case 'a' :
                while (*++format == 'a')
                    ;
                if (t->tm_hour < 12)
                    str << GetTimeAM();
                else
                    str << GetTimePM();
                break;
                
            case 'h' :
                while (*++format == 'h')
                    repeatCount++;
                str << setw(repeatCount) << (is12hour ? (t->tm_hour+11)%12+1 : t->tm_hour);
                break;
                
            case 'm' :
                while (*++format == 'm')
                    repeatCount++;
                str << setw(repeatCount) << t->tm_min;
                break;
                
            case 's' :
                while (*++format == 's')
                    repeatCount++;
                str << setw(repeatCount) << t->tm_sec;
                break;
                
            case 'w' :
                while (*++format == 'w')
                    repeatCount++;
                if (repeatCount != 3 || *format != 'e')
                    str << GetDayName((Weekdays)t->tm_wday, repeatCount <= 3 ? Abbreviated : FullName);
                else {
                    static const char * const EnglishDayName[] = {
                        "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
                    };
                    str << EnglishDayName[t->tm_wday];
                    format++;
                }
                break;
                
            case 'M' :
                while (*++format == 'M')
                    repeatCount++;
                if (repeatCount < 3)
                    str << setw(repeatCount) << (t->tm_mon+1);
                else if (repeatCount > 3 || *format != 'E')
                    str << GetMonthName((Months)(t->tm_mon+1),
                                        repeatCount == 3 ? Abbreviated : FullName);
                else {
                    static const char * const EnglishMonthName[] = {
                        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
                    };
                    str << EnglishMonthName[t->tm_mon];
                    format++;
                }
                break;
                
            case 'd' :
                while (*++format == 'd')
                    repeatCount++;
                str << setw(repeatCount) << t->tm_mday;
                break;
                
            case 'y' :
                while (*++format == 'y')
                    repeatCount++;
                if (repeatCount < 3)
                    str << setw(2) << (t->tm_year%100);
                else
                    str << setw(4) << (t->tm_year+1900);
                break;
                
            case 'z' :
            case 'Z' :
                if (zone == 0) {
                    if (*format == 'Z')
                        str << 'Z';
                    else
                        str << "GMT";
                }
                else {
                    str << (zone < 0 ? '-' : '+');
                    zone = PABS(zone);
                    str << setw(2) << (zone/60) << setw(2) << (zone%60);
                }
                while (toupper(*++format) == 'z')
                    ;
                break;
                
            case 'u' :
                while (*++format == 'u')
                    repeatCount++;
                switch (repeatCount) {
                    case 1 :
                        str << (microseconds/100000);
                        break;
                    case 2 :
                        str << setw(2) << (microseconds/10000);
                        break;
                    case 3 :
                        str << setw(3) << (microseconds/1000);
                        break;
                    default :
                        str << setw(6) << microseconds;
                        break;
                }
                break;
                
            case '\\' :
                format++;
                // Escaped character, put straight through to output string
                
            default :
                str << *format++;
        }
    }
    
    return str;
}

///////////////////////////////////////////////////////////
//
//  Time parser
//

extern "C" {
    
#ifndef STDAPICALLTYPE
#define STDAPICALLTYPE
#endif
    
    time_t STDAPICALLTYPE PTimeParse(void *, struct tm *, int);
    
    int STDAPICALLTYPE PTimeGetChar(void * stream)
    {
        return ((istream *)stream)->get();
    }
    
    
    void STDAPICALLTYPE PTimeUngetChar(void * stream, int c)
    {
        ((istream *)stream)->putback((char)c);
    }
    
    
    int STDAPICALLTYPE PTimeGetDateOrder()
    {
        return PTime::GetDateOrder();
    }
    
    
    int STDAPICALLTYPE PTimeIsMonthName(const char * str, int month, int abbrev)
    {
        return PTime::GetMonthName((PTime::Months)month,
                                   abbrev ? PTime::Abbreviated : PTime::FullName) *= str;
    }
    
    
    int STDAPICALLTYPE PTimeIsDayName(const char * str, int day, int abbrev)
    {
        return PTime::GetDayName((PTime::Weekdays)day,
                                 abbrev ? PTime::Abbreviated : PTime::FullName) *= str;
    }
    
    
};



void PTime::ReadFrom(istream & strm)
{
    time_t now;
    struct tm timeBuf;
    time(&now);
    microseconds = 0;
    strm >> ws;
}



PTime PTime::operator+(const PTimeInterval & t) const
{
    time_t secs = theTime + t.GetSeconds();
    long usecs = (long)(microseconds + (t.GetMilliSeconds()%1000)*1000);
    if (usecs < 0) {
        usecs += 1000000;
        secs--;
    }
    else if (usecs >= 1000000) {
        usecs -= 1000000;
        secs++;
    }
    
    return PTime(secs, usecs);
}


PTime & PTime::operator+=(const PTimeInterval & t)
{
    theTime += t.GetSeconds();
    microseconds += (long)(t.GetMilliSeconds()%1000)*1000;
    if (microseconds < 0) {
        microseconds += 1000000;
        theTime--;
    }
    else if (microseconds >= 1000000) {
        microseconds -= 1000000;
        theTime++;
    }
    
    return *this;
}


PTimeInterval PTime::operator-(const PTime & t) const
{
    time_t secs = theTime - t.theTime;
    long usecs = microseconds - t.microseconds;
    if (usecs < 0) {
        usecs += 1000000;
        secs--;
    }
    else if (usecs >= 1000000) {
        usecs -= 1000000;
        secs++;
    }
    return PTimeInterval(usecs/1000, secs);
}


PTime PTime::operator-(const PTimeInterval & t) const
{
    time_t secs = theTime - t.GetSeconds();
    long usecs = (long)(microseconds - (t.GetMilliSeconds()%1000)*1000);
    if (usecs < 0) {
        usecs += 1000000;
        secs--;
    }
    else if (usecs >= 1000000) {
        usecs -= 1000000;
        secs++;
    }
    return PTime(secs, usecs);
}


PTime & PTime::operator-=(const PTimeInterval & t)
{
    theTime -= t.GetSeconds();
    microseconds -= (long)(t.GetMilliSeconds()%1000)*1000;
    if (microseconds < 0) {
        microseconds += 1000000;
        theTime--;
    }
    else if (microseconds >= 1000000) {
        microseconds -= 1000000;
        theTime++;
    }
    return *this;
}


//
// timer
//chaged by brant

#define USE_CLOCK_GETTIME

#define CLOCK_MONOTONIC 0
int clock_gettime(int /*clk_id*/, struct timespec* t) {
    struct timeval now;
    int rv = gettimeofday(&now, NULL);
    if (rv) return rv;
    t->tv_sec  = now.tv_sec;
    t->tv_nsec = now.tv_usec * 1000;
    return 0;
}

// PTimer

PTimer::PTimer(long millisecs, int seconds, int minutes, int hours, int days)
: resetTime(millisecs, seconds, minutes, hours, days)
{
    Construct();
}


PTimer::PTimer(const PTimeInterval & time)
: resetTime(time)
{
    Construct();
}


void PTimer::Construct()
{
    state = Stopped;
    
    timerList = PProcess::Current().GetTimerList();
    
    timerList->listMutex.Wait();
    timerList->Append(this);
    timerList->listMutex.Signal();
    
    timerList->processingMutex.Wait();
    StartRunning(TRUE);
}


PTimer & PTimer::operator=(DWORD milliseconds)
{
    timerList->processingMutex.Wait();
    resetTime.SetInterval(milliseconds);
    StartRunning(oneshot);
    return *this;
}


PTimer & PTimer::operator=(const PTimeInterval & time)
{
    timerList->processingMutex.Wait();
    resetTime = time;
    StartRunning(oneshot);
    return *this;
}


PTimer::~PTimer()
{
    timerList->listMutex.Wait();
    timerList->Remove(this);
    PBOOL isCurrentTimer = this == timerList->currentTimer;
    timerList->listMutex.Signal();
    
    // Make sure that the OnTimeout for this timer has completed before
    // destroying the timer
    if (isCurrentTimer) {
        timerList->inTimeoutMutex.Wait();
        timerList->inTimeoutMutex.Signal();
    }
}


void PTimer::SetInterval(PInt64 milliseconds,
                         long seconds,
                         long minutes,
                         long hours,
                         int days)
{
    timerList->processingMutex.Wait();
    resetTime.SetInterval(milliseconds, seconds, minutes, hours, days);
    StartRunning(oneshot);
}


void PTimer::RunContinuous(const PTimeInterval & time)
{
    timerList->processingMutex.Wait();
    resetTime = time;
    StartRunning(FALSE);
}


void PTimer::StartRunning(PBOOL once)
{
    PTimeInterval::operator=(resetTime);
    oneshot = once;
    state = (*this) != 0 ? Starting : Stopped;
    
    if (IsRunning())
        PProcess::Current().SignalTimerChange();
    
    // This must have been set by the caller
    timerList->processingMutex.Signal();
}


void PTimer::Stop()
{
    timerList->processingMutex.Wait();
    state = Stopped;
    milliseconds = 0;
    PBOOL isCurrentTimer = this == timerList->currentTimer;
    timerList->processingMutex.Signal();
    
    // Make sure that the OnTimeout for this timer has completed before
    // retruning from Stop() function,
    if (isCurrentTimer) {
        timerList->inTimeoutMutex.Wait();
        timerList->inTimeoutMutex.Signal();
    }
}


void PTimer::Pause()
{
    timerList->processingMutex.Wait();
    if (IsRunning())
        state = Paused;
    timerList->processingMutex.Signal();
}


void PTimer::Resume()
{
    timerList->processingMutex.Wait();
    if (state == Paused)
        state = Starting;
    timerList->processingMutex.Signal();
}


void PTimer::Reset()
{
    timerList->processingMutex.Wait();
    StartRunning(oneshot);
}


void PTimer::OnTimeout()
{
    if (!callback.IsNULL())
        callback(*this, IsRunning());
}


void PTimer::Process(const PTimeInterval & delta, PTimeInterval & minTimeLeft)
{
    /*Ideally there should be a processingMutex for each individual timer, but
     that seems incredibly profligate of system resources as there  can be a
     LOT of PTimer instances about. So use one one mutex for all.
     */
    timerList->processingMutex.Wait();
    
    switch (state) {
        case Starting :
            state = Running;
            if (resetTime < minTimeLeft)
                minTimeLeft = resetTime;
            break;
            
        case Running :
            operator-=(delta);
            
            if (milliseconds > 0) {
                if (milliseconds < minTimeLeft.GetMilliSeconds())
                    minTimeLeft = *this;
            }
            else {
                if (oneshot) {
                    milliseconds = 0;
                    state = Stopped;
                }
                else {
                    PTimeInterval::operator=(resetTime);
                    if (resetTime < minTimeLeft)
                        minTimeLeft = resetTime;
                }
                
                timerList->processingMutex.Signal();
                
                /* This must be outside the mutex or if OnTimeout() changes the
                 timer value (quite plausible) it deadlocks.
                 */
                OnTimeout();
                return;
            }
            break;
            
        default : // Stopped or Paused, do nothing.
            break;
    }
    
    timerList->processingMutex.Signal();
}

PTimeInterval PTimer::Tick()

{
#ifdef USE_CLOCK_GETTIME
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC,&ts);
    return ((((PInt64)ts.tv_sec)*1000L) + ((PInt64)ts.tv_nsec)/1000000L);
#else
    static const PInt64 tck=PABS(sysconf(_SC_CLK_TCK));
	
    return  ((PInt64)times(NULL))*1000L/tck;
    
#endif
    /*
     struct timeval tv;
     ::gettimeofday (&tv, NULL);
     return (PInt64)(tv.tv_sec) * 1000 + tv.tv_usec/1000L;*/
}
