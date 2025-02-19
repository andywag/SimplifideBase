/*******************************************************************************
 * Copyright (c) 2009 Andrew Gvozdev (Quoin Inc.) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Andrew Gvozdev (Quoin Inc.) - Initial API and implementation
 *******************************************************************************/
package com.simplifide.core.errorparser;

/**
 * Extension of IErrorParser interface to attach id and names to an error parser.
 * Clients must implement {@link Object#clone} and {@link Object#equals} methods to avoid slicing.
 * @since 5.2
 */
public interface IErrorParserNamed extends IErrorParser, Cloneable {
	/**
	 * Set error parser ID.
	 * @param id of error parser
	 */
	public void setId(String id);

	/**
	 * Set error parser name.
	 * @param name of error parser
	 */
	public void setName(String name);

	/**
	 * @return id of error parser
	 */
	public String getId();

	/**
	 * @return name of error parser
	 */
	public String getName();
}
