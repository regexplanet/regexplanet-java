<%@ page buffer="16kb"
		 contentType="text/plain;charset=utf-8"
		 import="java.io.*,
				 java.text.*,
				 java.util.*,
				 com.google.appengine.api.datastore.*,
				 com.google.appengine.api.datastore.Query.FilterOperator"
		 session="false"
%><%

	TimedOutput tout = new TimedOutput(out);

	String numString = request.getParameter("num");
	int limit = numString == null ? 375 : Integer.parseInt(numString);
	tout.println(MessageFormat.format("Will try to purge {0} expired sessions", limit));

	Query query = new Query("_ah_SESSION");
	query.addFilter("_expires", FilterOperator.LESS_THAN, System.currentTimeMillis() - (7*24*60*60*1000));
	query.setKeysOnly();
	List<Key> killList = new ArrayList<Key>(limit);
	DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	tout.println("got datastore");
	PreparedQuery pq = datastore.prepare(query);
	tout.println("Prepared query");
	Iterable<Entity> entities = pq.asIterable(FetchOptions.Builder.withLimit(limit));
	tout.println("asIterable ready");
	for(Entity expiredSession : entities)
	{
		Key key = expiredSession.getKey();
		killList.add(key);
	}
	tout.println("KillList built");

	try
	{
		datastore.delete(killList);
	}
	catch (Exception e)
	{
		tout.println(MessageFormat.format("DatastoreTimeoutException after {0}", killList.size()));
	}

	tout.println(MessageFormat.format("Cleared {0} expired sessions", killList.size()));

%><%!

class TimedOutput
{
	JspWriter out;
	long start;
	long lap;

	public TimedOutput(JspWriter out)
	{
		this.out = out;
		this.start = System.currentTimeMillis();
	}

	public void println(String msg)
		throws IOException
	{
		long now = System.currentTimeMillis();
		out.print(msg);
		if (lap != 0)
		{
			out.print(MessageFormat.format(" ({0} ms)", (now - lap)));
		}
		out.println();
		out.flush();
		lap = System.currentTimeMillis();
	}
}

%>
