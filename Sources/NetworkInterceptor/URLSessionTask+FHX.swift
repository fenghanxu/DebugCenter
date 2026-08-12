
/**
 这个方法整体在干什么？
 
 记录时间 + 打印请求信息 + 再放行请求
 
 打印：请求方式 + URL
 */

import Foundation
import ObjectiveC.runtime

private var FHXStartTimeKey: UInt8 = 0

extension URLSessionTask {

    @objc
    func fhx_resume() {

        objc_setAssociatedObject(self, &FHXStartTimeKey, Date(), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        fhx_resume()
    }

    // 好像没有用过
    var fhx_startTime: Date? { objc_getAssociatedObject( self, &FHXStartTimeKey) as? Date }
    
}
