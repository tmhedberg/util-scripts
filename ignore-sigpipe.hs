{-
 - Consume data from stdin, echoing it to stdout as it becomes available
 -
 - Ensures that stdin is read completely, even if stdout is closed.
 -
 - This may be used in a pipeline to shield upstream processes from SIGPIPE. For
 - instance, consider the following pipeline:
 -
 -     long-running-task | less
 -
 - Since less reads its stdin lazily, if the user terminates less before
 - scrolling to the bottom of the buffer (thereby forcing all of less's stdin to
 - be consumed), long-running-task will receive SIGPIPE, which may cause it to
 - throw an error noisily.
 -
 - When this situation is expected, and long-running-task's noisy error
 - reporting cannot be easily suppressed, the following pipeline may be more
 - appropriate:
 -
 -     long-running-task | ignore-sigpipe | less
 -
 - ignore-sigpipe will consume all output produced by long-running-task before
 - terminating, even if less terminates sooner than that. Thus,
 - long-running-task will never be signaled to indicate that it is writing to a
 - closed stdout, and so will never make noise to that effect.
 -
 - ignore-sigpipe must be compiled with GHC's threaded RTS in order to have its
 - intended effect:
 -
 -     ghc -O2 -threaded ignore-sigpipe
 -}

import Control.Concurrent
import Control.DeepSeq
import Control.Exception

import qualified Data.ByteString.Lazy as BSL

import GHC.IO.Exception

import System.IO
import System.IO.Error
import System.Posix.Signals

main = do installHandler openEndedPipe Ignore Nothing
          hSetBuffering stdout NoBuffering
          input <- BSL.getContents
          forkIO $ BSL.putStr input `catchIOError` errHandler
          evaluate $ force input

errHandler :: IOError -> IO ()
errHandler IOError {ioe_type = ResourceVanished} = return ()
errHandler e = ioError e
