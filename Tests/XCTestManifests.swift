import XCTest

extension AlgorithmTestCase {
    static let __allTests = [
        ("testComplicated1", testComplicated1),
        ("testComplicated10", testComplicated10),
        ("testComplicated11", testComplicated11),
        ("testComplicated2", testComplicated2),
        ("testComplicated3", testComplicated3),
        ("testComplicated4", testComplicated4),
        ("testComplicated5", testComplicated5),
        ("testComplicated6", testComplicated6),
        ("testComplicated7", testComplicated7),
        ("testComplicated8", testComplicated8),
        ("testComplicated9", testComplicated9),
        ("testDeleted", testDeleted),
        ("testDuplicated", testDuplicated),
        ("testDuplicatedElement", testDuplicatedElement),
        ("testDuplicatedSection", testDuplicatedSection),
        ("testDuplicatedSectionAndElement", testDuplicatedSectionAndElement),
        ("testEmptyChangesets", testEmptyChangesets),
        ("testInserted", testInserted),
        ("testMixedChanges", testMixedChanges),
        ("testMixedSectionChanges", testMixedSectionChanges),
        ("testMoved", testMoved),
        ("testSameHashValue", testSameHashValue),
        ("testSectionDeleted", testSectionDeleted),
        ("testSectionedEmptyChangesets", testSectionedEmptyChangesets),
        ("testSectionInserted", testSectionInserted),
        ("testSectionMoved", testSectionMoved),
        ("testSectionUpdated", testSectionUpdated),
        ("testUpdated", testUpdated),
    ]
}

extension AnyDifferentiableTestCase {
    static let __allTests = [
        ("testHashable", testHashable),
    ]
}

extension ArraySectionTestCase {
    static let __allTests = [
        ("testReinitialize", testReinitialize),
    ]
}

extension ChangesetTestCase {
    static let __allTests = [
        ("testchangeCount", testchangeCount),
        ("testEquatable", testEquatable),
        ("testHasChanges", testHasChanges),
    ]
}

extension ContentEquatableTestCase {
    static let __allTests = [
        ("testEquatableValue", testEquatableValue),
        ("testOptionalValue", testOptionalValue),
    ]
}

extension ElementPathTestCase {
    static let __allTests = [
        ("testHashable", testHashable),
    ]
}

extension MeasurementTestCase {
    static let __allTests = [
        ("testMeasureAlgorithmForLinearCollection", testMeasureAlgorithmForLinearCollection),
        ("testMeasureAlgorithmForSectionedCollection", testMeasureAlgorithmForSectionedCollection),
    ]
}

extension StagedChangesetTestCase {
    static let __allTests = [
        ("testEquatable", testEquatable),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AlgorithmTestCase.__allTests),
        testCase(AnyDifferentiableTestCase.__allTests),
        testCase(ArraySectionTestCase.__allTests),
        testCase(ChangesetTestCase.__allTests),
        testCase(ContentEquatableTestCase.__allTests),
        testCase(ElementPathTestCase.__allTests),
        testCase(MeasurementTestCase.__allTests),
        testCase(StagedChangesetTestCase.__allTests),
    ]
}
#endif
