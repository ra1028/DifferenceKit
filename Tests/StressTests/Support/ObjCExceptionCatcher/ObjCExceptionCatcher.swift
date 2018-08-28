import Foundation

public final class ObjCExceptionCatcher {
    public static func tryClosure(
        tryClosure: () -> (),
        catchClosure: @escaping (NSException) -> (),
        finallyClosure: @escaping () -> () = {})
    {
        ObjCExceptionCatcherHelper.`try`(tryClosure, catch: catchClosure, finally: finallyClosure)
    }
}
