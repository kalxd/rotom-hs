-- | rotom启动服务
{-# LANGUAGE RecordWildCards #-}
module Server ( runServer
              , api
              ) where

import Servant

import Rotom.Type
import Rotom.Type.App (appToHandler)
import Rotom.Type.Config (XGAppConfig(..), readConfig)
import Rotom.Auth (XGContextType, authContext)
import Rotom.Api (API, api, apiRoute)
import Rotom.Middleware (appMiddleware)

import Network.Wai.Handler.Warp (run)

buildApp :: XGAppConfig -> Application
buildApp config = serveWithContext api context serverApi
    where serverApi = hoistServerWithContext api (Proxy :: Proxy XGContextType) trans apiRoute
          trans = appToHandler config
          context = authContext config

runServer :: IO ()
runServer = do
    config@AppConfig{..} <- readConfig
    run (fromIntegral appPort) $ appMiddleware $ buildApp config
