import Fluent
import Vapor

struct AppIconController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let appIcons = routes.grouped("api", "appIcon")

        appIcons.get(use: getIcon)
        // appIcons.post(use: newIcon)
        appIcons.on(.POST, body: .collect(maxSize: "1mb"), use: newIcon)
    }

    func getIcon(req: Request) async throws -> Response {
        // GET /api/appIcon?packageName=
        guard let packageName: String = req.query["packageName"] else {
            throw Abort(.badRequest)
        }

        return req.fileio.streamFile(at: "data/icons/\(packageName).png")
    }

    func newIcon(req: Request) async throws -> RequestResult {
        // POST /api/appIcon?packageName=
        guard req.headers["Content-Type"].contains("image/png"), 
            let packageName: String = req.query["packageName"],
            let buffer = req.body.data else {        
            throw Abort(.badRequest)
        }

        try await req.fileio.writeFile(buffer, at: "data/icons/\(packageName).png")
        return .init(code: 200, isSuccess: true, message: "Added/updated new app icon.")
    }
}
