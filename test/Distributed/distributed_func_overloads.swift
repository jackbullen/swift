// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend-emit-module -emit-module-path %t/FakeDistributedActorSystems.swiftmodule -module-name FakeDistributedActorSystems -disable-availability-checking %S/Inputs/FakeDistributedActorSystems.swift
// RUN: %target-swift-frontend -typecheck -verify -disable-availability-checking -I %t 2>&1 %s
// REQUIRES: concurrency
// REQUIRES: distributed

import Distributed
import FakeDistributedActorSystems

typealias DefaultDistributedActorSystem = FakeActorSystem

// ==== ------------------------------------------------------------------------

distributed actor Overloader {

  func overloaded() {}
  func overloaded() async {}

  distributed func overloadedDistA() {} // expected-error{{ambiguous distributed func declaration 'overloadedDistA()', cannot overload distributed methods on effect only}}
  distributed func overloadedDistA() async {} // expected-note{{ambiguous distributed func 'overloadedDistA()' declared here}}

  distributed func overloadedDistT() throws {} // expected-error{{ambiguous distributed func declaration 'overloadedDistT()', cannot overload distributed methods on effect only}}
  distributed func overloadedDistT() async throws {} // expected-note{{ambiguous distributed func 'overloadedDistT()' declared here}}

  // Throws overloads are not legal anyway, but let's check for them here too:
  distributed func overloadedDistThrows() {}
  // expected-note@-1{{'overloadedDistThrows()' previously declared here}}
  // expected-error@-2{{ambiguous distributed func declaration 'overloadedDistThrows()', cannot overload distributed methods on effect only}}
  distributed func overloadedDistThrows() throws {}
  // expected-error@-1{{invalid redeclaration of 'overloadedDistThrows()'}}
  // expected-note@-2{{ambiguous distributed func 'overloadedDistThrows()' declared here}}

  distributed func overloadedDistAsync() async {}
  // expected-note@-1{{'overloadedDistAsync()' previously declared here}}
  // expected-error@-2{{ambiguous distributed func declaration 'overloadedDistAsync()', cannot overload distributed methods on effect only}}
  distributed func overloadedDistAsync() async throws {}
  // expected-error@-1{{invalid redeclaration of 'overloadedDistAsync()'}}
  // expected-note@-2{{ambiguous distributed func 'overloadedDistAsync()' declared here}}

  // overloads differing by parameter type are allowed,
  // since the mangled identifier includes full type information:
  distributed func overloadedDistParams(param: String) async {}
  distributed func overloadedDistParams(param: Int) async {}

  distributed func overloadedDistParams() async {} // also ok

  distributed func overloadedDistParams<A: Sendable & Codable>(param: A) async {}
}

