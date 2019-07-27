package meetup

import kotlinx.cinterop.CValue
import kotlinx.cinterop.useContents
import platform.UIKit.UIScreen
import platform.CoreGraphics.CGSize


actual fun getDeviceResolution(): String {
    val mainScreen = UIScreen.mainScreen
    val screenMode = mainScreen.currentMode
    val size = screenMode?.size?.tokCGSize()
    return "${size?.width}x${size?.height}"
}

private data class kCGSize(var height: Float, var width: Float)

private fun CValue<CGSize>.tokCGSize() = this.useContents { kCGSize(height.toFloat(), width.toFloat()) }
