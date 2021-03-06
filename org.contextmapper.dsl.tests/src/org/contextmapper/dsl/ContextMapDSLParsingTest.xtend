/*
 * Copyright 2018 The Context Mapper Project Team
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
package org.contextmapper.dsl

import com.google.inject.Inject
import java.util.stream.Collectors
import org.contextmapper.dsl.contextMappingDSL.ContextMapState
import org.contextmapper.dsl.contextMappingDSL.ContextMapType
import org.contextmapper.dsl.contextMappingDSL.ContextMappingDSLPackage
import org.contextmapper.dsl.contextMappingDSL.ContextMappingModel
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static org.contextmapper.dsl.util.ParsingErrorAssertions.*
import static org.junit.jupiter.api.Assertions.*
import static org.contextmapper.dsl.validation.ValidationMessages.*
import org.contextmapper.dsl.tests.ContextMappingDSLInjectorProvider

@ExtendWith(InjectionExtension)
@InjectWith(ContextMappingDSLInjectorProvider)
class ContextMapDSLParsingTest {
	@Inject
	ParseHelper<ContextMappingModel> parseHelper

	ValidationTestHelper validationTestHelper = new ValidationTestHelper();

	@Test
	def void canDefineContextMap() {
		// given
		val String dslSnippet = '''
			ContextMap {}
		''';
		// when
		val ContextMappingModel result = parseHelper.parse(dslSnippet);
		// then
		assertThatNoParsingErrorsOccurred(result);
		assertThatNoValidationErrorsOccurred(result);
		assertNotNull(result.map);
	}

	@Test
	def void canDefineContextMapWithName() {
		// given
		val String dslSnippet = '''
			ContextMap myContextMap {}
		''';
		// when
		val ContextMappingModel result = parseHelper.parse(dslSnippet);
		// then
		assertThatNoParsingErrorsOccurred(result);
		assertThatNoValidationErrorsOccurred(result);
		assertNotNull(result.map);

		assertEquals("myContextMap", result.map.name)
	}

	@Test
	def void canAddBoundedContextToMap() {
		// given
		val String dslSnippet = '''
			ContextMap {
				 contains testContext
				 contains anotherTestContext
			}
			
			BoundedContext testContext
			BoundedContext anotherTestContext
		''';
		// when
		val ContextMappingModel result = parseHelper.parse(dslSnippet);
		// then
		assertThatNoParsingErrorsOccurred(result);
		assertThatNoValidationErrorsOccurred(result);
		assertNotNull(result.map);
		assertEquals(2, result.map.boundedContexts.size);

		val contextNames = result.map.boundedContexts.stream.map[name].collect(Collectors.toList);
		assertTrue(contextNames.contains("testContext"));
		assertTrue(contextNames.contains("anotherTestContext"));
	}

	@Test
	def void canAddBoundedContextToMapInOneLine() {
		// given
		val String dslSnippet = '''
			ContextMap {
				 contains testContext, anotherTestContext
			}
			
			BoundedContext testContext
			BoundedContext anotherTestContext
		''';
		// when
		val ContextMappingModel result = parseHelper.parse(dslSnippet);
		// then
		assertThatNoParsingErrorsOccurred(result);
		assertThatNoValidationErrorsOccurred(result);
		assertNotNull(result.map);
		assertEquals(2, result.map.boundedContexts.size);

		val contextNames = result.map.boundedContexts.stream.map[name].collect(Collectors.toList);
		assertTrue(contextNames.contains("testContext"));
		assertTrue(contextNames.contains("anotherTestContext"));
	}

	@Test
	def void canDefineContextMapState() {
		// given
		val String dslSnippet = '''
			ContextMap {
				state = AS_IS
			}
		''';
		// when
		val ContextMappingModel result = parseHelper.parse(dslSnippet);
		// then
		assertThatNoParsingErrorsOccurred(result);
		assertThatNoValidationErrorsOccurred(result);
		assertEquals(ContextMapState.AS_IS, result.map.state);
	}

	@Test
	def void canDefineContextMapType() {
		// given
		val String dslSnippet = '''
			ContextMap {
				type = SYSTEM_LANDSCAPE
			}
		''';
		// when
		val ContextMappingModel result = parseHelper.parse(dslSnippet);
		// then
		assertThatNoParsingErrorsOccurred(result);
		assertThatNoValidationErrorsOccurred(result);
		assertEquals(ContextMapType.SYSTEM_LANDSCAPE, result.map.type);
	}

	@Test
	def void showWarningIfBoundedContextsOnOrganizationalMapAreNotOfTypeTeam() {
		// given
		val String dslSnippet = '''
			ContextMap {
				type = ORGANIZATIONAL
			
				contains notATeam
			}
			
			BoundedContext notATeam {
				type = SYSTEM
			}
		''';
		// when
		val ContextMappingModel result = parseHelper.parse(dslSnippet);
		// then
		assertThatNoParsingErrorsOccurred(result);
		validationTestHelper.assertWarning(result, ContextMappingDSLPackage.Literals.CONTEXT_MAP, "",
			ORGANIZATIONAL_MAP_DOES_NOT_CONTAIN_TEAM);
	}

	@Test
	def void throwErrorIfTeamBoundedContextIsOnSystemLandscape() {
		// given
		val String dslSnippet = '''
			ContextMap {
				type = SYSTEM_LANDSCAPE
			
				contains aTeam
			}
			
			BoundedContext aTeam {
				type = TEAM
			}
		''';
		// when
		val ContextMappingModel result = parseHelper.parse(dslSnippet);
		// then
		validationTestHelper.assertError(result, ContextMappingDSLPackage.Literals.CONTEXT_MAP, "",
			String.format(SYSTEM_LANDSCAPE_MAP_CONTAINS_TEAM));
	}

	@Test
	def void canDefineBoundedContextBeforeContextMap() {
		// given
		val String dslSnippet = '''
			BoundedContext testContext
			BoundedContext anotherTestContext
			
			ContextMap {
				 contains testContext
				 contains anotherTestContext
			}
		''';
		// when
		val ContextMappingModel result = parseHelper.parse(dslSnippet);
		// then
		assertThatNoParsingErrorsOccurred(result);
		assertThatNoValidationErrorsOccurred(result);
		assertNotNull(result.map);
		assertEquals(2, result.map.boundedContexts.size);

		val contextNames = result.map.boundedContexts.stream.map[name].collect(Collectors.toList);
		assertTrue(contextNames.contains("testContext"));
		assertTrue(contextNames.contains("anotherTestContext"));
	}

	@Test
	def void throwErrorForSelfRelationship() {
		// given
		val String dslSnippet = '''
			BoundedContext testContext
			
			ContextMap {
				 contains testContext
				 
				 testContext [P]<->[P] testContext
			}
		''';
		// when
		val ContextMappingModel result = parseHelper.parse(dslSnippet);

		// then
		assertThatNoParsingErrorsOccurred(result);
		validationTestHelper.assertError(result, ContextMappingDSLPackage.Literals.CONTEXT_MAP, "",
			String.format(SELF_RELATIONSHIP_NOT_ALLOWED));
	}

	@Test
	def void canDefineAttributesWithoutEqualSign() {
		// given
		val String dslSnippet = '''
			ContextMap {
				type SYSTEM_LANDSCAPE
				state AS_IS
			}
		''';
		// when
		val ContextMappingModel result = parseHelper.parse(dslSnippet);
		// then
		assertThatNoParsingErrorsOccurred(result);
		assertThatNoValidationErrorsOccurred(result);
		assertEquals(ContextMapType.SYSTEM_LANDSCAPE, result.map.type);
		assertEquals(ContextMapState.AS_IS, result.map.state);
	}
}
