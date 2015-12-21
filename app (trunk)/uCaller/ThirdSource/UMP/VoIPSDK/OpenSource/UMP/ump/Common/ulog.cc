/*
 * ulog.cxx
 *
 *  Created on: 2014年6月25日
 *      Author: thehuah
 */

//#include<stdarg.h>
//#include<string.h>
//#include<stdio.h>
#include "ulog.h"

#include <fstream>
#include <iostream>


#ifdef VOIPBASE_ANDROID
#include <android/log.h>
#endif

//volatile
bool logopen=true;


bool logtofile=false;
//char * logfilename="/mnt/sdcard/hcplog5.txt";
char logfilename[256]={0};

void set_logoff()
{
	logopen=false;
}

void set_logon()
{
	logopen=true;
}


void set_logtofile(const char * dir)
{
	logtofile=true;
	strcpy(logfilename,dir);
	strcat(logfilename,"hcp.log");
}

void ump_log(UMPLogPriority prio,  const char* content)
{
	time_t t = time(0);
	char tmp[64] = {0};
	strftime( tmp, sizeof(tmp), "%Y/%m/%d %H:%M:%S",localtime(&t) );

	if(logtofile)
	{
		std::ofstream fout(logfilename,std::ios::app);
		fout << tmp << " " << content;
		fout.close();
		//return;
	}

	if(!logopen)
		return;

#ifdef VOIPBASE_ANDROID
	switch(prio)
	{
	case UMP_LOG_VERBOSE:
		__android_log_print(ANDROID_LOG_VERBOSE,UMP_LOG_TAG,"%s %s",tmp,content);
		break;
	case UMP_LOG_DEBUG:
		__android_log_print(ANDROID_LOG_DEBUG,UMP_LOG_TAG,"%s %s",tmp,content);
		break;
	case UMP_LOG_INFO:
		__android_log_print(ANDROID_LOG_INFO,UMP_LOG_TAG,"%s %s",tmp,content);
		break;
	case UMP_LOG_WARN:
		__android_log_print(ANDROID_LOG_WARN,UMP_LOG_TAG,"%s %s",tmp,content);
		break;
	case UMP_LOG_ERROR:
		__android_log_print(ANDROID_LOG_ERROR,UMP_LOG_TAG,"%s %s",tmp,content);
		break;
	case UMP_LOG_FATAL:
		__android_log_print(ANDROID_LOG_FATAL,UMP_LOG_TAG,"%s %s",tmp,content);
		break;
	default:
		__android_log_print(ANDROID_LOG_INFO,UMP_LOG_TAG,"%s %s",tmp,content);
	}
#else
    switch(prio)
	{
        case UMP_LOG_VERBOSE:
            //__android_log_print(ANDROID_LOG_VERBOSE,UMP_LOG_TAG,"%s %s",tmp,content);
            printf("%s %s\n",tmp,content);
            break;
        case UMP_LOG_DEBUG:
//            __android_log_print(ANDROID_LOG_DEBUG,UMP_LOG_TAG,"%s %s",tmp,content);
            printf("%s %s\n",tmp,content);
            break;
        case UMP_LOG_INFO:
//            __android_log_print(ANDROID_LOG_INFO,UMP_LOG_TAG,"%s %s",tmp,content);
            printf("%s %s\n",tmp,content);
            break;
        case UMP_LOG_WARN:
//            __android_log_print(ANDROID_LOG_WARN,UMP_LOG_TAG,"%s %s",tmp,content);
            printf("%s %s\n",tmp,content);
            break;
        case UMP_LOG_ERROR:
//            __android_log_print(ANDROID_LOG_ERROR,UMP_LOG_TAG,"%s %s",tmp,content);
            printf("%s %s\n",tmp,content);
            break;
        case UMP_LOG_FATAL:
//            __android_log_print(ANDROID_LOG_FATAL,UMP_LOG_TAG,"%s %s",tmp,content);
            printf("%s %s\n",tmp,content);
            break;
        default:
//            __android_log_print(ANDROID_LOG_INFO,UMP_LOG_TAG,"%s %s",tmp,content);
            printf("%s %s\n",tmp,content);
	}
#endif
}

