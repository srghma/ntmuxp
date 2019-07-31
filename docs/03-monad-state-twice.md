# 1

```hs
data GameState = GameState
  { attemptsUsed :: Int
  , secretIndexesAlreadyShownAsHint :: [Int]
  }

data GameState2 = GameState2 { dummy :: Int }

type Game = Haskeline.InputT (StateT GameState (StateT GameState2 IO))

instance MonadState GameState Game where -- throws Functional dependencies conflict between instance declarations
  state f = undefined

instance MonadState GameState2 Game where
  state f = undefined

foo :: (MonadState GameState m, MonadState GameState2 m) => m ()
foo = do
  gameState <- get
  gameState2 <- get
  return ()
```

# 2

```hs
module Main where

import           Protolude                                                               hiding
    ( FilePath
    , catch
    , try
    , MonadState
    )

import "monads-tf" Control.Monad.State

data GameState = GameState
  { attemptsUsed :: Int
  , secretIndexesAlreadyShownAsHint :: [Int]
  }

data GameState2 = GameState2 { dummy :: Int }

type Game = StateT GameState (StateT GameState2 IO)

instance MonadState Game where -- throws Duplicate instance declarations
  type StateType Game = GameState
  get = undefined
  put a = undefined

instance MonadState Game where
  type StateType Game = GameState
  get = undefined
  put a = undefined

foo :: (MonadState GameState m, MonadState GameState2 m) => m ()
foo = do
  gameState <- get
  gameState2 <- get
  return ()
```

# 3

```
you can do MonadGameState and MonadGameState2

class MonadGameState where
  getGameState = undefined

class MonadGameState2 where
  getGameState2 = undefined

newtype GameStateStateM m a = GameStateStateM (StateT GameState m a)

newtype GameState2StateM m a = GameState2StateM (StateT GameState2 m a)

implement MonadGameState GameStateStateM where
  getGameState = undefined

implement MonadGameState2 GameState2StateM where
  getGameState2 = undefined
```
