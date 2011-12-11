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

	String regex = request.getParameter("regex");
	String replacement = request.getParameter("replacement");
	Set<String> options = new TreeSet<String>();
	String[] ArrOption = request.getParameterValues("option");
	if (ArrOption != null && ArrOption.length > 0)
	{
		options.addAll(Arrays.asList(ArrOption));
	}
	String[] ArrInput = request.getParameterValues("input");

	if (Strings.isNullOrEmpty(regex))
	{
		retVal.put("success", Boolean.FALSE);
		retVal.put("message", "No regex to test");
	}
	else
	{
		StringWriter sw = new StringWriter();
		PrintWriter pw = new PrintWriter(sw);

		pw.println("<table class=\"bordered-table zebra-striped\">");
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
		if (options.contains("insensitive")) { flags |= Pattern.CASE_INSENSITIVE; }
		if (options.contains("comments")) { flags |= Pattern.COMMENTS; }
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
			pw.print("\t\t\t<td>");
			//ImgUtil.appendIcon(out, "stop", "error");
			pw.print(' ');
			pw.print(StringEscapeUtils.escapeHtml4(e.getMessage()));
			pw.println("</td>");
			pw.println("\t\t</tr>");
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


		if (p != null)
		{
			pw.println("<table class=\"bordered-table zebra-striped\">");
			pw.println("\t<thead>");
			pw.println("\t\t<tr>");
			pw.println("\t\t\t<th>Test</th>");
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

				Matcher m = p.matcher(test);

				pw.print("\t\t\t<td>");
				pw.print(StringEscapeUtils.escapeHtml4(booleanToString(m.matches(), loc)));
				pw.println("</td>");

				m.reset();

				pw.print("\t\t\t<td>");
				try
				{
					pw.print(StringEscapeUtils.escapeHtml4(m.replaceFirst(replacement)));
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
				try
				{
					pw.print(StringEscapeUtils.escapeHtml4(m.replaceAll(replacement)));
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
				pw.print(StringEscapeUtils.escapeHtml4(booleanToString(m.lookingAt(), loc)));
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

			pw.close();

			retVal.put("success", Boolean.TRUE);
			retVal.put("html", sw.toString());
		}
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
%>



