package meetup

import io.ktor.client.HttpClient
import io.ktor.client.request.get
import io.ktor.client.request.url

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

import kotlinx.serialization.Serializable
import kotlinx.serialization.UnstableDefault
import kotlinx.serialization.json.Json
import kotlinx.serialization.list

@Serializable
data class Status(val status: String)

@Serializable
data class Event(
    val id: String,
    val created: Long,
    val name: String,
    val local_date: String,
    val local_time: String
)

internal expect val ApplicationDispatcher: CoroutineDispatcher

interface MeetupApiDelegate {
    fun reloadLogFromData(data: List<db.Log>)
}

class MeetupApi(private val delegate: MeetupApiDelegate) {

    private val client = HttpClient()
    private val storage = Storage()

    init {
        storage.addLog("api inited on device with resolution ${getDeviceResolution()}")
    }

    /// https://secure.meetup.com/meetup_api/console/?path=/:urlname/events
    private val baseURL = "https://api.meetup.com"
    private val urlStatus = "$baseURL/status"
    private val urlEvents = "$baseURL/{GROUPNAME}/events?&scroll=recent_past"

    var logRows = 30L

    @UnstableDefault
    fun getStatus(callback: (Status) -> Unit) {
        storage.addLog("api functions get status")
        GlobalScope.apply {
            launch(ApplicationDispatcher) {
                val result: String = client.get {
                    url(this@MeetupApi.urlStatus)
                }
                val status = Json.parse(Status.serializer(), result)

                callback(status)

                reloadLogOnView()
            }
        }
    }

    @UnstableDefault
    fun getEvents(groupName: String, callback: (List<Event>) -> Unit) {
        storage.addLog("api functions get events")

        if (groupName.isEmpty()) {
            storage.addLog("error, groupName can't be empty")
            // throw Exception(message = "groupName can't be empty")
            reloadLogOnView()
            return
        }

        val urlString = urlEvents.toString().replace("{GROUPNAME}", groupName)

        GlobalScope.apply {
            launch(ApplicationDispatcher) {
                try {
                    val result: String = client.get {
                        url(urlString)
                    }
                    val events = Json.nonstrict.parse(Event.serializer().list, result)

                    callback(events)

                } catch (e: Exception) {
                    storage.addLog("error, exception: ${e.toString()}")
                    // throw e

                } finally {
                    reloadLogOnView()
                }
            }
        }
    }

    private fun reloadLogOnView() {

        val data = storage.getLogLastRows(logRows)
        delegate.reloadLogFromData(data)

    }
}