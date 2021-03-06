/*
 * Copyright 2019 The Context Mapper Project Team
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.contextmapper.dsl.ui.handler.wizard.pages;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.contextmapper.dsl.contextMappingDSL.Volatility;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.KeyAdapter;
import org.eclipse.swt.events.KeyEvent;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.program.Program;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;

public class LikelihoodForChangeSelectionWizardPage extends ContextMapperWizardPage {

	private Combo selectionCombo;
	private Composite container;
	private List<Volatility> availableLikelihoodsForChange;

	public LikelihoodForChangeSelectionWizardPage(List<Volatility> availableLikelihoodsForChange) {
		super("Volatility Selection Page");
		this.availableLikelihoodsForChange = availableLikelihoodsForChange;
	}

	@Override
	public String getTitle() {
		return "Volatility Selection";
	}

	@Override
	public String getDescription() {
		return "Select volatility by which you want to extract";
	}

	@Override
	public void createControl(Composite parent) {
		container = new Composite(parent, SWT.NONE);
		GridLayout layout = new GridLayout();
		container.setLayout(layout);
		layout.numColumns = 2;

		// name label
		Label boundedContextNameLabel1 = new Label(container, SWT.NONE);
		boundedContextNameLabel1.setText("Volatility (Likelihood for Change):");

		// selection field
		selectionCombo = new Combo(container, SWT.DROP_DOWN);
		selectionCombo.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
		List<String> selectionStrings = Arrays.asList(Volatility.values()).stream().map(l -> l.getName()).collect(Collectors.toList());
		selectionCombo.setItems(selectionStrings.toArray(new String[selectionStrings.size()]));
		selectionCombo.select(selectionStrings.indexOf(Volatility.OFTEN.getName()));
		selectionCombo.addSelectionListener(new SelectionAdapter() {
			@Override
			public void widgetSelected(SelectionEvent e) {
				setPageComplete(isPageComplete());
				updateValidationMessage();
			}
		});
		selectionCombo.addKeyListener(new KeyAdapter() {
			@Override
			public void keyReleased(KeyEvent e) {
				setPageComplete(isPageComplete());
				updateValidationMessage();
			}
		});

		setControl(container);
		setPageComplete(false);
	}

	private void updateValidationMessage() {
		setErrorMessage(null);
		if (Volatility.get(selectionCombo.getText()) != null && !this.availableLikelihoodsForChange.contains(Volatility.valueOf(selectionCombo.getText()))) {
			setErrorMessage("Your Bounded Context does not contain any Aggregates with a 'likelihood for change' of '" + selectionCombo.getText() + "'.");
		}
	}

	@Override
	public void setVisible(boolean visible) {
		super.setVisible(visible);
		this.selectionCombo.forceFocus();
	}

	public Volatility getVolatility() {
		return Volatility.valueOf(this.selectionCombo.getText());
	}

	@Override
	public boolean isPageComplete() {
		return this.selectionCombo.getText() != null && !"".equals(this.selectionCombo.getText()) && this.availableLikelihoodsForChange.contains(Volatility.valueOf(this.selectionCombo.getText()));
	}

	@Override
	public void performHelp() {
		Program.launch("https://contextmapper.org/docs/ar-extract-aggregates-by-volatility/");
	}
}
