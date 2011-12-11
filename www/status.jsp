<%@ page contentType="text/plain;charset=utf-8"
		 import="java.io.*,
				 java.util.*,
				 java.util.regex.*,
				 org.json.simple.*,
				 com.google.common.base.*,
				 org.apache.commons.lang3.*,
				 org.apache.commons.lang3.math.*"
%><%

	Locale loc = request.getLocale();

	JSONObject retVal = new JSONObject();

	retVal.put("success", Boolean.TRUE);
	retVal.put("message", "OK");

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
		out.print(json);
	}
%>

