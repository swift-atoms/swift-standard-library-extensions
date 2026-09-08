import Testing

@testable import Standard_Library_Extensions

@Test
func `unqualified cancellation handler remains unambiguous`() async {
    let value = await withTaskCancellationHandler {
        42
    } onCancel: {
    }

    #expect(value == 42)
}
