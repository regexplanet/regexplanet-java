<%@ page contentType="text/plain;charset=utf-8"
		 import="java.io.*,
			 java.time.*,
			 java.time.format.*,
			 java.util.*,
			 java.util.regex.*,
			 org.json.simple.*"
%><%

	JSONObject retVal = new JSONObject();

	retVal.put("success", Boolean.TRUE);
	retVal.put("message", "OK");
	retVal.put("commit", System.getenv("COMMIT"));
	retVal.put("timestamp", ZonedDateTime.now( ZoneOffset.UTC ).format( DateTimeFormatter.ISO_INSTANT ));
	retVal.put("lastmod", System.getenv("LASTMOD"));
	retVal.put("tech", "Java " + System.getProperty("java.specification.version", "(unknown)"));
	retVal.put("version", System.getProperty("java.version", "Unknown") + " (" + System.getProperty("java.vm.name", "Unknown VM") + ")");
	retVal.put("java.vendor", System.getProperty("java.vendor"));
	retVal.put("java.version", System.getProperty("java.version"));
	retVal.put("java.specification.version", System.getProperty("java.specification.version"));
	retVal.put("java.class.version", System.getProperty("java.class.version"));
	retVal.put("java.vm.version", System.getProperty("java.vm.version"));
	retVal.put("os.name", System.getProperty("os.name"));
	retVal.put("java.vm.specification.version", System.getProperty("java.vm.specification.version"));
	retVal.put("java.vm.vendor", System.getProperty("java.vm.vendor"));
	retVal.put("java.vm.name", System.getProperty("java.vm.name"));
	retVal.put("file.encoding", System.getProperty("file.encoding"));

	String json = retVal.toString();
	String callback = request.getParameter("callback");
	if (callback != null && callback.matches("[a-zA-Z][-a-zA-Z0-9_]*"))
	{
		out.print(callback);
		out.print("(");
		out.print(json);
		out.print(");");
	}
	else
	{
		response.setHeader("Access-Control-Allow-Origin", "*");
		response.setHeader("Access-Control-Allow-Methods", "GET, POST");
		response.setHeader("Access-Control-Max-Age", "604800");
		out.print(json);
	}
%>

