package meetup

import com.squareup.sqldelight.db.SqlDriver
import db.Log
import db.LogQueries
import db.MyDatabase

expect fun createSysSqlDriver(dbName:String): SqlDriver
expect val now: Long

class Storage() {
    private val db: MyDatabase
    private val log: LogQueries

    init {
        db = createMyDb()
        log = db.logQueries
    }

    fun addLog(message: String) {
        log.insert(now, message)
    }

    fun getLogLastRows(number: Long): List<Log> {
        return log.selectLastRows(number).executeAsList()
    }


    private fun createMyDb():MyDatabase {
        return MyDatabase(createSysSqlDriver("mydatabase.db"))
    }

}