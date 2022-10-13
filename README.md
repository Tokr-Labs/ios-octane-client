# iOS Octane Client

A lightweight example of using [Octane](https://github.com/solana-labs/octane) to re-sign a simple memo transaction assigning the transaction fees to a pre-determined (see [https://github.com/Tokr-Labs/octane-server](https://github.com/Tokr-Labs/octane-server)) solana account stored on the server. 

## Requirements

- iOS 16
- Running proxy server mentioned above.

## Running Locally

Rather than using an xcconfig file to reference a **[server](https://github.com/Tokr-Labs/octane-server)**, **[hot wallet](https://www.investopedia.com/terms/h/hot-wallet.asp)** and the **fee payer's public key**, the example app instead has a settings screen that simply saves these to the standard user default object (you would obviously not want to do this for any kind of production application 😉).
