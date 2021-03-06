module Color.Accessibility exposing (contrastRatio, luminance, maximumContrast)

{-|


# Accessibility

Functions to measure and maximize accessibility.

@docs contrastRatio, luminance, maximumContrast

-}

import Color exposing (..)


{-| Get the contrast ratio of two colors represented as a Float.

Formula based on:
<https://www.w3.org/TR/WCAG20/#contrast-ratiodef>

    contrastRatio Color.black Color.white -- 21.0

    contrastRatio Color.blue Color.blue -- 1.0

-}
contrastRatio : Color -> Color -> Float
contrastRatio c1 c2 =
    let
        a =
            luminance c1 + 0.05

        b =
            luminance c2 + 0.05
    in
    if a > b then
        a / b

    else
        b / a


{-| Get the relative luminance of a color represented as a Float.

Formula based on:
<https://www.w3.org/TR/WCAG20/#relativeluminancedef>

    luminance Color.black -- 0.0

    luminance Color.white -- 1.0

-}
luminance : Color -> Float
luminance cl =
    let
        ( r, g, b ) =
            cl |> toRgba |> (\a -> ( f a.red, f a.green, f a.blue ))

        f intensity =
            if intensity <= 0.03928 then
                intensity / 12.92

            else
                ((intensity + 0.055) / 1.055) ^ 2.4
    in
    0.2126 * r + 0.7152 * g + 0.0722 * b


{-| Returns the color with the highest contrast to the base color.

    maximumContrast Color.darkBlue Color.white [ Color.purple, Color.black ] -- Color.white

-}
maximumContrast : Color -> Color -> List Color -> Color
maximumContrast base first rest =
    maximumContrastMemo (contrastRatio base) (contrastRatio base first) first rest


maximumContrastMemo : (Color -> Float) -> Float -> Color -> List Color -> Color
maximumContrastMemo ratioFn bestRatio bestColor colors =
    case colors of
        [] ->
            bestColor

        color :: rest ->
            let
                newRatio =
                    ratioFn color
            in
            if bestRatio >= newRatio then
                maximumContrastMemo ratioFn bestRatio bestColor rest

            else
                maximumContrastMemo ratioFn newRatio color rest
