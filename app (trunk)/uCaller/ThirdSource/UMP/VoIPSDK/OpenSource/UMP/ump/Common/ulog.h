/*
 * ulog.h
 *
 *  Created on: 2014年6月25日
 *      Author: thehuah
 */

#ifndef ULOG_H_
#define ULOG_H_

#define UMP_LOG_TAG "UMP_LOG"

//#define ERR_TAG "[ERR ]"
//#define WARN_TAG "[WARN]"
//#define INFO_TAG "[INFO]"
//#define DBG_TAG "[DBG ]"

typedef enum UMPLogPriority {
    UMP_LOG_UNKNOWN = 0,
    UMP_LOG_DEFAULT,    /* only for SetMinPriority() */
    UMP_LOG_VERBOSE,
    UMP_LOG_DEBUG,
    UMP_LOG_INFO,
    UMP_LOG_WARN,
    UMP_LOG_ERROR,
    UMP_LOG_FATAL,
    UMP_LOG_SILENT,     /* only for SetMinPriority(); must be last */
} UMPLogPriority;

#ifdef __cplusplus
extern "C" {
#endif

void set_logtofile(const char * dir);
void set_logoff();
void set_logon();
void ump_log(UMPLogPriority prio,  const char* content);

#ifdef __cplusplus
}
#endif

#define U_FATAL_(content)	ump_log(UMP_LOG_FATAL, ((std::stringstream&)(std::stringstream().flush()<<content)).str().c_str())
#define U_ERR_(content)		ump_log(UMP_LOG_ERROR, ((std::stringstream&)(std::stringstream().flush()<<content)).str().c_str())
#define U_WARN_(content)	ump_log(UMP_LOG_WARN, ((std::stringstream&)(std::stringstream().flush()<<content)).str().c_str())
#define U_INFO_(content)	ump_log(UMP_LOG_INFO, ((std::stringstream&)(std::stringstream().flush()<<content)).str().c_str())
#define U_DBG_(content)		ump_log(UMP_LOG_DEBUG, ((std::stringstream&)(std::stringstream().flush()<<content)).str().c_str())
#define U_VERB_(content)	ump_log(UMP_LOG_VERBOSE, ((std::stringstream&)(std::stringstream().flush()<<content)).str().c_str())

#define ___TYPE_INFO___		typeid(*this).name()<<": "

#define U_FATAL(content)	U_FATAL_(	___TYPE_INFO___<<content)
#define U_ERR(content)		U_ERR_(		___TYPE_INFO___<<content)
#define U_WARN(content)		U_WARN_(	___TYPE_INFO___<<content)
#define U_INFO(content)		U_INFO_(	___TYPE_INFO___<<content)
#define U_DBG(content)		U_DBG_(		___TYPE_INFO___<<content)
#define U_VERB(content)		U_VERB_(	___TYPE_INFO___<<content)

#endif /* ULOG_H_ */
