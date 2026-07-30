package com.example.meal_planner

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class SafPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener {

    companion object {
        const val CHANNEL = "com.example.meal_planner/saf"
        const val REQUEST_OPEN_TREE = 1001
    }

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private var pendingResult: MethodChannel.Result? = null

    // ── FlutterPlugin ──────────────────────────────────────────────────────

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // ── ActivityAware ──────────────────────────────────────────────────────

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() { activity = null }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() { activity = null }

    // ── Method dispatch ────────────────────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "openDocumentTree" -> openDocumentTree(result)
            "readFile" -> {
                val treeUri = call.argument<String>("treeUri") ?: return result.error("ARG", "treeUri missing", null)
                val name    = call.argument<String>("name")    ?: return result.error("ARG", "name missing", null)
                readFile(treeUri, name, result)
            }
            "writeFile" -> {
                val treeUri = call.argument<String>("treeUri") ?: return result.error("ARG", "treeUri missing", null)
                val name    = call.argument<String>("name")    ?: return result.error("ARG", "name missing", null)
                val content = call.argument<String>("content") ?: return result.error("ARG", "content missing", null)
                writeFile(treeUri, name, content, result)
            }
            "deleteFile" -> {
                val treeUri = call.argument<String>("treeUri") ?: return result.error("ARG", "treeUri missing", null)
                val name    = call.argument<String>("name")    ?: return result.error("ARG", "name missing", null)
                deleteFile(treeUri, name, result)
            }
            "listFiles" -> {
                val treeUri = call.argument<String>("treeUri") ?: return result.error("ARG", "treeUri missing", null)
                listFiles(treeUri, result)
            }
            "getLastModified" -> {
                val treeUri = call.argument<String>("treeUri") ?: return result.error("ARG", "treeUri missing", null)
                val name    = call.argument<String>("name")    ?: return result.error("ARG", "name missing", null)
                getLastModified(treeUri, name, result)
            }
            else -> result.notImplemented()
        }
    }

    // ── Folder picker ──────────────────────────────────────────────────────

    private fun openDocumentTree(result: MethodChannel.Result) {
        val act = activity ?: return result.error("NO_ACTIVITY", "No activity", null)
        pendingResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        act.startActivityForResult(intent, REQUEST_OPEN_TREE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_OPEN_TREE) return false
        val result = pendingResult ?: return true
        pendingResult = null

        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            result.success(null)
            return true
        }
        val uri = data.data!!
        val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
        context.contentResolver.takePersistableUriPermission(uri, flags)
        result.success(uri.toString())
        return true
    }

    // ── SAF helpers ────────────────────────────────────────────────────────

    /** Returns the document ID of the tree root. */
    private fun rootDocId(treeUri: Uri): String =
        DocumentsContract.getTreeDocumentId(treeUri)

    /** Builds the children query URI for the tree root. */
    private fun childrenUri(treeUri: Uri): Uri =
        DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, rootDocId(treeUri))

    /** Returns (documentId, lastModified) for a child file matching [name], or null. */
    private fun findDocId(treeUri: Uri, name: String): Pair<String, Long>? {
        val childrenUri = childrenUri(treeUri)
        val projection = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_LAST_MODIFIED,
        )
        context.contentResolver.query(childrenUri, projection, null, null, null)?.use { cursor ->
            val idCol   = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
            val nameCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
            val modCol  = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_LAST_MODIFIED)
            while (cursor.moveToNext()) {
                if (cursor.getString(nameCol) == name) {
                    return cursor.getString(idCol) to cursor.getLong(modCol)
                }
            }
        }
        return null
    }

    private fun docUri(treeUri: Uri, docId: String): Uri =
        DocumentsContract.buildDocumentUriUsingTree(treeUri, docId)

    // ── File operations ────────────────────────────────────────────────────

    private fun readFile(treeUriStr: String, name: String, result: MethodChannel.Result) {
        try {
            val treeUri = Uri.parse(treeUriStr)
            val found = findDocId(treeUri, name)
            if (found == null) { result.success(null); return }
            val content = context.contentResolver
                .openInputStream(docUri(treeUri, found.first))
                ?.bufferedReader()
                ?.use { it.readText() }
            result.success(content)
        } catch (e: Exception) {
            result.error("READ_ERROR", e.message, null)
        }
    }

    private fun writeFile(treeUriStr: String, name: String, content: String, result: MethodChannel.Result) {
        try {
            val treeUri = Uri.parse(treeUriStr)
            val found = findDocId(treeUri, name)
            val target: Uri = if (found != null) {
                docUri(treeUri, found.first)
            } else {
                DocumentsContract.createDocument(
                    context.contentResolver,
                    docUri(treeUri, rootDocId(treeUri)),
                    "application/json",
                    name
                ) ?: return result.error("CREATE_ERROR", "Cannot create file", null)
            }
            context.contentResolver.openOutputStream(target, "wt")
                ?.bufferedWriter()
                ?.use { it.write(content) }
            result.success(null)
        } catch (e: Exception) {
            result.error("WRITE_ERROR", e.message, null)
        }
    }

    private fun deleteFile(treeUriStr: String, name: String, result: MethodChannel.Result) {
        try {
            val treeUri = Uri.parse(treeUriStr)
            val found = findDocId(treeUri, name)
            if (found == null) { result.success(null); return }
            DocumentsContract.deleteDocument(context.contentResolver, docUri(treeUri, found.first))
            result.success(null)
        } catch (e: Exception) {
            result.error("DELETE_ERROR", e.message, null)
        }
    }

    private fun listFiles(treeUriStr: String, result: MethodChannel.Result) {
        try {
            val treeUri = Uri.parse(treeUriStr)
            val childrenUri = childrenUri(treeUri)
            val projection = arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
            val names = mutableListOf<String>()
            context.contentResolver.query(childrenUri, projection, null, null, null)?.use { cursor ->
                val col = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
                while (cursor.moveToNext()) {
                    val n = cursor.getString(col) ?: continue
                    if (n.endsWith(".json") && !n.endsWith(".backup")) names.add(n)
                }
            }
            result.success(names)
        } catch (e: Exception) {
            result.error("LIST_ERROR", e.message, null)
        }
    }

    private fun getLastModified(treeUriStr: String, name: String, result: MethodChannel.Result) {
        try {
            val treeUri = Uri.parse(treeUriStr)
            val found = findDocId(treeUri, name)
            val lastMod: Long? = found?.second
            result.success(if (lastMod != null && lastMod > 0L) lastMod else null)
        } catch (e: Exception) {
            result.error("STAT_ERROR", e.message, null)
        }
    }
}
