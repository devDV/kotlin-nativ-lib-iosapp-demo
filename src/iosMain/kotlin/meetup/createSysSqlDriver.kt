package meetup

import com.squareup.sqldelight.db.SqlDriver
import com.squareup.sqldelight.drivers.ios.NativeSqliteDriver
import db.MyDatabase
import platform.Foundation.NSDate
import platform.Foundation.timeIntervalSince1970

actual fun createSysSqlDriver(dbName: String): SqlDriver {
    return NativeSqliteDriver(MyDatabase.Schema, dbName)
}

actual val now: Long
    get() = (NSDate().timeIntervalSince1970*1000).toLong()