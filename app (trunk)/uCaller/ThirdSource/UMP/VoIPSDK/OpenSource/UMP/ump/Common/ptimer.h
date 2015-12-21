//
//  ptimer.h
//  UMPStack
//
//  Created by thehuah on 14-3-6.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef __UMPStack__ptimer__
#define __UMPStack__ptimer__

#ifdef P_USE_PRAGMA
#pragma interface
#endif

// Include platform dependent part of class
#include <sys/times.h>
#include <time.h>

#include "pcommon.h"
#include "pnotifier.h"
#include "pstring.h"

#define PMaxTimeInterval PTimeInterval((long)0x7fffffff)

class PThread;

class PTimeInterval : public PObject
{
    PCLASSINFO(PTimeInterval, PObject);
    
public:
    /**@name Construction */
    //@{
    /** Create a new time interval object. The time interval, in milliseconds,
     is the sum of all of the parameters. For example all of the following
     are equivalent:
     \begin{verbatim}
     PTimeInterval(120000)
     PTimeInterval(60000, 60)
     PTimeInterval(60000, 0, 1)
     PTimeInterval(0, 60, 1)
     PTimeInterval(0, 0, 2)
     \end{verbatim}
     */
    PTimeInterval(
                  PInt64 millisecs = 0   ///< Number of milliseconds for interval.
    );
    PTimeInterval(
                  long millisecs,       ///< Number of milliseconds for interval.
                  long seconds,         ///< Number of seconds for interval.
                  long minutes = 0,     ///< Number of minutes for interval.
                  long hours = 0,       ///< Number of hours for interval.
                  int days = 0          ///< Number of days for interval.
    );
    PTimeInterval(
                  const PString & str   ///< String representation of time interval.
    );
    //@}
    
    /**@name Overrides from class PObject */
    //@{
    /** Create a new copy of the time interval. It is the responsibility of the
     called to delete the object.
     
     @return
     new time interval on heap.
     */
    PObject * Clone() const;
    
    /** Rank the two time intervals. This ranks the intervals as you would
     expect for two integers.
     
     @return
     #EqualTo#, #LessThan# or #GreaterThan#
     depending on their relative rank.
     */
    virtual Comparison Compare(
                               const PObject & obj   ///< Time interval to compare against.
    ) const;
    
    /** Output the time interval to the I/O stream. This outputs the number of
     milliseconds as a signed decimal integer number.
     */
    virtual void PrintOn(
                         ostream & strm    ///< I/O stream to output the time interval.
    ) const;
    
    /** Input the time interval from the I/O stream. This expects the input
     to be a signed decimal integer number.
     */
    virtual void ReadFrom(
                          istream & strm    ///< I/O stream to input the time interval from.
    );
    //@}
    
    /**@name Conversion functions */
    //@{
    enum Formats {
        NormalFormat,
        IncludeDays,
        SecondsOnly
    };
    
    PString AsString(
                     int decimals = 3,
                     Formats format = NormalFormat,
                     int width = 1
                     ) const;
    //@}
    
    /**@name Access functions */
    //@{
    /** Get the number of milliseconds for the time interval.
     
     @return
     very long integer number of milliseconds.
     */
    PInt64 GetMilliSeconds() const;
    
    /** Get the number of whole seconds for the time interval.
     
     @return
     long integer number of seconds.
     */
    long GetSeconds() const;
    
    /** Get the number of whole minutes for the time interval.
     
     @return
     integer number of minutes.
     */
    long GetMinutes() const;
    
    /** Get the number of whole hours for the time interval.
     
     @return
     integer number of hours.
     */
    int GetHours() const;
    
    /** Get the number of whole days for the time interval.
     
     @return
     integer number of days.
     */
    int GetDays() const;
    
    /** Get the number of milliseconds for the time interval.
     
     @return
     long integer number of milliseconds.
     */
    DWORD GetInterval() const;
    
    /** Set the value of the time interval. The time interval, in milliseconds,
     is the sum of all of the parameters. For example all of the following
     are equivalent:
     \begin{verbatim}
     SetInterval(120000)
     SetInterval(60000, 60)
     SetInterval(60000, 0, 1)
     SetInterval(0, 60, 1)
     SetInterval(0, 0, 2)
     \end{verbatim}
     */
    virtual void SetInterval(
                             PInt64 milliseconds = 0,  ///< Number of milliseconds for interval.
                             long seconds = 0,         ///< Number of seconds for interval.
                             long minutes = 0,         ///< Number of minutes for interval.
                             long hours = 0,           ///< Number of hours for interval.
                             int days = 0              ///< Number of days for interval.
    );
    //@}
    
    /**@name Operations */
    //@{
    /** Unary minus, get negative of time interval.
     
     @return
     difference of the time intervals.
     */
    PTimeInterval operator-() const;
    
    /** Add the two time intervals yielding a third time interval.
     
     @return
     sum of the time intervals.
     */
    PTimeInterval operator+(
                            const PTimeInterval & interval   ///< Time interval to add.
    ) const;
    
    /** Add the second time interval to the first time interval.
     
     @return
     reference to first time interval.
     */
    PTimeInterval & operator+=(
                               const PTimeInterval & interval   ///< Time interval to add.
    );
    
    /** Subtract the two time intervals yielding a third time interval.
     
     @return
     difference of the time intervals.
     */
    PTimeInterval operator-(
                            const PTimeInterval & interval   ///< Time interval to subtract.
    ) const;
    
    /** Subtract the second time interval from the first time interval.
     
     @return
     reference to first time interval.
     */
    PTimeInterval & operator-=(
                               const PTimeInterval & interval   ///< Time interval to subtract.
    );
    
    /** Multiply the time interval by a factor yielding a third time interval.
     
     @return
     the time intervals times the factor.
     */
    PTimeInterval operator*(
                            int factor   ///< factor to multiply.
    ) const;
    
    /** Multiply the time interval by a factor.
     
     @return
     reference to time interval.
     */
    PTimeInterval & operator*=(
                               int factor   ///< factor to multiply.
    );
    
    /** Divide the time interval by a factor yielding a third time interval.
     
     @return
     the time intervals divided by the factor.
     */
    PTimeInterval operator/(
                            int factor   ///< factor to divide.
    ) const;
    
    /** Divide the time interval by a factor.
     
     @return
     reference to time interval.
     */
    PTimeInterval & operator/=(
                               int factor   ///< factor to divide.
    );
    //@}
    
    /**@name Comparison functions */
    //@{
    /** Compare to the two time intervals. This is provided as an override to
     the default in PObject so that comparisons can be made to integer
     literals that represent milliseconds.
     
     @return
     TRUE if intervals are equal.
     */
    bool operator==(
                    const PTimeInterval & interval   ///< Time interval to compare.
    ) const;
    bool operator==(
                    long msecs    ///< Time interval as integer milliseconds to compare.
    ) const;
    
    /** Compare to the two time intervals. This is provided as an override to
     the default in PObject so that comparisons can be made to integer
     literals that represent milliseconds.
     
     @return
     TRUE if intervals are not equal.
     */
    bool operator!=(
                    const PTimeInterval & interval   ///< Time interval to compare.
    ) const;
    bool operator!=(
                    long msecs    ///< Time interval as integer milliseconds to compare.
    ) const;
    
    /** Compare to the two time intervals. This is provided as an override to
     the default in PObject so that comparisons can be made to integer
     literals that represent milliseconds.
     
     @return
     TRUE if intervals are greater than.
     */
    bool operator> (
                    const PTimeInterval & interval   ///< Time interval to compare.
    ) const;
    bool operator> (
                    long msecs    ///< Time interval as integer milliseconds to compare.
    ) const;
    
    /** Compare to the two time intervals. This is provided as an override to
     the default in PObject so that comparisons can be made to integer
     literals that represent milliseconds.
     
     @return
     TRUE if intervals are greater than or equal.
     */
    bool operator>=(
                    const PTimeInterval & interval   ///< Time interval to compare.
    ) const;
    bool operator>=(
                    long msecs    ///< Time interval as integer milliseconds to compare.
    ) const;
    
    /** Compare to the two time intervals. This is provided as an override to
     the default in PObject so that comparisons can be made to integer
     literals that represent milliseconds.
     
     @return
     TRUE if intervals are less than.
     */
    bool operator< (
                    const PTimeInterval & interval   ///< Time interval to compare.
    ) const;
    bool operator< (
                    long msecs    ///< Time interval as integer milliseconds to compare.
    ) const;
    
    /** Compare to the two time intervals. This is provided as an override to
     the default in PObject so that comparisons can be made to integer
     literals that represent milliseconds.
     
     @return
     TRUE if intervals are less than or equal.
     */
    bool operator<=(
                    const PTimeInterval & interval   ///< Time interval to compare.
    ) const;
    bool operator<=(
                    long msecs    ///< Time interval as integer milliseconds to compare.
    ) const;
    //@}
    
protected:
    // Member variables
    /// Number of milliseconds in time interval.
    PInt64 milliseconds;
};

class P_timeval {
public:
    P_timeval();
    P_timeval(const PTimeInterval & time)
    {
        operator=(time);
    }
    
    P_timeval & operator=(const PTimeInterval & time);
    
    operator timeval*()
    {
        return infinite ? NULL : &tval;
    }
    
    timeval * operator->()
    {
        return &tval;
    }
    
    timeval & operator*()
    {
        return tval;
    }
    
private:
    struct timeval tval;
    PBOOL infinite;
};

class PTime : public PObject
{
    PCLASSINFO(PTime, PObject);
    
public:
    /**@name Construction */
    //@{
    /** Time Zone special codes. The value for a time zone is usually in minutes
     from UTC, this enum are special values for specific areas.
     */
    enum {
        /// Universal Coordinated Time.
        UTC   = 0,
        /// Greenwich Mean Time, effectively UTC.
        GMT   = UTC,
        /// Local Time.
        Local = 9999
    };
    
    /**Create a time object instance.
     This initialises the time with the current time in the current time zone.
     */
    PTime();
    
    /**Create a time object instance.
     This initialises the time to the specified time.
     */
    PTime(
          time_t tsecs,          ///< Time in seconds since 00:00:00 1/1/70 UTC
          long usecs = 0
          ) { theTime = tsecs; microseconds = usecs; }
    
    /**Create a time object instance.
     This initialises the time to the specified time, parsed from the
     string. The string may be in many different formats, for example:
     "5/03/1999 12:34:56"
     "15/06/1999 12:34:56"
     "15/06/01 12:34:56 PST"
     "5/06/02 12:34:56"
     "5/23/1999 12:34am"
     "5/23/00 12:34am"
     "1999/23/04 12:34:56"
     "Mar 3, 1999 12:34pm"
     "3 Jul 2004 12:34pm"
     "12:34:56 5 December 1999"
     "10 minutes ago"
     "2 weeks"
     */
    PTime(
          const PString & str   ///< Time and data as a string
    );
    
    /**Create a time object instance.
     This initialises the time to the specified time.
     */
    PTime(
          int second,           ///< Second from 0 to 59.
          int minute,           ///< Minute from 0 to 59.
          int hour,             ///< Hour from 0 to 23.
          int day,              ///< Day of month from 1 to 31.
          int month,            ///< Month from 1 to 12.
          int year,             ///< Year from 1970 to 2038
          int tz = Local        ///< local time or UTC
    );
    //@}
    
    /**@name Overrides from class PObject */
    //@{
    /**Create a copy of the time on the heap. It is the responsibility of the
     caller to delete the created object.
     
     @return
     pointer to new time.
     */
    PObject * Clone() const;
    
    /**Determine the relative rank of the specified times. This ranks the
     times as you would expect.
     
     @return
     rank of the two times.
     */
    virtual Comparison Compare(
                               const PObject & obj   ///< Other time to compare against.
    ) const;
    
    /**Output the time to the stream. This uses the #AsString()# function
     with the #ShortDateTime# parameter.
     */
    virtual void PrintOn(
                         ostream & strm    ///< Stream to output the time to.
    ) const;
    
    /**Input the time from the specified stream. If a parse error occurs the
     time is set to the current time. The string may be in many different
     formats, for example:
     "5/03/1999 12:34:56"
     "15/06/1999 12:34:56"
     "15/06/01 12:34:56 PST"
     "5/06/02 12:34:56"
     "5/23/1999 12:34am"
     "5/23/00 12:34am"
     "1999/23/04 12:34:56"
     "Mar 3, 1999 12:34pm"
     "3 Jul 2004 12:34pm"
     "12:34:56 5 December 1999"
     "10 minutes ago"
     "2 weeks"
     */
    virtual void ReadFrom(
                          istream & strm    ///< Stream to input the time from.
    );
    //@}
    
    /**@name Access functions */
    //@{
    /**Determine if the timestamp is valid.
     This will return TRUE if the timestamp can be represented as a time
     in the epoch. The epoch is the 1st January 1970.
     
     In practice this means the time is > 13 hours to allow for time zones.
     */
    PBOOL IsValid() const;
    
    /**Get the total microseconds since the epoch. The epoch is the 1st
     January 1970.
     
     @return
     microseconds.
     */
    PInt64 GetTimestamp() const;
    
    /**Get the total seconds since the epoch. The epoch is the 1st
     January 1970.
     
     @return
     seconds.
     */
    time_t GetTimeInSeconds() const;
    
    /**Get the microsecond part of the time.
     
     @return
     integer in range 0..999999.
     */
    long GetMicrosecond() const;
    
    /**Get the second of the time.
     
     @return
     integer in range 0..59.
     */
    int GetSecond() const;
    
    /**Get the minute of the time.
     
     @return
     integer in range 0..59.
     */
    int GetMinute() const;
    
    /**Get the hour of the time.
     
     @return
     integer in range 0..23.
     */
    int GetHour() const;
    
    /**Get the day of the month of the date.
     
     @return
     integer in range 1..31.
     */
    int GetDay() const;
    
    /// Month codes.
    enum Months {
        January = 1,
        February,
        March,
        April,
        May,
        June,
        July,
        August,
        September,
        October,
        November,
        December
    };
    
    /**Get the month of the date.
     
     @return
     enum for month.
     */
    Months GetMonth() const;
    
    /**Get the year of the date.
     
     @return
     integer in range 1970..2038.
     */
    int GetYear() const;
    
    /// Days of the week.
    enum Weekdays {
        Sunday,
        Monday,
        Tuesday,
        Wednesday,
        Thursday,
        Friday,
        Saturday
    };
    
    /**Get the day of the week of the date.
     
     @return
     enum for week days with 0=Sun, 1=Mon, ..., 6=Sat.
     */
    Weekdays GetDayOfWeek() const;
    
    /**Get the day in the year of the date.
     
     @return
     integer from 1..366.
     */
    int GetDayOfYear() const;
    
    /**Determine if the time is in the past or in the future.
     
     @return
     TRUE if time is before the current real time.
     */
    PBOOL IsPast() const;
    
    /**Determine if the time is in the past or in the future.
     
     @return
     TRUE if time is after the current real time.
     */
    PBOOL IsFuture() const;
    //@}
    
    /**@name Time Zone configuration functions */
    //@{
    /**Get flag indicating daylight savings is current.
     
     @return
     TRUE if daylight savings time is active.
     */
    static PBOOL IsDaylightSavings();
    
    /// Flag for time zone adjustment on daylight savings.
    enum TimeZoneType {
        StandardTime,
        DaylightSavings
    };
    
    /// Get the time zone offset in minutes.
    static int GetTimeZone();
    /**Get the time zone offset in minutes.
     This is the number of minutes to add to UTC (previously known as GMT) to
     get the local time. The first form automatically adjusts for daylight
     savings time, whilst the second form returns the specified time.
     
     @return
     Number of minutes.
     */
    static int GetTimeZone(
                           TimeZoneType type  ///< Daylight saving or standard time.
    );
    
    /**Get the text identifier for the local time zone .
     
     @return
     Time zone identifier string.
     */
    static PString GetTimeZoneString(
                                     TimeZoneType type = StandardTime ///< Daylight saving or standard time.
    );
    //@}
    
    /**@name Operations */
    //@{
    /**Add the interval to the time to yield a new time.
     
     @return
     Time altered by the interval.
     */
    PTime operator+(
                    const PTimeInterval & time   ///< Time interval to add to the time.
    ) const;
    
    /**Add the interval to the time changing the instance.
     
     @return
     reference to the current time instance.
     */
    PTime & operator+=(
                       const PTimeInterval & time   ///< Time interval to add to the time.
    );
    
    /**Calculate the difference between two times to get a time interval.
     
     @return
     Time intervale difference between the times.
     */
    PTimeInterval operator-(
                            const PTime & time   ///< Time to subtract from the time.
    ) const;
    
    /**Subtract the interval from the time to yield a new time.
     
     @return
     Time altered by the interval.
     */
    PTime operator-(
                    const PTimeInterval & time   ///< Time interval to subtract from the time.
    ) const;
    
    /**Subtract the interval from the time changing the instance.
     
     @return
     reference to the current time instance.
     */
    PTime & operator-=(
                       const PTimeInterval & time   ///< Time interval to subtract from the time.
    );
    //@}
    
    /**@name String conversion functions */
    //@{
    /// Standard time formats for string representations of a time and date.
    enum TimeFormat {
        /// Internet standard format.
        RFC1123,
        /// Short form ISO standard format.
        ShortISO8601,
        /// Long form ISO standard format.
        LongISO8601,
        /// Date with weekday, full month names and time with seconds.
        LongDateTime,
        /// Date with weekday, full month names and no time.
        LongDate,
        /// Time with seconds.
        LongTime,
        /// Date with abbreviated month names and time without seconds.
        MediumDateTime,
        /// Date with abbreviated month names and no time.
        MediumDate,
        /// Date with numeric month name and time without seconds.
        ShortDateTime,
        /// Date with numeric month and no time.
        ShortDate,
        /// Time without seconds.
        ShortTime,
        NumTimeStrings
    };
    
    /** Convert the time to a string representation. */
    PString AsString(
                     TimeFormat formatCode = RFC1123,  ///< Standard format for time.
                     int zone = Local                  ///< Time zone for the time.
    ) const;
    
    /** Convert the time to a string representation. */
    PString AsString(
                     const PString & formatStr, ///< Arbitrary format string for time.
                     int zone = Local           ///< Time zone for the time.
    ) const;
    /* Convert the time to a string using the format code or string as a
     formatting template. The special characters in the formatting string
     are:
     \begin{description}
     \item[h]         hour without leading zero
     \item[hh]        hour with leading zero
     \item[m]         minute without leading zero
     \item[mm]        minute with leading zero
     \item[s]         second without leading zero
     \item[ss]        second with leading zero
     \item[u]         tenths of second
     \item[uu]        hundedths of second with leading zero
     \item[uuu]       millisecond with leading zeros
     \item[uuuu]      microsecond with leading zeros
     \item[a]         the am/pm string
     \item[w/ww/www]  abbreviated day of week name
     \item[wwww]      full day of week name
     \item[d]         day of month without leading zero
     \item[dd]        day of month with leading zero
     \item[M]         month of year without leading zero
     \item[MM]        month of year with leading zero
     \item[MMM]       month of year as abbreviated text
     \item[MMMM]      month of year as full text
     \item[y/yy]      year without century
     \item[yyy/yyyy]  year with century
     \item[z]         the time zone description
     \end{description}
     
     All other characters are copied to the output string unchanged.
     
     Note if there is an 'a' character in the string, the hour will be in 12
     hour format, otherwise in 24 hour format.
     */
    PString AsString(
                     const char * formatPtr,    ///< Arbitrary format C string pointer for time.
                     int zone = Local           ///< Time zone for the time.
    ) const;
    //@}
    
    /**@name Internationalisation functions */
    //@{
    /**Get the internationalised time separator.
     
     @return
     string for time separator.
     */
    static PString GetTimeSeparator();
    
    /**Get the internationalised time format: AM/PM or 24 hour.
     
     @return
     TRUE is 12 hour, FALSE if 24 hour.
     */
    static PBOOL GetTimeAMPM();
    
    /**Get the internationalised time AM string.
     
     @return
     string for AM.
     */
    static PString GetTimeAM();
    
    /**Get the internationalised time PM string.
     
     @return
     string for PM.
     */
    static PString GetTimePM();
    
    /// Flag for returning language dependent string names.
    enum NameType {
        FullName,
        Abbreviated
    };
    
    /**Get the internationalised day of week day name (0=Sun etc).
     
     @return
     string for week day.
     */
    static PString GetDayName(
                              Weekdays dayOfWeek,       ///< Code for day of week.
                              NameType type = FullName  ///< Flag for abbreviated or full name.
    );
    
    /**Get the internationalised date separator.
     
     @return
     string for date separator.
     */
    static PString GetDateSeparator();
    
    /**Get the internationalised month name string (1=Jan etc).
     
     @return
     string for month.
     */
    static PString GetMonthName(
                                Months month,             ///< Code for month in year.
                                NameType type = FullName  ///< Flag for abbreviated or full name.
    );
    
    /// Possible orders for date components.
    enum DateOrder {
        MonthDayYear,   ///< Date is ordered month then day then year.
        DayMonthYear,   ///< Date is ordered day then month then year.
        YearMonthDay    ///< Date is ordered year then day month then day.
    };
    
    /**Return the internationalised date order.
     
     @return
     code for date ordering.
     */
    static DateOrder GetDateOrder();
    //@}
    
    static struct tm * os_localtime(const time_t * clock, struct tm * t);
    static struct tm * os_gmtime(const time_t * clock, struct tm * t);
    /*
     Threadsafe version of localtime library call.
     We could make these calls non-static if we could put the struct tm inside the
     instance. But these calls are usually made with const objects so that's not possible,
     and we would require per-thread storage otherwise. Sigh...
     */
    
protected:
    // Member variables
    /// Number of seconds since 1 January 1970.
    time_t theTime;
    long   microseconds;
};
/**
 A class representing a system timer. The time interval ancestor value is
 the amount of time left in the timer.
 
 A timer on completion calls the virtual function #OnTimeout()#. This
 will in turn call the callback function provided by the instance. The user
 may either override the virtual function or set a callback as desired.
 
 A list of active timers is maintained by the applications #PProcess#
 instance and the timeout functions are executed in the context of a single
 thread of execution. There are many consequences of this: only one timeout
 function can be executed at a time and thus a user should not execute a
 lot of code in the timeout call-back functions or it will dealy the timely
 execution of other timers call-back functions.
 
 Also timers are not very accurate in sub-second delays, even though you can
 set the timer in milliseconds, its accuracy is only to -0/+250 ms. Even
 more (potentially MUCH more) if there are delays in the user call-back
 functions.
 
 Another trap is you cannot destroy a timer in its own call-back. There is
 code to cause an assert if you try but it is very easy to accidentally do
 this when you delete an object that contains an onject that contains the
 timer!
 
 Finally static timers cause race conditions on start up and termination and
 should be avoided.
 */
class PTimer : public PTimeInterval
{
    PCLASSINFO(PTimer, PTimeInterval);
    
public:
    /**@name Construction */
    //@{
    /** Create a new timer object and start it in one shot mode for the
     specified amount of time. If the time was zero milliseconds then the
     timer is {\bf not} started, ie the callback function is not executed
     immediately.
     */
    PTimer(
           long milliseconds = 0,  ///< Number of milliseconds for timer.
           int seconds = 0,        ///< Number of seconds for timer.
           int minutes = 0,        ///< Number of minutes for timer.
           int hours = 0,          ///< Number of hours for timer.
           int days = 0            ///< Number of days for timer.
    );
    PTimer(
           const PTimeInterval & time    ///< New time interval for timer.
    );
    
    /** Restart the timer in one shot mode using the specified time value. If
     the timer was already running, the "time left" is simply reset.
     
     @return
     reference to the timer.
     */
    PTimer & operator=(
                       DWORD milliseconds            ///< New time interval for timer.
    );
    PTimer & operator=(
                       const PTimeInterval & time    ///< New time interval for timer.
    );
    
    /** Destroy the timer object, removing it from the applications timer list
     if it was running.
     */
    virtual ~PTimer();
    //@}
    
    /**@name Control functions */
    //@{
    /** Set the value of the time interval. The time interval, in milliseconds,
     is the sum of all of the parameters. For example all of the following
     are equivalent:
     \begin{verbatim}
     SetInterval(120000)
     SetInterval(60000, 60)
     SetInterval(60000, 0, 1)
     SetInterval(0, 60, 1)
     SetInterval(0, 0, 2)
     \end{verbatim}
     */
    virtual void SetInterval(
                             PInt64 milliseconds = 0,  ///< Number of milliseconds for interval.
                             long seconds = 0,         ///< Number of seconds for interval.
                             long minutes = 0,         ///< Number of minutes for interval.
                             long hours = 0,           ///< Number of hours for interval.
                             int days = 0              ///< Number of days for interval.
    );
    
    /** Start a timer in continous cycle mode. Whenever the timer runs out it
     is automatically reset to the time specified. Thus, it calls the
     notification function every time interval.
     */
    void RunContinuous(
                       const PTimeInterval & time    // New time interval for timer.
    );
    
    /** Stop a running timer. The imer will not call the notification function
     and is reset back to the original timer value. Thus when the timer
     is restarted it begins again from the beginning.
     */
    void Stop();
    
    /** Determine if the timer is currently running. This really is only useful
     for one shot timers as repeating timers are always running.
     
     @return
     TRUE if timer is still counting.
     */
    PBOOL IsRunning() const;
    
    /** Pause a running timer. This differs from the #Stop()# function in
     that the timer may be resumed at the point that it left off. That is
     time is "frozen" while the timer is paused.
     */
    void Pause();
    
    /** Restart a paused timer continuing at the time it was paused. The time
     left at the moment the timer was paused is the time until the next
     call to the notification function.
     */
    void Resume();
    
    /** Determine if the timer is currently paused.
     
     @return
     TRUE if timer paused.
     */
    PBOOL IsPaused() const;
    
    /** Restart a timer continuing from the time it was initially.
     */
    void Reset();
    
    /** Get the time this timer was set to initially.
     */
    const PTimeInterval & GetResetTime() const;
    //@}
    
    /**@name Notification functions */
    //@{
    /**This function is called on time out. That is when the system timer
     processing decrements the timer from a positive value to less than or
     equal to zero. The interval is then reset to zero and the function
     called.
     
     Please note that the application should not execute large amounts of
     code in this call back or the accuracy of ALL timers can be severely
     impacted.
     
     The default behaviour of this function is to call the #PNotifier#
     callback function.
     */
    virtual void OnTimeout();
    
    /** Get the current call back function that is called whenever the timer
     expires. This is called by the #OnTimeout()# function.
     
     @return
     current notifier for the timer.
     */
    const PNotifier & GetNotifier() const;
    
    /** Set the call back function that is called whenever the timer expires.
     This is called by the #OnTimeout()# function.
     */
    void SetNotifier(
                     const PNotifier & func  // New notifier function for the timer.
    );
    //@}
    
    /**@name Global real time functions */
    //@{
    /** Get the number of milliseconds since some arbtrary point in time. This
     is a platform dependent function that yields a real time counter.
     
     Note that even though this function returns milliseconds, the value may
     jump in minimum quanta according the platforms timer system, eg under
     MS-DOS and MS-Windows the values jump by 55 every 55 milliseconds. The
     #Resolution()# function may be used to determine what the minimum
     time interval is.
     
     @return
     millisecond counter.
     */
    static PTimeInterval Tick();
    
    /** Get the smallest number of milliseconds that the timer can be set to.
     All actual timing events will be rounded up to the next value. This is
     typically the platforms internal timing units used in the #Tick()#
     function.
     
     @return
     minimum number of milliseconds per timer "tick".
     */
    static unsigned Resolution();
    //@}
    
private:
    void Construct();
    
    /* Start or restart the timer from the #resetTime# variable.
     This is an internal function.
     */
    void StartRunning(
                      PBOOL once   // Flag for one shot or continuous.
    );
    
    /* Process the timer decrementing it by the delta amount and calling the
     #OnTimeout()# when zero. This is used internally by the
     #PTimerList::Process()# function.
     */
    void Process(
                 const PTimeInterval & delta,    // Time interval since last call.
                 PTimeInterval & minTimeLeft     // Minimum time left till next timeout.
    );
    
    // Member variables
    PNotifier callback;
    // Callback function for expired timers.
    
    PTimeInterval resetTime;
    // The time to reset a timer to when RunContinuous() is called.
    
    PBOOL oneshot;
    // Timer operates once then stops.
    
    enum { Stopped, Starting, Running, Paused } state;
    // Timer state.
    
    
    friend class PTimerList;
    class PTimerList * timerList;
};



#endif /* defined(__UMPStack__ptimer__) */
