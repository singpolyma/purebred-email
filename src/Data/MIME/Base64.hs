{-# LANGUAGE OverloadedStrings #-}

{- |

Implementation of Base64 Content-Transfer-Encoding.

<https://tools.ietf.org/html/rfc2045#section-6.8>

-}
module Data.MIME.Base64
  (
    contentTransferEncodeBase64
  , contentTransferEncodingBase64
  ) where

import Control.Lens (prism')
import qualified Data.ByteString as B
import qualified Data.ByteString.Base64 as B64
import Data.Word (Word8)

import Data.MIME.Types (ContentTransferEncoding)



isBase64Char :: Word8 -> Bool
isBase64Char c =
  (c >= 0x41 && c <= 0x5a)  -- A-Z
  || (c >= 0x61 && c <= 0x7a) -- a-z
  || (c >= 0x30 && c <= 0x39) -- 0-9
  || c == 43 -- +
  || c == 47 -- /
  || c == 61 -- =

{-

Notes about encoding requirements:

- The encoded output stream must be represented in lines of no more
  than 76 characters each.

-}
contentTransferEncodeBase64 :: B.ByteString -> B.ByteString
contentTransferEncodeBase64 = B64.joinWith "\r\n" 76 . B64.encode

{-

Notes about decoding requirements:

- All line breaks or other characters not found in Table 1 must be
  ignored by decoding software.

- In base64 data, characters other than those in Table 1, line breaks,
  and other white space probably indicate a transmission error, about
  which a warning message or even a message rejection might be
  appropriate under some circumstances.

-}
contentTransferDecodeBase64 :: B.ByteString -> Either String B.ByteString
contentTransferDecodeBase64 = B64.decode . B.filter isBase64Char

contentTransferEncodingBase64 :: ContentTransferEncoding
contentTransferEncodingBase64 = prism'
  contentTransferEncodeBase64
  (either (const Nothing) Just . contentTransferDecodeBase64)
