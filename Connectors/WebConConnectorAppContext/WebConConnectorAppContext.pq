section WebConConnectorAppContext;

[DataSource.Kind="WebConConnectorAppContext", Publish="WebConConnectorAppContext.Publish"]
shared WebConConnectorAppContext.Contents = Value.ReplaceType(WebConConnectorAppContextImpl, WebConConnectorAppContextType);

WebConConnectorAppContextImpl = (portalAddress as text, apiVersion as text, databaseId as number, clientId as text, clientSecret as text) =>
let
    body = [
        client_id = clientId,
        grant_type = "client_credentials",
        client_secret = clientSecret
    ],

    Response = Web.Contents(portalAddress, [ 
        Headers = 
            [
                #"Accept" = "application/json", 
                #"Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"
            ], 
        Content = Text.ToBinary(Uri.BuildQueryString(body)), 
        RelativePath = "/api/oauth2/token", 
        ManualStatusHandling = {400, 401, 404, 500, 502}
    ]),
    ResponseJson = Json.Document(Response),
    accessToken = ResponseJson[access_token],
    tokenType = ResponseJson[token_type],
    fullAccessToken = tokenType&" "&accessToken,
    source = OData.Feed(portalAddress&"/api/odata/"&apiVersion&"/db/"&Number.ToText(databaseId), [Authorization = fullAccessToken])
in
    if (Record.HasFields(ResponseJson, {"message"})) then 
             error ResponseJson[message]
    else if (Record.HasFields(ResponseJson, {"error"})) then 
             error ResponseJson[error]
    else 
        source;

WebConConnectorAppContextType = type function (
    portalAddress as (type text meta [
        Documentation.FieldCaption = Extension.LoadString("PortalAddress"),
        Documentation.SampleValues = {"https://portalAddress.pl"}
    ]),
    apiVersion as (type text meta [
        Documentation.FieldCaption = Extension.LoadString("ApiVersion"),
        Documentation.AllowedValues = {"beta"}
    ]),
    databaseId as (type number meta [
        Documentation.FieldCaption = Extension.LoadString("DatabaseId"),
        Documentation.SampleValues = {1}
    ]),
    clientId as (type text meta [
        Documentation.FieldCaption = Extension.LoadString("ClientId"),
        Documentation.SampleValues = {"clientId"}
    ]),
    clientSecret as (type text meta [
        Documentation.FieldCaption = Extension.LoadString("ClientSecret"),
        Documentation.SampleValues = {"clientSecret"}
    ]))
   as table meta [
        Documentation.Name = Extension.LoadString("ConnectorName"),
        Documentation.LongDescription = Extension.LoadString("ConnectorDescription")
    ];

WebConConnectorAppContext = [
    TestConnection = (dataSourcePath) => { "WebConConnectorAppContext.Contents", Json.Document(dataSourcePath)[portalAddress],  Json.Document(dataSourcePath)[apiVersion], Json.Document(dataSourcePath)[databaseId], Json.Document(dataSourcePath)[clientId], Json.Document(dataSourcePath)[clientSecret] },
    Authentication = [
        Implicit = []
    ],
        Label = Extension.LoadString("AuthenticationLabel")
];

WebConConnectorAppContext.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = {Extension.LoadString("ButtonText")},
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = WebConConnectorAppContext.Icons,
    SourceTypeImage = WebConConnectorAppContext.Icons
];

WebConConnectorAppContext.Icons = [
    Icon16 = { Extension.Contents("WebConLogo16.png"), Extension.Contents("WebConLogo20.png"), Extension.Contents("WebConLogo24.png"), Extension.Contents("WebConLogo32.png") },
    Icon32 = { Extension.Contents("WebConLogo32.png"), Extension.Contents("WebConLogo40.png"), Extension.Contents("WebConLogo48.png"), Extension.Contents("WebConLogo64.png") }
];
