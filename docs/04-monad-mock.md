Mock.makeAction "GetInputLineAction" [Mock.ts| MonadGetInputLine |]

-- same as

data GetInputLineAction r where
  GetInputLine :: Text -> GetInputLineAction (Maybe Text)
deriving instance Eq (GetInputLineAction r)
deriving instance Show (GetInputLineAction r)

instance Mock.Action GetInputLineAction where
  eqAction (GetInputLine a) (GetInputLine b)
    = if a == b then Just Refl else Nothing
  eqAction _ _ = Nothing

instance Monad m => MonadGetInputLine (Mock.MockT GetInputLineAction m) where
  getInputLine a = Mock.mockAction "getInputLine" (GetInputLine a)
