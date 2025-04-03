package com.regexplanet;

import java.text.MessageFormat;

class TimeoutCharSequence
	implements CharSequence {
	private final CharSequence inner;
	private final int timeoutMillis;
	private final long timeoutTime;

	public TimeoutCharSequence(CharSequence inner, int timeoutMillis) {
		super();
		this.inner = inner;
		this.timeoutMillis = timeoutMillis;
		timeoutTime = System.currentTimeMillis() + timeoutMillis;
	}

	public char charAt(int index) {
		if (System.currentTimeMillis() > timeoutTime) {
			throw new RuntimeException(MessageFormat.format("Interrupted after {0}ms", timeoutMillis));
		}
		return inner.charAt(index);
	}

	public int length() {
		return inner.length();
	}

	public CharSequence subSequence(int start, int end) {
		return new TimeoutCharSequence(inner.subSequence(start, end), timeoutMillis);
	}

	@Override
	public String toString() {
		return inner.toString();
	}
}
