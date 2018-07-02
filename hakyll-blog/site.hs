{-# LANGUAGE OverloadedStrings #-}
import Data.Monoid (mappend)
import Hakyll
import Text.Pandoc


config = defaultConfiguration
    { deployCommand = "rsync --checksum -a _site/. ../"
    }


loadPostWriter = do
    template <- readFile "./templates/toc.html"

    return defaultHakyllWriterOptions
        { writerTableOfContents = True
        , writerTOCDepth        = 3
        , writerTemplate        = Just template
        }


postCtx =
    dateField "date" "%B %d, %Y"     `mappend`
    dateField "datetime" "%Y-%m-%d"  `mappend`
    constField "style" "article.css" `mappend`
    defaultContext


main = do
    postWriter <- loadPostWriter

    hakyllWith config $ do
        match "templates/*" $ compile templateBodyCompiler

        match "img/*" $ do
            route   idRoute
            compile copyFileCompiler

        match "css/*" $ do
            route   idRoute
            compile compressCssCompiler

        match "posts/*" $ do
            route $ setExtension "html"
            compile $ pandocCompilerWith defaultHakyllReaderOptions postWriter
                >>= loadAndApplyTemplate "templates/article.html" postCtx
                >>= loadAndApplyTemplate "templates/default.html" postCtx
                >>= relativizeUrls

        match "index.html" $ do
            route idRoute
            compile $ do
                posts <- recentFirst =<< loadAll "posts/*"
                let indexCtx =
                        listField "posts" postCtx (return posts) `mappend`
                        constField "title" "Steven's Journal"    `mappend`
                        constField "style" "style.css"           `mappend`
                        defaultContext

                getResourceBody
                    >>= applyAsTemplate indexCtx
                    >>= loadAndApplyTemplate "templates/default.html" indexCtx
                    >>= relativizeUrls
