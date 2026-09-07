
import Foundation

final class FHXNetworkLogger {

    static func log(
        task: URLSessionTask,
        error: Error?
    ) {

        let request =
            task.fhx_request
            ?? task.currentRequest
            ?? task.originalRequest

        guard let request else {
            return
        }

        let response =
            objc_getAssociatedObject(
                task,
                &FHXResponseKey
            ) as? URLResponse

        let responseData =
            objc_getAssociatedObject(
                task,
                &FHXResponseDataKey
            ) as? NSMutableData ?? NSMutableData()

        let startTime =
            task.fhx_startTime

        let cost: Int

        if let startTime {

            cost =
                Int(
                    Date()
                        .timeIntervalSince(startTime)
                    * 1000
                )

        } else {

            cost = 0
        }

        let statusCode =
            (
                response
                as? HTTPURLResponse
            )?.statusCode ?? 0

        let parameterData =
            task.fhx_requestBodyData
            ?? request.httpBody

        let parameter =
            parameterData.flatMap {
                String(
                    data: $0,
                    encoding: .utf8
                )
            } ?? ""

        let responseString =
            String(
                data: responseData as Data,
                encoding: .utf8
            ) ?? ""

        let headers =
            redactedHeaders(
                request.allHTTPHeaderFields
                ?? [:]
            )

        let log =
            """
            Method : \(request.httpMethod ?? "GET")

            URL : \(request.url?.absoluteString ?? "")

            StatusCode : \(statusCode)

            CostTime : \(cost) ms

            Error : \(error?.localizedDescription ?? "nil")

            Headers :
            \(prettyJSON(headers))

            Parameters :
            \(prettyJSONString(parameter))

            Response :
            \(prettyJSONString(responseString))
            """

        FHXLog.shared.log(
            log,
            .network
        )
    }

    // MARK: - Headers

    private static func redactedHeaders(
        _ headers: [String: String]
    ) -> [String: String] {

        var result = headers

        for key in result.keys {

            let lowerKey =
                key.lowercased()

            if lowerKey == "authorization" ||
                lowerKey == "cookie" ||
                lowerKey == "set-cookie" {

                result[key] =
                    "***REDACTED***"
            }
        }

        return result
    }
}
