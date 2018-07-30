{-# LANGUAGE OverloadedStrings #-}

import Data.Monoid (mappend)
import Hakyll
import Text.Pandoc

feedConfig = FeedConfiguration
    { feedTitle       = "Steven's Blog"
    , feedDescription = "This the homepage and blog of Steven Watson."
    , feedAuthorName  = "Steven Watson"
    , feedAuthorEmail = "16228203+steven741@users.noreply.github.com"
    , feedRoot        = "https://steven741.github.io"
    }


config = defaultConfiguration
    { deployCommand = "rsync --checksum -a _site/. ../"
    }


loadPostWriter = do
    template <- readFile "./templates/toc.html"

    return defaultHakyllWriterOptions
        { writerTableOfContents = True
        , writerTOCDepth        = 1
        , writerTemplate        = Just template
        }


postCtx =
    dateField "date" "%B %d, %Y"     `mappend`
    dateField "datetime" "%Y-%m-%d"  `mappend`
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

        match "posts/**" $ do
            route $ setExtension "html"
            compile $ pandocCompilerWith defaultHakyllReaderOptions postWriter
                >>= loadAndApplyTemplate "templates/article.html" postCtx
                >>= loadAndApplyTemplate "templates/default.html" postCtx
                >>= relativizeUrls

        match "index.html" $ do
            route idRoute
            compile $ do
                posts <- recentFirst =<< loadAll "posts/**"
                let indexCtx =
                        listField "posts" postCtx (return posts) `mappend`
                        constField "title" "Steven's Journal"    `mappend`
                        defaultContext

                getResourceBody
                    >>= applyAsTemplate indexCtx
                    >>= loadAndApplyTemplate "templates/default.html" indexCtx
                    >>= relativizeUrls

        create ["rss.xml"] $ do
            route idRoute
            compile $ do
                posts <- fmap (take 10) . recentFirst =<< loadAll "posts/**"

                renderRss feedConfig
                          (defaultContext `mappend` constField "description" "")
                          posts
