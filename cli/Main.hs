module Main where

import           Protolude                                                               hiding
    ( FilePath
    , stdout
    , stdin
    )

import Turtle
import qualified System.Directory as Directory
import qualified Filesystem.Path  as Path
import qualified Data.List        as List
import qualified System.IO.Temp   as Temp
import qualified System.IO
import qualified Data.Text        as Text
import qualified Data.String        as String
import qualified System.Posix.Process

import "prettyprinter" Data.Text.Prettyprint.Doc                               ((<+>))
import qualified "prettyprinter" Data.Text.Prettyprint.Doc                               as PP
import qualified "prettyprinter-ansi-terminal" Data.Text.Prettyprint.Doc.Render.Terminal as PP

-- NOTE: shell/proc doesnt mess with output, inshell/inproc - does (https://github.com/Gabriel439/Haskell-Turtle-Library/issues/29#issuecomment-74905298)

main :: IO ()
main = do
  args <- getArgs
  tempDirPath <- Directory.getTemporaryDirectory

  (args' :: [String.String]) <- mapM (
    \arg ->
      if ".tmuxp.nix" `List.isSuffixOf` arg
        then do
          isExists <- Directory.doesFileExist (toS arg)

          unless isExists (do
            putStr $ "File " <> arg <> " doesn't exist, can't convert it to json"
            exitFailure)

          let originalPath = fromText (toS arg)

          let baseName :: String.String = toS . encodeString $ Path.basename originalPath

          -- putText $ Text.unwords ["nix-build", "--no-out-link", "--verbose", "-E", "'with import <nixpkgs> {}; writeTextFile { name = \""<> toS baseName <> ".json\"; text = builtins.toJSON (import "<> toS arg <>"); }'"]

          -- fixes https://stackoverflow.com/questions/57302668/how-to-nix-instantiate-expression-to-json-string-and-build-realize-all-its-depe
          (exitCode, outputFile :: Text) <- procStrict "nix-build" ["--no-out-link", "--quiet", "-E", "with import <nixpkgs> {}; writeTextFile { name = \""<> toS baseName <> ".json\"; text = builtins.toJSON (import "<> toS arg <>"); }"] ""

          let outputFile' = Text.strip outputFile

          case exitCode of
            ExitFailure int -> exitWith (ExitFailure int)
            ExitSuccess -> do
              isExists <- Directory.doesFileExist (toS outputFile')

              unless isExists (do
                putStr $ "File " <> outputFile' <> " doesn't exist, whaaat"
                exitFailure)

              PP.putDoc
                (   green "[ntmuxp]"
                <+> blue (PP.pretty arg)
                <+> "was build to"
                <+> blue (PP.pretty outputFile')
                <+> PP.hardline
                )

              return (toS outputFile')
        else
          return arg
        ) args

  -- exec is a functionality of an operating system that runs an executable file in the context of an already existing process, replacing the previous executable
  -- https://en.wikipedia.org/wiki/Exec_(system_call)
  System.Posix.Process.executeFile "tmuxp" True args' Nothing
    where
      blue = PP.annotate $ PP.color PP.Blue
      green = PP.annotate $ PP.color PP.Green
