I'm using MonadThrow here (from Kmett http://hackage.haskell.org/package/exceptions-0.10.0 lib)
instead of MonadError (from protolude), because MonadThrow laverage extensible exceptions (i.g. throws SomeException subclasses)

## HOW EXTENSIBLE EXCEPTIONS WORK (from https://simonmar.github.io/bib/papers/ext-exceptions.pdf):

When we throw an exception value, it is wrapped in constructors,
one for each parent node successively until the root is reached.
For example, when we throw DivideByZero, the value actually
thrown is
`SomeException (SomeArithException DivideByZero)`

```hs
Example:
λ> fromException (SomeException EmptyGuess) :: Maybe MarkerException
Nothing
λ> fromException (SomeException (CodebreakerException EmptyGuess)) :: Maybe MarkerException
Just EmptyGuess
λ> fromException (SomeException (CodebreakerException EmptyGuess)) :: Maybe CodebreakerException
Just EmptyGuess
-- though it shows `Just EmptyGuess`, it's really `Just (CodebreakerException EmptyGuess)`
λ> fromException (SomeException (CodebreakerException EmptyGuess)) :: Maybe SomeException
Just EmptyGuess
-- though it shows `Just EmptyGuess`, it's really `Just (SomeException (CodebreakerException EmptyGuess))`
```
