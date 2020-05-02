{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wno-missing-export-lists #-}

module Handler.IframeDonate where

import Import

--
-- TODO
--

getIframeDonateR :: Handler Html
getIframeDonateR = do
  (formWidget, formEnctype) <-
    generateFormPost $ renderBootstrap3 BootstrapInlineForm maForm
  noLayout $ do
    setTitleI MsgIframeDonateRTitle
    $(widgetFile "iframe-donate")

maForm :: AForm Handler MoneyAmount
maForm =
  areq (selectFieldList ms) (bfs MsgNothing) (Just defMoneyAmount)
    <* bootstrapSubmit (BootstrapSubmit MsgIframeDonateRTitle "btn-default" [])
  where
    ms = [("0.01 mBTC" :: Text, MoneyAmount 1000), ("0.1 mBTC", MoneyAmount 10000)]

defMoneyAmount :: MoneyAmount
defMoneyAmount = MoneyAmount 1000
