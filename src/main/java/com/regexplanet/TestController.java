package com.regexplanet;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.util.HtmlUtils;

@Controller
public class TestController {

		String booleanToString(boolean b)
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
		if (ch == 'Y' || ch == 'y' || ch == 'T' || ch == 't' || ch == '1')
		{
			return true;
		}

		return false;
	}


    @RequestMapping(value = "/test.json", method = {RequestMethod.GET, RequestMethod.POST})
	public void handle(jakarta.servlet.http.HttpServletResponse resp,
			@RequestParam(required = false) String regex,
			@RequestParam(required = false) String replacement,
			@RequestParam(required = false) List<String> option,
			@RequestParam(required = false) List<String> input,
			@RequestParam(required = false) String callback)
			throws IOException {

		Map<String, Object> retVal = new HashMap<>();

		if (replacement == null) {
			replacement = "";
		}

		String[] ArrInput = input != null ? input.toArray(new String[0]) : null;
		String[] ArrOption = option != null ? option.toArray(new String[0]) : null;
		Set<String> options = new TreeSet<String>();
		if (ArrOption != null && ArrOption.length > 0) {
			options.addAll(Arrays.asList(ArrOption));
		}
		int timeoutMillis = 10 * 1000;

		if (regex == null || regex.equals("")) {
			retVal.put("success", Boolean.FALSE);
			retVal.put("message", "No regex to test");
		} else {
			StringWriter sw = new StringWriter();
			PrintWriter pw = new PrintWriter(sw);

			pw.println(
					"<table class=\"table table-bordered table-striped bordered-table zebra-striped\" style=\"width:auto;\">");
			pw.println("\t<tbody>");

			pw.println("\t\t<tr>");
			pw.println("\t\t\t<td>Regular Expression</td>");
			pw.print("\t\t\t<td>");
			pw.print(HtmlUtils.htmlEscape(regex));
			pw.print("</td>");
			pw.println("\t\t</tr>");

			pw.println("\t\t<tr>");
			pw.println("\t\t\t<td>as a Java string</td>");
			pw.print("\t\t\t<td>&quot;");
			char[] chars = regex.toCharArray();
			for (int loop = 0; loop < chars.length; loop++) {
				if (chars[loop] == '"') {
					pw.print("\\&quot;");
				} else if (chars[loop] == '\\') {
					pw.print("\\\\");
				} else {
					pw.print(HtmlUtils.htmlEscape(Character.toString(chars[loop])));
				}
			}
			pw.print("&quot;</td>");
			pw.println("\t\t</tr>");

			pw.println("\t\t<tr>");
			pw.println("\t\t\t<td>Replacement</td>");
			pw.print("\t\t\t<td>");
			pw.print(HtmlUtils.htmlEscape(replacement));
			pw.print("</td>");
			pw.println("\t\t</tr>");

			int flags = 0;
			if (options.contains("canon")) {
				flags |= Pattern.CANON_EQ;
			}
			if (options.contains("ignorecase")) {
				flags |= Pattern.CASE_INSENSITIVE;
			}
			if (options.contains("comment")) {
				flags |= Pattern.COMMENTS;
			}
			if (options.contains("dotall")) {
				flags |= Pattern.DOTALL;
			}
			if (options.contains("multiline")) {
				flags |= Pattern.MULTILINE;
			}
			if (options.contains("unicode")) {
				flags |= Pattern.UNICODE_CASE;
			}
			if (options.contains("unixline")) {
				flags |= Pattern.UNIX_LINES;
			}

			Pattern p = null;

			try {
				p = Pattern.compile(regex, flags);
			} catch (Exception e) {
				pw.println("\t\t<tr>");
				pw.println("\t\t\t<td>Compile error</td>");
				pw.print("\t\t\t<td><pre>");
				pw.print(HtmlUtils.htmlEscape(e.getMessage()));
				pw.println("</pre></td>");
				pw.println("\t\t</tr>");
				retVal.put("message", e.getMessage());
			}
			int groupCount = 0;

			if (p != null) {
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

			if (p == null) {
				retVal.put("success", Boolean.FALSE);
			} else {
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
				for (int loop = 0; loop <= groupCount; loop++) {
					pw.print("\t\t\t<th>group(");
					pw.print(loop);
					pw.println(")</th>");
				}
				pw.println("\t\t</tr>");
				pw.println("\t</thead>");

				pw.println("\t<tbody>");

				for (int loop = 0, len = ArrInput == null ? 0 : ArrInput.length; loop < len; loop++) {
					String test = ArrInput[loop];
					if (test == null || test.length() == 0) {
						continue;
					}
					pw.println("\t\t<tr>");
					pw.print("\t\t\t<td style=\"text-align:center\">");
					pw.print(loop + 1);
					pw.println("</td>");

					pw.print("\t\t\t<td>");
					pw.print(HtmlUtils.htmlEscape(test));
					pw.println("</td>");

					Matcher m = null;
					boolean matches, lookingAt;
					String replaceFirst, replaceAll;

					try {
						m = p.matcher(new TimeoutCharSequence(test, timeoutMillis));
						matches = m.matches();
						m.reset();
						replaceFirst = m.replaceFirst(replacement);
						m.reset();
						replaceAll = m.replaceAll(replacement);
						m.reset();
						lookingAt = m.lookingAt();
					} catch (Exception e) {
						pw.print("\t\t\t<td class=\"text-error\" colspan=\"6\">");
						pw.print("ERROR: ");
						pw.print(HtmlUtils.htmlEscape(e.getMessage()));
						pw.println("</td>");
						pw.println("\t\t</tr>");
						continue;
					}

					pw.print("\t\t\t<td>");
					pw.print(HtmlUtils.htmlEscape(booleanToString(matches)));
					pw.println("</td>");

					pw.print("\t\t\t<td>");
					try {
						pw.print(HtmlUtils.htmlEscape(replaceFirst));
					} catch (Exception e) {
						pw.print("<i>(ERROR: ");
						pw.print(HtmlUtils.htmlEscape(e.getMessage()));
						pw.print(")</i>");
					}

					pw.println("</td>");

					m.reset();

					pw.print("\t\t\t<td>");
					pw.print(HtmlUtils.htmlEscape(replaceAll));
					pw.println("</td>");

					pw.print("\t\t\t<td>");
					pw.print(HtmlUtils.htmlEscape(booleanToString(lookingAt)));
					pw.println("</td>");

					m.reset();

					int count = 0;
					int findCount = 0;
					boolean ifFirst = true;
					while (m.find()) {
						count = 0;
						findCount++;
						if (ifFirst == true) {
							ifFirst = false;
						} else {
							pw.println("\t\t</tr>");
							pw.println("\t\t<tr>");
							pw.println("\t\t\t<td colspan=\"6\" style=\"text-align:right\">next find()</td>");
						}
						pw.print("\t\t\t<td>");
						pw.print(HtmlUtils.htmlEscape(booleanToString(true)));
						pw.println("</td>");

						for (int group = 0; group <= m.groupCount(); group++) {
							count++;
							pw.print("\t\t\t<td>");
							pw.print(HtmlUtils.htmlEscape(m.group(group)));
							pw.println("</td>");
						}
						for (; count < groupCount; count++) {
							// for group 0
							pw.println("\t\t\t<td>&nbsp;</td>");
						}
					}
					if (findCount == 0) {
						pw.print("\t\t\t<td>");
						pw.print(HtmlUtils.htmlEscape(booleanToString(false)));
						pw.println("</td>");
					}
					for (; count < groupCount; count++) {
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
		HandleJsonp.handleJsonp(resp, callback, retVal);
	}

}
