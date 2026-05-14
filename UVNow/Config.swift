/// App-wide configuration. Fill in API keys here.
enum Config {

    /// Free key from https://www.openuv.io (50 requests/day on free tier).
    /// Leave empty to use Open-Meteo only. OpenUV is automatically added
    /// as a second source when this is non-empty.
    static let openUVApiKey = "openuv-7pucyprmp4zuiw3-io"

    // To add WeatherKit later:
    // 1. Enable the WeatherKit capability in Xcode (Signing & Capabilities tab)
    // 2. Create WeatherKitService conforming to UVDataProvider
    // 3. Append WeatherKitService() to the providers array in UVViewModel
}
