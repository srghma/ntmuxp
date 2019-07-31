module Main where

import           Protolude                                                               hiding
    ( FilePath
    , stdout
    )

import Turtle
import qualified System.Directory                                                        as Directory
import qualified Filesystem.Path                                                        as Path
import qualified Data.List                                                        as List
import qualified System.IO.Temp                                                        as Temp
import qualified Data.Text as Text

main :: IO ()
main = sh $ do
  args <- fmap Text.pack <$> liftIO getArgs
  tempDirPath <- decodeString <$> liftIO Directory.getTemporaryDirectory

  (args' :: [Text]) <- mapM (
    \arg ->
      if ".tmuxp.nix" `Text.isSuffixOf` arg
        then do
          isExists <- liftIO $ Directory.doesFileExist (toS arg)

          unless isExists (do
            liftIO . putText $ "File " <> arg <> " doesn't exist, can't convert it to json"
            liftIO exitFailure)

          let originalPath = fromText arg

          let baseName :: Text = toS . encodeString $ Path.basename originalPath

          tempFilePath <- mktempfile tempDirPath (baseName <> ".json")

          -- nix-instantiate --strict --eval $i --json | json_reformat > $tempFilePath
          inproc "nix-instantiate" ["--strict", "--json", "--eval", toS arg] "" & inproc "json_reformat" [] & output tempFilePath

          return (toS . encodeString $ tempFilePath)
        else
          return arg
        ) args

  inproc "tmuxp" args' "" & stdout
