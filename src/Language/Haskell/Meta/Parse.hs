
{- |
  Module      :  Language.Haskell.Meta.Parse
  Copyright   :  (c) Matt Morrow 2008
  License     :  BSD3
  Maintainer  :  Matt Morrow <mjm2002@gmail.com>
  Stability   :  experimental
  Portability :  portable (template-haskell)
-}

module Language.Haskell.Meta.Parse where

import Language.Haskell.TH.Syntax
import Language.Haskell.Meta.Syntax.Translate
import qualified Language.Haskell.Exts.Syntax as Hs
import Language.Haskell.Exts.Annotated.Fixity
import Language.Haskell.Exts.Extension
import Language.Haskell.Exts.Parser
import Language.Haskell.Exts.Pretty

-----------------------------------------------------------------------------

-- * template-haskell

parsePat :: String -> Either String Pat
parsePat = either Left (Right . toPat) . parseHsPat

parseExp :: String -> Either String Exp
parseExp = either Left (Right . toExp) . parseHsExp

parseType :: String -> Either String Type
parseType = either Left (Right . toType) . parseHsType

parseDecs :: String -> Either String [Dec]
parseDecs  = either Left (Right . toDecs) . parseHsDecls

-----------------------------------------------------------------------------

myDefaultParseMode :: ParseMode
myDefaultParseMode = ParseMode
  {parseFilename = []
  ,extensions = myDefaultExtensions
  ,ignoreLinePragmas = False
  ,ignoreLanguagePragmas = False
  ,fixities = baseFixities}

myDefaultExtensions :: [Extension]
myDefaultExtensions = [PostfixOperators
                      ,QuasiQuotes
                      ,UnicodeSyntax
                      ,PatternSignatures
                      ,MagicHash
                      ,ForeignFunctionInterface
                      ,TemplateHaskell
                      ,RankNTypes
                      ,MultiParamTypeClasses
                      ,RecursiveDo]

parseResultToEither :: ParseResult a -> Either String a
parseResultToEither (ParseOk a) = Right a
parseResultToEither (ParseFailed loc e)
  = let line = Hs.srcLine loc - 1
    in Left (unlines [show line,show loc,e])

parseHsModule :: String -> Either String Hs.Module
parseHsModule = parseResultToEither . parseModuleWithMode myDefaultParseMode

parseHsDecls :: String -> Either String [Hs.Decl]
parseHsDecls = either Left (Right . moduleDecls)
  . parseResultToEither . parseModuleWithMode myDefaultParseMode


parseHsType :: String -> Either String Hs.Type
parseHsType = parseResultToEither . parseTypeWithMode myDefaultParseMode


parseHsExp :: String -> Either String Hs.Exp
parseHsExp = parseResultToEither . parseExpWithMode myDefaultParseMode

parseHsPat :: String -> Either String Hs.Pat
parseHsPat = parseResultToEither . parsePatWithMode myDefaultParseMode

pprHsModule :: Hs.Module -> String
pprHsModule = prettyPrint


moduleDecls :: Hs.Module -> [Hs.Decl]
moduleDecls (Hs.Module _ _ _ _ _ _ x) = x

-- mkModule :: String -> Hs.Module
-- mkModule s = Hs.Module undefined (Hs.ModuleName s) Nothing [] []

emptySrcLoc :: Hs.SrcLoc
emptySrcLoc = (Hs.SrcLoc [] 0 0)

emptyHsModule :: String -> Hs.Module
emptyHsModule n =
    (Hs.Module
        emptySrcLoc
        (Hs.ModuleName n)
        []
        Nothing
        Nothing
        []
        [])

{-
ghci> :i Module
data Module
  = Module SrcLoc
           ModuleName
           [OptionPragma]
           (Maybe WarningText)
           (Maybe [ExportSpec])
           [ImportDecl]
           [Decl]
        -- Defined in Language.Haskell.Exts.Syntax
instance Show Module -- Defined in Language.Haskell.Exts.Syntax
-}

-----------------------------------------------------------------------------
