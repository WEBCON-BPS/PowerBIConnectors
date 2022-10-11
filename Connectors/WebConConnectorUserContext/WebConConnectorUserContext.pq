section WebConConnectorUserContext;

[DataSource.Kind="WebConConnectorUserContext", Publish="WebConConnectorUserContext.Publish"]
shared WebConConnectorUserContext.Feed = Value.ReplaceType(WebConConnectorUserContextImpl, WebConConnectorUserContextType);

WebConConnectorUserContextImpl = (portalAddress as text, apiVersion as text, databaseId as number, clientId as text, clientSecret as text) =>
    let
        source = OData.Feed(portalAddress&"/api/odata/"&apiVersion&"/db/"&Number.ToText(databaseId))
    in
        source;

WebConConnectorUserContext = [
    TestConnection = (dataSourcePath) => { "WebConConnectorUserContext.Feed", Json.Document(dataSourcePath)[portalAddress], Json.Document(dataSourcePath)[apiVersion], Json.Document(dataSourcePath)[databaseId], Json.Document(dataSourcePath)[clientId], Json.Document(dataSourcePath)[clientSecret] },
    Authentication = [
        OAuth = [
            StartLogin = StartLogin,
            FinishLogin = FinishLogin,
            Refresh = Refresh
            ]
    ],
    Label = Extension.LoadString("AuthenticationLabel")
];

StartLogin = (clientApplication, dataSourcePath, state, display)=>
    let
        authorizeUrl = Json.Document(dataSourcePath)[portalAddress]&"/connect/authorize?" & Uri.BuildQueryString([
            client_id = Json.Document(dataSourcePath)[clientId],  
            redirect_uri = "https://oauth.powerbi.com/views/oauthredirect.html",
            state = state,
            scope = "User.Odata.Read.All",
            response_type = "code",
            login = "login"
        ])
    in
        [
            LoginUri = authorizeUrl,
            CallbackUri = "https://oauth.powerbi.com/views/oauthredirect.html",
            WindowHeight = 720,
            WindowWidth = 1024,
            Context = null
        ];


FinishLogin = (clientApplication, dataSourcePath, context, callbackUri, state) =>
    let
        parts = Uri.Parts(callbackUri)[Query],
        result =  if (Record.HasFields(parts, {"errorGuid"})) then 
                      error Error.Record(parts[errorGuid], parts[message])
                  else if (Record.HasFields(parts, {"error"})) then
                      error Error.Record(parts[error], parts[error])
                  else
                    TokenMethod("authorization_code", "code", dataSourcePath, parts[code])
    in
        result;

TokenMethod = (grantType, tokenField, dataSourcePath, code) =>
    let
        queryString = [
            client_id = Json.Document(dataSourcePath)[clientId],
            grant_type = grantType,
            client_secret = Json.Document(dataSourcePath)[clientSecret],
            redirect_uri = "https://oauth.powerbi.com/views/oauthredirect.html",
            access_type = "offline"
        ],
        queryWithCode = Record.AddField(queryString, tokenField, code),
        tokenResponse = Web.Contents(Json.Document(dataSourcePath)[portalAddress]&"/api/oauth2/token", [
            Content = Text.ToBinary(Uri.BuildQueryString(queryWithCode)),
            Headers = [
                #"Content-type" = "application/x-www-form-urlencoded",
                #"Accept" = "application/json"               
            ],
            ManualStatusHandling = {400, 401, 404, 500, 502}
        ]),

        token = Json.Document(tokenResponse)
    in
        if (Record.HasFields(token, {"access_token"})) then
            token
        else if (Record.HasFields(tokenResponse, {"message"})) then 
            error tokenResponse[message]
        else if (Record.HasFields(tokenResponse, {"error"})) then 
            error tokenResponse[error]
        else 
            error Error.Record("Failed to login");
        


Refresh = (dataSourcePath, refreshToken) => 
    let
        source = TokenMethod("refresh_token", "refresh_token", dataSourcePath, refreshToken)
        in
            source;


WebConConnectorUserContextType = type function (
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

WebConConnectorUserContext.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = {Extension.LoadString("ButtonText")},
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = WebConConnectorUserContext.Icons,
    SourceTypeImage = WebConConnectorUserContext.Icons
];

WebConConnectorUserContext.Icons = [
    Icon16 = { Extension.Contents("WebConLogo16.png"), Extension.Contents("WebConLogo20.png"), Extension.Contents("WebConLogo24.png"), Extension.Contents("WebConLogo32.png") },
    Icon32 = { Extension.Contents("WebConLogo32.png"), Extension.Contents("WebConLogo40.png"), Extension.Contents("WebConLogo48.png"), Extension.Contents("WebConLogo80.png") }
];