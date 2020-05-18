{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}

-- | 分组
module Rotom.Hand.Group ( API
                        , api
                        ) where

import Servant
import Rotom.Type
import Rotom.Type.Group

import qualified Data.Text as T
import Data.Aeson (FromJSON(..))
import GHC.Generics

-- | 分组API
-- type API = "分组" :> (CreateAPI :<|> UpdateAPI)
type API = "分组" :> AllAPI

api :: XGUser -> ServerT API XGApp
-- api user = createAPI user :<|> updateAPI user
api user = allAPI user

type AllAPI = "列表" :> Get '[JSON] [XGGroup]

s_all = [sql| select
              "id", "名字", "用户id", "创建日期"
              from "分组"
              where "用户id" = ?
              |]
-- | 查找所有分组。
allAPI :: XGUser -> XGApp [XGGroup]
allAPI User{..} = query s_all [userId]

{-
--
-- 创建分组
--
newtype XGFormBody = FormBody { ffzuName :: T.Text
                              } deriving (Generic)
instance FromJSON XGFormBody

type CreateAPI = ReqBody '[JSON] XGFormBody
                 :> Post '[JSON] XGFFZU

ccsql = [sql| insert into "ffzu"
              ("mkzi", "yshu_id")
              values (?, ?)
              returning * |]

createAPI :: XGUser -> XGFormBody -> XGApp XGFFZU
createAPI User{..} FormBody{..} = do
    queryOne ccsql (ffzuName, userId) >>= liftMaybe NotFoundFFZU

--
-- 重命名分组，即更新
--
type UpdateAPI = Capture "id" Int :> ReqBody '[JSON] XGFormBody :> Put '[JSON] XGFFZU

uusql = [sql| update "ffzu"
              set "mkzi" = ? where id = ?
              returning * |]

updateAPI :: XGUser -> Int -> XGFormBody -> XGApp XGFFZU
updateAPI _ id FormBody{..} = queryOne uusql (ffzuName, id) >>= liftMaybe NotFoundFFZU
-}
