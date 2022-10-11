// Use this file to write queries to test your data connector
let
    result = WebConConnectorAppContext.Contents("https://webconPortalUrl", "beta", 1, "clientIDValue", "clientSecretValue")
in
    result