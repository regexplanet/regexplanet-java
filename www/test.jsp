<%@ page contentType="text/plain;charset=utf-8"
		 import="java.io.*,
		 		 java.text.*,
				 java.util.*,
				 java.util.regex.*,
				 org.json.simple.*,
				 com.google.common.base.*,
				 org.apache.commons.lang3.*,
				 org.apache.commons.lang3.math.*"
%><%

	response.setHeader("Access-Control-Allow-Origin", "*"); //"http://www.regexplanet.com");
	response.setHeader("Access-Control-Allow-Methods", "POST, GET");
	response.setHeader("Access-Control-Max-Age", Integer.toString(60 * 60 * 24 * 7));
	if (request.getMethod().equalsIgnoreCase("options"))
	{
		out.print("yes, CORS is allowed!");
		return;
	}

	Locale loc = request.getLocale();

	JSONObject retVal = new JSONObject();

	String regex = request.getParameter("regex");
	String replacement = request.getParameter("replacement");
	Set<String> options = new TreeSet<String>();
	String[] ArrOption = request.getParameterValues("option");
	if (ArrOption != null && ArrOption.length > 0)
	{
		options.addAll(Arrays.asList(ArrOption));
	}
	String[] ArrInput = request.getParameterValues("input");
	int timeoutMillis = 10 * 1000;

	if (Strings.isNullOrEmpty(regex))
	{
		retVal.put("success", Boolean.FALSE);
		retVal.put("message", "No regex to test");
	}
	else
	{
		StringWriter sw = new StringWriter();
		PrintWriter pw = new PrintWriter(sw);

		pw.println("<table class=\"table table-bordered table-striped bordered-table zebra-striped\" style=\"width:auto;\">");
		pw.println("\t<tbody>");

		pw.println("\t\t<tr>");
		pw.println("\t\t\t<td>Regular Expression</td>");
		pw.print("\t\t\t<td>");
		pw.print(StringEscapeUtils.escapeHtml4(regex));
		pw.print("</td>");
		pw.println("\t\t</tr>");

		pw.println("\t\t<tr>");
		pw.println("\t\t\t<td>as a Java string</td>");
		pw.print("\t\t\t<td>&quot;");
		char[] chars = regex.toCharArray();
		for (int loop = 0; loop < chars.length; loop++)
		{
			if (chars[loop] == '"')
			{
				pw.print("\\&quot;");
			}
			else if (chars[loop] == '\\')
			{
				pw.print("\\\\");
			}
			else
			{
				pw.print(StringEscapeUtils.escapeHtml4(Character.toString(chars[loop])));
			}
		}
		pw.print("&quot;</td>");
		pw.println("\t\t</tr>");

		pw.println("\t\t<tr>");
		pw.println("\t\t\t<td>Replacement</td>");
		pw.print("\t\t\t<td>");
		pw.print(StringEscapeUtils.escapeHtml4(replacement));
		pw.print("</td>");
		pw.println("\t\t</tr>");

		int flags = 0;
		if (options.contains("canon")) { flags |= Pattern.CANON_EQ; }
		if (options.contains("ignorecase")) { flags |= Pattern.CASE_INSENSITIVE; }
		if (options.contains("comment")) { flags |= Pattern.COMMENTS; }
		if (options.contains("dotall")) { flags |= Pattern.DOTALL; }
		if (options.contains("multiline")) { flags |= Pattern.MULTILINE; }
		if (options.contains("unicode")) { flags |= Pattern.UNICODE_CASE; }
		if (options.contains("unixline")) { flags |= Pattern.UNIX_LINES; }

		Pattern p = null;

		try
		{
			p = Pattern.compile(regex, flags);
		}
		catch (Exception e)
		{
			pw.println("\t\t<tr>");
			pw.println("\t\t\t<td>Compile error</td>");
			pw.print("\t\t\t<td><pre>");
			pw.print(StringEscapeUtils.escapeHtml4(e.getMessage()));
			pw.println("</pre></td>");
			pw.println("\t\t</tr>");
			retVal.put("message", e.getMessage());
		}
		int groupCount = 0;

		if (p != null)
		{
			groupCount = p.matcher("").groupCount();
			pw.println("\t\t<tr>");
			pw.println("\t\t\t<td>groupCount()</td>");
			pw.print("\t\t\t<td>");
			pw.print(groupCount);
			pw.print("</td>");
			pw.println("\t\t</tr>");
		}
		pw.println("\t</tbody>");
		pw.println("</table>");


		if (p == null)
		{
			retVal.put("success", Boolean.FALSE);
		}
		else
		{
			pw.println("<table class=\"table table-bordered table-striped bordered-table zebra-striped\">");
			pw.println("\t<thead>");
			pw.println("\t\t<tr>");
			pw.println("\t\t\t<th style=\"text-align:center\">Test</th>");
			pw.println("\t\t\t<th>Target String</th>");
			pw.println("\t\t\t<th>matches()</th>");
			pw.println("\t\t\t<th>replaceFirst()</th>");
			pw.println("\t\t\t<th>replaceAll()</th>");
			pw.println("\t\t\t<th>lookingAt()</th>");
			pw.println("\t\t\t<th>find()</th>");
			for (int loop = 0; loop <= groupCount; loop++)
			{
				pw.print("\t\t\t<th>group(");
				pw.print(loop);
				pw.println(")</th>");
			}
			pw.println("\t\t</tr>");
			pw.println("\t</thead>");

			pw.println("\t<tbody>");

			for (int loop = 0, len = ArrInput == null ? 0 : ArrInput.length; loop < len; loop++)
			{
				String test = ArrInput[loop];
				if (test == null || test.length() == 0)
				{
					continue;
				}
				pw.println("\t\t<tr>");
				pw.print("\t\t\t<td style=\"text-align:center\">");
				pw.print(loop+1);
				pw.println("</td>");

				pw.print("\t\t\t<td>");
				pw.print(StringEscapeUtils.escapeHtml4(test));
				pw.println("</td>");

				Matcher m = null;
				boolean matches, lookingAt;
				String replaceFirst, replaceAll;

				try
				{
					m = p.matcher(new TimeoutCharSequence(test, timeoutMillis));
					matches = m.matches();
					m.reset();
					replaceFirst = m.replaceFirst(replacement);
					m.reset();
					replaceAll = m.replaceAll(replacement);
					m.reset();
					lookingAt = m.lookingAt();
				}
				catch (Exception e)
				{
					pw.print("\t\t\t<td class=\"text-error\" colspan=\"6\">");
					pw.print("ERROR: ");
					pw.print(StringEscapeUtils.escapeHtml4(e.getMessage()));
					pw.println("</td>");
					pw.println("\t\t</tr>");
					continue;
				}

				pw.print("\t\t\t<td>");
				pw.print(StringEscapeUtils.escapeHtml4(booleanToString(matches, loc)));
				pw.println("</td>");


				pw.print("\t\t\t<td>");
				try
				{
					pw.print(StringEscapeUtils.escapeHtml4(replaceFirst));
				}
				catch (Exception e)
				{
					pw.print("<i>(ERROR: ");
					pw.print(StringEscapeUtils.escapeHtml4(e.getMessage()));
					pw.print(")</i>");
				}

				pw.println("</td>");

				m.reset();

				pw.print("\t\t\t<td>");
				pw.print(StringEscapeUtils.escapeHtml4(replaceAll));
				pw.println("</td>");

				pw.print("\t\t\t<td>");
				pw.print(StringEscapeUtils.escapeHtml4(booleanToString(lookingAt, loc)));
				pw.println("</td>");

				m.reset();

				int count = 0;
				int findCount = 0;
				boolean ifFirst = true;
				while (m.find())
				{
					count = 0;
					findCount++;
					if (ifFirst == true)
					{
						ifFirst = false;
					}
					else
					{
						pw.println("\t\t</tr>");
						pw.println("\t\t<tr>");
						pw.println("\t\t\t<td colspan=\"6\" style=\"text-align:right\">next find()</td>");
					}
					pw.print("\t\t\t<td>");
					pw.print(StringEscapeUtils.escapeHtml4(booleanToString(true, loc)));
					pw.println("</td>");

					for (int group = 0; group <= m.groupCount(); group++)
					{
						count++;
						pw.print("\t\t\t<td>");
						pw.print(StringEscapeUtils.escapeHtml4(m.group(group)));
						pw.println("</td>");
					}
					for (;count < groupCount; count++)
					{
						// for group 0
						pw.println("\t\t\t<td>&nbsp;</td>");
					}
				}
				if (findCount == 0)
				{
					pw.print("\t\t\t<td>");
					pw.print(StringEscapeUtils.escapeHtml4(booleanToString(false, loc)));
					pw.println("</td>");
				}
				for (;count < groupCount; count++)
				{
					// for group 0
					pw.println("\t\t\t<td>&nbsp;</td>");
				}

				pw.println("\t\t</tr>");
			}
			pw.println("\t</tbody>");
			pw.println("</table>");

			retVal.put("success", Boolean.TRUE);
		}
		pw.close();
		retVal.put("html", sw.toString());
	}

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
%><%!
	String booleanToString(boolean b, Locale loc)
	{
		return b ? "Yes" : "No";
	}

	boolean stringToBoolean(String s)
	{
		if (s == null || s.length() == 0)
		{
			return false;
		}

		char ch = s.charAt(0);
		if (ch == 'Y' || ch == 'y' || ch == '1')
		{
			return true;
		}

		return false;
	}

	class TimeoutCharSequence
		implements CharSequence
	{
		private final CharSequence inner;
		private final int timeoutMillis;
		private final long timeoutTime;

		public TimeoutCharSequence(CharSequence inner, int timeoutMillis)
		{
			super();
			this.inner = inner;
			this.timeoutMillis = timeoutMillis;
			timeoutTime = System.currentTimeMillis() + timeoutMillis;
		}

		public char charAt(int index)
		{
			if (System.currentTimeMillis() > timeoutTime)
			{
				throw new RuntimeException(MessageFormat.format("Interrupted after {0}ms", timeoutMillis));
			}
			return inner.charAt(index);
		}

		public int length()
		{
			return inner.length();
		}

		public CharSequence subSequence(int start, int end)
		{
			return new TimeoutCharSequence(inner.subSequence(start, end), timeoutMillis);
		}

		@Override
		public String toString()
		{
			return inner.toString();
		}
	}
%>



